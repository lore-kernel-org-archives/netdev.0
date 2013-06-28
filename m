From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] 8021q: fix vlan 0 inconsistencies
Date: Fri, 28 Jun 2013 10:20:32 +0200
Message-ID: <51CD4750.6060307@redhat.com>
References: <1371731078-12531-1-git-send-email-nikolay@redhat.com> <51C30CE2.5030803@redhat.com> <20130627.222749.1795566196568945291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984Ab3F1IUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 04:20:39 -0400
In-Reply-To: <20130627.222749.1795566196568945291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2013 07:27 AM, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> Date: Thu, 20 Jun 2013 16:08:34 +0200
> 
>> On 06/20/2013 02:24 PM, nikolay@redhat.com wrote:
>>> From: Nikolay Aleksandrov <nikolay@redhat.com>
>>>
>>> The first part of the patch stops the addition of VLAN 0 to bonding
>>> devices because we use an internal vlan_list to keep the added vlans and
>>> after that when checking if we're using vlans on the bond
>>> (bond_vlan_used) it evaluates to true always, which leads to different
>>> problems. Since this is intended for HW vlan filters, it's not needed
>>> for the bonding, and for its slaves it will still get added upon
>>> NETDEV_UP.
>>> The second part that does unconditional vlan_vid_del is needed because
>>> when we add vlan 0 to a bonding device, it can never be removed
>>> completely (it will always stay in the local vlan_list). Since there's
>>> refcounting, I don't think this will change the behaviour because if a
>>> real device is UP then vlan 0 will have at least refcnt == 1 so
>>> ndo_vlan_rx_kill_vid won't get called until the device is down, but in
>>> the bonding case we need it while the device is up so we can cleanup
>>> properly after vlan 0 removal.
>>> As an addition I'd like to say that I tried many different fixes of this
>>> issue from inside the bonding, but they all have shortcomings and fixing
>>> the root cause would be much better. For example I can't filter out vlan
>>> 0 in the bond's ndo_vlan_rx_add_vid because bond_has_this_ip() (and others)
>>> rely on being able to check the vlan devices on top through the local
>>> vlan_list. Also there's no way to differentiate between addition of vlan 0
>>> from vlan_device_event and from register_vlan_dev.
>>>
>>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> In fact I think there's a deeper issue with vlan 0 because if you add it to any
>> device its refcount will only be incremented (unconditional vlan_vid_add in
>> register_vlan_dev) and never decremented. And this issue is also fixed by this
>> patch.
> 
> I don't think I can apply this patch, it seems to revert very much intentional
> behavior.
> 
> If you have the 8021q module available, and you bring a device up, it gets
> VLAN 0 by default, and if necessary programmed into the HW filters of the
> device.
> 
> This VLAN 0 entry is not treated like a real VLAN, it is just there to be
> decapsulated for the sake of 802.1p Priority Code Points (QoS).
> 
> If the user explicitly configures other VLAN entries, then removes them all,
> that conditional check on vlan_id in the delete path retains this default
> VLAN 0 configuration and is very much intended to behave that way.
> 
> Your patch breaks this, so I cannot apply it.
> 
> If bonding is so broken that it cannot cope with this default 802.1p behavior,
> that is really bonding's problem.  It seemingly needs logic to handle 802.1p,
> and that default VID 0, properly.
> 
Hi Dave,
Thank you for the review, but I think I didn't explain myself well :-)
I know about this behavior and was trying to preserve it, this patch will
not destroy that. The reason is that now vlan_vid_add/del are used and in
the case of refcount > 0 in vlan_vid_del the vlan doesn't get deleted from
the HW filters. So when a device is opened VLAN 0 gets added
unconditionally so refcnt = 1, but if I add VLAN 0 (e.g. through vconfig)
additionally its refcnt will get = 2, but since in unregister_vlan_dev
vlan_vid_del is not called for VLAN 0 its refcnt will stay at 2 (if it was
called the only thing that would happen is its refcnt going down without
being removed from the HW filter of the card so the behavior you speak of
is preserved).
Now an example with prints added to vlan_vid_add and vlan_vid_del:
ifconfig eth1 up
Jun 28 10:04:00 localhost kernel: [   90.856548] vlan_vid_add: VID 0 REF 1 CR 0
-----
vconfig add eth1 0
Jun 28 10:04:21 localhost kernel: [  112.033976] vlan_vid_add: VID 0 REF 2 CR 0
-----
vconfig rem eth1.0
(no message, since vlan_vid_del doesn't get called - vid 0 refcnt still = 2)
-----
ifconfig eth1 down
Jun 28 10:04:30 localhost kernel: [  120.792305] vlan_vid_del: VID 0 REF 1
^ - this is the only place vlan_vid_del is called for vlan 0

Now if I were to add and delete vlan 0 once again, its refcnt will only go
up, eg:
series of vconfig add eth1 0, vconfig rem eth1.0
Jun 28 10:15:40 localhost kernel: [  790.349967] vlan_vid_add: VID 0 REF 3 CR 0
Jun 28 10:15:42 localhost kernel: [  792.450245] vlan_vid_add: VID 0 REF 4 CR 0


Nik
