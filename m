From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a separate vlan from bond device
Date: Tue, 01 Dec 2009 13:28:13 -0800
Message-ID: <21331.1259702893@death.nxdomain.ibm.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com> <6611.1259632635@death.nxdomain.ibm.com> <20091201144410.GI1639@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:37971 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbZLAV2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 16:28:24 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nB1LRGW2017042
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2009 14:27:16 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id nB1LSPgR081014
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2009 14:28:25 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB1FJOeq015074
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2009 08:19:24 -0700
In-reply-to: <20091201144410.GI1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:
[...]
>I am using arp_validate, actually.  I forgot that the arp_validate
>option doesn't show up in the output of /proc/net/bonding/bondX and I
>intended to have that in the subject, but somehow dropped it.

	Ok, I was doing it wrong earlier; it works with arp_validate.
I'm seeing one problem with tcpdump, though, which I'll get to in a
minute.

	Could you update the summary / changelog message to mention that
this patch fixes the specific case of arp_validate + arp_ip_target on
VLAN?

	Second, in regards to this:

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2439,8 +2439,8 @@ int netif_receive_skb(struct sk_buff *skb)
 		skb->skb_iif = skb->dev->ifindex;

 	null_or_orig = NULL;
-	orig_dev = skb->dev;
-	if (orig_dev->master) {
+	orig_dev = __dev_get_by_index(dev_net(skb->dev),skb->skb_iif);
+	if (orig_dev->master && !(skb->dev->priv_flags & IFF_802_1Q_VLAN)) {
 		if (skb_bond_should_drop(skb))
 			null_or_orig = orig_dev; /* deliver only exact match */
 		else

	Would it be useful to add a comment to the effect that VLAN
packets are run through skb_bond_should_drop at the VLAN layer?

	Lastly, in regards to this:

@@ -2492,7 +2492,7 @@ ncls:
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type &&
 		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
-		     ptype->dev == orig_dev)) {
+		     ptype->dev == orig_dev || ptype->dev == orig_dev->master)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;

	This is presumably here because orig_dev will now be the actual
slave the packet arrived on, but we want to additionally deliver to the
master, correct?

	Lastly, tcpdump.

	This patch appears to affect what traffic tcpdump of a slave or
the bonding master itself will capture.  Previously, tcpdump of the
active slave would see only the transmitted packets sent over the bond,
and tcpdump of the inactive slave would see incoming Ethernet-layer
multicast or broadcasts sent to its switch port.  Tcpdump on the master
would see all sent and non-VLAN received traffic, and tcpdump of the
VLAN interface over the master would see just the VLAN traffic.

	After this change, tcpdump of the active slave or of the bonding
master (bond0) sees both sent and received traffic for the VLAN, but
nothing for the non-VLAN traffic other than incoming broadcast /
multicasts.  This holds true whether or not a VLAN is configured.

	I added a "ptype->dev == orig_dev->master" test to the ptype_all
receive block in netif_receive_skb, but it didn't help.  At the moment,
I'm not exactly sure why tcpdump breaks.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
