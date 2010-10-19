From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC net-next] caif: code cleanup
Date: Tue, 19 Oct 2010 09:55:53 -0700
Message-ID: <20101019095553.0b413b80@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56777 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756384Ab0JSQz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 12:55:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup of new CAIF code.
  * make local functions static
  * remove code that is never used
  * expand get_caif_conf() since wrapper is no longer needed
  * make args to comparison functions const 
  * rename connect_req_to_link_param to keep exported names
    consistent

Compile tested only.
  
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/caif/caif_dev.h |   27 +-----
 include/net/caif/cfctrl.h   |   12 --
 include/net/caif/cfmuxl.h   |    2 
 include/net/caif/cfpkt.h    |   75 ------------------
 include/net/caif/cfsrvl.h   |    3 
 net/caif/caif_config_util.c |    6 -
 net/caif/caif_dev.c         |   24 +----
 net/caif/cfcnfg.c           |    2 
 net/caif/cfctrl.c           |   74 +-----------------
 net/caif/cfmuxl.c           |   35 --------
 net/caif/cfpkt_skbuff.c     |  178 +-------------------------------------------
 net/caif/cfsrvl.c           |    7 -
 12 files changed, 29 insertions(+), 416 deletions(-)

--- a/include/net/caif/caif_dev.h	2010-10-19 09:25:53.581751379 -0700
+++ b/include/net/caif/caif_dev.h	2010-10-19 09:53:00.077792212 -0700
@@ -74,19 +74,8 @@ int caif_connect_client(struct caif_conn
 int caif_disconnect_client(struct cflayer *client_layer);
 
 /**
- * caif_release_client - Release adaptation layer reference to client.
- *
- * @client_layer: Client layer.
- *
- * Releases a client/adaptation layer use of the caif stack.
- * This function must be used after caif_disconnect_client to
- * decrease the reference count of the service layer.
- */
-void caif_release_client(struct cflayer *client_layer);
-
-/**
- * connect_req_to_link_param - Translate configuration parameters
- *				from socket format to internal format.
+ * caif_connect_req_to_link_param - Translate configuration parameters
+ *				    from socket format to internal format.
  * @cnfg:	Pointer to configuration handler
  * @con_req:	Configuration parameters supplied in function
  *		caif_connect_client
@@ -94,14 +83,8 @@ void caif_release_client(struct cflayer
  *			 setting up channels.
  *
  */
-int connect_req_to_link_param(struct cfcnfg *cnfg,
-				struct caif_connect_request *con_req,
-				struct cfctrl_link_param *channel_setup_param);
-
-/**
- * get_caif_conf() - Get the configuration handler.
- */
-struct cfcnfg *get_caif_conf(void);
-
+int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
+				   struct caif_connect_request *con_req,
+				   struct cfctrl_link_param *channel_setup_param);
 
 #endif /* CAIF_DEV_H_ */
--- a/include/net/caif/cfctrl.h	2010-10-19 09:25:53.709764168 -0700
+++ b/include/net/caif/cfctrl.h	2010-10-19 09:39:11.361244959 -0700
@@ -121,19 +121,9 @@ int cfctrl_linkup_request(struct cflayer
 			   struct cflayer *user_layer);
 int  cfctrl_linkdown_req(struct cflayer *cfctrl, u8 linkid,
 			 struct cflayer *client);
-void cfctrl_sleep_req(struct cflayer *cfctrl);
-void cfctrl_wake_req(struct cflayer *cfctrl);
-void cfctrl_getstartreason_req(struct cflayer *cfctrl);
+
 struct cflayer *cfctrl_create(void);
-void cfctrl_set_dnlayer(struct cflayer *this, struct cflayer *dn);
-void cfctrl_set_uplayer(struct cflayer *this, struct cflayer *up);
 struct cfctrl_rsp *cfctrl_get_respfuncs(struct cflayer *layer);
-bool cfctrl_req_eq(struct cfctrl_request_info *r1,
-		   struct cfctrl_request_info *r2);
-void cfctrl_insert_req(struct cfctrl *ctrl,
-			      struct cfctrl_request_info *req);
-struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
-					      struct cfctrl_request_info *req);
 void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_layer);
 
 #endif				/* CFCTRL_H_ */
--- a/include/net/caif/cfpkt.h	2010-10-19 09:25:53.785771759 -0700
+++ b/include/net/caif/cfpkt.h	2010-10-19 09:37:32.651429118 -0700
@@ -16,12 +16,6 @@ struct cfpkt;
  */
 struct cfpkt *cfpkt_create(u16 len);
 
-/* Create a CAIF packet.
- * data Data to copy.
- * len Length of packet to be created
- * @return New packet.
- */
-struct cfpkt *cfpkt_create_uplink(const unsigned char *data, unsigned int len);
 /*
  * Destroy a CAIF Packet.
  * pkt Packet to be destoyed.
@@ -181,22 +175,6 @@ u16 cfpkt_iterate(struct cfpkt *pkt,
 		u16 (*iter_func)(u16 chks, void *buf, u16 len),
 		u16 data);
 
-/* Append by giving user access to packet buffer
- * cfpkt Packet to append to
- * buf Buffer inside pkt that user shall copy data into
- * buflen Length of buffer and number of bytes added to packet
- * @return 0 on error, 1 on success
- */
-int cfpkt_raw_append(struct cfpkt *cfpkt, void **buf, unsigned int buflen);
-
-/* Extract by giving user access to packet buffer
- * cfpkt Packet to extract from
- * buf Buffer inside pkt that user shall copy data from
- * buflen Length of buffer and number of bytes removed from packet
- * @return 0 on error, 1 on success
- */
-int cfpkt_raw_extract(struct cfpkt *cfpkt, void **buf, unsigned int buflen);
-
 /* Map from a "native" packet (e.g. Linux Socket Buffer) to a CAIF packet.
  *  dir - Direction indicating whether this packet is to be sent or received.
  *  nativepkt  - The native packet to be transformed to a CAIF packet
@@ -210,59 +188,6 @@ struct cfpkt *cfpkt_fromnative(enum caif
  */
 void *cfpkt_tonative(struct cfpkt *pkt);
 
-/*
- * Insert a packet in the packet queue.
- * pktq Packet queue to insert into
- * pkt Packet to be inserted in queue
- * prio Priority of packet
- */
-void cfpkt_queue(struct cfpktq *pktq, struct cfpkt *pkt,
-		 unsigned short prio);
-
-/*
- * Remove a packet from the packet queue.
- * pktq Packet queue to fetch packets from.
- * @return Dequeued packet.
- */
-struct cfpkt *cfpkt_dequeue(struct cfpktq *pktq);
-
-/*
- * Peek into a packet from the packet queue.
- * pktq Packet queue to fetch packets from.
- * @return Peeked packet.
- */
-struct cfpkt *cfpkt_qpeek(struct cfpktq *pktq);
-
-/*
- * Initiates the packet queue.
- * @return Pointer to new packet queue.
- */
-struct cfpktq *cfpktq_create(void);
-
-/*
- * Get the number of packets in the queue.
- * pktq Packet queue to fetch count from.
- * @return Number of packets in queue.
- */
-int cfpkt_qcount(struct cfpktq *pktq);
-
-/*
- * Put content of packet into buffer for debuging purposes.
- * pkt Packet to copy data from
- * buf Buffer to copy data into
- * buflen Length of data to copy
- * @return Pointer to copied data
- */
-char *cfpkt_log_pkt(struct cfpkt *pkt, char *buf, int buflen);
-
-/*
- * Clones a packet and releases the original packet.
- * This is used for taking ownership of a packet e.g queueing.
- * pkt Packet to clone and release.
- * @return Cloned packet.
- */
-struct cfpkt *cfpkt_clone_release(struct cfpkt *pkt);
-
 
 /*
  * Returns packet information for a packet.
--- a/net/caif/caif_dev.c	2010-10-19 09:26:08.959287331 -0700
+++ b/net/caif/caif_dev.c	2010-10-19 09:53:28.508446823 -0700
@@ -257,7 +257,7 @@ static int caif_device_notify(struct not
 			break;
 		}
 		dev_hold(dev);
-		cfcnfg_add_phy_layer(get_caif_conf(),
+		cfcnfg_add_phy_layer(cfg,
 				     phy_type,
 				     dev,
 				     &caifd->layer,
@@ -300,7 +300,7 @@ static int caif_device_notify(struct not
 		if (atomic_read(&caifd->in_use))
 			netdev_warn(dev,
 				    "Unregistering an active CAIF device\n");
-		cfcnfg_del_phy_layer(get_caif_conf(), &caifd->layer);
+		cfcnfg_del_phy_layer(cfg, &caifd->layer);
 		dev_put(dev);
 		atomic_set(&caifd->state, what);
 		break;
@@ -320,24 +320,18 @@ static struct notifier_block caif_device
 	.priority = 0,
 };
 
-
-struct cfcnfg *get_caif_conf(void)
-{
-	return cfg;
-}
-EXPORT_SYMBOL(get_caif_conf);
-
 int caif_connect_client(struct caif_connect_request *conn_req,
 			struct cflayer *client_layer, int *ifindex,
 			int *headroom, int *tailroom)
 {
 	struct cfctrl_link_param param;
 	int ret;
-	ret = connect_req_to_link_param(get_caif_conf(), conn_req, &param);
+
+	ret = caif_connect_req_to_link_param(cfg, conn_req, &param);
 	if (ret)
 		return ret;
 	/* Hook up the adaptation layer. */
-	return cfcnfg_add_adaptation_layer(get_caif_conf(), &param,
+	return cfcnfg_add_adaptation_layer(cfg, &param,
 					client_layer, ifindex,
 					headroom, tailroom);
 }
@@ -345,16 +339,10 @@ EXPORT_SYMBOL(caif_connect_client);
 
 int caif_disconnect_client(struct cflayer *adap_layer)
 {
-       return cfcnfg_disconn_adapt_layer(get_caif_conf(), adap_layer);
+       return cfcnfg_disconn_adapt_layer(cfg, adap_layer);
 }
 EXPORT_SYMBOL(caif_disconnect_client);
 
-void caif_release_client(struct cflayer *adap_layer)
-{
-       cfcnfg_release_adap_layer(adap_layer);
-}
-EXPORT_SYMBOL(caif_release_client);
-
 /* Per-namespace Caif devices handling */
 static int caif_init_net(struct net *net)
 {
--- a/net/caif/cfcnfg.c	2010-10-19 09:24:41.354535051 -0700
+++ b/net/caif/cfcnfg.c	2010-10-19 09:25:17.390135851 -0700
@@ -257,7 +257,7 @@ static void cfcnfg_linkdestroy_rsp(struc
 {
 }
 
-int protohead[CFCTRL_SRV_MASK] = {
+static const int protohead[CFCTRL_SRV_MASK] = {
 	[CFCTRL_SRV_VEI] = 4,
 	[CFCTRL_SRV_DATAGRAM] = 7,
 	[CFCTRL_SRV_UTIL] = 4,
--- a/net/caif/cfctrl.c	2010-10-19 09:29:11.169475442 -0700
+++ b/net/caif/cfctrl.c	2010-10-19 09:40:24.472511862 -0700
@@ -58,7 +58,7 @@ struct cflayer *cfctrl_create(void)
 	return &this->serv.layer;
 }
 
-static bool param_eq(struct cfctrl_link_param *p1, struct cfctrl_link_param *p2)
+static bool param_eq(const struct cfctrl_link_param *p1, const struct cfctrl_link_param *p2)
 {
 	bool eq =
 	    p1->linktype == p2->linktype &&
@@ -100,8 +100,8 @@ static bool param_eq(struct cfctrl_link_
 	return false;
 }
 
-bool cfctrl_req_eq(struct cfctrl_request_info *r1,
-		   struct cfctrl_request_info *r2)
+static bool cfctrl_req_eq(const struct cfctrl_request_info *r1,
+			  const struct cfctrl_request_info *r2)
 {
 	if (r1->cmd != r2->cmd)
 		return false;
@@ -112,7 +112,7 @@ bool cfctrl_req_eq(struct cfctrl_request
 }
 
 /* Insert request at the end */
-void cfctrl_insert_req(struct cfctrl *ctrl,
+static void cfctrl_insert_req(struct cfctrl *ctrl,
 			      struct cfctrl_request_info *req)
 {
 	spin_lock(&ctrl->info_list_lock);
@@ -123,8 +123,8 @@ void cfctrl_insert_req(struct cfctrl *ct
 }
 
 /* Compare and remove request */
-struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
-					      struct cfctrl_request_info *req)
+static struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
+						     struct cfctrl_request_info *req)
 {
 	struct cfctrl_request_info *p, *tmp, *first;
 
@@ -154,16 +154,6 @@ struct cfctrl_rsp *cfctrl_get_respfuncs(
 	return &this->res;
 }
 
-void cfctrl_set_dnlayer(struct cflayer *this, struct cflayer *dn)
-{
-	this->dn = dn;
-}
-
-void cfctrl_set_uplayer(struct cflayer *this, struct cflayer *up)
-{
-	this->up = up;
-}
-
 static void init_info(struct caif_payload_info *info, struct cfctrl *cfctrl)
 {
 	info->hdr_len = 0;
@@ -304,58 +294,6 @@ int cfctrl_linkdown_req(struct cflayer *
 	return ret;
 }
 
-void cfctrl_sleep_req(struct cflayer *layer)
-{
-	int ret;
-	struct cfctrl *cfctrl = container_obj(layer);
-	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
-	if (!pkt) {
-		pr_warn("Out of memory\n");
-		return;
-	}
-	cfpkt_addbdy(pkt, CFCTRL_CMD_SLEEP);
-	init_info(cfpkt_info(pkt), cfctrl);
-	ret =
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
-	if (ret < 0)
-		cfpkt_destroy(pkt);
-}
-
-void cfctrl_wake_req(struct cflayer *layer)
-{
-	int ret;
-	struct cfctrl *cfctrl = container_obj(layer);
-	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
-	if (!pkt) {
-		pr_warn("Out of memory\n");
-		return;
-	}
-	cfpkt_addbdy(pkt, CFCTRL_CMD_WAKE);
-	init_info(cfpkt_info(pkt), cfctrl);
-	ret =
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
-	if (ret < 0)
-		cfpkt_destroy(pkt);
-}
-
-void cfctrl_getstartreason_req(struct cflayer *layer)
-{
-	int ret;
-	struct cfctrl *cfctrl = container_obj(layer);
-	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
-	if (!pkt) {
-		pr_warn("Out of memory\n");
-		return;
-	}
-	cfpkt_addbdy(pkt, CFCTRL_CMD_START_REASON);
-	init_info(cfpkt_info(pkt), cfctrl);
-	ret =
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
-	if (ret < 0)
-		cfpkt_destroy(pkt);
-}
-
-
 void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_layer)
 {
 	struct cfctrl_request_info *p, *tmp;
--- a/net/caif/cfmuxl.c	2010-10-19 09:30:45.802913489 -0700
+++ b/net/caif/cfmuxl.c	2010-10-19 09:40:33.573416250 -0700
@@ -71,41 +71,6 @@ int cfmuxl_set_uplayer(struct cflayer *l
 	return 0;
 }
 
-bool cfmuxl_is_phy_inuse(struct cflayer *layr, u8 phyid)
-{
-	struct list_head *node;
-	struct cflayer *layer;
-	struct cfmuxl *muxl = container_obj(layr);
-	bool match = false;
-	spin_lock(&muxl->receive_lock);
-
-	list_for_each(node, &muxl->srvl_list) {
-		layer = list_entry(node, struct cflayer, node);
-		if (cfsrvl_phyid_match(layer, phyid)) {
-			match = true;
-			break;
-		}
-
-	}
-	spin_unlock(&muxl->receive_lock);
-	return match;
-}
-
-u8 cfmuxl_get_phyid(struct cflayer *layr, u8 channel_id)
-{
-	struct cflayer *up;
-	int phyid;
-	struct cfmuxl *muxl = container_obj(layr);
-	spin_lock(&muxl->receive_lock);
-	up = get_up(muxl, channel_id);
-	if (up != NULL)
-		phyid = cfsrvl_getphyid(up);
-	else
-		phyid = 0;
-	spin_unlock(&muxl->receive_lock);
-	return phyid;
-}
-
 int cfmuxl_set_dnlayer(struct cflayer *layr, struct cflayer *dn, u8 phyid)
 {
 	struct cfmuxl *muxl = (struct cfmuxl *) layr;
--- a/net/caif/cfpkt_skbuff.c	2010-10-19 09:31:38.804197063 -0700
+++ b/net/caif/cfpkt_skbuff.c	2010-10-19 09:42:03.710371120 -0700
@@ -42,22 +42,22 @@ struct cfpkt_priv_data {
 	bool erronous;
 };
 
-inline struct cfpkt_priv_data *cfpkt_priv(struct cfpkt *pkt)
+static inline struct cfpkt_priv_data *cfpkt_priv(struct cfpkt *pkt)
 {
 	return (struct cfpkt_priv_data *) pkt->skb.cb;
 }
 
-inline bool is_erronous(struct cfpkt *pkt)
+static inline bool is_erronous(struct cfpkt *pkt)
 {
 	return cfpkt_priv(pkt)->erronous;
 }
 
-inline struct sk_buff *pkt_to_skb(struct cfpkt *pkt)
+static inline struct sk_buff *pkt_to_skb(struct cfpkt *pkt)
 {
 	return &pkt->skb;
 }
 
-inline struct cfpkt *skb_to_pkt(struct sk_buff *skb)
+static inline struct cfpkt *skb_to_pkt(struct sk_buff *skb)
 {
 	return (struct cfpkt *) skb;
 }
@@ -317,17 +317,6 @@ int cfpkt_setlen(struct cfpkt *pkt, u16
 }
 EXPORT_SYMBOL(cfpkt_setlen);
 
-struct cfpkt *cfpkt_create_uplink(const unsigned char *data, unsigned int len)
-{
-	struct cfpkt *pkt = cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
-	if (!pkt)
-		return NULL;
-	if (unlikely(data != NULL))
-		cfpkt_add_body(pkt, data, len);
-	return pkt;
-}
-EXPORT_SYMBOL(cfpkt_create_uplink);
-
 struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
 			     struct cfpkt *addpkt,
 			     u16 expectlen)
@@ -408,169 +397,12 @@ struct cfpkt *cfpkt_split(struct cfpkt *
 }
 EXPORT_SYMBOL(cfpkt_split);
 
-char *cfpkt_log_pkt(struct cfpkt *pkt, char *buf, int buflen)
-{
-	struct sk_buff *skb = pkt_to_skb(pkt);
-	char *p = buf;
-	int i;
-
-	/*
-	 * Sanity check buffer length, it needs to be at least as large as
-	 * the header info: ~=50+ bytes
-	 */
-	if (buflen < 50)
-		return NULL;
-
-	snprintf(buf, buflen, "%s: pkt:%p len:%ld(%ld+%ld) {%ld,%ld} data: [",
-		is_erronous(pkt) ? "ERRONOUS-SKB" :
-		 (skb->data_len != 0 ? "COMPLEX-SKB" : "SKB"),
-		 skb,
-		 (long) skb->len,
-		 (long) (skb_tail_pointer(skb) - skb->data),
-		 (long) skb->data_len,
-		 (long) (skb->data - skb->head),
-		 (long) (skb_tail_pointer(skb) - skb->head));
-	p = buf + strlen(buf);
-
-	for (i = 0; i < skb_tail_pointer(skb) - skb->data && i < 300; i++) {
-		if (p > buf + buflen - 10) {
-			sprintf(p, "...");
-			p = buf + strlen(buf);
-			break;
-		}
-		sprintf(p, "%02x,", skb->data[i]);
-		p = buf + strlen(buf);
-	}
-	sprintf(p, "]\n");
-	return buf;
-}
-EXPORT_SYMBOL(cfpkt_log_pkt);
-
-int cfpkt_raw_append(struct cfpkt *pkt, void **buf, unsigned int buflen)
-{
-	struct sk_buff *skb = pkt_to_skb(pkt);
-	struct sk_buff *lastskb;
-
-	caif_assert(buf != NULL);
-	if (unlikely(is_erronous(pkt)))
-		return -EPROTO;
-	/* Make sure SKB is writable */
-	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
-		PKT_ERROR(pkt, "skb_cow_data failed\n");
-		return -EPROTO;
-	}
-
-	if (unlikely(skb_linearize(skb) != 0)) {
-		PKT_ERROR(pkt, "linearize failed\n");
-		return -EPROTO;
-	}
-
-	if (unlikely(skb_tailroom(skb) < buflen)) {
-		PKT_ERROR(pkt, "buffer too short - failed\n");
-		return -EPROTO;
-	}
-
-	*buf = skb_put(skb, buflen);
-	return 1;
-}
-EXPORT_SYMBOL(cfpkt_raw_append);
-
-int cfpkt_raw_extract(struct cfpkt *pkt, void **buf, unsigned int buflen)
-{
-	struct sk_buff *skb = pkt_to_skb(pkt);
-
-	caif_assert(buf != NULL);
-	if (unlikely(is_erronous(pkt)))
-		return -EPROTO;
-
-	if (unlikely(buflen > skb->len)) {
-		PKT_ERROR(pkt, "buflen too large - failed\n");
-		return -EPROTO;
-	}
-
-	if (unlikely(buflen > skb_headlen(skb))) {
-		if (unlikely(skb_linearize(skb) != 0)) {
-			PKT_ERROR(pkt, "linearize failed\n");
-			return -EPROTO;
-		}
-	}
-
-	*buf = skb->data;
-	skb_pull(skb, buflen);
-
-	return 1;
-}
-EXPORT_SYMBOL(cfpkt_raw_extract);
-
-inline bool cfpkt_erroneous(struct cfpkt *pkt)
+bool cfpkt_erroneous(struct cfpkt *pkt)
 {
 	return cfpkt_priv(pkt)->erronous;
 }
 EXPORT_SYMBOL(cfpkt_erroneous);
 
-struct cfpktq *cfpktq_create(void)
-{
-	struct cfpktq *q = kmalloc(sizeof(struct cfpktq), GFP_ATOMIC);
-	if (!q)
-		return NULL;
-	skb_queue_head_init(&q->head);
-	atomic_set(&q->count, 0);
-	spin_lock_init(&q->lock);
-	return q;
-}
-EXPORT_SYMBOL(cfpktq_create);
-
-void cfpkt_queue(struct cfpktq *pktq, struct cfpkt *pkt, unsigned short prio)
-{
-	atomic_inc(&pktq->count);
-	spin_lock(&pktq->lock);
-	skb_queue_tail(&pktq->head, pkt_to_skb(pkt));
-	spin_unlock(&pktq->lock);
-
-}
-EXPORT_SYMBOL(cfpkt_queue);
-
-struct cfpkt *cfpkt_qpeek(struct cfpktq *pktq)
-{
-	struct cfpkt *tmp;
-	spin_lock(&pktq->lock);
-	tmp = skb_to_pkt(skb_peek(&pktq->head));
-	spin_unlock(&pktq->lock);
-	return tmp;
-}
-EXPORT_SYMBOL(cfpkt_qpeek);
-
-struct cfpkt *cfpkt_dequeue(struct cfpktq *pktq)
-{
-	struct cfpkt *pkt;
-	spin_lock(&pktq->lock);
-	pkt = skb_to_pkt(skb_dequeue(&pktq->head));
-	if (pkt) {
-		atomic_dec(&pktq->count);
-		caif_assert(atomic_read(&pktq->count) >= 0);
-	}
-	spin_unlock(&pktq->lock);
-	return pkt;
-}
-EXPORT_SYMBOL(cfpkt_dequeue);
-
-int cfpkt_qcount(struct cfpktq *pktq)
-{
-	return atomic_read(&pktq->count);
-}
-EXPORT_SYMBOL(cfpkt_qcount);
-
-struct cfpkt *cfpkt_clone_release(struct cfpkt *pkt)
-{
-	struct cfpkt *clone;
-	clone  = skb_to_pkt(skb_clone(pkt_to_skb(pkt), GFP_ATOMIC));
-	/* Free original packet. */
-	cfpkt_destroy(pkt);
-	if (!clone)
-		return NULL;
-	return clone;
-}
-EXPORT_SYMBOL(cfpkt_clone_release);
 
 struct caif_payload_info *cfpkt_info(struct cfpkt *pkt)
 {
--- a/net/caif/cfsrvl.c	2010-10-19 09:38:07.842929217 -0700
+++ b/net/caif/cfsrvl.c	2010-10-19 09:40:31.817241735 -0700
@@ -151,12 +151,7 @@ static int cfservl_modemcmd(struct cflay
 	return -EINVAL;
 }
 
-void cfservl_destroy(struct cflayer *layer)
-{
-	kfree(layer);
-}
-
-void cfsrvl_release(struct kref *kref)
+static void cfsrvl_release(struct kref *kref)
 {
 	struct cfsrvl *service = container_of(kref, struct cfsrvl, ref);
 	kfree(service);
--- a/include/net/caif/cfmuxl.h	2010-10-19 09:25:53.761769361 -0700
+++ b/include/net/caif/cfmuxl.h	2010-10-19 09:39:23.178419722 -0700
@@ -16,7 +16,5 @@ int cfmuxl_set_uplayer(struct cflayer *l
 struct cflayer *cfmuxl_remove_dnlayer(struct cflayer *layr, u8 phyid);
 int cfmuxl_set_dnlayer(struct cflayer *layr, struct cflayer *up, u8 phyid);
 struct cflayer *cfmuxl_remove_uplayer(struct cflayer *layr, u8 linkid);
-bool cfmuxl_is_phy_inuse(struct cflayer *layr, u8 phyid);
-u8 cfmuxl_get_phyid(struct cflayer *layr, u8 channel_id);
 
 #endif				/* CFMUXL_H_ */
--- a/include/net/caif/cfsrvl.h	2010-10-19 09:25:53.837776953 -0700
+++ b/include/net/caif/cfsrvl.h	2010-10-19 09:39:21.410243950 -0700
@@ -22,7 +22,6 @@ struct cfsrvl {
 	struct kref ref;
 };
 
-void cfsrvl_release(struct kref *kref);
 struct cflayer *cfvei_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfdgml_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfutill_create(u8 linkid, struct dev_info *dev_info);
@@ -31,7 +30,7 @@ struct cflayer *cfrfml_create(u8 linkid,
 				int mtu_size);
 struct cflayer *cfdbgl_create(u8 linkid, struct dev_info *dev_info);
 bool cfsrvl_phyid_match(struct cflayer *layer, int phyid);
-void cfservl_destroy(struct cflayer *layer);
+
 void cfsrvl_init(struct cfsrvl *service,
 			u8 channel_id,
 			struct dev_info *dev_info,
--- a/net/caif/caif_config_util.c	2010-10-19 09:53:45.182003880 -0700
+++ b/net/caif/caif_config_util.c	2010-10-19 09:53:58.887283867 -0700
@@ -10,9 +10,9 @@
 #include <net/caif/cfcnfg.h>
 #include <net/caif/caif_dev.h>
 
-int connect_req_to_link_param(struct cfcnfg *cnfg,
-				struct caif_connect_request *s,
-				struct cfctrl_link_param *l)
+int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
+				   struct caif_connect_request *s,
+				   struct cfctrl_link_param *l)
 {
 	struct dev_info *dev_info;
 	enum cfcnfg_phy_preference pref;
