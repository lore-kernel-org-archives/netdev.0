From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Receive issues with bonding and vlans
Date: Mon, 12 Apr 2010 16:10:51 -0700
Message-ID: <29849.1271113851@death.nxdomain.ibm.com>
References: <20100412221645.8068.71073.stgit@localhost6.localdomain6>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	bonding-devel@lists.sourceforge.net
To: Chris Leech <christopher.leech@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:55945 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649Ab0DLXK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 19:10:56 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3CMx7m6005819
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 18:59:07 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3CNAtbC1339642
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 19:10:55 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3CNArp3004772
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 20:10:55 -0300
In-reply-to: <20100412221645.8068.71073.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Leech <christopher.leech@intel.com> wrote:

>Quick summary: VLANs and bonding are interacting in strange ways in the
>receive path, VLAN devices do not act the same as real Ethernet devices,
>hardware accelerated VLANs do not act the same as software tagged VLANs,
>and I think frames are incorrectly being passed up to protocols from
>inactive bonding links.
>
>I've been looking at high availability configurations for converged LAN
>+ SAN networking, trying to see what running FCoE and IP traffic looked
>like with bonding and dm_multipath.  The goal is to allow sysadmins to
>use the tools they are already using with separate LAN and SAN adapters,
>now on a single converged adapter.
>
>The setup I'm trying to use looks like this; with IP traffic running on
>bond0, storage VLANs created on eth0 and eth1, and FCoE running on the
>VLANs.  Both switches provide Fiber Channel Forwarder (FCF) services,
>and connect to the same LAN and SAN.
>
>	 .-----------------------------------------.
>	 |             .--------------.            |
>	 |             | dm_multipath |            |
>	 |             '--------------'            |
>	 |                     ^                   |
>	 | .----------.        |      .----------. |
>	 | | fc_host0 |--------'------| fc_host1 | |
>	 | '----------'               '----------' |
>	 |       ^                          ^      |
>	 |       |                          |      |
>	 | .----------.   .-------.   .----------. |
>	 | | eth0.101 |   | bond0 |   | eth1.101 | |
>	 | '----------'   '-------'   '----------' |
>	 |       ^            ^             ^      |
>	 |       | .------.   |    .------. |      |
>	 |       '-| eth0 |---'----| eth1 |-'      |
>	 |         '------'        '------'        |
>	 '-------------|---------------|-----------'
>	               |               |
>	               v               v
>	         .----------.    .----------.
>	         | switch A |----| switch B |
>	         '----------'    '----------'
>	             |  |            |  |
>	          .--'--'------------'--'-.
>	          |                       |
>	          v                       v
>	     .-,(  ),-.               .-,(  ),-.    
>	  .-(          )-.         .-(          )-. 
>	 (     FC SAN     )       (     IP LAN     )
>	  '-(          ).-'        '-(          ).-'
>	      '-.( ).-'                '-.( ).-'    
>
>bond0 is in active-backup mode, but FCoE is actively running on both
>links providing two different paths into the SAN.  This configuration
>matches a typical HA setup with separate Ethernet + FC adapters.  In
>this case I'm interested in software convergence where all traffic
>passes through the standard network transmit and receive paths.
>
>The VLANs aren't strictly required by FCoE, but it is the recommended
>best practice by switch vendors.  The FCF switches map FC VSANs to
>VLANs.
>
>Ever since this series of changes to net/core/dev.c
>
>  Author: Joe Eykholt <jre@nuovasystems.com>
>  Date:   Wed Jul 2 18:22:02 2008 -0700
>  net/core: Uninline skb_bond().
>  net/core: Allow certain receives on inactive slave.
>  net/core: Allow receive on active slaves.
>
>it has been possible to receive directly on both active and inactive
>slave links if the packet_type specifies the slave device.  This
>combined with the PACKET_ORIGDEV socket option allowed for FCoE to run
>on the slave devices (DCB link configuration uses a userspace LLDP
>agent, and FCoE includes a VLAN discovery protocol that is implemented
>in userspace as well).

	Is the FCoE supposed to run over the inactive bonding slave?  Or
am I misunderstanding what you're saying?  I had thought the LLDP, et
al, special case in bonding was to permit, essentially, path discovery,
not necessarily active use of the inactive slave.

	Not that this is necessarily bad; the "drop stuff on inactive
slaves" is really there for duplicate suppression, but it also can
uncover network topology issues, e.g., network layouts that won't work
if the devices fail, but appear to work during testing because the
"inactive" slave still receives traffic (it hasn't really failed).

>The problem is that it doesn't work for hardware accelerated VLAN
>devices, because the VLAN receive paths have their own
>skb_bond_should_drop calls that were not updated.
>
>From what I can tell, VLAN receives always end up going through
>netif_receive_skb anyway, so skb_bond_should_drop gets called twice if
>the frame isn't dropped the first time.  I think the bonding checks in
>__vlan_hwaccel_rx and vlan_gro_common should just be removed.

	I'm not so sure.  The checks in __vlan_hwaccel_rx are done with
the original receiving device in skb->dev; by the time the packet gets
to netif_receive_skb, the original slave the packet was received on has
been lost (and replaced with the VLAN device).  Various things are
interested in that, in particular the "arp_validate" and the "inactive
slave drop" logic for bonding depend on knowing the real device the
packet arrived on.

	I note that the vlan accel logic doesn't change skb_iif to the
VLAN device; it remains as the original device.  I suppose one
alternative would be to convert the bonding drop, et al, logic to use
skb_iif instead of skb->dev; if that works, then I think the VLAN core
would not need to call skb_bond_should_drop, which in turn would be a
bit more complicated as it would have to look up the dev from the
skb_iif.  There's already some code in bonding that takes advantage of
this property of the VLANs, so maybe this is the way to go.

>@@ -11,9 +11,6 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
> 	if (netpoll_rx(skb))
> 		return NET_RX_DROP;
>
>-	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>-		goto drop;
>-
> 	skb->skb_iif = skb->dev->ifindex;
> 	__vlan_hwaccel_put_tag(skb, vlan_tci);
> 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>@@ -83,9 +80,6 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
> {
> 	struct sk_buff *p;
>
>-	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>-		goto drop;
>-
> 	skb->skb_iif = skb->dev->ifindex;
> 	__vlan_hwaccel_put_tag(skb, vlan_tci);
> 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>
>That fixes my setup ... but thinking about it raised some more
>questions.  The VLAN discovery tool I wrote shouldn't have worked, I
>didn't bother to bind a packet socket to each interface I wanted to use.
>So a single unbound packet socket is successfully passing traffic on
>both active and inactive slave interfaces, which from my understanding
>shouldn't work.  It's easier for me this way, but it still seems wrong.

	There is no logic to block transmission on bonding slave
devices; anything is free to bind to the slave and send whatever it
wants.

	The reception logic (to drop most traffic on the inactive slave
in an active-backup bond) was originally put in place to prevent
duplicate packets from being received for broadcasts and for unicasts
when the switch floods to all ports (which can happen during the
interval that a switch is still learning the MAC address).

>I think the problem was introduced with these changes.
>
>  Author: Andy Gospodarek <andy@greyhouse.net>
>  Date:   Wed Jan 6 12:56:37 2010 +0000
>  fix bonding: allow arp_ip_targets on separate vlans to use arp validation
>  Date:   Mon Dec 14 10:48:58 2009 +0000
>  bonding: allow arp_ip_targets on separate vlans to use arp validation
>
>The use of null_or_bond in netif_receive_skb looks suspicious to me.  In
>the presence of both bonding and VLANs it probably does what was
>intended.  Without VLANs however, it is always set to NULL which matches
>unbound packet_types.  So unbound packet_types will process all frames
>received on an inactive slave link, ignoring the result of
>skb_bond_should_drop.
>
>I haven't quite figured out what I think the correct change for
>null_or_bond is.  I suspect it involves not using NULL at all.  I can
>see how it addresses the arp_ip_target on a VLAN issue, but this is also
>changing the receive matching rules for other traffic in unexpected
>ways.

	I'll hazard a guess that something like this might do it:

diff --git a/net/core/dev.c b/net/core/dev.c
index b98ddc6..cc665bb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2735,7 +2735,7 @@ ncls:
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type && (ptype->dev == null_or_orig ||
 		     ptype->dev == skb->dev || ptype->dev == orig_dev ||
-		     ptype->dev == null_or_bond)) {
+		     (null_or_bond && (ptype->dev == null_or_bond))) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;


	I haven't tested this, but the theory is to only test against
null_or_bond if null_or_bond isn't NULL, which is only the case for VLAN
traffic over bonding.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
