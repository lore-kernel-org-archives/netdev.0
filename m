From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: kernel panic receiving flooded VXLAN traffic with OVS
Date: Wed, 03 Dec 2014 17:45:47 -0800
Message-ID: <8549.1417657547@famine>
References: <19014.1415325508@famine>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org, discuss@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54901 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbaLDBpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 20:45:52 -0500
In-reply-to: <19014.1415325508@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jay Vosburgh <jay.vosburgh@canonical.com> wrote:

>	I am able to reproduce a kernel panic on an system using
>openvswitch when receiving VXLAN traffic under a very specific set of
>circumstances.  This occurs with a recent net-next as well as an Ubuntu
>3.13 kernel.  I'm not sure if the error lies in OVS, GRO, or elsewhere.
>
>	In summary, when the system receives multiple VXLAN encapsulated
>TCP segments for a different system (not intended for local reception)
>that are from the middle of an active connection (received due to a switch
>flood), and are tagged to a VLAN not configured on the local host, then
>the system panics in skb_segment when OVS calls __skb_gso_segment on the
>GRO skb prior to performing an upcall to user space.
>
>	The panic occurs in skbuff.c:skb_segment(), at the BUG_ON around
>line 3036:
>
>struct sk_buff *skb_segment(struct sk_buff *head_skb,
>			    netdev_features_t features)
>{
>[...]
>		skb_shinfo(nskb)->tx_flags = skb_shinfo(head_skb)->tx_flags &
>			SKBTX_SHARED_FRAG;
>
>		while (pos < offset + len) {
>			if (i >= nfrags) {
>				BUG_ON(skb_headlen(list_skb));
>
>				i = 0;
>
>
>	The BUG_ON triggers because the skbs that have been GRO
>accumulated are partially or entirely linear, depending upon the receiving
>network device (sky2 is partial, enic is entire).  The receive buffers end
>up being linear evidently because the mtu is set to 9000, and
>__netdev_alloc_skb calls __alloc_skb (and thus kmalloc) instead of
>__netdev_alloc_frag followed by build_skb.
>
>	The foreign-VLAN VXLAN TCP segments are not processed as normal
>VXLAN traffic, as there is no listener on the VLAN in question, so once
>GRO processes them, they are sent directly to ovs_vport_receive.  The
>panic stack appears as follows:

	I've worked out some more details on this with regards to the
cause.

	There seems to be a mismatch between GRO and the packet receive
processing.  GRO only looks at the receiving port number in order to
trigger VXLAN GRO accumulation (which will in turn perform TCP
accumulation on the encapsulated segment).  For the panicking case, the
packet receive processing doesn't deliver the GRO skb to VXLAN because
there is no VXLAN listener on the foreign VLAN.

	The GRO skb is not processed through iptunnel_pull_header by
vxlan_udp_encap_recv, so the GRO skb is left with the skb header
pointing to the UDP header, not the inner TCP header.  Note that second
and later skbs within the GRO skb have their headers pointing to the
inner TCP header.  

	Then, when ovs_dp_upcall later ends up in inet_gso_segment, it
passes the GRO skb to udp4_ufo_fragment, not tcp_gso_segment.

	GRO and the skb_segment call from ovs_dp_upcall appear to work
fine on TCP-in-VXLAN segments that do pass through the VXLAN receive
processing.

	I'm not sure how best to resolve this; adding a check to the GRO
processing that an skb destined for the VXLAN port would actually be
received by VXLAN sounds like a possible solution, but that doesn't seem
to be simple to implement (because the skb->dev at the time GRO runs may
not match what it becomes later if the VXLAN runs on a VLAN).

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
