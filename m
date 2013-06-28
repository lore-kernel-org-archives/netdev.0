From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8021q: fix vlan 0 inconsistencies
Date: Thu, 27 Jun 2013 22:27:49 -0700 (PDT)
Message-ID: <20130627.222749.1795566196568945291.davem@davemloft.net>
References: <1371731078-12531-1-git-send-email-nikolay@redhat.com>
	<51C30CE2.5030803@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3F1F1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 01:27:51 -0400
In-Reply-To: <51C30CE2.5030803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 20 Jun 2013 16:08:34 +0200

> On 06/20/2013 02:24 PM, nikolay@redhat.com wrote:
>> From: Nikolay Aleksandrov <nikolay@redhat.com>
>> 
>> The first part of the patch stops the addition of VLAN 0 to bonding
>> devices because we use an internal vlan_list to keep the added vlans and
>> after that when checking if we're using vlans on the bond
>> (bond_vlan_used) it evaluates to true always, which leads to different
>> problems. Since this is intended for HW vlan filters, it's not needed
>> for the bonding, and for its slaves it will still get added upon
>> NETDEV_UP.
>> The second part that does unconditional vlan_vid_del is needed because
>> when we add vlan 0 to a bonding device, it can never be removed
>> completely (it will always stay in the local vlan_list). Since there's
>> refcounting, I don't think this will change the behaviour because if a
>> real device is UP then vlan 0 will have at least refcnt == 1 so
>> ndo_vlan_rx_kill_vid won't get called until the device is down, but in
>> the bonding case we need it while the device is up so we can cleanup
>> properly after vlan 0 removal.
>> As an addition I'd like to say that I tried many different fixes of this
>> issue from inside the bonding, but they all have shortcomings and fixing
>> the root cause would be much better. For example I can't filter out vlan
>> 0 in the bond's ndo_vlan_rx_add_vid because bond_has_this_ip() (and others)
>> rely on being able to check the vlan devices on top through the local
>> vlan_list. Also there's no way to differentiate between addition of vlan 0
>> from vlan_device_event and from register_vlan_dev.
>> 
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> In fact I think there's a deeper issue with vlan 0 because if you add it to any
> device its refcount will only be incremented (unconditional vlan_vid_add in
> register_vlan_dev) and never decremented. And this issue is also fixed by this
> patch.

I don't think I can apply this patch, it seems to revert very much intentional
behavior.

If you have the 8021q module available, and you bring a device up, it gets
VLAN 0 by default, and if necessary programmed into the HW filters of the
device.

This VLAN 0 entry is not treated like a real VLAN, it is just there to be
decapsulated for the sake of 802.1p Priority Code Points (QoS).

If the user explicitly configures other VLAN entries, then removes them all,
that conditional check on vlan_id in the delete path retains this default
VLAN 0 configuration and is very much intended to behave that way.

Your patch breaks this, so I cannot apply it.

If bonding is so broken that it cannot cope with this default 802.1p behavior,
that is really bonding's problem.  It seemingly needs logic to handle 802.1p,
and that default VID 0, properly.
