From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2-6 1/3] caif: code cleanup
Date: Mon, 11 Apr 2011 22:43:50 +0200
Message-ID: <1302554632-13638-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1302554632-13638-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	sjurbren@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:46879 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab1DKUoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:44:37 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI00ABN9LYVC00@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:44:22 +0200 (CEST)
Received: from localhost.localdomain ([80.203.137.187])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI0082H9LXJMZ0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:44:22 +0200 (CEST)
In-reply-to: <1302554632-13638-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <shemminger@vyatta.com>

Cleanup of new CAIF code.
  * make local functions static
  * remove code that is never used
  * expand get_caif_conf() since wrapper is no longer needed
  * make args to comparison functions const
  * rename connect_req_to_link_param to keep exported names
    consistent

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
Hi Stephen,

Thank you for the RFC you sent me long time ago. It's been hanging arou=
nd
for too long, but I'm submitting it now together with other=20
code cleanups. Hope this is OK by you.

Regards,
Sjur

 include/net/caif/caif_dev.h |   27 +-----
 include/net/caif/cfctrl.h   |   12 +---
 include/net/caif/cfmuxl.h   |    2 -
 include/net/caif/cfpkt.h    |   75 ------------------
 include/net/caif/cfsrvl.h   |    3 +-
 net/caif/caif_config_util.c |    6 +-
 net/caif/caif_dev.c         |   24 ++-----
 net/caif/cfcnfg.c           |    2 +-
 net/caif/cfctrl.c           |   75 ++----------------
 net/caif/cfmuxl.c           |   35 ---------
 net/caif/cfpkt_skbuff.c     |  178 +----------------------------------=
-------
 net/caif/cfsrvl.c           |    7 +--
 12 files changed, 30 insertions(+), 416 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index 8eff83b..7e3f7a6 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -74,19 +74,8 @@ int caif_connect_client(struct caif_connect_request =
*conn_req,
 int caif_disconnect_client(struct cflayer *client_layer);
=20
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
@@ -94,14 +83,8 @@ void caif_release_client(struct cflayer *client_laye=
r);
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
+				   struct cfctrl_link_param *setup_param);
=20
 #endif /* CAIF_DEV_H_ */
diff --git a/include/net/caif/cfctrl.h b/include/net/caif/cfctrl.h
index e54f639..d84416f 100644
--- a/include/net/caif/cfctrl.h
+++ b/include/net/caif/cfctrl.h
@@ -121,19 +121,9 @@ int cfctrl_linkup_request(struct cflayer *cfctrl,
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
 void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_laye=
r);
=20
 #endif				/* CFCTRL_H_ */
diff --git a/include/net/caif/cfmuxl.h b/include/net/caif/cfmuxl.h
index 4e1b4f3..5847a19 100644
--- a/include/net/caif/cfmuxl.h
+++ b/include/net/caif/cfmuxl.h
@@ -16,7 +16,5 @@ int cfmuxl_set_uplayer(struct cflayer *layr, struct c=
flayer *up, u8 linkid);
 struct cflayer *cfmuxl_remove_dnlayer(struct cflayer *layr, u8 phyid);
 int cfmuxl_set_dnlayer(struct cflayer *layr, struct cflayer *up, u8 ph=
yid);
 struct cflayer *cfmuxl_remove_uplayer(struct cflayer *layr, u8 linkid)=
;
-bool cfmuxl_is_phy_inuse(struct cflayer *layr, u8 phyid);
-u8 cfmuxl_get_phyid(struct cflayer *layr, u8 channel_id);
=20
 #endif				/* CFMUXL_H_ */
diff --git a/include/net/caif/cfpkt.h b/include/net/caif/cfpkt.h
index fbc681b..8b550f8 100644
--- a/include/net/caif/cfpkt.h
+++ b/include/net/caif/cfpkt.h
@@ -16,12 +16,6 @@ struct cfpkt;
  */
 struct cfpkt *cfpkt_create(u16 len);
=20
-/* Create a CAIF packet.
- * data Data to copy.
- * len Length of packet to be created
- * @return New packet.
- */
-struct cfpkt *cfpkt_create_uplink(const unsigned char *data, unsigned =
int len);
 /*
  * Destroy a CAIF Packet.
  * pkt Packet to be destoyed.
@@ -181,22 +175,6 @@ u16 cfpkt_iterate(struct cfpkt *pkt,
 		u16 (*iter_func)(u16 chks, void *buf, u16 len),
 		u16 data);
=20
-/* Append by giving user access to packet buffer
- * cfpkt Packet to append to
- * buf Buffer inside pkt that user shall copy data into
- * buflen Length of buffer and number of bytes added to packet
- * @return 0 on error, 1 on success
- */
-int cfpkt_raw_append(struct cfpkt *cfpkt, void **buf, unsigned int buf=
len);
-
-/* Extract by giving user access to packet buffer
- * cfpkt Packet to extract from
- * buf Buffer inside pkt that user shall copy data from
- * buflen Length of buffer and number of bytes removed from packet
- * @return 0 on error, 1 on success
- */
-int cfpkt_raw_extract(struct cfpkt *cfpkt, void **buf, unsigned int bu=
flen);
-
 /* Map from a "native" packet (e.g. Linux Socket Buffer) to a CAIF pac=
ket.
  *  dir - Direction indicating whether this packet is to be sent or re=
ceived.
  *  nativepkt  - The native packet to be transformed to a CAIF packet
@@ -210,59 +188,6 @@ struct cfpkt *cfpkt_fromnative(enum caif_direction=
 dir, void *nativepkt);
  */
 void *cfpkt_tonative(struct cfpkt *pkt);
=20
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
=20
 /*
  * Returns packet information for a packet.
diff --git a/include/net/caif/cfsrvl.h b/include/net/caif/cfsrvl.h
index b1fa87e..6c8279c 100644
--- a/include/net/caif/cfsrvl.h
+++ b/include/net/caif/cfsrvl.h
@@ -22,7 +22,6 @@ struct cfsrvl {
 	struct kref ref;
 };
=20
-void cfsrvl_release(struct kref *kref);
 struct cflayer *cfvei_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfdgml_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfutill_create(u8 linkid, struct dev_info *dev_info);
@@ -31,7 +30,7 @@ struct cflayer *cfrfml_create(u8 linkid, struct dev_i=
nfo *dev_info,
 				int mtu_size);
 struct cflayer *cfdbgl_create(u8 linkid, struct dev_info *dev_info);
 bool cfsrvl_phyid_match(struct cflayer *layer, int phyid);
-void cfservl_destroy(struct cflayer *layer);
+
 void cfsrvl_init(struct cfsrvl *service,
 			u8 channel_id,
 			struct dev_info *dev_info,
diff --git a/net/caif/caif_config_util.c b/net/caif/caif_config_util.c
index d522d8c..9b63e4e 100644
--- a/net/caif/caif_config_util.c
+++ b/net/caif/caif_config_util.c
@@ -10,9 +10,9 @@
 #include <net/caif/cfcnfg.h>
 #include <net/caif/caif_dev.h>
=20
-int connect_req_to_link_param(struct cfcnfg *cnfg,
-				struct caif_connect_request *s,
-				struct cfctrl_link_param *l)
+int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
+				   struct caif_connect_request *s,
+				   struct cfctrl_link_param *l)
 {
 	struct dev_info *dev_info;
 	enum cfcnfg_phy_preference pref;
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index a42a408..b533bb0 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -257,7 +257,7 @@ static int caif_device_notify(struct notifier_block=
 *me, unsigned long what,
 			break;
 		}
 		dev_hold(dev);
-		cfcnfg_add_phy_layer(get_caif_conf(),
+		cfcnfg_add_phy_layer(cfg,
 				     phy_type,
 				     dev,
 				     &caifd->layer,
@@ -300,7 +300,7 @@ static int caif_device_notify(struct notifier_block=
 *me, unsigned long what,
 		if (atomic_read(&caifd->in_use))
 			netdev_warn(dev,
 				    "Unregistering an active CAIF device\n");
-		cfcnfg_del_phy_layer(get_caif_conf(), &caifd->layer);
+		cfcnfg_del_phy_layer(cfg, &caifd->layer);
 		dev_put(dev);
 		atomic_set(&caifd->state, what);
 		break;
@@ -322,24 +322,18 @@ static struct notifier_block caif_device_notifier=
 =3D {
 	.priority =3D 0,
 };
=20
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
-	ret =3D connect_req_to_link_param(get_caif_conf(), conn_req, &param);
+
+	ret =3D caif_connect_req_to_link_param(cfg, conn_req, &param);
 	if (ret)
 		return ret;
 	/* Hook up the adaptation layer. */
-	return cfcnfg_add_adaptation_layer(get_caif_conf(), &param,
+	return cfcnfg_add_adaptation_layer(cfg, &param,
 					client_layer, ifindex,
 					headroom, tailroom);
 }
@@ -347,16 +341,10 @@ EXPORT_SYMBOL(caif_connect_client);
=20
 int caif_disconnect_client(struct cflayer *adap_layer)
 {
-       return cfcnfg_disconn_adapt_layer(get_caif_conf(), adap_layer);
+	return cfcnfg_disconn_adapt_layer(cfg, adap_layer);
 }
 EXPORT_SYMBOL(caif_disconnect_client);
=20
-void caif_release_client(struct cflayer *adap_layer)
-{
-       cfcnfg_release_adap_layer(adap_layer);
-}
-EXPORT_SYMBOL(caif_release_client);
-
 /* Per-namespace Caif devices handling */
 static int caif_init_net(struct net *net)
 {
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index f1f98d9..25c0b19 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -253,7 +253,7 @@ static void cfcnfg_linkdestroy_rsp(struct cflayer *=
layer, u8 channel_id)
 {
 }
=20
-int protohead[CFCTRL_SRV_MASK] =3D {
+static const int protohead[CFCTRL_SRV_MASK] =3D {
 	[CFCTRL_SRV_VEI] =3D 4,
 	[CFCTRL_SRV_DATAGRAM] =3D 7,
 	[CFCTRL_SRV_UTIL] =3D 4,
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 3cd8f97..397a2c0 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -58,7 +58,8 @@ struct cflayer *cfctrl_create(void)
 	return &this->serv.layer;
 }
=20
-static bool param_eq(struct cfctrl_link_param *p1, struct cfctrl_link_=
param *p2)
+static bool param_eq(const struct cfctrl_link_param *p1,
+			const struct cfctrl_link_param *p2)
 {
 	bool eq =3D
 	    p1->linktype =3D=3D p2->linktype &&
@@ -100,8 +101,8 @@ static bool param_eq(struct cfctrl_link_param *p1, =
struct cfctrl_link_param *p2)
 	return false;
 }
=20
-bool cfctrl_req_eq(struct cfctrl_request_info *r1,
-		   struct cfctrl_request_info *r2)
+static bool cfctrl_req_eq(const struct cfctrl_request_info *r1,
+			  const struct cfctrl_request_info *r2)
 {
 	if (r1->cmd !=3D r2->cmd)
 		return false;
@@ -112,7 +113,7 @@ bool cfctrl_req_eq(struct cfctrl_request_info *r1,
 }
=20
 /* Insert request at the end */
-void cfctrl_insert_req(struct cfctrl *ctrl,
+static void cfctrl_insert_req(struct cfctrl *ctrl,
 			      struct cfctrl_request_info *req)
 {
 	spin_lock(&ctrl->info_list_lock);
@@ -123,8 +124,8 @@ void cfctrl_insert_req(struct cfctrl *ctrl,
 }
=20
 /* Compare and remove request */
-struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
-					      struct cfctrl_request_info *req)
+static struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ct=
rl,
+						struct cfctrl_request_info *req)
 {
 	struct cfctrl_request_info *p, *tmp, *first;
=20
@@ -154,16 +155,6 @@ struct cfctrl_rsp *cfctrl_get_respfuncs(struct cfl=
ayer *layer)
 	return &this->res;
 }
=20
-void cfctrl_set_dnlayer(struct cflayer *this, struct cflayer *dn)
-{
-	this->dn =3D dn;
-}
-
-void cfctrl_set_uplayer(struct cflayer *this, struct cflayer *up)
-{
-	this->up =3D up;
-}
-
 static void init_info(struct caif_payload_info *info, struct cfctrl *c=
fctrl)
 {
 	info->hdr_len =3D 0;
@@ -304,58 +295,6 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8 =
channelid,
 	return ret;
 }
=20
-void cfctrl_sleep_req(struct cflayer *layer)
-{
-	int ret;
-	struct cfctrl *cfctrl =3D container_obj(layer);
-	struct cfpkt *pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
-	if (!pkt) {
-		pr_warn("Out of memory\n");
-		return;
-	}
-	cfpkt_addbdy(pkt, CFCTRL_CMD_SLEEP);
-	init_info(cfpkt_info(pkt), cfctrl);
-	ret =3D
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
-	if (ret < 0)
-		cfpkt_destroy(pkt);
-}
-
-void cfctrl_wake_req(struct cflayer *layer)
-{
-	int ret;
-	struct cfctrl *cfctrl =3D container_obj(layer);
-	struct cfpkt *pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
-	if (!pkt) {
-		pr_warn("Out of memory\n");
-		return;
-	}
-	cfpkt_addbdy(pkt, CFCTRL_CMD_WAKE);
-	init_info(cfpkt_info(pkt), cfctrl);
-	ret =3D
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
-	if (ret < 0)
-		cfpkt_destroy(pkt);
-}
-
-void cfctrl_getstartreason_req(struct cflayer *layer)
-{
-	int ret;
-	struct cfctrl *cfctrl =3D container_obj(layer);
-	struct cfpkt *pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
-	if (!pkt) {
-		pr_warn("Out of memory\n");
-		return;
-	}
-	cfpkt_addbdy(pkt, CFCTRL_CMD_START_REASON);
-	init_info(cfpkt_info(pkt), cfctrl);
-	ret =3D
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
-	if (ret < 0)
-		cfpkt_destroy(pkt);
-}
-
-
 void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_laye=
r)
 {
 	struct cfctrl_request_info *p, *tmp;
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 46f34b2..eb94826 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -71,41 +71,6 @@ int cfmuxl_set_uplayer(struct cflayer *layr, struct =
cflayer *up, u8 linkid)
 	return 0;
 }
=20
-bool cfmuxl_is_phy_inuse(struct cflayer *layr, u8 phyid)
-{
-	struct list_head *node;
-	struct cflayer *layer;
-	struct cfmuxl *muxl =3D container_obj(layr);
-	bool match =3D false;
-	spin_lock(&muxl->receive_lock);
-
-	list_for_each(node, &muxl->srvl_list) {
-		layer =3D list_entry(node, struct cflayer, node);
-		if (cfsrvl_phyid_match(layer, phyid)) {
-			match =3D true;
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
-	struct cfmuxl *muxl =3D container_obj(layr);
-	spin_lock(&muxl->receive_lock);
-	up =3D get_up(muxl, channel_id);
-	if (up !=3D NULL)
-		phyid =3D cfsrvl_getphyid(up);
-	else
-		phyid =3D 0;
-	spin_unlock(&muxl->receive_lock);
-	return phyid;
-}
-
 int cfmuxl_set_dnlayer(struct cflayer *layr, struct cflayer *dn, u8 ph=
yid)
 {
 	struct cfmuxl *muxl =3D (struct cfmuxl *) layr;
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index d7e865e..20c6cb3 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -42,22 +42,22 @@ struct cfpkt_priv_data {
 	bool erronous;
 };
=20
-inline struct cfpkt_priv_data *cfpkt_priv(struct cfpkt *pkt)
+static inline struct cfpkt_priv_data *cfpkt_priv(struct cfpkt *pkt)
 {
 	return (struct cfpkt_priv_data *) pkt->skb.cb;
 }
=20
-inline bool is_erronous(struct cfpkt *pkt)
+static inline bool is_erronous(struct cfpkt *pkt)
 {
 	return cfpkt_priv(pkt)->erronous;
 }
=20
-inline struct sk_buff *pkt_to_skb(struct cfpkt *pkt)
+static inline struct sk_buff *pkt_to_skb(struct cfpkt *pkt)
 {
 	return &pkt->skb;
 }
=20
-inline struct cfpkt *skb_to_pkt(struct sk_buff *skb)
+static inline struct cfpkt *skb_to_pkt(struct sk_buff *skb)
 {
 	return (struct cfpkt *) skb;
 }
@@ -317,17 +317,6 @@ int cfpkt_setlen(struct cfpkt *pkt, u16 len)
 }
 EXPORT_SYMBOL(cfpkt_setlen);
=20
-struct cfpkt *cfpkt_create_uplink(const unsigned char *data, unsigned =
int len)
-{
-	struct cfpkt *pkt =3D cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX)=
;
-	if (!pkt)
-		return NULL;
-	if (unlikely(data !=3D NULL))
-		cfpkt_add_body(pkt, data, len);
-	return pkt;
-}
-EXPORT_SYMBOL(cfpkt_create_uplink);
-
 struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
 			     struct cfpkt *addpkt,
 			     u16 expectlen)
@@ -408,169 +397,12 @@ struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16=
 pos)
 }
 EXPORT_SYMBOL(cfpkt_split);
=20
-char *cfpkt_log_pkt(struct cfpkt *pkt, char *buf, int buflen)
-{
-	struct sk_buff *skb =3D pkt_to_skb(pkt);
-	char *p =3D buf;
-	int i;
-
-	/*
-	 * Sanity check buffer length, it needs to be at least as large as
-	 * the header info: ~=3D50+ bytes
-	 */
-	if (buflen < 50)
-		return NULL;
-
-	snprintf(buf, buflen, "%s: pkt:%p len:%ld(%ld+%ld) {%ld,%ld} data: ["=
,
-		is_erronous(pkt) ? "ERRONOUS-SKB" :
-		 (skb->data_len !=3D 0 ? "COMPLEX-SKB" : "SKB"),
-		 skb,
-		 (long) skb->len,
-		 (long) (skb_tail_pointer(skb) - skb->data),
-		 (long) skb->data_len,
-		 (long) (skb->data - skb->head),
-		 (long) (skb_tail_pointer(skb) - skb->head));
-	p =3D buf + strlen(buf);
-
-	for (i =3D 0; i < skb_tail_pointer(skb) - skb->data && i < 300; i++) =
{
-		if (p > buf + buflen - 10) {
-			sprintf(p, "...");
-			p =3D buf + strlen(buf);
-			break;
-		}
-		sprintf(p, "%02x,", skb->data[i]);
-		p =3D buf + strlen(buf);
-	}
-	sprintf(p, "]\n");
-	return buf;
-}
-EXPORT_SYMBOL(cfpkt_log_pkt);
-
-int cfpkt_raw_append(struct cfpkt *pkt, void **buf, unsigned int bufle=
n)
-{
-	struct sk_buff *skb =3D pkt_to_skb(pkt);
-	struct sk_buff *lastskb;
-
-	caif_assert(buf !=3D NULL);
-	if (unlikely(is_erronous(pkt)))
-		return -EPROTO;
-	/* Make sure SKB is writable */
-	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
-		PKT_ERROR(pkt, "skb_cow_data failed\n");
-		return -EPROTO;
-	}
-
-	if (unlikely(skb_linearize(skb) !=3D 0)) {
-		PKT_ERROR(pkt, "linearize failed\n");
-		return -EPROTO;
-	}
-
-	if (unlikely(skb_tailroom(skb) < buflen)) {
-		PKT_ERROR(pkt, "buffer too short - failed\n");
-		return -EPROTO;
-	}
-
-	*buf =3D skb_put(skb, buflen);
-	return 1;
-}
-EXPORT_SYMBOL(cfpkt_raw_append);
-
-int cfpkt_raw_extract(struct cfpkt *pkt, void **buf, unsigned int bufl=
en)
-{
-	struct sk_buff *skb =3D pkt_to_skb(pkt);
-
-	caif_assert(buf !=3D NULL);
-	if (unlikely(is_erronous(pkt)))
-		return -EPROTO;
-
-	if (unlikely(buflen > skb->len)) {
-		PKT_ERROR(pkt, "buflen too large - failed\n");
-		return -EPROTO;
-	}
-
-	if (unlikely(buflen > skb_headlen(skb))) {
-		if (unlikely(skb_linearize(skb) !=3D 0)) {
-			PKT_ERROR(pkt, "linearize failed\n");
-			return -EPROTO;
-		}
-	}
-
-	*buf =3D skb->data;
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
=20
-struct cfpktq *cfpktq_create(void)
-{
-	struct cfpktq *q =3D kmalloc(sizeof(struct cfpktq), GFP_ATOMIC);
-	if (!q)
-		return NULL;
-	skb_queue_head_init(&q->head);
-	atomic_set(&q->count, 0);
-	spin_lock_init(&q->lock);
-	return q;
-}
-EXPORT_SYMBOL(cfpktq_create);
-
-void cfpkt_queue(struct cfpktq *pktq, struct cfpkt *pkt, unsigned shor=
t prio)
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
-	tmp =3D skb_to_pkt(skb_peek(&pktq->head));
-	spin_unlock(&pktq->lock);
-	return tmp;
-}
-EXPORT_SYMBOL(cfpkt_qpeek);
-
-struct cfpkt *cfpkt_dequeue(struct cfpktq *pktq)
-{
-	struct cfpkt *pkt;
-	spin_lock(&pktq->lock);
-	pkt =3D skb_to_pkt(skb_dequeue(&pktq->head));
-	if (pkt) {
-		atomic_dec(&pktq->count);
-		caif_assert(atomic_read(&pktq->count) >=3D 0);
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
-	clone  =3D skb_to_pkt(skb_clone(pkt_to_skb(pkt), GFP_ATOMIC));
-	/* Free original packet. */
-	cfpkt_destroy(pkt);
-	if (!clone)
-		return NULL;
-	return clone;
-}
-EXPORT_SYMBOL(cfpkt_clone_release);
=20
 struct caif_payload_info *cfpkt_info(struct cfpkt *pkt)
 {
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index ab5e542..24ba392 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -151,12 +151,7 @@ static int cfservl_modemcmd(struct cflayer *layr, =
enum caif_modemcmd ctrl)
 	return -EINVAL;
 }
=20
-void cfservl_destroy(struct cflayer *layer)
-{
-	kfree(layer);
-}
-
-void cfsrvl_release(struct kref *kref)
+static void cfsrvl_release(struct kref *kref)
 {
 	struct cfsrvl *service =3D container_of(kref, struct cfsrvl, ref);
 	kfree(service);
--=20
1.7.0.4

