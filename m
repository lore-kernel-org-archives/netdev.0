From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 3/4] caif: Use link layer MTU instead of fixed MTU
Date: Thu, 17 Jun 2010 18:55:40 +0200
Message-ID: <1276793741-20278-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
 <1276793741-20278-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: sjurbr@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:37367 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933068Ab0FQQ4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 12:56:00 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4600FHG4DB0S90@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 17 Jun 2010 18:55:59 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4600ITZ4D6RO21@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 17 Jun 2010 18:55:59 +0200 (CEST)
In-reply-to: <1276793741-20278-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Previously CAIF supported maximum transfer size of ~4050.
The transfer size is now calculated dynamically based on the
link layers mtu size.

Signed-off-by: Sjur Braendeland@stericsson.com
---
 drivers/net/caif/caif_serial.c |    1 -
 include/net/caif/caif_dev.h    |    8 +++-
 include/net/caif/caif_layer.h  |    6 ---
 include/net/caif/cfcnfg.h      |   16 +++++++--
 net/caif/caif_dev.c            |   12 +++++--
 net/caif/caif_socket.c         |   54 +++++++++++++++++++++-----------
 net/caif/cfcnfg.c              |   44 ++++++++++++++++++++++++--
 net/caif/cfctrl.c              |    6 ++--
 net/caif/cfdgml.c              |    5 +++
 net/caif/cfpkt_skbuff.c        |    4 +-
 net/caif/cfserl.c              |    7 ++--
 net/caif/cfsrvl.c              |    1 -
 net/caif/cfutill.c             |    6 ---
 net/caif/cfveil.c              |    5 ---
 net/caif/chnl_net.c            |   67 ++++++++++++++++++++++++++++++++++------
 15 files changed, 173 insertions(+), 69 deletions(-)

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 3e706f0..3df0c0f 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -403,7 +403,6 @@ static void caifdev_setup(struct net_device *dev)
 	dev->type = ARPHRD_CAIF;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu = CAIF_MAX_MTU;
-	dev->hard_header_len = CAIF_NEEDED_HEADROOM;
 	dev->tx_queue_len = 0;
 	dev->destructor = free_netdev;
 	skb_queue_head_init(&serdev->head);
diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index 318ab94..6da573c 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -50,6 +50,9 @@ struct caif_connect_request {
  * @client_layer:	User implementation of client layer. This layer
  *			MUST have receive and control callback functions
  *			implemented.
+ * @ifindex:		Link layer interface index used for this connection.
+ * @headroom:		Head room needed by CAIF protocol.
+ * @tailroom:		Tail room needed by CAIF protocol.
  *
  * This function connects a CAIF channel. The Client must implement
  * the struct cflayer. This layer represents the Client layer and holds
@@ -59,8 +62,9 @@ struct caif_connect_request {
  * E.g. CAIF Socket will call this function for each socket it connects
  * and have one client_layer instance for each socket.
  */
-int caif_connect_client(struct caif_connect_request *config,
-			   struct cflayer *client_layer);
+int caif_connect_client(struct caif_connect_request *conn_req,
+			struct cflayer *client_layer, int *ifindex,
+			int *headroom, int *tailroom);
 
 /**
  * caif_disconnect_client - Disconnects a client from the CAIF stack.
diff --git a/include/net/caif/caif_layer.h b/include/net/caif/caif_layer.h
index 25c472f..c8b07a9 100644
--- a/include/net/caif/caif_layer.h
+++ b/include/net/caif/caif_layer.h
@@ -15,14 +15,8 @@ struct cfpktq;
 struct caif_payload_info;
 struct caif_packet_funcs;
 
-#define CAIF_MAX_FRAMESIZE 4096
-#define CAIF_MAX_PAYLOAD_SIZE (4096 - 64)
-#define CAIF_NEEDED_HEADROOM (10)
-#define CAIF_NEEDED_TAILROOM (2)
 
 #define CAIF_LAYER_NAME_SZ 16
-#define CAIF_SUCCESS	1
-#define CAIF_FAILURE	0
 
 /**
  * caif_assert() - Assert function for CAIF.
diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index 9fc2fc2..bd646fa 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -7,6 +7,7 @@
 #ifndef CFCNFG_H_
 #define CFCNFG_H_
 #include <linux/spinlock.h>
+#include <linux/netdevice.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfctrl.h>
 
@@ -73,8 +74,8 @@ void cfcnfg_remove(struct cfcnfg *cfg);
 
 void
 cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
-		     void *dev, struct cflayer *phy_layer, u16 *phyid,
-		     enum cfcnfg_phy_preference pref,
+		     struct net_device *dev, struct cflayer *phy_layer,
+		     u16 *phyid, enum cfcnfg_phy_preference pref,
 		     bool fcs, bool stx);
 
 /**
@@ -114,11 +115,18 @@ void cfcnfg_release_adap_layer(struct cflayer *adap_layer);
  * @param:		Link setup parameters.
  * @adap_layer:		Specify the adaptation layer; the receive and
  *			flow-control functions MUST be set in the structure.
- *
+ * @ifindex:		Link layer interface index used for this connection.
+ * @proto_head:		Protocol head-space needed by CAIF protocol,
+ *			excluding link layer.
+ * @proto_tail:		Protocol tail-space needed by CAIF protocol,
+ *			excluding link layer.
  */
 int cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
 			    struct cfctrl_link_param *param,
-			    struct cflayer *adap_layer);
+			    struct cflayer *adap_layer,
+			    int *ifindex,
+			    int *proto_head,
+			    int *proto_tail);
 
 /**
  * cfcnfg_get_phyid() - Get physical ID, given type.
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index e2b86f1..0b586e9 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -255,7 +255,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 			pref = CFPHYPREF_HIGH_BW;
 			break;
 		}
-
+		dev_hold(dev);
 		cfcnfg_add_phy_layer(get_caif_conf(),
 				     phy_type,
 				     dev,
@@ -285,6 +285,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 		caifd->layer.up->ctrlcmd(caifd->layer.up,
 					 _CAIF_CTRLCMD_PHYIF_DOWN_IND,
 					 caifd->layer.id);
+		might_sleep();
 		res = wait_event_interruptible_timeout(caifd->event,
 					atomic_read(&caifd->in_use) == 0,
 					TIMEOUT);
@@ -300,6 +301,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 				   "Unregistering an active CAIF device: %s\n",
 				   __func__, dev->name);
 		cfcnfg_del_phy_layer(get_caif_conf(), &caifd->layer);
+		dev_put(dev);
 		atomic_set(&caifd->state, what);
 		break;
 
@@ -326,7 +328,8 @@ struct cfcnfg *get_caif_conf(void)
 EXPORT_SYMBOL(get_caif_conf);
 
 int caif_connect_client(struct caif_connect_request *conn_req,
-			   struct cflayer *client_layer)
+			struct cflayer *client_layer, int *ifindex,
+			int *headroom, int *tailroom)
 {
 	struct cfctrl_link_param param;
 	int ret;
@@ -334,8 +337,9 @@ int caif_connect_client(struct caif_connect_request *conn_req,
 	if (ret)
 		return ret;
 	/* Hook up the adaptation layer. */
-	return cfcnfg_add_adaptation_layer(get_caif_conf(),
-						&param, client_layer);
+	return cfcnfg_add_adaptation_layer(get_caif_conf(), &param,
+					client_layer, ifindex,
+					headroom, tailroom);
 }
 EXPORT_SYMBOL(caif_connect_client);
 
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 848ae75..8ce9047 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -28,8 +28,8 @@
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_NETPROTO(AF_CAIF);
 
-#define CAIF_DEF_SNDBUF (CAIF_MAX_PAYLOAD_SIZE*10)
-#define CAIF_DEF_RCVBUF (CAIF_MAX_PAYLOAD_SIZE*100)
+#define CAIF_DEF_SNDBUF (4096*10)
+#define CAIF_DEF_RCVBUF (4096*100)
 
 /*
  * CAIF state is re-using the TCP socket states.
@@ -76,6 +76,7 @@ struct caifsock {
 	struct caif_connect_request conn_req;
 	struct mutex readlock;
 	struct dentry *debugfs_socket_dir;
+	int headroom, tailroom, maxframe;
 };
 
 static int rx_flow_is_on(struct caifsock *cf_sk)
@@ -594,23 +595,32 @@ static int caif_seqpkt_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		goto err;
 	noblock = msg->msg_flags & MSG_DONTWAIT;
 
-	buffer_size = len + CAIF_NEEDED_HEADROOM + CAIF_NEEDED_TAILROOM;
-
 	timeo = sock_sndtimeo(sk, noblock);
 	timeo = caif_wait_for_flow_on(container_of(sk, struct caifsock, sk),
 				1, timeo, &ret);
 
+	if (ret)
+		goto err;
 	ret = -EPIPE;
 	if (cf_sk->sk.sk_state != CAIF_CONNECTED ||
 		sock_flag(sk, SOCK_DEAD) ||
 		(sk->sk_shutdown & RCV_SHUTDOWN))
 		goto err;
 
+	/* Error if trying to write more than maximum frame size. */
+	ret = -EMSGSIZE;
+	if (len > cf_sk->maxframe && cf_sk->sk.sk_protocol != CAIFPROTO_RFM)
+		goto err;
+
+	buffer_size = len + cf_sk->headroom + cf_sk->tailroom;
+
 	ret = -ENOMEM;
 	skb = sock_alloc_send_skb(sk, buffer_size, noblock, &ret);
-	if (!skb)
+
+	if (!skb || skb_tailroom(skb) < buffer_size)
 		goto err;
-	skb_reserve(skb, CAIF_NEEDED_HEADROOM);
+
+	skb_reserve(skb, cf_sk->headroom);
 
 	ret = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
 
@@ -641,7 +651,6 @@ static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	long timeo;
 
 	err = -EOPNOTSUPP;
-
 	if (unlikely(msg->msg_flags&MSG_OOB))
 		goto out_err;
 
@@ -658,8 +667,8 @@ static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 		size = len-sent;
 
-		if (size > CAIF_MAX_PAYLOAD_SIZE)
-			size = CAIF_MAX_PAYLOAD_SIZE;
+		if (size > cf_sk->maxframe)
+			size = cf_sk->maxframe;
 
 		/* If size is more than half of sndbuf, chop up message */
 		if (size > ((sk->sk_sndbuf >> 1) - 64))
@@ -669,14 +678,14 @@ static int caif_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			size = SKB_MAX_ALLOC;
 
 		skb = sock_alloc_send_skb(sk,
-					size + CAIF_NEEDED_HEADROOM
-					+ CAIF_NEEDED_TAILROOM,
+					size + cf_sk->headroom +
+					cf_sk->tailroom,
 					msg->msg_flags&MSG_DONTWAIT,
 					&err);
 		if (skb == NULL)
 			goto out_err;
 
-		skb_reserve(skb, CAIF_NEEDED_HEADROOM);
+		skb_reserve(skb, cf_sk->headroom);
 		/*
 		 *	If you pass two values to the sock_alloc_send_skb
 		 *	it tries to grab the large buffer with GFP_NOFS
@@ -817,17 +826,15 @@ static int caif_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
 	long timeo;
 	int err;
+	int ifindex, headroom, tailroom;
+	struct net_device *dev;
+
 	lock_sock(sk);
 
 	err = -EAFNOSUPPORT;
 	if (uaddr->sa_family != AF_CAIF)
 		goto out;
 
-	err = -ESOCKTNOSUPPORT;
-	if (unlikely(!(sk->sk_type == SOCK_STREAM &&
-		       cf_sk->sk.sk_protocol == CAIFPROTO_AT) &&
-		       sk->sk_type != SOCK_SEQPACKET))
-		goto out;
 	switch (sock->state) {
 	case SS_UNCONNECTED:
 		/* Normal case, a fresh connect */
@@ -883,12 +890,23 @@ static int caif_connect(struct socket *sock, struct sockaddr *uaddr,
 	dbfs_atomic_inc(&cnt.num_connect_req);
 	cf_sk->layer.receive = caif_sktrecv_cb;
 	err = caif_connect_client(&cf_sk->conn_req,
-				&cf_sk->layer);
+				&cf_sk->layer, &ifindex, &headroom, &tailroom);
 	if (err < 0) {
 		cf_sk->sk.sk_socket->state = SS_UNCONNECTED;
 		cf_sk->sk.sk_state = CAIF_DISCONNECTED;
 		goto out;
 	}
+	dev = dev_get_by_index(sock_net(sk), ifindex);
+	cf_sk->headroom = LL_RESERVED_SPACE_EXTRA(dev, headroom);
+	cf_sk->tailroom = tailroom;
+	cf_sk->maxframe = dev->mtu - (headroom + tailroom);
+	dev_put(dev);
+	if (cf_sk->maxframe < 1) {
+		pr_warning("CAIF: %s(): CAIF Interface MTU too small (%d)\n",
+			__func__, dev->mtu);
+		err = -ENODEV;
+		goto out;
+	}
 
 	err = -EINPROGRESS;
 wait_connect:
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index cff2dcb..1c29189 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -6,6 +6,7 @@
 #include <linux/kernel.h>
 #include <linux/stddef.h>
 #include <linux/slab.h>
+#include <linux/netdevice.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/cfcnfg.h>
@@ -42,6 +43,15 @@ struct cfcnfg_phyinfo {
 
 	/* Information about the physical device */
 	struct dev_info dev_info;
+
+	/* Interface index */
+	int ifindex;
+
+	/* Use Start of frame extension */
+	bool use_stx;
+
+	/* Use Start of frame checksum */
+	bool use_fcs;
 };
 
 struct cfcnfg {
@@ -249,9 +259,20 @@ static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id)
 {
 }
 
+int protohead[CFCTRL_SRV_MASK] = {
+	[CFCTRL_SRV_VEI] = 4,
+	[CFCTRL_SRV_DATAGRAM] = 7,
+	[CFCTRL_SRV_UTIL] = 4,
+	[CFCTRL_SRV_RFM] = 3,
+	[CFCTRL_SRV_DBG] = 3,
+};
+
 int cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
 				struct cfctrl_link_param *param,
-				struct cflayer *adap_layer)
+				struct cflayer *adap_layer,
+				int *ifindex,
+				int *proto_head,
+				int *proto_tail)
 {
 	struct cflayer *frml;
 	if (adap_layer == NULL) {
@@ -277,6 +298,14 @@ int cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
 		     param->phyid);
 	caif_assert(cnfg->phy_layers[param->phyid].phy_layer->id ==
 		     param->phyid);
+
+	*ifindex = cnfg->phy_layers[param->phyid].ifindex;
+	*proto_head =
+		protohead[param->linktype]+
+		(cnfg->phy_layers[param->phyid].use_stx ? 1 : 0);
+
+	*proto_tail = 2;
+
 	/* FIXME: ENUMERATE INITIALLY WHEN ACTIVATING PHYSICAL INTERFACE */
 	cfctrl_enum_req(cnfg->ctrl, param->phyid);
 	return cfctrl_linkup_request(cnfg->ctrl, param, adap_layer);
@@ -298,6 +327,8 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 	struct cfcnfg *cnfg = container_obj(layer);
 	struct cflayer *servicel = NULL;
 	struct cfcnfg_phyinfo *phyinfo;
+	struct net_device *netdev;
+
 	if (adapt_layer == NULL) {
 		pr_debug("CAIF: %s(): link setup response "
 				"but no client exist, send linkdown back\n",
@@ -329,8 +360,9 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 		servicel = cfdgml_create(channel_id, &phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_RFM:
+		netdev = phyinfo->dev_info.dev;
 		servicel = cfrfml_create(channel_id, &phyinfo->dev_info,
-						RFM_FRAGMENT_SIZE);
+						netdev->mtu);
 		break;
 	case CFCTRL_SRV_UTIL:
 		servicel = cfutill_create(channel_id, &phyinfo->dev_info);
@@ -361,8 +393,8 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 
 void
 cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
-		     void *dev, struct cflayer *phy_layer, u16 *phyid,
-		     enum cfcnfg_phy_preference pref,
+		     struct net_device *dev, struct cflayer *phy_layer,
+		     u16 *phyid, enum cfcnfg_phy_preference pref,
 		     bool fcs, bool stx)
 {
 	struct cflayer *frml;
@@ -416,6 +448,10 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
 	cnfg->phy_layers[*phyid].dev_info.dev = dev;
 	cnfg->phy_layers[*phyid].phy_layer = phy_layer;
 	cnfg->phy_layers[*phyid].phy_ref_count = 0;
+	cnfg->phy_layers[*phyid].ifindex = dev->ifindex;
+	cnfg->phy_layers[*phyid].use_stx = stx;
+	cnfg->phy_layers[*phyid].use_fcs = fcs;
+
 	phy_layer->type = phy_type;
 	frml = cffrml_create(*phyid, fcs);
 	if (!frml) {
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 107c4b2..563145f 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -19,7 +19,7 @@
 #ifdef CAIF_NO_LOOP
 static int handle_loop(struct cfctrl *ctrl,
 			      int cmd, struct cfpkt *pkt){
-	return CAIF_FAILURE;
+	return -1;
 }
 #else
 static int handle_loop(struct cfctrl *ctrl,
@@ -395,7 +395,7 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 	cmd = cmdrsp & CFCTRL_CMD_MASK;
 	if (cmd != CFCTRL_CMD_LINK_ERR
 	    && CFCTRL_RSP_BIT != (CFCTRL_RSP_BIT & cmdrsp)) {
-		if (handle_loop(cfctrl, cmd, pkt) == CAIF_FAILURE)
+		if (handle_loop(cfctrl, cmd, pkt) != 0)
 			cmdrsp |= CFCTRL_ERR_BIT;
 	}
 
@@ -647,6 +647,6 @@ found:
 	default:
 		break;
 	}
-	return CAIF_SUCCESS;
+	return 0;
 }
 #endif
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index 32d9f0d..ed9d53a 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -17,6 +17,7 @@
 #define DGM_FLOW_OFF 0x81
 #define DGM_FLOW_ON  0x80
 #define DGM_CTRL_PKT_SIZE 1
+#define DGM_MTU 1500
 
 static int cfdgml_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cfdgml_transmit(struct cflayer *layr, struct cfpkt *pkt);
@@ -89,6 +90,10 @@ static int cfdgml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	if (!cfsrvl_ready(service, &ret))
 		return ret;
 
+	/* STE Modem cannot handle more than 1500 bytes datagrams */
+	if (cfpkt_getlen(pkt) > DGM_MTU)
+		return -EMSGSIZE;
+
 	cfpkt_add_head(pkt, &zero, 4);
 
 	/* Add info for MUX-layer to route the packet out. */
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 318b0f4..01f238f 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -9,8 +9,8 @@
 #include <linux/hardirq.h>
 #include <net/caif/cfpkt.h>
 
-#define PKT_PREFIX CAIF_NEEDED_HEADROOM
-#define PKT_POSTFIX CAIF_NEEDED_TAILROOM
+#define PKT_PREFIX  16
+#define PKT_POSTFIX 2
 #define PKT_LEN_WHEN_EXTENDING 128
 #define PKT_ERROR(pkt, errmsg) do {	   \
     cfpkt_priv(pkt)->erronous = true;	   \
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index 965c5ba..a11fbd6 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -14,7 +14,8 @@
 #define container_obj(layr) ((struct cfserl *) layr)
 
 #define CFSERL_STX 0x02
-#define CAIF_MINIUM_PACKET_SIZE 4
+#define SERIAL_MINIUM_PACKET_SIZE 4
+#define SERIAL_MAX_FRAMESIZE 4096
 struct cfserl {
 	struct cflayer layer;
 	struct cfpkt *incomplete_frm;
@@ -119,8 +120,8 @@ static int cfserl_receive(struct cflayer *l, struct cfpkt *newpkt)
 		/*
 		 * Frame error handling
 		 */
-		if (expectlen < CAIF_MINIUM_PACKET_SIZE
-		    || expectlen > CAIF_MAX_FRAMESIZE) {
+		if (expectlen < SERIAL_MINIUM_PACKET_SIZE
+		    || expectlen > SERIAL_MAX_FRAMESIZE) {
 			if (!layr->usestx) {
 				if (pkt != NULL)
 					cfpkt_destroy(pkt);
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index 4c9f147..f40939a 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -162,7 +162,6 @@ void cfservl_destroy(struct cflayer *layer)
 void cfsrvl_release(struct kref *kref)
 {
 	struct cfsrvl *service = container_of(kref, struct cfsrvl, ref);
-	pr_info("CAIF: %s(): enter\n", __func__);
 	kfree(service);
 }
 
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index ce525ca..02795af 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -90,12 +90,6 @@ static int cfutill_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	if (!cfsrvl_ready(service, &ret))
 		return ret;
 
-	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
-		pr_err("CAIF: %s(): packet too large size=%d\n",
-			__func__, cfpkt_getlen(pkt));
-		return -EOVERFLOW;
-	}
-
 	cfpkt_add_head(pkt, &zero, 1);
 	/* Add info for MUX-layer to route the packet out. */
 	info = cfpkt_info(pkt);
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index 637cb0e..77cc09f 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -84,11 +84,6 @@ static int cfvei_transmit(struct cflayer *layr, struct cfpkt *pkt)
 		return ret;
 	caif_assert(layr->dn != NULL);
 	caif_assert(layr->dn->transmit != NULL);
-	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
-		pr_warning("CAIF: %s(): Packet too large - size=%d\n",
-			   __func__, cfpkt_getlen(pkt));
-		return -EOVERFLOW;
-	}
 
 	if (cfpkt_add_head(pkt, &tmp, 1) < 0) {
 		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 610966a..4293e19 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -23,7 +23,7 @@
 #include <net/caif/caif_dev.h>
 
 /* GPRS PDP connection has MTU to 1500 */
-#define SIZE_MTU 1500
+#define GPRS_PDP_MTU 1500
 /* 5 sec. connect timeout */
 #define CONNECT_TIMEOUT (5 * HZ)
 #define CAIF_NET_DEFAULT_QUEUE_LEN 500
@@ -232,6 +232,8 @@ static int chnl_net_open(struct net_device *dev)
 {
 	struct chnl_net *priv = NULL;
 	int result = -1;
+	int llifindex, headroom, tailroom, mtu;
+	struct net_device *lldev;
 	ASSERT_RTNL();
 	priv = netdev_priv(dev);
 	if (!priv) {
@@ -241,41 +243,88 @@ static int chnl_net_open(struct net_device *dev)
 
 	if (priv->state != CAIF_CONNECTING) {
 		priv->state = CAIF_CONNECTING;
-		result = caif_connect_client(&priv->conn_req, &priv->chnl);
+		result = caif_connect_client(&priv->conn_req, &priv->chnl,
+					&llifindex, &headroom, &tailroom);
 		if (result != 0) {
-				priv->state = CAIF_DISCONNECTED;
 				pr_debug("CAIF: %s(): err: "
 					"Unable to register and open device,"
 					" Err:%d\n",
 					__func__,
 					result);
-				return result;
+				goto error;
+		}
+
+		lldev = dev_get_by_index(dev_net(dev), llifindex);
+
+		if (lldev == NULL) {
+			pr_debug("CAIF: %s(): no interface?\n", __func__);
+			result = -ENODEV;
+			goto error;
+		}
+
+		dev->needed_tailroom = tailroom + lldev->needed_tailroom;
+		dev->hard_header_len = headroom + lldev->hard_header_len +
+			lldev->needed_tailroom;
+
+		/*
+		 * MTU, head-room etc is not know before we have a
+		 * CAIF link layer device available. MTU calculation may
+		 * override initial RTNL configuration.
+		 * MTU is minimum of current mtu, link layer mtu pluss
+		 * CAIF head and tail, and PDP GPRS contexts max MTU.
+		 */
+		mtu = min_t(int, dev->mtu, lldev->mtu - (headroom + tailroom));
+		mtu = min_t(int, GPRS_PDP_MTU, mtu);
+		dev_set_mtu(dev, mtu);
+		dev_put(lldev);
+
+		if (mtu < 100) {
+			pr_warning("CAIF: %s(): "
+				"CAIF Interface MTU too small (%d)\n",
+				__func__, mtu);
+			result = -ENODEV;
+			goto error;
 		}
 	}
 
+	rtnl_unlock();  /* Release RTNL lock during connect wait */
+
 	result = wait_event_interruptible_timeout(priv->netmgmt_wq,
 						priv->state != CAIF_CONNECTING,
 						CONNECT_TIMEOUT);
 
+	rtnl_lock();
+
 	if (result == -ERESTARTSYS) {
 		pr_debug("CAIF: %s(): wait_event_interruptible"
 			 " woken by a signal\n", __func__);
-		return -ERESTARTSYS;
+		result = -ERESTARTSYS;
+		goto error;
 	}
+
 	if (result == 0) {
 		pr_debug("CAIF: %s(): connect timeout\n", __func__);
 		caif_disconnect_client(&priv->chnl);
 		priv->state = CAIF_DISCONNECTED;
 		pr_debug("CAIF: %s(): state disconnected\n", __func__);
-		return -ETIMEDOUT;
+		result = -ETIMEDOUT;
+		goto error;
 	}
 
 	if (priv->state != CAIF_CONNECTED) {
 		pr_debug("CAIF: %s(): connect failed\n", __func__);
-		return -ECONNREFUSED;
+		result = -ECONNREFUSED;
+		goto error;
 	}
 	pr_debug("CAIF: %s(): CAIF Netdevice connected\n", __func__);
 	return 0;
+
+error:
+	caif_disconnect_client(&priv->chnl);
+	priv->state = CAIF_DISCONNECTED;
+	pr_debug("CAIF: %s(): state disconnected\n", __func__);
+	return result;
+
 }
 
 static int chnl_net_stop(struct net_device *dev)
@@ -321,9 +370,7 @@ static void ipcaif_net_setup(struct net_device *dev)
 	dev->destructor = free_netdev;
 	dev->flags |= IFF_NOARP;
 	dev->flags |= IFF_POINTOPOINT;
-	dev->needed_headroom = CAIF_NEEDED_HEADROOM;
-	dev->needed_tailroom = CAIF_NEEDED_TAILROOM;
-	dev->mtu = SIZE_MTU;
+	dev->mtu = GPRS_PDP_MTU;
 	dev->tx_queue_len = CAIF_NET_DEFAULT_QUEUE_LEN;
 
 	priv = netdev_priv(dev);
-- 
1.6.3.3

