From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 07/15]  ax25: Refactor to use private neighbour operations.
Date: Mon, 02 Mar 2015 00:05:28 -0600
Message-ID: <87d24s7x3r.fsf_-_@x220.int.ebiederm.org>
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


AX25 already has it's own private arp cache operations to isolate
it's abuse of dev_rebuild_header to transmit packets.  Add a function
ax25_neigh_construct that will allow all of the ax25 devices to
force using these operations, so that the generic arp code does
not need to.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/hamradio/6pack.c      |  2 ++
 drivers/net/hamradio/baycom_epp.c |  2 ++
 drivers/net/hamradio/bpqether.c   |  2 ++
 drivers/net/hamradio/dmascc.c     |  2 ++
 drivers/net/hamradio/hdlcdrv.c    |  2 ++
 drivers/net/hamradio/mkiss.c      |  2 ++
 drivers/net/hamradio/scc.c        |  2 ++
 drivers/net/hamradio/yam.c        |  2 ++
 include/net/ax25.h                |  5 +++++
 net/ax25/ax25_ip.c                | 21 +++++++++++++++++++++
 10 files changed, 42 insertions(+)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 2533933c79dc..0b8393ca8c80 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -302,6 +302,7 @@ static const struct net_device_ops sp_netdev_ops = {
 	.ndo_stop		= sp_close,
 	.ndo_start_xmit		= sp_xmit,
 	.ndo_set_mac_address    = sp_set_mac_address,
+	.ndo_neigh_construct	= ax25_neigh_construct,
 };
 
 static void sp_setup(struct net_device *dev)
@@ -315,6 +316,7 @@ static void sp_setup(struct net_device *dev)
 
 	dev->addr_len		= AX25_ADDR_LEN;
 	dev->type		= ARPHRD_AX25;
+	dev->neigh_priv_len	= sizeof(struct ax25_neigh_priv);
 	dev->tx_queue_len	= 10;
 
 	/* Only activated in AX.25 mode */
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index a98c153f371e..3539ab392f7d 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -1109,6 +1109,7 @@ static const struct net_device_ops baycom_netdev_ops = {
 	.ndo_do_ioctl	     = baycom_ioctl,
 	.ndo_start_xmit      = baycom_send_packet,
 	.ndo_set_mac_address = baycom_set_mac_address,
+	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 /*
@@ -1146,6 +1147,7 @@ static void baycom_probe(struct net_device *dev)
 	dev->header_ops = &ax25_header_ops;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
+	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu = AX25_DEF_PACLEN;        /* eth_mtu is the default */
 	dev->addr_len = AX25_ADDR_LEN;     /* sizeof an ax.25 address */
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index c2894e43840e..bce105b16ed0 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -469,6 +469,7 @@ static const struct net_device_ops bpq_netdev_ops = {
 	.ndo_start_xmit	     = bpq_xmit,
 	.ndo_set_mac_address = bpq_set_mac_address,
 	.ndo_do_ioctl	     = bpq_ioctl,
+	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 static void bpq_setup(struct net_device *dev)
@@ -486,6 +487,7 @@ static void bpq_setup(struct net_device *dev)
 #endif
 
 	dev->type            = ARPHRD_AX25;
+	dev->neigh_priv_len  = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu             = AX25_DEF_PACLEN;
 	dev->addr_len        = AX25_ADDR_LEN;
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 0fad408f24aa..abab7be77406 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -433,6 +433,7 @@ module_exit(dmascc_exit);
 static void __init dev_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_AX25;
+	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN;
 	dev->mtu = 1500;
 	dev->addr_len = AX25_ADDR_LEN;
@@ -447,6 +448,7 @@ static const struct net_device_ops scc_netdev_ops = {
 	.ndo_start_xmit = scc_send_packet,
 	.ndo_do_ioctl = scc_ioctl,
 	.ndo_set_mac_address = scc_set_mac_address,
+	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 static int __init setup_adapter(int card_base, int type, int n)
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index c67a27245072..435868a7b69c 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -626,6 +626,7 @@ static const struct net_device_ops hdlcdrv_netdev = {
 	.ndo_start_xmit = hdlcdrv_send_packet,
 	.ndo_do_ioctl	= hdlcdrv_ioctl,
 	.ndo_set_mac_address = hdlcdrv_set_mac_address,
+	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 /*
@@ -676,6 +677,7 @@ static void hdlcdrv_setup(struct net_device *dev)
 	dev->header_ops = &ax25_header_ops;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
+	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu = AX25_DEF_PACLEN;        /* eth_mtu is the default */
 	dev->addr_len = AX25_ADDR_LEN;     /* sizeof an ax.25 address */
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index e37c8d515ce8..c12ec2c2b594 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -641,6 +641,7 @@ static const struct net_device_ops ax_netdev_ops = {
 	.ndo_stop            = ax_close,
 	.ndo_start_xmit	     = ax_xmit,
 	.ndo_set_mac_address = ax_set_mac_address,
+	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 static void ax_setup(struct net_device *dev)
@@ -650,6 +651,7 @@ static void ax_setup(struct net_device *dev)
 	dev->hard_header_len = 0;
 	dev->addr_len        = 0;
 	dev->type            = ARPHRD_AX25;
+	dev->neigh_priv_len  = sizeof(struct ax25_neigh_priv);
 	dev->tx_queue_len    = 10;
 	dev->header_ops      = &ax25_header_ops;
 	dev->netdev_ops	     = &ax_netdev_ops;
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 57be9e0e98a6..b305f51eb420 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1550,6 +1550,7 @@ static const struct net_device_ops scc_netdev_ops = {
 	.ndo_set_mac_address = scc_net_set_mac_address,
 	.ndo_get_stats       = scc_net_get_stats,
 	.ndo_do_ioctl        = scc_net_ioctl,
+	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 /* ----> Initialize device <----- */
@@ -1567,6 +1568,7 @@ static void scc_net_setup(struct net_device *dev)
 	dev->flags      = 0;
 
 	dev->type = ARPHRD_AX25;
+	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu = AX25_DEF_PACLEN;
 	dev->addr_len = AX25_ADDR_LEN;
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 717433cfb81d..89d9da7a0c51 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -1100,6 +1100,7 @@ static const struct net_device_ops yam_netdev_ops = {
 	.ndo_start_xmit      = yam_send_packet,
 	.ndo_do_ioctl 	     = yam_ioctl,
 	.ndo_set_mac_address = yam_set_mac_address,
+	.ndo_neigh_construct = ax25_neigh_construct,
 };
 
 static void yam_setup(struct net_device *dev)
@@ -1128,6 +1129,7 @@ static void yam_setup(struct net_device *dev)
 	dev->header_ops = &ax25_header_ops;
 
 	dev->type = ARPHRD_AX25;
+	dev->neigh_priv_len = sizeof(struct ax25_neigh_priv);
 	dev->hard_header_len = AX25_MAX_HEADER_LEN;
 	dev->mtu = AX25_MTU;
 	dev->addr_len = AX25_ADDR_LEN;
diff --git a/include/net/ax25.h b/include/net/ax25.h
index 7385a64b61b8..45feeba7a325 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -12,6 +12,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/atomic.h>
+#include <net/neighbour.h>
 
 #define	AX25_T1CLAMPLO  		1
 #define	AX25_T1CLAMPHI 			(30 * HZ)
@@ -366,7 +367,11 @@ int ax25_kiss_rcv(struct sk_buff *, struct net_device *, struct packet_type *,
 		  struct net_device *);
 
 /* ax25_ip.c */
+int ax25_neigh_construct(struct neighbour *neigh);
 extern const struct header_ops ax25_header_ops;
+struct ax25_neigh_priv {
+	struct neigh_ops ops;
+};
 
 /* ax25_out.c */
 ax25_cb *ax25_send_frame(struct sk_buff *, int, ax25_address *, ax25_address *,
diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index d93103ba8cec..bff12e0c9090 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -216,6 +216,22 @@ put:
 	return 1;
 }
 
+int ax25_neigh_construct(struct neighbour *neigh)
+{
+	/* This trouble could be saved if ax25 would right a proper
+	 * dev_queue_xmit function.
+	 */
+	struct ax25_neigh_priv *priv = neighbour_priv(neigh);
+
+	if (neigh->tbl->family != AF_INET)
+		return -EINVAL;
+
+	priv->ops = *neigh->ops;
+	priv->ops.output = neigh_compat_output;
+	priv->ops.connected_output = neigh_compat_output;
+	return 0;
+}
+
 #else	/* INET */
 
 static int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
@@ -230,6 +246,10 @@ static int ax25_rebuild_header(struct sk_buff *skb)
 	return 1;
 }
 
+int ax25_neigh_construct(struct neighbour *neigh)
+{
+	return 0;
+}
 #endif
 
 const struct header_ops ax25_header_ops = {
@@ -238,4 +258,5 @@ const struct header_ops ax25_header_ops = {
 };
 
 EXPORT_SYMBOL(ax25_header_ops);
+EXPORT_SYMBOL(ax25_neigh_construct);
 
-- 
2.2.1

