From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 2/4] caif: Bugfix - RFM must support segmentation.
Date: Thu, 17 Jun 2010 18:55:39 +0200
Message-ID: <1276793741-20278-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: sjurbr@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:37367 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760304Ab0FQQz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 12:55:59 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4600FGY4D90S90@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 17 Jun 2010 18:55:57 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4600ITZ4D6RO21@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 17 Jun 2010 18:55:57 +0200 (CEST)
In-reply-to: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

CAIF Remote File Manager may send or receive more than 4050 bytes.
Due to this The CAIF RFM service have to support segmentation.

Signed-off-by: Sjur Braendeland@stericsson.com
---
 include/net/caif/cfsrvl.h |    9 +-
 net/caif/caif_socket.c    |    4 -
 net/caif/cfcnfg.c         |    4 +-
 net/caif/cfpkt_skbuff.c   |    1 -
 net/caif/cfrfml.c         |  314 +++++++++++++++++++++++++++++++++++++--------
 net/caif/cfsrvl.c         |   13 +-
 6 files changed, 278 insertions(+), 67 deletions(-)

diff --git a/include/net/caif/cfsrvl.h b/include/net/caif/cfsrvl.h
index 5d921f5..b1fa87e 100644
--- a/include/net/caif/cfsrvl.h
+++ b/include/net/caif/cfsrvl.h
@@ -17,6 +17,7 @@ struct cfsrvl {
 	bool phy_flow_on;
 	bool modem_flow_on;
 	bool supports_flowctrl;
+	void (*release)(struct kref *);
 	struct dev_info dev_info;
 	struct kref ref;
 };
@@ -26,7 +27,8 @@ struct cflayer *cfvei_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfdgml_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfutill_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfvidl_create(u8 linkid, struct dev_info *dev_info);
-struct cflayer *cfrfml_create(u8 linkid, struct dev_info *dev_info);
+struct cflayer *cfrfml_create(u8 linkid, struct dev_info *dev_info,
+				int mtu_size);
 struct cflayer *cfdbgl_create(u8 linkid, struct dev_info *dev_info);
 bool cfsrvl_phyid_match(struct cflayer *layer, int phyid);
 void cfservl_destroy(struct cflayer *layer);
@@ -52,7 +54,10 @@ static inline void cfsrvl_put(struct cflayer *layr)
 	if (layr == NULL)
 		return;
 	s = container_of(layr, struct cfsrvl, layer);
-	kref_put(&s->ref, cfsrvl_release);
+
+	WARN_ON(!s->release);
+	if (s->release)
+		kref_put(&s->ref, s->release);
 }
 
 #endif				/* CFSRVL_H_ */
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 7912493..848ae75 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -596,10 +596,6 @@ static int caif_seqpkt_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	buffer_size = len + CAIF_NEEDED_HEADROOM + CAIF_NEEDED_TAILROOM;
 
-	ret = -EMSGSIZE;
-	if (buffer_size > CAIF_MAX_PAYLOAD_SIZE)
-		goto err;
-
 	timeo = sock_sndtimeo(sk, noblock);
 	timeo = caif_wait_for_flow_on(container_of(sk, struct caifsock, sk),
 				1, timeo, &ret);
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 7c81974..cff2dcb 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -22,6 +22,7 @@
 #define PHY_NAME_LEN 20
 
 #define container_obj(layr) container_of(layr, struct cfcnfg, layer)
+#define RFM_FRAGMENT_SIZE 4030
 
 /* Information about CAIF physical interfaces held by Config Module in order
  * to manage physical interfaces
@@ -328,7 +329,8 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 		servicel = cfdgml_create(channel_id, &phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_RFM:
-		servicel = cfrfml_create(channel_id, &phyinfo->dev_info);
+		servicel = cfrfml_create(channel_id, &phyinfo->dev_info,
+						RFM_FRAGMENT_SIZE);
 		break;
 	case CFCTRL_SRV_UTIL:
 		servicel = cfutill_create(channel_id, &phyinfo->dev_info);
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index a6fdf89..318b0f4 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -338,7 +338,6 @@ struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
 	u16 dstlen;
 	u16 createlen;
 	if (unlikely(is_erronous(dstpkt) || is_erronous(addpkt))) {
-		cfpkt_destroy(addpkt);
 		return dstpkt;
 	}
 	if (expectlen > addlen)
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 689cbfd..4b04d25 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -7,98 +7,304 @@
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
+#include <linux/unaligned/le_byteshift.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfsrvl.h>
 #include <net/caif/cfpkt.h>
 
-#define container_obj(layr) container_of(layr, struct cfsrvl, layer)
-
+#define container_obj(layr) container_of(layr, struct cfrfml, serv.layer)
 #define RFM_SEGMENTATION_BIT 0x01
-#define RFM_PAYLOAD  0x00
-#define RFM_CMD_BIT  0x80
-#define RFM_FLOW_OFF 0x81
-#define RFM_FLOW_ON  0x80
-#define RFM_SET_PIN  0x82
-#define RFM_CTRL_PKT_SIZE 1
+#define RFM_HEAD_SIZE 7
 
 static int cfrfml_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt);
 
-struct cflayer *cfrfml_create(u8 channel_id, struct dev_info *dev_info)
+struct cfrfml {
+	struct cfsrvl serv;
+	struct cfpkt *incomplete_frm;
+	int fragment_size;
+	u8  seghead[6];
+	u16 pdu_size;
+	/* Protects serialized processing of packets */
+	spinlock_t sync;
+};
+
+static void cfrfml_release(struct kref *kref)
+{
+	struct cfsrvl *srvl = container_of(kref, struct cfsrvl, ref);
+	struct cfrfml *rfml = container_obj(&srvl->layer);
+
+	if (rfml->incomplete_frm)
+		cfpkt_destroy(rfml->incomplete_frm);
+
+	kfree(srvl);
+}
+
+struct cflayer *cfrfml_create(u8 channel_id, struct dev_info *dev_info,
+					int mtu_size)
 {
-	struct cfsrvl *rfm = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	int tmp;
+	struct cfrfml *this =
+		kzalloc(sizeof(struct cfrfml), GFP_ATOMIC);
 
-	if (!rfm) {
+	if (!this) {
 		pr_warning("CAIF: %s(): Out of memory\n", __func__);
 		return NULL;
 	}
 
-	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+	cfsrvl_init(&this->serv, channel_id, dev_info, false);
+	this->serv.release = cfrfml_release;
+	this->serv.layer.receive = cfrfml_receive;
+	this->serv.layer.transmit = cfrfml_transmit;
+
+	/* Round down to closest multiple of 16 */
+	tmp = (mtu_size - RFM_HEAD_SIZE - 6) / 16;
+	tmp *= 16;
+
+	this->fragment_size = tmp;
+	spin_lock_init(&this->sync);
+	snprintf(this->serv.layer.name, CAIF_LAYER_NAME_SZ,
+		"rfm%d", channel_id);
+
+	return &this->serv.layer;
+}
+
+static struct cfpkt *rfm_append(struct cfrfml *rfml, char *seghead,
+			struct cfpkt *pkt, int *err)
+{
+	struct cfpkt *tmppkt;
+	*err = -EPROTO;
+	/* n-th but not last segment */
+
+	if (cfpkt_extr_head(pkt, seghead, 6) < 0)
+		return NULL;
+
+	/* Verify correct header */
+	if (memcmp(seghead, rfml->seghead, 6) != 0)
+		return NULL;
+
+	tmppkt = cfpkt_append(rfml->incomplete_frm, pkt,
+			rfml->pdu_size + RFM_HEAD_SIZE);
+
+	/* If cfpkt_append failes input pkts are not freed */
+	*err = -ENOMEM;
+	if (tmppkt == NULL)
+		return NULL;
 
-	memset(rfm, 0, sizeof(struct cfsrvl));
-	cfsrvl_init(rfm, channel_id, dev_info, false);
-	rfm->layer.receive = cfrfml_receive;
-	rfm->layer.transmit = cfrfml_transmit;
-	snprintf(rfm->layer.name, CAIF_LAYER_NAME_SZ, "rfm%d", channel_id);
-	return &rfm->layer;
+	*err = 0;
+	return tmppkt;
 }
 
 static int cfrfml_receive(struct cflayer *layr, struct cfpkt *pkt)
 {
 	u8 tmp;
 	bool segmented;
-	int ret;
+	int err;
+	u8 seghead[6];
+	struct cfrfml *rfml;
+	struct cfpkt *tmppkt = NULL;
+
 	caif_assert(layr->up != NULL);
 	caif_assert(layr->receive != NULL);
+	rfml = container_obj(layr);
+	spin_lock(&rfml->sync);
+
+	err = -EPROTO;
+	if (cfpkt_extr_head(pkt, &tmp, 1) < 0)
+		goto out;
+	segmented = tmp & RFM_SEGMENTATION_BIT;
+
+	if (segmented) {
+		if (rfml->incomplete_frm == NULL) {
+			/* Initial Segment */
+			if (cfpkt_peek_head(pkt, rfml->seghead, 6) < 0)
+				goto out;
+
+			rfml->pdu_size = get_unaligned_le16(rfml->seghead+4);
+
+			if (cfpkt_erroneous(pkt))
+				goto out;
+			rfml->incomplete_frm = pkt;
+			pkt = NULL;
+		} else {
+
+			tmppkt = rfm_append(rfml, seghead, pkt, &err);
+			if (tmppkt == NULL)
+				goto out;
+
+			if (cfpkt_erroneous(tmppkt))
+				goto out;
+
+			rfml->incomplete_frm = tmppkt;
+
+
+			if (cfpkt_erroneous(tmppkt))
+				goto out;
+		}
+		err = 0;
+		goto out;
+	}
+
+	if (rfml->incomplete_frm) {
+
+		/* Last Segment */
+		tmppkt = rfm_append(rfml, seghead, pkt, &err);
+		if (tmppkt == NULL)
+			goto out;
+
+		if (cfpkt_erroneous(tmppkt))
+			goto out;
+
+		rfml->incomplete_frm = NULL;
+		pkt = tmppkt;
+		tmppkt = NULL;
+
+		/* Verify that length is correct */
+		err = EPROTO;
+		if (rfml->pdu_size != cfpkt_getlen(pkt) - RFM_HEAD_SIZE + 1)
+			goto out;
+	}
+
+	err = rfml->serv.layer.up->receive(rfml->serv.layer.up, pkt);
+
+out:
+
+	if (err != 0) {
+		if (tmppkt)
+			cfpkt_destroy(tmppkt);
+		if (pkt)
+			cfpkt_destroy(pkt);
+		if (rfml->incomplete_frm)
+			cfpkt_destroy(rfml->incomplete_frm);
+		rfml->incomplete_frm = NULL;
+
+		pr_info("CAIF: %s(): "
+				"Connection error %d triggered on RFM link\n",
+				__func__, err);
+
+		/* Trigger connection error upon failure.*/
+		layr->up->ctrlcmd(layr->up, CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND,
+					rfml->serv.dev_info.id);
+	}
+	spin_unlock(&rfml->sync);
+	return err;
+}
+
+
+static int cfrfml_transmit_segment(struct cfrfml *rfml, struct cfpkt *pkt)
+{
+	caif_assert(!cfpkt_getlen(pkt) < rfml->fragment_size);
+
+	/* Add info for MUX-layer to route the packet out. */
+	cfpkt_info(pkt)->channel_id = rfml->serv.layer.id;
 
 	/*
-	 * RFM is taking care of segmentation and stripping of
-	 * segmentation bit.
+	 * To optimize alignment, we add up the size of CAIF header before
+	 * payload.
 	 */
-	if (cfpkt_extr_head(pkt, &tmp, 1) < 0) {
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
-		cfpkt_destroy(pkt);
-		return -EPROTO;
-	}
-	segmented = tmp & RFM_SEGMENTATION_BIT;
-	caif_assert(!segmented);
+	cfpkt_info(pkt)->hdr_len = RFM_HEAD_SIZE;
+	cfpkt_info(pkt)->dev_info = &rfml->serv.dev_info;
 
-	ret = layr->up->receive(layr->up, pkt);
-	return ret;
+	return rfml->serv.layer.dn->transmit(rfml->serv.layer.dn, pkt);
 }
 
 static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 {
-	u8 tmp = 0;
-	int ret;
-	struct cfsrvl *service = container_obj(layr);
+	int err;
+	u8 seg;
+	u8 head[6];
+	struct cfpkt *rearpkt = NULL;
+	struct cfpkt *frontpkt = pkt;
+	struct cfrfml *rfml = container_obj(layr);
 
 	caif_assert(layr->dn != NULL);
 	caif_assert(layr->dn->transmit != NULL);
 
-	if (!cfsrvl_ready(service, &ret))
-		return ret;
+	if (!cfsrvl_ready(&rfml->serv, &err))
+		return err;
+
+	err = -EPROTO;
+	if (cfpkt_getlen(pkt) <= RFM_HEAD_SIZE-1)
+		goto out;
+
+	err = 0;
+	if (cfpkt_getlen(pkt) > rfml->fragment_size + RFM_HEAD_SIZE)
+		err = cfpkt_peek_head(pkt, head, 6);
+
+	if (err < 0)
+		goto out;
+
+	while (cfpkt_getlen(frontpkt) > rfml->fragment_size + RFM_HEAD_SIZE) {
+
+		seg = 1;
+		err = -EPROTO;
+
+		if (cfpkt_add_head(frontpkt, &seg, 1) < 0)
+			goto out;
+		/*
+		 * On OOM error cfpkt_split returns NULL.
+		 *
+		 * NOTE: Segmented pdu is not correctly aligned.
+		 * This has negative performance impact.
+		 */
+
+		rearpkt = cfpkt_split(frontpkt, rfml->fragment_size);
+		if (rearpkt == NULL)
+			goto out;
+
+		err = cfrfml_transmit_segment(rfml, frontpkt);
+
+		if (err != 0)
+			goto out;
+		frontpkt = rearpkt;
+		rearpkt = NULL;
+
+		err = -ENOMEM;
+		if (frontpkt == NULL)
+			goto out;
+		err = -EPROTO;
+		if (cfpkt_add_head(frontpkt, head, 6) < 0)
+			goto out;
 
-	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
-		pr_err("CAIF: %s():Packet too large - size=%d\n",
-			__func__, cfpkt_getlen(pkt));
-		return -EOVERFLOW;
 	}
-	if (cfpkt_add_head(pkt, &tmp, 1) < 0) {
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
-		return -EPROTO;
+
+	seg = 0;
+	err = -EPROTO;
+
+	if (cfpkt_add_head(frontpkt, &seg, 1) < 0)
+		goto out;
+
+	err = cfrfml_transmit_segment(rfml, frontpkt);
+
+	frontpkt = NULL;
+out:
+
+	if (err != 0) {
+		pr_info("CAIF: %s(): "
+				"Connection error %d triggered on RFM link\n",
+				__func__, err);
+		/* Trigger connection error upon failure.*/
+
+		layr->up->ctrlcmd(layr->up, CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND,
+					rfml->serv.dev_info.id);
+
+		if (rearpkt)
+			cfpkt_destroy(rearpkt);
+
+		if (frontpkt && frontpkt != pkt) {
+
+			cfpkt_destroy(frontpkt);
+			/*
+			 * Socket layer will free the original packet,
+			 * but this packet may already be sent and
+			 * freed. So we have to return 0 in this case
+			 * to avoid socket layer to re-free this packet.
+			 * The return of shutdown indication will
+			 * cause connection to be invalidated anyhow.
+			 */
+			err = 0;
+		}
 	}
 
-	/* Add info for MUX-layer to route the packet out. */
-	cfpkt_info(pkt)->channel_id = service->layer.id;
-	/*
-	 * To optimize alignment, we add up the size of CAIF header before
-	 * payload.
-	 */
-	cfpkt_info(pkt)->hdr_len = 1;
-	cfpkt_info(pkt)->dev_info = &service->dev_info;
-	ret = layr->dn->transmit(layr->dn, pkt);
-	if (ret < 0)
-		cfpkt_extr_head(pkt, &tmp, 1);
-	return ret;
+	return err;
 }
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index 7aa1f03..4c9f147 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -159,6 +159,13 @@ void cfservl_destroy(struct cflayer *layer)
 	kfree(layer);
 }
 
+void cfsrvl_release(struct kref *kref)
+{
+	struct cfsrvl *service = container_of(kref, struct cfsrvl, ref);
+	pr_info("CAIF: %s(): enter\n", __func__);
+	kfree(service);
+}
+
 void cfsrvl_init(struct cfsrvl *service,
 			u8 channel_id,
 			struct dev_info *dev_info,
@@ -174,14 +181,10 @@ void cfsrvl_init(struct cfsrvl *service,
 	service->layer.modemcmd = cfservl_modemcmd;
 	service->dev_info = *dev_info;
 	service->supports_flowctrl = supports_flowctrl;
+	service->release = cfsrvl_release;
 	kref_init(&service->ref);
 }
 
-void cfsrvl_release(struct kref *kref)
-{
-	struct cfsrvl *service = container_of(kref, struct cfsrvl, ref);
-	kfree(service);
-}
 
 bool cfsrvl_ready(struct cfsrvl *service, int *err)
 {
-- 
1.6.3.3

