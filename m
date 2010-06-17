From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 1/4] caif: Bugfix not all services uses flow-ctrl.
Date: Thu, 17 Jun 2010 18:55:38 +0200
Message-ID: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: sjurbr@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:37367 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760291Ab0FQQz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 12:55:58 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4600FGM4D70S90@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 17 Jun 2010 18:55:55 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4600ITZ4D6RO21@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 17 Jun 2010 18:55:55 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Flow control is not used by all CAIF services.
The usage of flow control is now part of the gerneal
initialization function for CAIF Services.

Signed-off-by: Sjur Braendeland@stericsson.com
---
 include/net/caif/cfsrvl.h |    6 ++++--
 net/caif/cfctrl.c         |    2 +-
 net/caif/cfdbgl.c         |    2 +-
 net/caif/cfdgml.c         |    2 +-
 net/caif/cfrfml.c         |   12 ++++--------
 net/caif/cfsrvl.c         |   14 ++++++++++++--
 net/caif/cfutill.c        |    2 +-
 net/caif/cfveil.c         |    2 +-
 net/caif/cfvidl.c         |    2 +-
 9 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/include/net/caif/cfsrvl.h b/include/net/caif/cfsrvl.h
index 2dc9eb1..5d921f5 100644
--- a/include/net/caif/cfsrvl.h
+++ b/include/net/caif/cfsrvl.h
@@ -16,6 +16,7 @@ struct cfsrvl {
 	bool open;
 	bool phy_flow_on;
 	bool modem_flow_on;
+	bool supports_flowctrl;
 	struct dev_info dev_info;
 	struct kref ref;
 };
@@ -30,8 +31,9 @@ struct cflayer *cfdbgl_create(u8 linkid, struct dev_info *dev_info);
 bool cfsrvl_phyid_match(struct cflayer *layer, int phyid);
 void cfservl_destroy(struct cflayer *layer);
 void cfsrvl_init(struct cfsrvl *service,
-		 u8 channel_id,
-		 struct dev_info *dev_info);
+			u8 channel_id,
+			struct dev_info *dev_info,
+			bool supports_flowctrl);
 bool cfsrvl_ready(struct cfsrvl *service, int *err);
 u8 cfsrvl_getphyid(struct cflayer *layer);
 
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index fcfda98..107c4b2 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -43,7 +43,7 @@ struct cflayer *cfctrl_create(void)
 	memset(&dev_info, 0, sizeof(dev_info));
 	dev_info.id = 0xff;
 	memset(this, 0, sizeof(*this));
-	cfsrvl_init(&this->serv, 0, &dev_info);
+	cfsrvl_init(&this->serv, 0, &dev_info, false);
 	atomic_set(&this->req_seq_no, 1);
 	atomic_set(&this->rsp_seq_no, 1);
 	this->serv.layer.receive = cfctrl_recv;
diff --git a/net/caif/cfdbgl.c b/net/caif/cfdbgl.c
index ab6b6dc..676648c 100644
--- a/net/caif/cfdbgl.c
+++ b/net/caif/cfdbgl.c
@@ -22,7 +22,7 @@ struct cflayer *cfdbgl_create(u8 channel_id, struct dev_info *dev_info)
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
 	memset(dbg, 0, sizeof(struct cfsrvl));
-	cfsrvl_init(dbg, channel_id, dev_info);
+	cfsrvl_init(dbg, channel_id, dev_info, false);
 	dbg->layer.receive = cfdbgl_receive;
 	dbg->layer.transmit = cfdbgl_transmit;
 	snprintf(dbg->layer.name, CAIF_LAYER_NAME_SZ - 1, "dbg%d", channel_id);
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index 5319484..32d9f0d 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -30,7 +30,7 @@ struct cflayer *cfdgml_create(u8 channel_id, struct dev_info *dev_info)
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
 	memset(dgm, 0, sizeof(struct cfsrvl));
-	cfsrvl_init(dgm, channel_id, dev_info);
+	cfsrvl_init(dgm, channel_id, dev_info, true);
 	dgm->layer.receive = cfdgml_receive;
 	dgm->layer.transmit = cfdgml_transmit;
 	snprintf(dgm->layer.name, CAIF_LAYER_NAME_SZ - 1, "dgm%d", channel_id);
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index fd27b17..689cbfd 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -23,30 +23,26 @@
 
 static int cfrfml_receive(struct cflayer *layr, struct cfpkt *pkt);
 static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt);
-static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl);
 
 struct cflayer *cfrfml_create(u8 channel_id, struct dev_info *dev_info)
 {
 	struct cfsrvl *rfm = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+
 	if (!rfm) {
 		pr_warning("CAIF: %s(): Out of memory\n", __func__);
 		return NULL;
 	}
+
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
+
 	memset(rfm, 0, sizeof(struct cfsrvl));
-	cfsrvl_init(rfm, channel_id, dev_info);
-	rfm->layer.modemcmd = cfservl_modemcmd;
+	cfsrvl_init(rfm, channel_id, dev_info, false);
 	rfm->layer.receive = cfrfml_receive;
 	rfm->layer.transmit = cfrfml_transmit;
 	snprintf(rfm->layer.name, CAIF_LAYER_NAME_SZ, "rfm%d", channel_id);
 	return &rfm->layer;
 }
 
-static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
-{
-       return -EPROTO;
-}
-
 static int cfrfml_receive(struct cflayer *layr, struct cfpkt *pkt)
 {
 	u8 tmp;
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index 6e5b707..7aa1f03 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -24,8 +24,10 @@ static void cfservl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 				int phyid)
 {
 	struct cfsrvl *service = container_obj(layr);
+
 	caif_assert(layr->up != NULL);
 	caif_assert(layr->up->ctrlcmd != NULL);
+
 	switch (ctrl) {
 	case CAIF_CTRLCMD_INIT_RSP:
 		service->open = true;
@@ -89,9 +91,14 @@ static void cfservl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 {
 	struct cfsrvl *service = container_obj(layr);
+
 	caif_assert(layr != NULL);
 	caif_assert(layr->dn != NULL);
 	caif_assert(layr->dn->transmit != NULL);
+
+	if (!service->supports_flowctrl)
+		return 0;
+
 	switch (ctrl) {
 	case CAIF_MODEMCMD_FLOW_ON_REQ:
 		{
@@ -153,8 +160,10 @@ void cfservl_destroy(struct cflayer *layer)
 }
 
 void cfsrvl_init(struct cfsrvl *service,
-		 u8 channel_id,
-		 struct dev_info *dev_info)
+			u8 channel_id,
+			struct dev_info *dev_info,
+			bool supports_flowctrl
+			)
 {
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
 	service->open = false;
@@ -164,6 +173,7 @@ void cfsrvl_init(struct cfsrvl *service,
 	service->layer.ctrlcmd = cfservl_ctrlcmd;
 	service->layer.modemcmd = cfservl_modemcmd;
 	service->dev_info = *dev_info;
+	service->supports_flowctrl = supports_flowctrl;
 	kref_init(&service->ref);
 }
 
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index 5fd2c9e..ce525ca 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -31,7 +31,7 @@ struct cflayer *cfutill_create(u8 channel_id, struct dev_info *dev_info)
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
 	memset(util, 0, sizeof(struct cfsrvl));
-	cfsrvl_init(util, channel_id, dev_info);
+	cfsrvl_init(util, channel_id, dev_info, true);
 	util->layer.receive = cfutill_receive;
 	util->layer.transmit = cfutill_transmit;
 	snprintf(util->layer.name, CAIF_LAYER_NAME_SZ - 1, "util1");
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index e04f7d9..637cb0e 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -30,7 +30,7 @@ struct cflayer *cfvei_create(u8 channel_id, struct dev_info *dev_info)
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
 	memset(vei, 0, sizeof(struct cfsrvl));
-	cfsrvl_init(vei, channel_id, dev_info);
+	cfsrvl_init(vei, channel_id, dev_info, true);
 	vei->layer.receive = cfvei_receive;
 	vei->layer.transmit = cfvei_transmit;
 	snprintf(vei->layer.name, CAIF_LAYER_NAME_SZ - 1, "vei%d", channel_id);
diff --git a/net/caif/cfvidl.c b/net/caif/cfvidl.c
index 89ad4ea..ada6ee2 100644
--- a/net/caif/cfvidl.c
+++ b/net/caif/cfvidl.c
@@ -27,7 +27,7 @@ struct cflayer *cfvidl_create(u8 channel_id, struct dev_info *dev_info)
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
 
 	memset(vid, 0, sizeof(struct cfsrvl));
-	cfsrvl_init(vid, channel_id, dev_info);
+	cfsrvl_init(vid, channel_id, dev_info, false);
 	vid->layer.receive = cfvidl_receive;
 	vid->layer.transmit = cfvidl_transmit;
 	snprintf(vid->layer.name, CAIF_LAYER_NAME_SZ - 1, "vid1");
-- 
1.6.3.3

