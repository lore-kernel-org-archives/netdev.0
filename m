From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] 8021q: fix vlan 0 inconsistencies
Date: Thu, 20 Jun 2013 16:08:34 +0200
Message-ID: <51C30CE2.5030803@redhat.com>
References: <1371731078-12531-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965093Ab3FTOLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 10:11:25 -0400
In-Reply-To: <1371731078-12531-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2013 02:24 PM, nikolay@redhat.com wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> The first part of the patch stops the addition of VLAN 0 to bonding
> devices because we use an internal vlan_list to keep the added vlans and
> after that when checking if we're using vlans on the bond
> (bond_vlan_used) it evaluates to true always, which leads to different
> problems. Since this is intended for HW vlan filters, it's not needed
> for the bonding, and for its slaves it will still get added upon
> NETDEV_UP.
> The second part that does unconditional vlan_vid_del is needed because
> when we add vlan 0 to a bonding device, it can never be removed
> completely (it will always stay in the local vlan_list). Since there's
> refcounting, I don't think this will change the behaviour because if a
> real device is UP then vlan 0 will have at least refcnt == 1 so
> ndo_vlan_rx_kill_vid won't get called until the device is down, but in
> the bonding case we need it while the device is up so we can cleanup
> properly after vlan 0 removal.
> As an addition I'd like to say that I tried many different fixes of this
> issue from inside the bonding, but they all have shortcomings and fixing
> the root cause would be much better. For example I can't filter out vlan
> 0 in the bond's ndo_vlan_rx_add_vid because bond_has_this_ip() (and others)
> rely on being able to check the vlan devices on top through the local
> vlan_list. Also there's no way to differentiate between addition of vlan 0
> from vlan_device_event and from register_vlan_dev.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
In fact I think there's a deeper issue with vlan 0 because if you add it to any
device its refcount will only be incremented (unconditional vlan_vid_add in
register_vlan_dev) and never decremented. And this issue is also fixed by this
patch.

Nik
