From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 v3] bonding: allow arp_ip_targets on separate vlans to use arp validation
Date: Thu, 10 Dec 2009 21:17:12 -0800
Message-ID: <32269.1260508632@death.nxdomain.ibm.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com> <6611.1259632635@death.nxdomain.ibm.com> <20091201144410.GI1639@gospo.rdu.redhat.com> <21331.1259702893@death.nxdomain.ibm.com> <20091202212449.GL1639@gospo.rdu.redhat.com> <20091207181349.GN1639@gospo.rdu.redhat.com> <4B1D4879.3040809@gmail.com> <20091209220131.GO1639@gospo.rdu.redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:33741 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbZLKFRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 00:17:23 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBB5F3D8004710
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 22:15:03 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBB5HP3I165720
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 22:17:25 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBB5JEZs010470
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 22:19:15 -0700
In-reply-to: <20091209220131.GO1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>[...]  Here is the updated patch:
>
>[PATCH net-next-2.6 v3] bonding: allow arp_ip_targets on separate vlans to use arp validation
>
>This allows a bond device to specify an arp_ip_target as a host that is
>not on the same vlan as the base bond device and still use arp
>validation.  A configuration like this, now works:
[...]

	I'm testing with one modification to your patch (the change from
your patch is below).  The gist of this change is to use "null_or_orig"
instead of adding a new variable "null_or_bond."  I believe this is
safe, as null_or_orig should currently only be set for non-VLAN traffic
(VLAN traffic won't pass the "orig_dev->master" test; the VLAN code
itself does the skb_bond_should_drop stuff), and the null_or_bond is/was
only used for VLAN traffic.

	This patch has a debug printk in it right now for testing until
I'm sure I'm not confused.

	Thoughts?

	-J

diff --git a/net/core/dev.c b/net/core/dev.c
index 0c96321..ac47be9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2422,7 +2422,6 @@ int netif_receive_skb(struct sk_buff *skb)
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
 	struct net_device *null_or_orig;
-	struct net_device *null_or_bond;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -2494,17 +2493,18 @@ ncls:
 	 * device that may have registered for a specific ptype.  The
 	 * handler will have to adjust skb->dev and orig_dev though.
 	 */
-	null_or_bond = NULL;
 	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
 	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
-		null_or_bond = vlan_dev_real_dev(skb->dev);
+		if (null_or_orig)
+			printk(KERN_ERR "BAD: n_o_o %p %s\n", null_or_orig,
+			       null_or_orig->name);
+		null_or_orig = vlan_dev_real_dev(skb->dev);
 	}
 
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
-		if (ptype->type == type &&
-		    (ptype->dev == null_or_orig || ptype->dev == null_or_bond ||
+		if (ptype->type == type && (ptype->dev == null_or_orig ||
 		     ptype->dev == skb->dev || ptype->dev == orig_dev)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
