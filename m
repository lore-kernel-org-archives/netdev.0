From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 05/10] caif: Move refcount from service layer to sock and dev.
Date: Fri, 13 May 2011 14:44:03 +0200
Message-ID: <1305290648-9613-6-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:58682 "EHLO
	slow2.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758918Ab1EMNCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:02:37 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow2.isp.as2116.net (Postfix) with ESMTP id BC5CF40B14
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:10 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having reference counts in caif service layers,
we hook into existing refcount handling in socket layer and netdevice.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cfsrvl.h |   29 ++++++++++++++++-------------
 net/caif/cfrfml.c         |    4 ++--
 net/caif/cfsrvl.c         |   35 +++++++++++++++++++++++++++++------
 3 files changed, 47 insertions(+), 21 deletions(-)

diff --git a/include/net/caif/cfsrvl.h b/include/net/caif/cfsrvl.h
index 6c8279c..0f59052 100644
--- a/include/net/caif/cfsrvl.h
+++ b/include/net/caif/cfsrvl.h
@@ -10,6 +10,7 @@
 #include <linux/stddef.h>
 #include <linux/types.h>
 #include <linux/kref.h>
+#include <linux/rculist.h>
=20
 struct cfsrvl {
 	struct cflayer layer;
@@ -17,9 +18,11 @@ struct cfsrvl {
 	bool phy_flow_on;
 	bool modem_flow_on;
 	bool supports_flowctrl;
-	void (*release)(struct kref *);
+	void (*release)(struct cflayer *layer);
 	struct dev_info dev_info;
-	struct kref ref;
+	void (*hold)(struct cflayer *lyr);
+	void (*put)(struct cflayer *lyr);
+	struct rcu_head rcu;
 };
=20
 struct cflayer *cfvei_create(u8 linkid, struct dev_info *dev_info);
@@ -29,6 +32,10 @@ struct cflayer *cfvidl_create(u8 linkid, struct dev_=
info *dev_info);
 struct cflayer *cfrfml_create(u8 linkid, struct dev_info *dev_info,
 				int mtu_size);
 struct cflayer *cfdbgl_create(u8 linkid, struct dev_info *dev_info);
+
+void cfsrvl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
+		     int phyid);
+
 bool cfsrvl_phyid_match(struct cflayer *layer, int phyid);
=20
 void cfsrvl_init(struct cfsrvl *service,
@@ -40,23 +47,19 @@ u8 cfsrvl_getphyid(struct cflayer *layer);
=20
 static inline void cfsrvl_get(struct cflayer *layr)
 {
-	struct cfsrvl *s;
-	if (layr =3D=3D NULL)
+	struct cfsrvl *s =3D container_of(layr, struct cfsrvl, layer);
+	if (layr =3D=3D NULL || layr->up =3D=3D NULL || s->hold =3D=3D NULL)
 		return;
-	s =3D container_of(layr, struct cfsrvl, layer);
-	kref_get(&s->ref);
+
+	s->hold(layr->up);
 }
=20
 static inline void cfsrvl_put(struct cflayer *layr)
 {
-	struct cfsrvl *s;
-	if (layr =3D=3D NULL)
+	struct cfsrvl *s =3D container_of(layr, struct cfsrvl, layer);
+	if (layr =3D=3D NULL || layr->up =3D=3D NULL || s->hold =3D=3D NULL)
 		return;
-	s =3D container_of(layr, struct cfsrvl, layer);
=20
-	WARN_ON(!s->release);
-	if (s->release)
-		kref_put(&s->ref, s->release);
+	s->put(layr->up);
 }
-
 #endif				/* CFSRVL_H_ */
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index e2fb5fa..0deabb4 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -31,9 +31,9 @@ struct cfrfml {
 	spinlock_t sync;
 };
=20
-static void cfrfml_release(struct kref *kref)
+static void cfrfml_release(struct cflayer *layer)
 {
-	struct cfsrvl *srvl =3D container_of(kref, struct cfsrvl, ref);
+	struct cfsrvl *srvl =3D container_of(layer, struct cfsrvl, layer);
 	struct cfrfml *rfml =3D container_obj(&srvl->layer);
=20
 	if (rfml->incomplete_frm)
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index 24ba392..535a1e7 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -10,6 +10,7 @@
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/slab.h>
+#include <linux/module.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfsrvl.h>
 #include <net/caif/cfpkt.h>
@@ -27,8 +28,8 @@ static void cfservl_ctrlcmd(struct cflayer *layr, enu=
m caif_ctrlcmd ctrl,
 {
 	struct cfsrvl *service =3D container_obj(layr);
=20
-	caif_assert(layr->up !=3D NULL);
-	caif_assert(layr->up->ctrlcmd !=3D NULL);
+	if (layr->up =3D=3D NULL || layr->up->ctrlcmd =3D=3D NULL)
+		return;
=20
 	switch (ctrl) {
 	case CAIF_CTRLCMD_INIT_RSP:
@@ -151,9 +152,9 @@ static int cfservl_modemcmd(struct cflayer *layr, e=
num caif_modemcmd ctrl)
 	return -EINVAL;
 }
=20
-static void cfsrvl_release(struct kref *kref)
+static void cfsrvl_release(struct cflayer *layer)
 {
-	struct cfsrvl *service =3D container_of(kref, struct cfsrvl, ref);
+	struct cfsrvl *service =3D container_of(layer, struct cfsrvl, layer);
 	kfree(service);
 }
=20
@@ -173,10 +174,8 @@ void cfsrvl_init(struct cfsrvl *service,
 	service->dev_info =3D *dev_info;
 	service->supports_flowctrl =3D supports_flowctrl;
 	service->release =3D cfsrvl_release;
-	kref_init(&service->ref);
 }
=20
-
 bool cfsrvl_ready(struct cfsrvl *service, int *err)
 {
 	if (service->open && service->modem_flow_on && service->phy_flow_on)
@@ -189,6 +188,7 @@ bool cfsrvl_ready(struct cfsrvl *service, int *err)
 	*err =3D -EAGAIN;
 	return false;
 }
+
 u8 cfsrvl_getphyid(struct cflayer *layer)
 {
 	struct cfsrvl *servl =3D container_obj(layer);
@@ -200,3 +200,26 @@ bool cfsrvl_phyid_match(struct cflayer *layer, int=
 phyid)
 	struct cfsrvl *servl =3D container_obj(layer);
 	return servl->dev_info.id =3D=3D phyid;
 }
+
+void caif_free_client(struct cflayer *adap_layer)
+{
+	struct cfsrvl *servl;
+	if (adap_layer =3D=3D NULL || adap_layer->dn =3D=3D NULL)
+		return;
+	servl =3D container_obj(adap_layer->dn);
+	servl->release(&servl->layer);
+}
+EXPORT_SYMBOL(caif_free_client);
+
+void caif_client_register_refcnt(struct cflayer *adapt_layer,
+					void (*hold)(struct cflayer *lyr),
+					void (*put)(struct cflayer *lyr))
+{
+	struct cfsrvl *service;
+	service =3D container_of(adapt_layer->dn, struct cfsrvl, layer);
+
+	WARN_ON(adapt_layer =3D=3D NULL || adapt_layer->dn =3D=3D NULL);
+	service->hold =3D hold;
+	service->put =3D put;
+}
+EXPORT_SYMBOL(caif_client_register_refcnt);
--=20
1.7.1

