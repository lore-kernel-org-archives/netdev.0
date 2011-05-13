From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 04/10] caif: Add ref-count to framing layer
Date: Fri, 13 May 2011 14:44:02 +0200
Message-ID: <1305290648-9613-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:29698 "EHLO
	slow1.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758843Ab1EMNQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:16:22 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow1.isp.as2116.net (Postfix) with ESMTP id 7553B80165
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:33 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce Per-cpu reference for lower part of CAIF Stack.
Before freeing payload is disabled, synchronize_rcu() is called,
and then ref-count verified to be zero.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cffrml.h |    5 ++++-
 net/caif/cfcnfg.c         |    9 ++++++++-
 net/caif/cffrml.c         |   31 +++++++++++++++++++++++++++++++
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/net/caif/cffrml.h b/include/net/caif/cffrml.h
index 4f126d7..afac1a4 100644
--- a/include/net/caif/cffrml.h
+++ b/include/net/caif/cffrml.h
@@ -7,12 +7,15 @@
 #ifndef CFFRML_H_
 #define CFFRML_H_
 #include <net/caif/caif_layer.h>
+#include <linux/netdevice.h>
=20
 struct cffrml;
-struct cflayer *cffrml_create(u16 phyid, bool DoFCS);
+struct cflayer *cffrml_create(u16 phyid, bool use_fcs);
+void cffrml_free(struct cflayer *layr);
 void cffrml_set_uplayer(struct cflayer *this, struct cflayer *up);
 void cffrml_set_dnlayer(struct cflayer *this, struct cflayer *dn);
 void cffrml_put(struct cflayer *layr);
 void cffrml_hold(struct cflayer *layr);
+int cffrml_refcnt_read(struct cflayer *layr);
=20
 #endif /* CFFRML_H_ */
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 7892cc0..3f4f31f 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -519,6 +519,13 @@ int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, stru=
ct cflayer *phy_layer)
 	caif_assert(phy_layer->id =3D=3D phyid);
 	caif_assert(phyinfo->frm_layer->id =3D=3D phyid);
=20
+	/* Fail if reference count is not zero */
+	if (cffrml_refcnt_read(phyinfo->frm_layer) !=3D 0) {
+		pr_info("Wait for device inuse\n");
+		mutex_unlock(&cnfg->lock);
+		return -EAGAIN;
+	}
+
 	list_del_rcu(&phyinfo->node);
 	synchronize_rcu();
=20
@@ -537,7 +544,7 @@ int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struc=
t cflayer *phy_layer)
 	if (phyinfo->phy_layer !=3D frml_dn)
 		kfree(frml_dn);
=20
-	kfree(frml);
+	cffrml_free(frml);
 	kfree(phyinfo);
 	mutex_unlock(&cnfg->lock);
=20
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index f4b8892..4f4f756 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -12,6 +12,7 @@
 #include <linux/spinlock.h>
 #include <linux/slab.h>
 #include <linux/crc-ccitt.h>
+#include <linux/netdevice.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/cffrml.h>
@@ -21,6 +22,7 @@
 struct cffrml {
 	struct cflayer layer;
 	bool dofcs;		/* !< FCS active */
+	int __percpu		*pcpu_refcnt;
 };
=20
 static int cffrml_receive(struct cflayer *layr, struct cfpkt *pkt);
@@ -31,12 +33,19 @@ static void cffrml_ctrlcmd(struct cflayer *layr, en=
um caif_ctrlcmd ctrl,
 static u32 cffrml_rcv_error;
 static u32 cffrml_rcv_checsum_error;
 struct cflayer *cffrml_create(u16 phyid, bool use_fcs)
+
 {
 	struct cffrml *this =3D kmalloc(sizeof(struct cffrml), GFP_ATOMIC);
 	if (!this) {
 		pr_warn("Out of memory\n");
 		return NULL;
 	}
+	this->pcpu_refcnt =3D alloc_percpu(int);
+	if (this->pcpu_refcnt =3D=3D NULL) {
+		kfree(this);
+		return NULL;
+	}
+
 	caif_assert(offsetof(struct cffrml, layer) =3D=3D 0);
=20
 	memset(this, 0, sizeof(struct cflayer));
@@ -49,6 +58,13 @@ struct cflayer *cffrml_create(u16 phyid, bool use_fc=
s)
 	return (struct cflayer *) this;
 }
=20
+void cffrml_free(struct cflayer *layer)
+{
+	struct cffrml *this =3D container_obj(layer);
+	free_percpu(this->pcpu_refcnt);
+	kfree(layer);
+}
+
 void cffrml_set_uplayer(struct cflayer *this, struct cflayer *up)
 {
 	this->up =3D up;
@@ -148,8 +164,23 @@ static void cffrml_ctrlcmd(struct cflayer *layr, e=
num caif_ctrlcmd ctrl,
=20
 void cffrml_put(struct cflayer *layr)
 {
+	struct cffrml *this =3D container_obj(layr);
+	if (layr !=3D NULL && this->pcpu_refcnt !=3D NULL)
+		irqsafe_cpu_dec(*this->pcpu_refcnt);
 }
=20
 void cffrml_hold(struct cflayer *layr)
 {
+	struct cffrml *this =3D container_obj(layr);
+	if (layr !=3D NULL && this->pcpu_refcnt !=3D NULL)
+		irqsafe_cpu_inc(*this->pcpu_refcnt);
+}
+
+int cffrml_refcnt_read(struct cflayer *layr)
+{
+	int i, refcnt =3D 0;
+	struct cffrml *this =3D container_obj(layr);
+	for_each_possible_cpu(i)
+		refcnt +=3D *per_cpu_ptr(this->pcpu_refcnt, i);
+	return refcnt;
 }
--=20
1.7.1

