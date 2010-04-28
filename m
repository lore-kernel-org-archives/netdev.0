From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 3/7] caif: Add reference counting to service layer
Date: Wed, 28 Apr 2010 20:54:36 +0200
Message-ID: <1272480880-30672-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	sjurbr@gmail.com, linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:35420 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460Ab0D1Sz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:55:26 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00K2SOK6DG80@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:18 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00MYUOK4Q560@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:18 +0200 (CEST)
In-reply-to: <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Changes:
o Added functions cfsrvl_get and cfsrvl_put.
o Added support release_client to use by socket and net device.
o Increase reference counting for in-flight packets from cfmuxl

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h |   11 +++++++++++
 include/net/caif/cfcnfg.h   |    7 +++++++
 include/net/caif/cfsrvl.h   |   22 ++++++++++++++++++++++
 net/caif/caif_dev.c         |    6 ++++++
 net/caif/cfcnfg.c           |    7 +++++++
 net/caif/cfmuxl.c           |    7 ++++++-
 net/caif/cfsrvl.c           |    7 +++++++
 7 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index 3aa1ff6..318ab94 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -70,6 +70,17 @@ int caif_connect_client(struct caif_connect_request *config,
 int caif_disconnect_client(struct cflayer *client_layer);
 
 /**
+ * caif_release_client - Release adaptation layer reference to client.
+ *
+ * @client_layer: Client layer.
+ *
+ * Releases a client/adaptation layer use of the caif stack.
+ * This function must be used after caif_disconnect_client to
+ * decrease the reference count of the service layer.
+ */
+void caif_release_client(struct cflayer *client_layer);
+
+/**
  * connect_req_to_link_param - Translate configuration parameters
  *				from socket format to internal format.
  * @cnfg:	Pointer to configuration handler
diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index f16b875..9fc2fc2 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -97,6 +97,13 @@ int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg,
 			struct cflayer *adap_layer);
 
 /**
+ * cfcnfg_release_adap_layer - Used by client to release the adaptation layer.
+ *
+ * @adap_layer: Adaptation layer.
+ */
+void cfcnfg_release_adap_layer(struct cflayer *adap_layer);
+
+/**
  * cfcnfg_add_adaptation_layer - Add an adaptation layer to the CAIF stack.
  *
  * The adaptation Layer is where the interface to application or higher-level
diff --git a/include/net/caif/cfsrvl.h b/include/net/caif/cfsrvl.h
index b2a12db..2dc9eb1 100644
--- a/include/net/caif/cfsrvl.h
+++ b/include/net/caif/cfsrvl.h
@@ -9,14 +9,18 @@
 #include <linux/list.h>
 #include <linux/stddef.h>
 #include <linux/types.h>
+#include <linux/kref.h>
+
 struct cfsrvl {
 	struct cflayer layer;
 	bool open;
 	bool phy_flow_on;
 	bool modem_flow_on;
 	struct dev_info dev_info;
+	struct kref ref;
 };
 
+void cfsrvl_release(struct kref *kref);
 struct cflayer *cfvei_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfdgml_create(u8 linkid, struct dev_info *dev_info);
 struct cflayer *cfutill_create(u8 linkid, struct dev_info *dev_info);
@@ -31,4 +35,22 @@ void cfsrvl_init(struct cfsrvl *service,
 bool cfsrvl_ready(struct cfsrvl *service, int *err);
 u8 cfsrvl_getphyid(struct cflayer *layer);
 
+static inline void cfsrvl_get(struct cflayer *layr)
+{
+	struct cfsrvl *s;
+	if (layr == NULL)
+		return;
+	s = container_of(layr, struct cfsrvl, layer);
+	kref_get(&s->ref);
+}
+
+static inline void cfsrvl_put(struct cflayer *layr)
+{
+	struct cfsrvl *s;
+	if (layr == NULL)
+		return;
+	s = container_of(layr, struct cfsrvl, layer);
+	kref_put(&s->ref, cfsrvl_release);
+}
+
 #endif				/* CFSRVL_H_ */
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index be1f674..0145bae 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -346,6 +346,12 @@ int caif_disconnect_client(struct cflayer *adap_layer)
 }
 EXPORT_SYMBOL(caif_disconnect_client);
 
+void caif_release_client(struct cflayer *adap_layer)
+{
+       cfcnfg_release_adap_layer(adap_layer);
+}
+EXPORT_SYMBOL(caif_release_client);
+
 /* Per-namespace Caif devices handling */
 static int caif_init_net(struct net *net)
 {
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index d52f256..f94f3df 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -247,6 +247,13 @@ end:
 }
 EXPORT_SYMBOL(cfcnfg_disconn_adapt_layer);
 
+void cfcnfg_release_adap_layer(struct cflayer *adap_layer)
+{
+	if (adap_layer->dn)
+		cfsrvl_put(adap_layer->dn);
+}
+EXPORT_SYMBOL(cfcnfg_release_adap_layer);
+
 static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id,
 				  struct cflayer *client_layer)
 {
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 6fb9f9e..7372f27 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -62,6 +62,7 @@ int cfmuxl_set_uplayer(struct cflayer *layr, struct cflayer *up, u8 linkid)
 {
 	struct cfmuxl *muxl = container_obj(layr);
 	spin_lock(&muxl->receive_lock);
+	cfsrvl_get(up);
 	list_add(&up->node, &muxl->srvl_list);
 	spin_unlock(&muxl->receive_lock);
 	return 0;
@@ -172,8 +173,11 @@ struct cflayer *cfmuxl_remove_uplayer(struct cflayer *layr, u8 id)
 	struct cfmuxl *muxl = container_obj(layr);
 	spin_lock(&muxl->receive_lock);
 	up = get_up(muxl, id);
+	if (up == NULL)
+		return NULL;
 	memset(muxl->up_cache, 0, sizeof(muxl->up_cache));
 	list_del(&up->node);
+	cfsrvl_put(up);
 	spin_unlock(&muxl->receive_lock);
 	return up;
 }
@@ -203,8 +207,9 @@ static int cfmuxl_receive(struct cflayer *layr, struct cfpkt *pkt)
 		 */
 		return /* CFGLU_EPROT; */ 0;
 	}
-
+	cfsrvl_get(up);
 	ret = up->receive(up, pkt);
+	cfsrvl_put(up);
 	return ret;
 }
 
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index d470c51..aff31f3 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -158,6 +158,13 @@ void cfsrvl_init(struct cfsrvl *service,
 	service->layer.ctrlcmd = cfservl_ctrlcmd;
 	service->layer.modemcmd = cfservl_modemcmd;
 	service->dev_info = *dev_info;
+	kref_init(&service->ref);
+}
+
+void cfsrvl_release(struct kref *kref)
+{
+	struct cfsrvl *service = container_of(kref, struct cfsrvl, ref);
+	kfree(service);
 }
 
 bool cfsrvl_ready(struct cfsrvl *service, int *err)
-- 
1.6.3.3

