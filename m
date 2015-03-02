From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 09/15] neigh: Move neigh_compat_output into ax25_ip.c
Date: Mon, 02 Mar 2015 00:07:37 -0600
Message-ID: <87vbik6ifq.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The only caller is now is ax25_neigh_construct so move
neigh_compat_output into ax25_ip.c make it static and rename it
ax25_neigh_output.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/neighbour.h |  1 -
 net/ax25/ax25_ip.c      | 18 ++++++++++++++++--
 net/core/neighbour.c    | 20 --------------------
 3 files changed, 16 insertions(+), 23 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 76f708486aae..bc66babb5f27 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -268,7 +268,6 @@ void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb);
 int neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb);
-int neigh_compat_output(struct neighbour *neigh, struct sk_buff *skb);
 int neigh_direct_output(struct neighbour *neigh, struct sk_buff *skb);
 struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 						u8 *lladdr, void *saddr,
diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index bff12e0c9090..cc7415b33cfb 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -216,6 +216,20 @@ put:
 	return 1;
 }
 
+static int ax25_neigh_output(struct neighbour *neigh, struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+
+	__skb_pull(skb, skb_network_offset(skb));
+
+	if (dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL,
+			    skb->len) < 0 &&
+	    dev_rebuild_header(skb))
+		return 0;
+
+	return dev_queue_xmit(skb);
+}
+
 int ax25_neigh_construct(struct neighbour *neigh)
 {
 	/* This trouble could be saved if ax25 would right a proper
@@ -227,8 +241,8 @@ int ax25_neigh_construct(struct neighbour *neigh)
 		return -EINVAL;
 
 	priv->ops = *neigh->ops;
-	priv->ops.output = neigh_compat_output;
-	priv->ops.connected_output = neigh_compat_output;
+	priv->ops.output = ax25_neigh_output;
+	priv->ops.connected_output = ax25_neigh_output;
 	return 0;
 }
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 70fe9e10ac86..8a319ff3e8d1 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1280,26 +1280,6 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst)
 	write_unlock_bh(&n->lock);
 }
 
-/* This function can be used in contexts, where only old dev_queue_xmit
- * worked, f.e. if you want to override normal output path (eql, shaper),
- * but resolution is not made yet.
- */
-
-int neigh_compat_output(struct neighbour *neigh, struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-
-	__skb_pull(skb, skb_network_offset(skb));
-
-	if (dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL,
-			    skb->len) < 0 &&
-	    dev_rebuild_header(skb))
-		return 0;
-
-	return dev_queue_xmit(skb);
-}
-EXPORT_SYMBOL(neigh_compat_output);
-
 /* Slow and careful. */
 
 int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
-- 
2.2.1

