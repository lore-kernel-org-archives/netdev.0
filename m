From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] ax25: Stop using magic neighbour cache operations.
Date: Tue, 03 Mar 2015 09:41:47 -0600
Message-ID: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
References: <20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
	<20150302.164426.494515497595921630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20150302.164426.494515497595921630.davem@davemloft.net> (David
	Miller's message of "Mon, 02 Mar 2015 16:44:26 -0500 (EST)")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Before the ax25 stack calls dev_queue_xmit it always calls
ax25_type_trans which sets skb->protocol to ETH_P_AX25.

Which means that by looking at the protocol type it is possible to
detect IP packets that have not been munged by the ax25 stack in
ndo_start_xmit and call a function to munge them.

Rename ax25_neigh_xmit to ax25_ip_xmit and tweak the return type and
value to be appropriate for an ndo_start_xmit function.

Update all of the ax25 devices to test the protocol type for ETH_P_IP
and return ax25_ip_xmit as the first thing they do.  This preserves
the existing semantics of IP packet processing, but the timing will be
a little different as the IP packets now pass through the qdisc layer
before reaching the ax25 ip packet processing.

Remove the now unnecessary ax25 neighbour table operations.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/hamradio/6pack.c      |  5 ++--
 drivers/net/hamradio/baycom_epp.c |  5 ++--
 drivers/net/hamradio/bpqether.c   |  5 ++--
 drivers/net/hamradio/dmascc.c     |  5 ++--
 drivers/net/hamradio/hdlcdrv.c    |  5 ++--
 drivers/net/hamradio/mkiss.c      |  5 ++--
 drivers/net/hamradio/scc.c        |  5 ++--
 drivers/net/hamradio/yam.c        |  5 ++--
 include/net/ax25.h                |  5 +---
 net/ax25/ax25_ip.c                | 60 ++++-----------------------------------
 10 files changed, 31 insertions(+), 74 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 0b8393ca8c80..7c4a4151ef0f 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -247,6 +247,9 @@ static netdev_tx_t sp_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sixpack *sp = netdev_priv(dev);
 
+	if (skb->protocol == htons(ETH_P_IP))
+		return ax25_ip_xmit(skb);
+
 	spin_lock_bh(&sp->lock);
 	/* We were not busy, so we are now... :-) */
 	netif_stop_queue(dev);
@@ -302,7 +305,6 @@ static const struct net_device_ops sp_netdev_ops = {
 	.ndo_stop		= sp_close,
 	.ndo_start_xmit		= sp_xmit,
 	.ndo_set_mac_address    = sp_set_mac_address,
-	.ndo_neigh_construct	= ax25_neigh_construct,
 };
 
 static void sp_setup(struct net_device *dev)
@@ -316,7 +318,6 @@ static void sp_setup(struct net_device *dev)
 
 	dev->addr_len		= AX25_ADDR_LEN;
 	dev->type		= ARPHRD_AX25;
-	dev->neigh_priv_len	= sizeof(struct ax25_neigh_priv);
 	dev->tx_queue_len	= 10;
 
 	/* Only activated in AX.25 mode */
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 3539ab392f7d..83c7cce0d172 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -772,6 +772,9 @@ static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct baycom_state *bc = netdev_priv(dev);
 
+	if (skb->protocol == htons(ETH_P_IP))
+		return ax25_ip_xmit(skb);
+
 	if (skb->data[0] != 0) {
 		do_kiss_params(bc, skb->data, skb->len);
 		dev_kfree_skb(skb);
@@ -1109,7 +1112,6 @@ static const struct net_device_ops baycom_netdev_ops = {
 	.ndo_do_ioctl	     = baycom_ioctl,
 	.ndo_start_xmit      = baycom_send_packet,
 	.ndo_set_mac_address = baycom_set_mac_address,
-	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 /*
@@ -1147,7 +1149,6 @@ static void baycom_probe(struct net_device *dev)
 	dev->header_ops = &ax25_header_ops;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
-	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu = AX25_DEF_PACLEN;        /* eth_mtu is the default */
 	dev->addr_len = AX25_ADDR_LEN;     /* sizeof an ax.25 address */
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index bce105b16ed0..63ff08a26da8 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -251,6 +251,9 @@ static netdev_tx_t bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_device *orig_dev;
 	int size;
 
+	if (skb->protocol == htons(ETH_P_IP))
+		return ax25_ip_xmit(skb);
+
 	/*
 	 * Just to be *really* sure not to send anything if the interface
 	 * is down, the ethernet device may have gone.
@@ -469,7 +472,6 @@ static const struct net_device_ops bpq_netdev_ops = {
 	.ndo_start_xmit	     = bpq_xmit,
 	.ndo_set_mac_address = bpq_set_mac_address,
 	.ndo_do_ioctl	     = bpq_ioctl,
-	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 static void bpq_setup(struct net_device *dev)
@@ -487,7 +489,6 @@ static void bpq_setup(struct net_device *dev)
 #endif
 
 	dev->type            = ARPHRD_AX25;
-	dev->neigh_priv_len  = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu             = AX25_DEF_PACLEN;
 	dev->addr_len        = AX25_ADDR_LEN;
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index abab7be77406..c3d377770616 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -433,7 +433,6 @@ module_exit(dmascc_exit);
 static void __init dev_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_AX25;
-	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN;
 	dev->mtu = 1500;
 	dev->addr_len = AX25_ADDR_LEN;
@@ -448,7 +447,6 @@ static const struct net_device_ops scc_netdev_ops = {
 	.ndo_start_xmit = scc_send_packet,
 	.ndo_do_ioctl = scc_ioctl,
 	.ndo_set_mac_address = scc_set_mac_address,
-	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 static int __init setup_adapter(int card_base, int type, int n)
@@ -922,6 +920,9 @@ static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	int i;
 
+	if (skb->protocol == htons(ETH_P_IP))
+		return ax25_ip_xmit(skb);
+
 	/* Temporarily stop the scheduler feeding us packets */
 	netif_stop_queue(dev);
 
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 435868a7b69c..49fe59b180a8 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -404,6 +404,9 @@ static netdev_tx_t hdlcdrv_send_packet(struct sk_buff *skb,
 {
 	struct hdlcdrv_state *sm = netdev_priv(dev);
 
+	if (skb->protocol == htons(ETH_P_IP))
+		return ax25_ip_xmit(skb);
+
 	if (skb->data[0] != 0) {
 		do_kiss_params(sm, skb->data, skb->len);
 		dev_kfree_skb(skb);
@@ -626,7 +629,6 @@ static const struct net_device_ops hdlcdrv_netdev = {
 	.ndo_start_xmit = hdlcdrv_send_packet,
 	.ndo_do_ioctl	= hdlcdrv_ioctl,
 	.ndo_set_mac_address = hdlcdrv_set_mac_address,
-	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 /*
@@ -677,7 +679,6 @@ static void hdlcdrv_setup(struct net_device *dev)
 	dev->header_ops = &ax25_header_ops;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
-	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu = AX25_DEF_PACLEN;        /* eth_mtu is the default */
 	dev->addr_len = AX25_ADDR_LEN;     /* sizeof an ax.25 address */
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index c12ec2c2b594..17058c490b79 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -529,6 +529,9 @@ static netdev_tx_t ax_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mkiss *ax = netdev_priv(dev);
 
+	if (skb->protocol == htons(ETH_P_IP))
+		return ax25_ip_xmit(skb);
+
 	if (!netif_running(dev))  {
 		printk(KERN_ERR "mkiss: %s: xmit call when iface is down\n", dev->name);
 		return NETDEV_TX_BUSY;
@@ -641,7 +644,6 @@ static const struct net_device_ops ax_netdev_ops = {
 	.ndo_stop            = ax_close,
 	.ndo_start_xmit	     = ax_xmit,
 	.ndo_set_mac_address = ax_set_mac_address,
-	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 static void ax_setup(struct net_device *dev)
@@ -651,7 +653,6 @@ static void ax_setup(struct net_device *dev)
 	dev->hard_header_len = 0;
 	dev->addr_len        = 0;
 	dev->type            = ARPHRD_AX25;
-	dev->neigh_priv_len  = sizeof(struct ax25_neigh_priv);
 	dev->tx_queue_len    = 10;
 	dev->header_ops      = &ax25_header_ops;
 	dev->netdev_ops	     = &ax_netdev_ops;
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index b305f51eb420..ce88df33fe17 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1550,7 +1550,6 @@ static const struct net_device_ops scc_netdev_ops = {
 	.ndo_set_mac_address = scc_net_set_mac_address,
 	.ndo_get_stats       = scc_net_get_stats,
 	.ndo_do_ioctl        = scc_net_ioctl,
-	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 /* ----> Initialize device <----- */
@@ -1568,7 +1567,6 @@ static void scc_net_setup(struct net_device *dev)
 	dev->flags      = 0;
 
 	dev->type = ARPHRD_AX25;
-	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu = AX25_DEF_PACLEN;
 	dev->addr_len = AX25_ADDR_LEN;
@@ -1641,6 +1639,9 @@ static netdev_tx_t scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	char kisscmd;
 
+	if (skb->protocol == htons(ETH_P_IP))
+		return ax25_ip_xmit(skb);
+
 	if (skb->len > scc->stat.bufsize || skb->len < 2) {
 		scc->dev_stat.tx_dropped++;	/* bogus frame */
 		dev_kfree_skb(skb);
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 89d9da7a0c51..1a4729c36aa4 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -597,6 +597,9 @@ static netdev_tx_t yam_send_packet(struct sk_buff *skb,
 {
 	struct yam_port *yp = netdev_priv(dev);
 
+	if (skb->protocol == htons(ETH_P_IP))
+		return ax25_ip_xmit(skb);
+
 	skb_queue_tail(&yp->send_queue, skb);
 	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
@@ -1100,7 +1103,6 @@ static const struct net_device_ops yam_netdev_ops = {
 	.ndo_start_xmit      = yam_send_packet,
 	.ndo_do_ioctl 	     = yam_ioctl,
 	.ndo_set_mac_address = yam_set_mac_address,
-	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 static void yam_setup(struct net_device *dev)
@@ -1129,7 +1131,6 @@ static void yam_setup(struct net_device *dev)
 	dev->header_ops = &ax25_header_ops;
 
 	dev->type = ARPHRD_AX25;
-	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN;
 	dev->mtu = AX25_MTU;
 	dev->addr_len = AX25_ADDR_LEN;
diff --git a/include/net/ax25.h b/include/net/ax25.h
index 45feeba7a325..16a923a3a43a 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -367,11 +367,8 @@ int ax25_kiss_rcv(struct sk_buff *, struct net_device *, struct packet_type *,
 		  struct net_device *);
 
 /* ax25_ip.c */
-int ax25_neigh_construct(struct neighbour *neigh);
+netdev_tx_t ax25_ip_xmit(struct sk_buff *skb);
 extern const struct header_ops ax25_header_ops;
-struct ax25_neigh_priv {
-	struct neigh_ops ops;
-};
 
 /* ax25_out.c */
 ax25_cb *ax25_send_frame(struct sk_buff *, int, ax25_address *, ax25_address *,
diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index e030c64ebfb7..8b35af4ef93e 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -100,7 +100,7 @@ static int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return -AX25_HEADER_LEN;	/* Unfinished header */
 }
 
-static int ax25_neigh_xmit(struct sk_buff *skb)
+netdev_tx_t ax25_ip_xmit(struct sk_buff *skb)
 {
 	struct sk_buff *ourskb;
 	unsigned char *bp  = skb->data;
@@ -210,56 +210,7 @@ put:
 	if (route)
 		ax25_put_route(route);
 
-	return 1;
-}
-
-static int ax25_neigh_output(struct neighbour *neigh, struct sk_buff *skb)
-{
-	/* Except for calling ax25_neigh_xmit instead of
-	 * dev_queue_xmit this is neigh_resolve_output.
-	 */
-	int rc = 0;
-
-	if (!neigh_event_send(neigh, skb)) {
-		int err;
-		struct net_device *dev = neigh->dev;
-		unsigned int seq;
-
-		do {
-			__skb_pull(skb, skb_network_offset(skb));
-			seq = read_seqbegin(&neigh->ha_lock);
-			err = dev_hard_header(skb, dev, ntohs(skb->protocol),
-					      neigh->ha, NULL, skb->len);
-		} while (read_seqretry(&neigh->ha_lock, seq));
-
-		if (err >= 0) {
-			ax25_neigh_xmit(skb);
-		} else
-			goto out_kfree_skb;
-	}
-out:
-	return rc;
-
-out_kfree_skb:
-	rc = -EINVAL;
-	kfree_skb(skb);
-	goto out;
-}
-
-int ax25_neigh_construct(struct neighbour *neigh)
-{
-	/* This trouble could be saved if ax25 would right a proper
-	 * dev_queue_xmit function.
-	 */
-	struct ax25_neigh_priv *priv = neighbour_priv(neigh);
-
-	if (neigh->tbl->family != AF_INET)
-		return -EINVAL;
-
-	priv->ops = *neigh->ops;
-	priv->ops.output = ax25_neigh_output;
-	priv->ops.connected_output = ax25_neigh_output;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 #else	/* INET */
@@ -271,9 +222,10 @@ static int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return -AX25_HEADER_LEN;
 }
 
-int ax25_neigh_construct(struct neighbour *neigh)
+netdev_tx_t ax25_ip_xmit(sturct sk_buff *skb)
 {
-	return 0;
+	kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 #endif
 
@@ -282,5 +234,5 @@ const struct header_ops ax25_header_ops = {
 };
 
 EXPORT_SYMBOL(ax25_header_ops);
-EXPORT_SYMBOL(ax25_neigh_construct);
+EXPORT_SYMBOL(ax25_ip_xmit);
 
-- 
2.2.1

