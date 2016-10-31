From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Enable support for VRF with ipv4 multicast
Date: Mon, 31 Oct 2016 15:54:00 -0700
Message-ID: <1477954440-12339-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35472 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947750AbcJaWyJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 18:54:09 -0400
Received: by mail-pf0-f169.google.com with SMTP id s8so83419700pfj.2
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 15:54:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable support for IPv4 multicast:
- similar to unicast the flow struct is updated to L3 master device
  if relevant prior to calling fib_rules_lookup. The table id is saved
  to the lookup arg so the rule action for ipmr can return the table
  associated with the device.

- ip_mr_forward needs to check for master device mismatch as well
  since the skb->dev is set to it

- allow multicast address on VRF device for Rx by checking for the
  daddr in the VRF device as well as the original ingress device

- on Tx need to drop to __mkroute_output when FIB lookup fails for
  multicast destination address.

- if CONFIG_IP_MROUTE_MULTIPLE_TABLES is enabled VRF driver creates
  IPMR FIB rules on first device create similar to FIB rules. In
  addition the VRF driver does not divert IPv4 multicast packets:
  it breaks on Tx since the fib lookup fails on the mcast address.

With this patch, ipmr forwarding and local rx/tx work.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 23 ++++++++++++++++++-----
 net/ipv4/ipmr.c   | 13 ++++++++++++-
 net/ipv4/route.c  | 41 ++++++++++++++++++++++++++---------------
 3 files changed, 56 insertions(+), 21 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 820de6a9ddde..3bca24651dc0 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -272,11 +272,6 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 	if (IS_ERR(rt))
 		goto err;
 
-	if (rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) {
-		ip_rt_put(rt);
-		goto err;
-	}
-
 	skb_dst_drop(skb);
 
 	/* if dst.dev is loopback or the VRF device again this is locally
@@ -611,6 +606,10 @@ static struct sk_buff *vrf_ip_out(struct net_device *vrf_dev,
 	struct dst_entry *dst = NULL;
 	struct rtable *rth;
 
+	/* don't divert multicast */
+	if (ipv4_is_multicast(ip_hdr(skb)->daddr))
+		return skb;
+
 	rcu_read_lock();
 
 	rth = rcu_dereference(vrf->rth);
@@ -999,6 +998,9 @@ static struct sk_buff *vrf_ip_rcv(struct net_device *vrf_dev,
 	skb->skb_iif = vrf_dev->ifindex;
 	IPCB(skb)->flags |= IPSKB_L3SLAVE;
 
+	if (ipv4_is_multicast(ip_hdr(skb)->daddr))
+		goto out;
+
 	/* loopback traffic; do not push through packet taps again.
 	 * Reset pkt_type for upper layers to process skb
 	 */
@@ -1162,8 +1164,19 @@ static int vrf_add_fib_rules(const struct net_device *dev)
 	if (err < 0)
 		goto ipv6_err;
 
+#if IS_ENABLED(CONFIG_IP_MROUTE_MULTIPLE_TABLES)
+	err = vrf_fib_rule(dev, RTNL_FAMILY_IPMR, true);
+	if (err < 0)
+		goto ipmr_err;
+#endif
+
 	return 0;
 
+#if IS_ENABLED(CONFIG_IP_MROUTE_MULTIPLE_TABLES)
+ipmr_err:
+	vrf_fib_rule(dev, AF_INET6,  false);
+#endif
+
 ipv6_err:
 	vrf_fib_rule(dev, AF_INET,  false);
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5f006e13de56..020b8e0698bd 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -137,6 +137,9 @@ static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
 		.flags = FIB_LOOKUP_NOREF,
 	};
 
+	/* update flow if oif or iif point to device enslaved to l3mdev */
+	l3mdev_update_flow(net, flowi4_to_flowi(flp4));
+
 	err = fib_rules_lookup(net->ipv4.mr_rules_ops,
 			       flowi4_to_flowi(flp4), 0, &arg);
 	if (err < 0)
@@ -163,7 +166,9 @@ static int ipmr_rule_action(struct fib_rule *rule, struct flowi *flp,
 		return -EINVAL;
 	}
 
-	mrt = ipmr_get_table(rule->fr_net, rule->table);
+	arg->table = fib_rule_get_table(rule, arg);
+
+	mrt = ipmr_get_table(rule->fr_net, arg->table);
 	if (!mrt)
 		return -EAGAIN;
 	res->mrt = mrt;
@@ -1809,6 +1814,12 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 
 	/* Wrong interface: drop packet and (maybe) send PIM assert. */
 	if (mrt->vif_table[vif].dev != skb->dev) {
+		struct net_device *mdev;
+
+		mdev = l3mdev_master_dev_rcu(mrt->vif_table[vif].dev);
+		if (mdev == skb->dev)
+			goto forward;
+
 		if (rt_is_output_route(skb_rtable(skb))) {
 			/* It is our own packet, looped back.
 			 * Very complicated situation...
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 62d4d90c1389..4392db83d540 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1980,25 +1980,35 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 */
 	if (ipv4_is_multicast(daddr)) {
 		struct in_device *in_dev = __in_dev_get_rcu(dev);
+		int our = 0;
 
-		if (in_dev) {
-			int our = ip_check_mc_rcu(in_dev, daddr, saddr,
-						  ip_hdr(skb)->protocol);
-			if (our
+		if (in_dev)
+			our = ip_check_mc_rcu(in_dev, daddr, saddr,
+					      ip_hdr(skb)->protocol);
+
+		/* check l3 master if no match yet */
+		if ((!in_dev || !our) && netif_is_l3_slave(dev)) {
+			struct in_device *l3_in_dev;
+
+			l3_in_dev = __in_dev_get_rcu(skb->dev);
+			if (l3_in_dev)
+				our = ip_check_mc_rcu(l3_in_dev, daddr, saddr,
+						      ip_hdr(skb)->protocol);
+		}
+
+		res = -EINVAL;
+		if (our
 #ifdef CONFIG_IP_MROUTE
-				||
-			    (!ipv4_is_local_multicast(daddr) &&
-			     IN_DEV_MFORWARD(in_dev))
+			||
+		    (!ipv4_is_local_multicast(daddr) &&
+		     IN_DEV_MFORWARD(in_dev))
 #endif
-			   ) {
-				int res = ip_route_input_mc(skb, daddr, saddr,
-							    tos, dev, our);
-				rcu_read_unlock();
-				return res;
-			}
+		   ) {
+			res = ip_route_input_mc(skb, daddr, saddr,
+						tos, dev, our);
 		}
 		rcu_read_unlock();
-		return -EINVAL;
+		return res;
 	}
 	res = ip_route_input_slow(skb, daddr, saddr, tos, dev);
 	rcu_read_unlock();
@@ -2266,7 +2276,8 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 		res.fi = NULL;
 		res.table = NULL;
 		if (fl4->flowi4_oif &&
-		    !netif_index_is_l3_master(net, fl4->flowi4_oif)) {
+		    (ipv4_is_multicast(fl4->daddr) ||
+		    !netif_index_is_l3_master(net, fl4->flowi4_oif))) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
 
-- 
2.1.4
