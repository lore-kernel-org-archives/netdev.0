From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 01/10] caif: Use rcu_read_lock in CAIF mux layer.
Date: Fri, 13 May 2011 14:43:59 +0200
Message-ID: <1305290648-9613-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:54330 "EHLO
	slow1.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758943Ab1EMNBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:01:02 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow1.isp.as2116.net (Postfix) with ESMTP id B73A7800E5
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:08 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace spin_lock with rcu_read_lock when accessing lists to layers
and cache. While packets are in flight rcu_read_lock should not be held=
,
instead ref-counters are used in combination with RCU.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cffrml.h |    2 +
 net/caif/cffrml.c         |    8 +++
 net/caif/cfmuxl.c         |  119 ++++++++++++++++++++++++++++---------=
--------
 3 files changed, 85 insertions(+), 44 deletions(-)

diff --git a/include/net/caif/cffrml.h b/include/net/caif/cffrml.h
index 3f14d2e..4f126d7 100644
--- a/include/net/caif/cffrml.h
+++ b/include/net/caif/cffrml.h
@@ -12,5 +12,7 @@ struct cffrml;
 struct cflayer *cffrml_create(u16 phyid, bool DoFCS);
 void cffrml_set_uplayer(struct cflayer *this, struct cflayer *up);
 void cffrml_set_dnlayer(struct cflayer *this, struct cflayer *dn);
+void cffrml_put(struct cflayer *layr);
+void cffrml_hold(struct cflayer *layr);
=20
 #endif /* CFFRML_H_ */
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index 2423fed..f4b8892 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -145,3 +145,11 @@ static void cffrml_ctrlcmd(struct cflayer *layr, e=
num caif_ctrlcmd ctrl,
 	if (layr->up->ctrlcmd)
 		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
 }
+
+void cffrml_put(struct cflayer *layr)
+{
+}
+
+void cffrml_hold(struct cflayer *layr)
+{
+}
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index fc24974..2a56df7 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -9,6 +9,7 @@
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
+#include <linux/rculist.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/cfmuxl.h>
 #include <net/caif/cfsrvl.h>
@@ -64,31 +65,31 @@ struct cflayer *cfmuxl_create(void)
 int cfmuxl_set_uplayer(struct cflayer *layr, struct cflayer *up, u8 li=
nkid)
 {
 	struct cfmuxl *muxl =3D container_obj(layr);
-	spin_lock(&muxl->receive_lock);
-	cfsrvl_get(up);
-	list_add(&up->node, &muxl->srvl_list);
-	spin_unlock(&muxl->receive_lock);
+
+	spin_lock_bh(&muxl->receive_lock);
+	list_add_rcu(&up->node, &muxl->srvl_list);
+	spin_unlock_bh(&muxl->receive_lock);
 	return 0;
 }
=20
 int cfmuxl_set_dnlayer(struct cflayer *layr, struct cflayer *dn, u8 ph=
yid)
 {
 	struct cfmuxl *muxl =3D (struct cfmuxl *) layr;
-	spin_lock(&muxl->transmit_lock);
-	list_add(&dn->node, &muxl->frml_list);
-	spin_unlock(&muxl->transmit_lock);
+
+	spin_lock_bh(&muxl->transmit_lock);
+	list_add_rcu(&dn->node, &muxl->frml_list);
+	spin_unlock_bh(&muxl->transmit_lock);
 	return 0;
 }
=20
 static struct cflayer *get_from_id(struct list_head *list, u16 id)
 {
-	struct list_head *node;
-	struct cflayer *layer;
-	list_for_each(node, list) {
-		layer =3D list_entry(node, struct cflayer, node);
-		if (layer->id =3D=3D id)
-			return layer;
+	struct cflayer *lyr;
+	list_for_each_entry_rcu(lyr, list, node) {
+		if (lyr->id =3D=3D id)
+			return lyr;
 	}
+
 	return NULL;
 }
=20
@@ -96,41 +97,45 @@ struct cflayer *cfmuxl_remove_dnlayer(struct cflaye=
r *layr, u8 phyid)
 {
 	struct cfmuxl *muxl =3D container_obj(layr);
 	struct cflayer *dn;
-	spin_lock(&muxl->transmit_lock);
-	memset(muxl->dn_cache, 0, sizeof(muxl->dn_cache));
+	int idx =3D phyid % DN_CACHE_SIZE;
+
+	spin_lock_bh(&muxl->transmit_lock);
+	rcu_assign_pointer(muxl->dn_cache[idx], NULL);
 	dn =3D get_from_id(&muxl->frml_list, phyid);
-	if (dn =3D=3D NULL) {
-		spin_unlock(&muxl->transmit_lock);
-		return NULL;
-	}
-	list_del(&dn->node);
+	if (dn =3D=3D NULL)
+		goto out;
+
+	list_del_rcu(&dn->node);
 	caif_assert(dn !=3D NULL);
-	spin_unlock(&muxl->transmit_lock);
+out:
+	spin_unlock_bh(&muxl->transmit_lock);
 	return dn;
 }
=20
-/* Invariant: lock is taken */
 static struct cflayer *get_up(struct cfmuxl *muxl, u16 id)
 {
 	struct cflayer *up;
 	int idx =3D id % UP_CACHE_SIZE;
-	up =3D muxl->up_cache[idx];
+	up =3D rcu_dereference(muxl->up_cache[idx]);
 	if (up =3D=3D NULL || up->id !=3D id) {
+		spin_lock_bh(&muxl->receive_lock);
 		up =3D get_from_id(&muxl->srvl_list, id);
-		muxl->up_cache[idx] =3D up;
+		rcu_assign_pointer(muxl->up_cache[idx], up);
+		spin_unlock_bh(&muxl->receive_lock);
 	}
 	return up;
 }
=20
-/* Invariant: lock is taken */
 static struct cflayer *get_dn(struct cfmuxl *muxl, struct dev_info *de=
v_info)
 {
 	struct cflayer *dn;
 	int idx =3D dev_info->id % DN_CACHE_SIZE;
-	dn =3D muxl->dn_cache[idx];
+	dn =3D rcu_dereference(muxl->dn_cache[idx]);
 	if (dn =3D=3D NULL || dn->id !=3D dev_info->id) {
+		spin_lock_bh(&muxl->transmit_lock);
 		dn =3D get_from_id(&muxl->frml_list, dev_info->id);
-		muxl->dn_cache[idx] =3D dn;
+		rcu_assign_pointer(muxl->dn_cache[idx], dn);
+		spin_unlock_bh(&muxl->transmit_lock);
 	}
 	return dn;
 }
@@ -139,15 +144,17 @@ struct cflayer *cfmuxl_remove_uplayer(struct cfla=
yer *layr, u8 id)
 {
 	struct cflayer *up;
 	struct cfmuxl *muxl =3D container_obj(layr);
-	spin_lock(&muxl->receive_lock);
-	up =3D get_up(muxl, id);
+	int idx =3D id % UP_CACHE_SIZE;
+
+	spin_lock_bh(&muxl->receive_lock);
+	up =3D get_from_id(&muxl->srvl_list, id);
 	if (up =3D=3D NULL)
 		goto out;
-	memset(muxl->up_cache, 0, sizeof(muxl->up_cache));
-	list_del(&up->node);
-	cfsrvl_put(up);
+
+	rcu_assign_pointer(muxl->up_cache[idx], NULL);
+	list_del_rcu(&up->node);
 out:
-	spin_unlock(&muxl->receive_lock);
+	spin_unlock_bh(&muxl->receive_lock);
 	return up;
 }
=20
@@ -162,22 +169,28 @@ static int cfmuxl_receive(struct cflayer *layr, s=
truct cfpkt *pkt)
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
-
-	spin_lock(&muxl->receive_lock);
+	rcu_read_lock();
 	up =3D get_up(muxl, id);
-	spin_unlock(&muxl->receive_lock);
+
 	if (up =3D=3D NULL) {
-		pr_info("Received data on unknown link ID =3D %d (0x%x) up =3D=3D NU=
LL",
-			id, id);
+		pr_debug("Received data on unknown link ID =3D %d (0x%x)"
+			" up =3D=3D NULL", id, id);
 		cfpkt_destroy(pkt);
 		/*
 		 * Don't return ERROR, since modem misbehaves and sends out
 		 * flow on before linksetup response.
 		 */
+
+		rcu_read_unlock();
 		return /* CFGLU_EPROT; */ 0;
 	}
+
+	/* We can't hold rcu_lock during receive, so take a ref count instead=
 */
 	cfsrvl_get(up);
+	rcu_read_unlock();
+
 	ret =3D up->receive(up, pkt);
+
 	cfsrvl_put(up);
 	return ret;
 }
@@ -185,31 +198,49 @@ static int cfmuxl_receive(struct cflayer *layr, s=
truct cfpkt *pkt)
 static int cfmuxl_transmit(struct cflayer *layr, struct cfpkt *pkt)
 {
 	struct cfmuxl *muxl =3D container_obj(layr);
+	int err;
 	u8 linkid;
 	struct cflayer *dn;
 	struct caif_payload_info *info =3D cfpkt_info(pkt);
 	BUG_ON(!info);
+
+	rcu_read_lock();
+
 	dn =3D get_dn(muxl, info->dev_info);
 	if (dn =3D=3D NULL) {
-		pr_warn("Send data on unknown phy ID =3D %d (0x%x)\n",
+		pr_debug("Send data on unknown phy ID =3D %d (0x%x)\n",
 			info->dev_info->id, info->dev_info->id);
+		rcu_read_unlock();
+		cfpkt_destroy(pkt);
 		return -ENOTCONN;
 	}
+
 	info->hdr_len +=3D 1;
 	linkid =3D info->channel_id;
 	cfpkt_add_head(pkt, &linkid, 1);
-	return dn->transmit(dn, pkt);
+
+	/* We can't hold rcu_lock during receive, so take a ref count instead=
 */
+	cffrml_hold(dn);
+
+	rcu_read_unlock();
+
+	err =3D dn->transmit(dn, pkt);
+
+	cffrml_put(dn);
+	return err;
 }
=20
 static void cfmuxl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctr=
l,
 				int phyid)
 {
 	struct cfmuxl *muxl =3D container_obj(layr);
-	struct list_head *node, *next;
 	struct cflayer *layer;
-	list_for_each_safe(node, next, &muxl->srvl_list) {
-		layer =3D list_entry(node, struct cflayer, node);
-		if (cfsrvl_phyid_match(layer, phyid))
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(layer, &muxl->srvl_list, node) {
+		if (cfsrvl_phyid_match(layer, phyid) && layer->ctrlcmd)
+			/* NOTE: ctrlcmd is not allowed to block */
 			layer->ctrlcmd(layer, ctrl, phyid);
 	}
+	rcu_read_unlock();
 }
--=20
1.7.1

