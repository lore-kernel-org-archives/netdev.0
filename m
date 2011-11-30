From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 2/3] caif: Restructure how link caif link layer enroll
Date: Wed, 30 Nov 2011 20:22:47 +0100
Message-ID: <1322680968-6470-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1322680968-6470-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38508 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab1K3TXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 14:23:12 -0500
Received: by eaak14 with SMTP id k14so1102392eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 11:23:11 -0800 (PST)
In-Reply-To: <1322680968-6470-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrolling CAIF link layers are refactored.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h |   21 ++++++
 include/net/caif/cfcnfg.h   |    9 ++-
 net/caif/caif_dev.c         |  145 ++++++++++++++++++++++++++---------=
-------
 net/caif/cfcnfg.c           |   47 +++++---------
 4 files changed, 132 insertions(+), 90 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index c011281..ef2dd94 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -9,6 +9,7 @@
=20
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfcnfg.h>
+#include <net/caif/caif_device.h>
 #include <linux/caif/caif_socket.h>
 #include <linux/if.h>
 #include <linux/net.h>
@@ -104,4 +105,24 @@ void caif_client_register_refcnt(struct cflayer *a=
dapt_layer,
  */
 void caif_free_client(struct cflayer *adap_layer);
=20
+/**
+ * struct caif_enroll_dev - Enroll a net-device as a CAIF Link layer
+ * @dev:		Network device to enroll.
+ * @caifdev:		Configuration information from CAIF Link Layer
+ * @link_support:	Link layer support layer
+ * @head_room:		Head room needed by link support layer
+ * @layer:		Lowest layer in CAIF stack
+ * @rcv_fun:		Receive function for CAIF stack.
+ *
+ * This function enroll a CAIF link layer into CAIF Stack and
+ * expects the interface to be able to handle CAIF payload.
+ * The link_support layer is used to add any Link Layer specific
+ * framing.
+ */
+void caif_enroll_dev(struct net_device *dev, struct caif_dev_common *c=
aifdev,
+			struct cflayer *link_support, int head_room,
+			struct cflayer **layer, int (**rcv_func)(
+				struct sk_buff *, struct net_device *,
+				struct packet_type *, struct net_device *));
+
 #endif /* CAIF_DEV_H_ */
diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index 3e93a4a..a421723 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -72,15 +72,16 @@ void cfcnfg_remove(struct cfcnfg *cfg);
  * @phy_layer:	Specify the physical layer. The transmit function
  *		MUST be set in the structure.
  * @pref:	The phy (link layer) preference.
+ * @link_support: Protocol implementation for link layer specific prot=
ocol.
  * @fcs:	Specify if checksum is used in CAIF Framing Layer.
- * @stx:	Specify if Start Of Frame eXtention is used.
+ * @head_room:	Head space needed by link specific protocol.
  */
-
 void
-cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_typ=
e,
+cfcnfg_add_phy_layer(struct cfcnfg *cnfg,
 		     struct net_device *dev, struct cflayer *phy_layer,
 		     enum cfcnfg_phy_preference pref,
-		     bool fcs, bool stx);
+		     struct cflayer *link_support,
+		     bool fcs, int head_room);
=20
 /**
  * cfcnfg_del_phy_layer - Deletes an phy layer from the CAIF stack.
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index f1fa1f6..70034c0 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -24,6 +24,7 @@
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/cfcnfg.h>
+#include <net/caif/cfserl.h>
=20
 MODULE_LICENSE("GPL");
=20
@@ -53,7 +54,8 @@ struct cfcnfg *get_cfcnfg(struct net *net)
 	struct caif_net *caifn;
 	BUG_ON(!net);
 	caifn =3D net_generic(net, caif_net_id);
-	BUG_ON(!caifn);
+	if (!caifn)
+		return NULL;
 	return caifn->cfg;
 }
 EXPORT_SYMBOL(get_cfcnfg);
@@ -63,7 +65,8 @@ static struct caif_device_entry_list *caif_device_lis=
t(struct net *net)
 	struct caif_net *caifn;
 	BUG_ON(!net);
 	caifn =3D net_generic(net, caif_net_id);
-	BUG_ON(!caifn);
+	if (!caifn)
+		return NULL;
 	return &caifn->caifdevs;
 }
=20
@@ -92,7 +95,8 @@ static struct caif_device_entry *caif_device_alloc(st=
ruct net_device *dev)
 	struct caif_device_entry *caifd;
=20
 	caifdevs =3D caif_device_list(dev_net(dev));
-	BUG_ON(!caifdevs);
+	if (!caifdevs)
+		return NULL;
=20
 	caifd =3D kzalloc(sizeof(*caifd), GFP_KERNEL);
 	if (!caifd)
@@ -112,7 +116,9 @@ static struct caif_device_entry *caif_get(struct ne=
t_device *dev)
 	struct caif_device_entry_list *caifdevs =3D
 	    caif_device_list(dev_net(dev));
 	struct caif_device_entry *caifd;
-	BUG_ON(!caifdevs);
+	if (!caifdevs)
+		return NULL;
+
 	list_for_each_entry_rcu(caifd, &caifdevs->list, list) {
 		if (caifd->netdev =3D=3D dev)
 			return caifd;
@@ -129,6 +135,8 @@ static int transmit(struct cflayer *layer, struct c=
fpkt *pkt)
=20
 	skb =3D cfpkt_tonative(pkt);
 	skb->dev =3D caifd->netdev;
+	skb_reset_network_header(skb);
+	skb->protocol =3D htons(ETH_P_CAIF);
=20
 	err =3D dev_queue_xmit(skb);
 	if (err > 0)
@@ -172,7 +180,10 @@ static int receive(struct sk_buff *skb, struct net=
_device *dev,
=20
 	/* Release reference to stack upwards */
 	caifd_put(caifd);
-	return 0;
+
+	if (err !=3D 0)
+		err =3D NET_RX_DROP;
+	return err;
 }
=20
 static struct packet_type caif_packet_type __read_mostly =3D {
@@ -203,6 +214,55 @@ static void dev_flowctrl(struct net_device *dev, i=
nt on)
 	caifd_put(caifd);
 }
=20
+void caif_enroll_dev(struct net_device *dev, struct caif_dev_common *c=
aifdev,
+			struct cflayer *link_support, int head_room,
+			struct cflayer **layer, int (**rcv_func)(
+				struct sk_buff *, struct net_device *,
+				struct packet_type *, struct net_device *))
+{
+	struct caif_device_entry *caifd;
+	enum cfcnfg_phy_preference pref;
+	struct cfcnfg *cfg =3D get_cfcnfg(dev_net(dev));
+	struct caif_device_entry_list *caifdevs;
+
+	caifdevs =3D caif_device_list(dev_net(dev));
+	if (!cfg || !caifdevs)
+		return;
+	caifd =3D caif_device_alloc(dev);
+	if (!caifd)
+		return;
+	*layer =3D &caifd->layer;
+
+	switch (caifdev->link_select) {
+	case CAIF_LINK_HIGH_BANDW:
+		pref =3D CFPHYPREF_HIGH_BW;
+		break;
+	case CAIF_LINK_LOW_LATENCY:
+		pref =3D CFPHYPREF_LOW_LAT;
+		break;
+	default:
+		pref =3D CFPHYPREF_HIGH_BW;
+		break;
+	}
+	mutex_lock(&caifdevs->lock);
+	list_add_rcu(&caifd->list, &caifdevs->list);
+
+	strncpy(caifd->layer.name, dev->name,
+		sizeof(caifd->layer.name) - 1);
+	caifd->layer.name[sizeof(caifd->layer.name) - 1] =3D 0;
+	caifd->layer.transmit =3D transmit;
+	cfcnfg_add_phy_layer(cfg,
+				dev,
+				&caifd->layer,
+				pref,
+				link_support,
+				caifdev->use_fcs,
+				head_room);
+	mutex_unlock(&caifdevs->lock);
+	if (rcv_func)
+		*rcv_func =3D receive;
+}
+
 /* notify Caif of device events */
 static int caif_device_notify(struct notifier_block *me, unsigned long=
 what,
 			      void *arg)
@@ -210,62 +270,40 @@ static int caif_device_notify(struct notifier_blo=
ck *me, unsigned long what,
 	struct net_device *dev =3D arg;
 	struct caif_device_entry *caifd =3D NULL;
 	struct caif_dev_common *caifdev;
-	enum cfcnfg_phy_preference pref;
-	enum cfcnfg_phy_type phy_type;
 	struct cfcnfg *cfg;
+	struct cflayer *layer, *link_support;
+	int head_room =3D 0;
 	struct caif_device_entry_list *caifdevs;
=20
-	if (dev->type !=3D ARPHRD_CAIF)
-		return 0;
-
 	cfg =3D get_cfcnfg(dev_net(dev));
-	if (cfg =3D=3D NULL)
+	caifdevs =3D caif_device_list(dev_net(dev));
+	if (!cfg || !caifdevs)
 		return 0;
=20
-	caifdevs =3D caif_device_list(dev_net(dev));
+	caifd =3D caif_get(dev);
+	if (caifd =3D=3D NULL && dev->type !=3D ARPHRD_CAIF)
+		return 0;
=20
 	switch (what) {
 	case NETDEV_REGISTER:
-		caifd =3D caif_device_alloc(dev);
-		if (!caifd)
-			return 0;
+		if (caifd !=3D NULL)
+			break;
=20
 		caifdev =3D netdev_priv(dev);
-		caifdev->flowctrl =3D dev_flowctrl;
=20
-		caifd->layer.transmit =3D transmit;
-
-		if (caifdev->use_frag)
-			phy_type =3D CFPHYTYPE_FRAG;
-		else
-			phy_type =3D CFPHYTYPE_CAIF;
-
-		switch (caifdev->link_select) {
-		case CAIF_LINK_HIGH_BANDW:
-			pref =3D CFPHYPREF_HIGH_BW;
-			break;
-		case CAIF_LINK_LOW_LATENCY:
-			pref =3D CFPHYPREF_LOW_LAT;
-			break;
-		default:
-			pref =3D CFPHYPREF_HIGH_BW;
-			break;
+		link_support =3D NULL;
+		if (caifdev->use_frag) {
+			head_room =3D 1;
+			link_support =3D cfserl_create(dev->ifindex,
+					CFPHYTYPE_FRAG, caifdev->use_stx);
+			if (!link_support) {
+				pr_warn("Out of memory\n");
+				break;
+			}
 		}
-		strncpy(caifd->layer.name, dev->name,
-			sizeof(caifd->layer.name) - 1);
-		caifd->layer.name[sizeof(caifd->layer.name) - 1] =3D 0;
-
-		mutex_lock(&caifdevs->lock);
-		list_add_rcu(&caifd->list, &caifdevs->list);
-
-		cfcnfg_add_phy_layer(cfg,
-				     phy_type,
-				     dev,
-				     &caifd->layer,
-				     pref,
-				     caifdev->use_fcs,
-				     caifdev->use_stx);
-		mutex_unlock(&caifdevs->lock);
+		caif_enroll_dev(dev, caifdev, link_support, head_room,
+				&layer, NULL);
+		caifdev->flowctrl =3D dev_flowctrl;
 		break;
=20
 	case NETDEV_UP:
@@ -371,17 +409,14 @@ static void caif_exit_net(struct net *net)
 	struct caif_device_entry *caifd, *tmp;
 	struct caif_device_entry_list *caifdevs =3D
 	    caif_device_list(net);
-	struct cfcnfg *cfg;
+	struct cfcnfg *cfg =3D  get_cfcnfg(net);
+
+	if (!cfg || !caifdevs)
+		return;
=20
 	rtnl_lock();
 	mutex_lock(&caifdevs->lock);
=20
-	cfg =3D get_cfcnfg(net);
-	if (cfg =3D=3D NULL) {
-		mutex_unlock(&caifdevs->lock);
-		return;
-	}
-
 	list_for_each_entry_safe(caifd, tmp, &caifdevs->list, list) {
 		int i =3D 0;
 		list_del_rcu(&caifd->list);
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 00523ec..598aafb 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -45,8 +45,8 @@ struct cfcnfg_phyinfo {
 	/* Interface index */
 	int ifindex;
=20
-	/* Use Start of frame extension */
-	bool use_stx;
+	/* Protocol head room added for CAIF link layer */
+	int head_room;
=20
 	/* Use Start of frame checksum */
 	bool use_fcs;
@@ -187,11 +187,11 @@ int caif_disconnect_client(struct net *net, struc=
t cflayer *adap_layer)
 	if (channel_id !=3D 0) {
 		struct cflayer *servl;
 		servl =3D cfmuxl_remove_uplayer(cfg->mux, channel_id);
+		cfctrl_linkdown_req(cfg->ctrl, channel_id, adap_layer);
 		if (servl !=3D NULL)
 			layer_set_up(servl, NULL);
 	} else
 		pr_debug("nothing to disconnect\n");
-	cfctrl_linkdown_req(cfg->ctrl, channel_id, adap_layer);
=20
 	/* Do RCU sync before initiating cleanup */
 	synchronize_rcu();
@@ -350,9 +350,7 @@ int caif_connect_client(struct net *net, struct cai=
f_connect_request *conn_req,
=20
 	*ifindex =3D phy->ifindex;
 	*proto_tail =3D 2;
-	*proto_head =3D
-
-	protohead[param.linktype] + (phy->use_stx ? 1 : 0);
+	*proto_head =3D protohead[param.linktype] + phy->head_room;
=20
 	rcu_read_unlock();
=20
@@ -460,13 +458,13 @@ unlock:
 }
=20
 void
-cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_typ=
e,
+cfcnfg_add_phy_layer(struct cfcnfg *cnfg,
 		     struct net_device *dev, struct cflayer *phy_layer,
 		     enum cfcnfg_phy_preference pref,
-		     bool fcs, bool stx)
+		     struct cflayer *link_support,
+		     bool fcs, int head_room)
 {
 	struct cflayer *frml;
-	struct cflayer *phy_driver =3D NULL;
 	struct cfcnfg_phyinfo *phyinfo =3D NULL;
 	int i;
 	u8 phyid;
@@ -482,26 +480,13 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cf=
cnfg_phy_type phy_type,
 			goto got_phyid;
 	}
 	pr_warn("Too many CAIF Link Layers (max 6)\n");
-	goto out_err;
+	goto out;
=20
 got_phyid:
 	phyinfo =3D kzalloc(sizeof(struct cfcnfg_phyinfo), GFP_ATOMIC);
 	if (!phyinfo)
 		goto out_err;
=20
-	switch (phy_type) {
-	case CFPHYTYPE_FRAG:
-		phy_driver =3D
-		    cfserl_create(CFPHYTYPE_FRAG, phyid, stx);
-		if (!phy_driver)
-			goto out_err;
-		break;
-	case CFPHYTYPE_CAIF:
-		phy_driver =3D NULL;
-		break;
-	default:
-		goto out_err;
-	}
 	phy_layer->id =3D phyid;
 	phyinfo->pref =3D pref;
 	phyinfo->id =3D phyid;
@@ -509,7 +494,7 @@ got_phyid:
 	phyinfo->dev_info.dev =3D dev;
 	phyinfo->phy_layer =3D phy_layer;
 	phyinfo->ifindex =3D dev->ifindex;
-	phyinfo->use_stx =3D stx;
+	phyinfo->head_room =3D head_room;
 	phyinfo->use_fcs =3D fcs;
=20
 	frml =3D cffrml_create(phyid, fcs);
@@ -519,23 +504,23 @@ got_phyid:
 	phyinfo->frm_layer =3D frml;
 	layer_set_up(frml, cnfg->mux);
=20
-	if (phy_driver !=3D NULL) {
-		phy_driver->id =3D phyid;
-		layer_set_dn(frml, phy_driver);
-		layer_set_up(phy_driver, frml);
-		layer_set_dn(phy_driver, phy_layer);
-		layer_set_up(phy_layer, phy_driver);
+	if (link_support !=3D NULL) {
+		link_support->id =3D phyid;
+		layer_set_dn(frml, link_support);
+		layer_set_up(link_support, frml);
+		layer_set_dn(link_support, phy_layer);
+		layer_set_up(phy_layer, link_support);
 	} else {
 		layer_set_dn(frml, phy_layer);
 		layer_set_up(phy_layer, frml);
 	}
=20
 	list_add_rcu(&phyinfo->node, &cnfg->phys);
+out:
 	mutex_unlock(&cnfg->lock);
 	return;
=20
 out_err:
-	kfree(phy_driver);
 	kfree(phyinfo);
 	mutex_unlock(&cnfg->lock);
 }
--=20
1.7.0.4
