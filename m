From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 07/10] caif: prepare support for namespaces
Date: Fri, 13 May 2011 14:44:05 +0200
Message-ID: <1305290648-9613-8-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:49808 "EHLO
	slow1.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932800Ab1EMNQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:16:04 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow1.isp.as2116.net (Postfix) with ESMTP id AD6C980170
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:33 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use struct net to reference CAIF configuration object instead of static=
 variables.
Refactor functions caif_connect_client, caif_disconnect_client and squa=
ch
files cfcnfg.c and caif_config_utils.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h |   24 ++-----
 include/net/caif/cfcnfg.h   |   71 +++------------------
 net/caif/Makefile           |    2 +-
 net/caif/caif_config_util.c |   99 -----------------------------
 net/caif/caif_dev.c         |   77 +++++++++++------------
 net/caif/caif_socket.c      |    6 +-
 net/caif/cfcnfg.c           |  146 ++++++++++++++++++++++++++++++++++-=
--------
 net/caif/chnl_net.c         |   12 ++--
 8 files changed, 176 insertions(+), 261 deletions(-)
 delete mode 100644 net/caif/caif_config_util.c

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index 6638435..c011281 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -11,6 +11,7 @@
 #include <net/caif/cfcnfg.h>
 #include <linux/caif/caif_socket.h>
 #include <linux/if.h>
+#include <linux/net.h>
=20
 /**
  * struct caif_param - CAIF parameters.
@@ -62,16 +63,18 @@ struct caif_connect_request {
  * E.g. CAIF Socket will call this function for each socket it connect=
s
  * and have one client_layer instance for each socket.
  */
-int caif_connect_client(struct caif_connect_request *conn_req,
+int caif_connect_client(struct net *net,
+			struct caif_connect_request *conn_req,
 			struct cflayer *client_layer, int *ifindex,
 			int *headroom, int *tailroom);
=20
 /**
  * caif_disconnect_client - Disconnects a client from the CAIF stack.
  *
- * @client_layer: Client layer to be removed.
+ * @client_layer: Client layer to be disconnected.
  */
-int caif_disconnect_client(struct cflayer *client_layer);
+int caif_disconnect_client(struct net *net, struct cflayer *client_lay=
er);
+
=20
 /**
  * caif_client_register_refcnt - register ref-count functions provided=
 by client.
@@ -91,21 +94,6 @@ void caif_client_register_refcnt(struct cflayer *ada=
pt_layer,
 					void (*hold)(struct cflayer *lyr),
 					void (*put)(struct cflayer *lyr));
 /**
- * caif_connect_req_to_link_param - Translate configuration parameters
- *				    from socket format to internal format.
- * @cnfg:	Pointer to configuration handler
- * @con_req:	Configuration parameters supplied in function
- *		caif_connect_client
- * @channel_setup_param: Parameters supplied to the CAIF Core stack fo=
r
- *			 setting up channels.
- *
- */
-
-int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
-				   struct caif_connect_request *con_req,
-				   struct cfctrl_link_param *setup_param);
-
-/**
  * caif_free_client - Free memory used to manage the client in the CAI=
=46 Stack.
  *
  * @client_layer: Client layer to be removed.
diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index e0a1eb5..3e93a4a 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -46,6 +46,12 @@ enum cfcnfg_phy_preference {
 };
=20
 /**
+ * cfcnfg_create() - Get the CAIF configuration object given network.
+ * @net:	Network for the CAIF configuration object.
+ */
+struct cfcnfg *get_cfcnfg(struct net *net);
+
+/**
  * cfcnfg_create() - Create the CAIF configuration object.
  */
 struct cfcnfg *cfcnfg_create(void);
@@ -65,17 +71,15 @@ void cfcnfg_remove(struct cfcnfg *cfg);
  * @dev:	Pointer to link layer device
  * @phy_layer:	Specify the physical layer. The transmit function
  *		MUST be set in the structure.
- * @phyid:	The assigned physical ID for this layer, used in
- *		cfcnfg_add_adapt_layer to specify PHY for the link.
  * @pref:	The phy (link layer) preference.
  * @fcs:	Specify if checksum is used in CAIF Framing Layer.
- * @stx:	Specify if Start Of Frame extension is used.
+ * @stx:	Specify if Start Of Frame eXtention is used.
  */
=20
 void
 cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_typ=
e,
 		     struct net_device *dev, struct cflayer *phy_layer,
-		     u16 *phyid, enum cfcnfg_phy_preference pref,
+		     enum cfcnfg_phy_preference pref,
 		     bool fcs, bool stx);
=20
 /**
@@ -88,65 +92,6 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnf=
g_phy_type phy_type,
 int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct cflayer *phy_laye=
r);
=20
 /**
- * cfcnfg_disconn_adapt_layer - Disconnects an adaptation layer.
- *
- * @cnfg:	Pointer to a CAIF configuration object, created by
- *		cfcnfg_create().
- * @adap_layer: Adaptation layer to be removed.
- */
-int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg,
-			struct cflayer *adap_layer);
-
-/**
- * cfcnfg_release_adap_layer - Used by client to release the adaptatio=
n layer.
- *
- * @adap_layer: Adaptation layer.
- */
-void cfcnfg_release_adap_layer(struct cflayer *adap_layer);
-
-/**
- * cfcnfg_add_adaptation_layer - Add an adaptation layer to the CAIF s=
tack.
- *
- * The adaptation Layer is where the interface to application or highe=
r-level
- * driver functionality is implemented.
- *
- * @cnfg:		Pointer to a CAIF configuration object, created by
- *			cfcnfg_create().
- * @param:		Link setup parameters.
- * @adap_layer:		Specify the adaptation layer; the receive and
- *			flow-control functions MUST be set in the structure.
- * @ifindex:		Link layer interface index used for this connection.
- * @proto_head:		Protocol head-space needed by CAIF protocol,
- *			excluding link layer.
- * @proto_tail:		Protocol tail-space needed by CAIF protocol,
- *			excluding link layer.
- */
-int cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
-			    struct cfctrl_link_param *param,
-			    struct cflayer *adap_layer,
-			    int *ifindex,
-			    int *proto_head,
-			    int *proto_tail);
-
-/**
- * cfcnfg_get_phyid() - Get physical ID, given type.
- * Returns one of the physical interfaces matching the given type.
- * Zero if no match is found.
- * @cnfg:	Configuration object
- * @phy_pref:	Caif Link Layer preference
- */
-struct dev_info *cfcnfg_get_phyid(struct cfcnfg *cnfg,
-		     enum cfcnfg_phy_preference phy_pref);
-
-/**
- * cfcnfg_get_id_from_ifi() - Get the Physical Identifier of ifindex,
- * 			it matches caif physical id with the kernel interface id.
- * @cnfg:	Configuration object
- * @ifi:	ifindex obtained from socket.c bindtodevice.
- */
-int cfcnfg_get_id_from_ifi(struct cfcnfg *cnfg, int ifi);
-
-/**
  * cfcnfg_set_phy_state() - Set the state of the physical interface de=
vice.
  * @cnfg:	Configuration object
  * @phy_layer:	Physical Layer representation
diff --git a/net/caif/Makefile b/net/caif/Makefile
index 9d38e40..ebcd4e7 100644
--- a/net/caif/Makefile
+++ b/net/caif/Makefile
@@ -5,7 +5,7 @@ caif-y :=3D caif_dev.o \
 	cffrml.o cfveil.o cfdbgl.o\
 	cfserl.o cfdgml.o  \
 	cfrfml.o cfvidl.o cfutill.o \
-	cfsrvl.o cfpkt_skbuff.o caif_config_util.o
+	cfsrvl.o cfpkt_skbuff.o
=20
 obj-$(CONFIG_CAIF) +=3D caif.o
 obj-$(CONFIG_CAIF_NETDEV) +=3D chnl_net.o
diff --git a/net/caif/caif_config_util.c b/net/caif/caif_config_util.c
deleted file mode 100644
index 9b63e4e..0000000
--- a/net/caif/caif_config_util.c
+++ /dev/null
@@ -1,99 +0,0 @@
-/*
- * Copyright (C) ST-Ericsson AB 2010
- * Author:	Sjur Brendeland sjur.brandeland@stericsson.com
- * License terms: GNU General Public License (GPL) version 2
- */
-
-#include <linux/module.h>
-#include <linux/spinlock.h>
-#include <net/caif/cfctrl.h>
-#include <net/caif/cfcnfg.h>
-#include <net/caif/caif_dev.h>
-
-int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
-				   struct caif_connect_request *s,
-				   struct cfctrl_link_param *l)
-{
-	struct dev_info *dev_info;
-	enum cfcnfg_phy_preference pref;
-	int res;
-
-	memset(l, 0, sizeof(*l));
-	/* In caif protocol low value is high priority */
-	l->priority =3D CAIF_PRIO_MAX - s->priority + 1;
-
-	if (s->ifindex !=3D 0){
-		res =3D cfcnfg_get_id_from_ifi(cnfg, s->ifindex);
-		if (res < 0)
-			return res;
-		l->phyid =3D res;
-	}
-	else {
-		switch (s->link_selector) {
-		case CAIF_LINK_HIGH_BANDW:
-			pref =3D CFPHYPREF_HIGH_BW;
-			break;
-		case CAIF_LINK_LOW_LATENCY:
-			pref =3D CFPHYPREF_LOW_LAT;
-			break;
-		default:
-			return -EINVAL;
-		}
-		dev_info =3D cfcnfg_get_phyid(cnfg, pref);
-		if (dev_info =3D=3D NULL)
-			return -ENODEV;
-		l->phyid =3D dev_info->id;
-	}
-	switch (s->protocol) {
-	case CAIFPROTO_AT:
-		l->linktype =3D CFCTRL_SRV_VEI;
-		if (s->sockaddr.u.at.type =3D=3D CAIF_ATTYPE_PLAIN)
-			l->chtype =3D 0x02;
-		else
-			l->chtype =3D s->sockaddr.u.at.type;
-		l->endpoint =3D 0x00;
-		break;
-	case CAIFPROTO_DATAGRAM:
-		l->linktype =3D CFCTRL_SRV_DATAGRAM;
-		l->chtype =3D 0x00;
-		l->u.datagram.connid =3D s->sockaddr.u.dgm.connection_id;
-		break;
-	case CAIFPROTO_DATAGRAM_LOOP:
-		l->linktype =3D CFCTRL_SRV_DATAGRAM;
-		l->chtype =3D 0x03;
-		l->endpoint =3D 0x00;
-		l->u.datagram.connid =3D s->sockaddr.u.dgm.connection_id;
-		break;
-	case CAIFPROTO_RFM:
-		l->linktype =3D CFCTRL_SRV_RFM;
-		l->u.datagram.connid =3D s->sockaddr.u.rfm.connection_id;
-		strncpy(l->u.rfm.volume, s->sockaddr.u.rfm.volume,
-			sizeof(l->u.rfm.volume)-1);
-		l->u.rfm.volume[sizeof(l->u.rfm.volume)-1] =3D 0;
-		break;
-	case CAIFPROTO_UTIL:
-		l->linktype =3D CFCTRL_SRV_UTIL;
-		l->endpoint =3D 0x00;
-		l->chtype =3D 0x00;
-		strncpy(l->u.utility.name, s->sockaddr.u.util.service,
-			sizeof(l->u.utility.name)-1);
-		l->u.utility.name[sizeof(l->u.utility.name)-1] =3D 0;
-		caif_assert(sizeof(l->u.utility.name) > 10);
-		l->u.utility.paramlen =3D s->param.size;
-		if (l->u.utility.paramlen > sizeof(l->u.utility.params))
-			l->u.utility.paramlen =3D sizeof(l->u.utility.params);
-
-		memcpy(l->u.utility.params, s->param.data,
-		       l->u.utility.paramlen);
-
-		break;
-	case CAIFPROTO_DEBUG:
-		l->linktype =3D CFCTRL_SRV_DBG;
-		l->endpoint =3D s->sockaddr.u.dbg.service;
-		l->chtype =3D s->sockaddr.u.dbg.type;
-		break;
-	default:
-		return -EINVAL;
-	}
-	return 0;
-}
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 6d1d86b..0e651cf 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -21,7 +21,6 @@
 #include <net/net_namespace.h>
 #include <net/pkt_sched.h>
 #include <net/caif/caif_device.h>
-#include <net/caif/caif_dev.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/cfcnfg.h>
@@ -43,11 +42,21 @@ struct caif_device_entry_list {
 };
=20
 struct caif_net {
+	struct cfcnfg *cfg;
 	struct caif_device_entry_list caifdevs;
 };
=20
 static int caif_net_id;
-static struct cfcnfg *cfg;
+
+struct cfcnfg *get_cfcnfg(struct net *net)
+{
+	struct caif_net *caifn;
+	BUG_ON(!net);
+	caifn =3D net_generic(net, caif_net_id);
+	BUG_ON(!caifn);
+	return caifn->cfg;
+}
+EXPORT_SYMBOL(get_cfcnfg);
=20
 static struct caif_device_entry_list *caif_device_list(struct net *net=
)
 {
@@ -191,12 +200,17 @@ static int caif_device_notify(struct notifier_blo=
ck *me, unsigned long what,
 	struct caif_dev_common *caifdev;
 	enum cfcnfg_phy_preference pref;
 	enum cfcnfg_phy_type phy_type;
+	struct cfcnfg *cfg;
 	struct caif_device_entry_list *caifdevs =3D
 	    caif_device_list(dev_net(dev));
=20
 	if (dev->type !=3D ARPHRD_CAIF)
 		return 0;
=20
+	cfg =3D get_cfcnfg(dev_net(dev));
+	if (cfg =3D=3D NULL)
+		return 0;
+
 	switch (what) {
 	case NETDEV_REGISTER:
 		caifd =3D caif_device_alloc(dev);
@@ -235,7 +249,6 @@ static int caif_device_notify(struct notifier_block=
 *me, unsigned long what,
 				     phy_type,
 				     dev,
 				     &caifd->layer,
-				     0,
 				     pref,
 				     caifdev->use_fcs,
 				     caifdev->use_stx);
@@ -323,35 +336,20 @@ static struct notifier_block caif_device_notifier=
 =3D {
 	.priority =3D 0,
 };
=20
-int caif_connect_client(struct caif_connect_request *conn_req,
-		       struct cflayer *client_layer, int *ifindex,
-		       int *headroom, int *tailroom)
-{
-	struct cfctrl_link_param param;
-	int ret;
-
-	ret =3D caif_connect_req_to_link_param(cfg, conn_req, &param);
-	if (ret)
-		return ret;
-	/* Hook up the adaptation layer. */
-	return cfcnfg_add_adaptation_layer(cfg, &param,
-				       client_layer, ifindex,
-				       headroom, tailroom);
-}
-EXPORT_SYMBOL(caif_connect_client);
-
-int caif_disconnect_client(struct cflayer *adap_layer)
-{
-	return cfcnfg_disconn_adapt_layer(cfg, adap_layer);
-}
-EXPORT_SYMBOL(caif_disconnect_client);
-
 /* Per-namespace Caif devices handling */
 static int caif_init_net(struct net *net)
 {
 	struct caif_net *caifn =3D net_generic(net, caif_net_id);
+	BUG_ON(!caifn);
 	INIT_LIST_HEAD(&caifn->caifdevs.list);
 	mutex_init(&caifn->caifdevs.lock);
+
+	caifn->cfg =3D cfcnfg_create();
+	if (!caifn->cfg) {
+		pr_warn("can't create cfcnfg\n");
+		return -ENOMEM;
+	}
+
 	return 0;
 }
=20
@@ -360,10 +358,17 @@ static void caif_exit_net(struct net *net)
 	struct caif_device_entry *caifd, *tmp;
 	struct caif_device_entry_list *caifdevs =3D
 	    caif_device_list(net);
+	struct cfcnfg *cfg;
=20
 	rtnl_lock();
 	mutex_lock(&caifdevs->lock);
=20
+	cfg =3D get_cfcnfg(net);
+	if (cfg =3D=3D NULL) {
+		mutex_unlock(&caifdevs->lock);
+		return;
+	}
+
 	list_for_each_entry_safe(caifd, tmp, &caifdevs->list, list) {
 		int i =3D 0;
 		list_del_rcu(&caifd->list);
@@ -382,7 +387,7 @@ static void caif_exit_net(struct net *net)
 		free_percpu(caifd->pcpu_refcnt);
 		kfree(caifd);
 	}
-
+	cfcnfg_remove(cfg);
=20
 	mutex_unlock(&caifdevs->lock);
 	rtnl_unlock();
@@ -400,32 +405,22 @@ static int __init caif_device_init(void)
 {
 	int result;
=20
-	cfg =3D cfcnfg_create();
-	if (!cfg) {
-		pr_warn("can't create cfcnfg\n");
-		goto err_cfcnfg_create_failed;
-	}
 	result =3D register_pernet_device(&caif_net_ops);
=20
-	if (result) {
-		kfree(cfg);
-		cfg =3D NULL;
+	if (result)
 		return result;
-	}
-	dev_add_pack(&caif_packet_type);
+
 	register_netdevice_notifier(&caif_device_notifier);
+	dev_add_pack(&caif_packet_type);
=20
 	return result;
-err_cfcnfg_create_failed:
-	return -ENODEV;
 }
=20
 static void __exit caif_device_exit(void)
 {
-	dev_remove_pack(&caif_packet_type);
 	unregister_pernet_device(&caif_net_ops);
 	unregister_netdevice_notifier(&caif_device_notifier);
-	cfcnfg_remove(cfg);
+	dev_remove_pack(&caif_packet_type);
 }
=20
 module_init(caif_device_init);
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 01f612d..653db75 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -810,7 +810,7 @@ static int caif_connect(struct socket *sock, struct=
 sockaddr *uaddr,
 				sk->sk_state =3D=3D CAIF_DISCONNECTED);
 		if (sk->sk_shutdown & SHUTDOWN_MASK) {
 			/* Allow re-connect after SHUTDOWN_IND */
-			caif_disconnect_client(&cf_sk->layer);
+			caif_disconnect_client(sock_net(sk), &cf_sk->layer);
 			break;
 		}
 		/* No reconnect on a seqpacket socket */
@@ -851,7 +851,7 @@ static int caif_connect(struct socket *sock, struct=
 sockaddr *uaddr,
 	dbfs_atomic_inc(&cnt.num_connect_req);
 	cf_sk->layer.receive =3D caif_sktrecv_cb;
=20
-	err =3D caif_connect_client(&cf_sk->conn_req,
+	err =3D caif_connect_client(sock_net(sk), &cf_sk->conn_req,
 				&cf_sk->layer, &ifindex, &headroom, &tailroom);
=20
 	if (err < 0) {
@@ -949,7 +949,7 @@ static int caif_release(struct socket *sock)
=20
 	if (cf_sk->sk.sk_socket->state =3D=3D SS_CONNECTED ||
 		cf_sk->sk.sk_socket->state =3D=3D SS_CONNECTING)
-		res =3D caif_disconnect_client(&cf_sk->layer);
+		res =3D caif_disconnect_client(sock_net(sk), &cf_sk->layer);
=20
 	cf_sk->sk.sk_socket->state =3D SS_DISCONNECTING;
 	wake_up_interruptible_poll(sk_sleep(sk), POLLERR|POLLHUP);
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 3f4f31f..e857d89 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -150,7 +150,7 @@ static void cfctrl_enum_resp(void)
 {
 }
=20
-struct dev_info *cfcnfg_get_phyid(struct cfcnfg *cnfg,
+static struct dev_info *cfcnfg_get_phyid(struct cfcnfg *cnfg,
 				  enum cfcnfg_phy_preference phy_pref)
 {
 	/* Try to match with specified preference */
@@ -171,7 +171,7 @@ struct dev_info *cfcnfg_get_phyid(struct cfcnfg *cn=
fg,
 	return NULL;
 }
=20
-int cfcnfg_get_id_from_ifi(struct cfcnfg *cnfg, int ifi)
+static int cfcnfg_get_id_from_ifi(struct cfcnfg *cnfg, int ifi)
 {
 	struct cfcnfg_phyinfo *phy;
=20
@@ -181,11 +181,12 @@ int cfcnfg_get_id_from_ifi(struct cfcnfg *cnfg, i=
nt ifi)
 	return -ENODEV;
 }
=20
-int cfcnfg_disconn_adapt_layer(struct cfcnfg *cfg, struct cflayer *ada=
p_layer)
+int caif_disconnect_client(struct net *net, struct cflayer *adap_layer=
)
 {
 	u8 channel_id =3D 0;
 	int ret =3D 0;
 	struct cflayer *servl =3D NULL;
+	struct cfcnfg *cfg =3D get_cfcnfg(net);
=20
 	caif_assert(adap_layer !=3D NULL);
=20
@@ -217,14 +218,7 @@ end:
 	return ret;
=20
 }
-EXPORT_SYMBOL(cfcnfg_disconn_adapt_layer);
-
-void cfcnfg_release_adap_layer(struct cflayer *adap_layer)
-{
-	if (adap_layer->dn)
-		cfsrvl_put(adap_layer->dn);
-}
-EXPORT_SYMBOL(cfcnfg_release_adap_layer);
+EXPORT_SYMBOL(caif_disconnect_client);
=20
 static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_i=
d)
 {
@@ -238,19 +232,109 @@ static const int protohead[CFCTRL_SRV_MASK] =3D =
{
 	[CFCTRL_SRV_DBG] =3D 3,
 };
=20
-int cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
-				struct cfctrl_link_param *param,
-				struct cflayer *adap_layer,
-				int *ifindex,
+
+static int caif_connect_req_to_link_param(struct cfcnfg *cnfg,
+				   struct caif_connect_request *s,
+				   struct cfctrl_link_param *l)
+{
+	struct dev_info *dev_info;
+	enum cfcnfg_phy_preference pref;
+	int res;
+
+	memset(l, 0, sizeof(*l));
+	/* In caif protocol low value is high priority */
+	l->priority =3D CAIF_PRIO_MAX - s->priority + 1;
+
+	if (s->ifindex !=3D 0) {
+		res =3D cfcnfg_get_id_from_ifi(cnfg, s->ifindex);
+		if (res < 0)
+			return res;
+		l->phyid =3D res;
+	} else {
+		switch (s->link_selector) {
+		case CAIF_LINK_HIGH_BANDW:
+			pref =3D CFPHYPREF_HIGH_BW;
+			break;
+		case CAIF_LINK_LOW_LATENCY:
+			pref =3D CFPHYPREF_LOW_LAT;
+			break;
+		default:
+			return -EINVAL;
+		}
+		dev_info =3D cfcnfg_get_phyid(cnfg, pref);
+		if (dev_info =3D=3D NULL)
+			return -ENODEV;
+		l->phyid =3D dev_info->id;
+	}
+	switch (s->protocol) {
+	case CAIFPROTO_AT:
+		l->linktype =3D CFCTRL_SRV_VEI;
+		l->endpoint =3D (s->sockaddr.u.at.type >> 2) & 0x3;
+		l->chtype =3D s->sockaddr.u.at.type & 0x3;
+		break;
+	case CAIFPROTO_DATAGRAM:
+		l->linktype =3D CFCTRL_SRV_DATAGRAM;
+		l->chtype =3D 0x00;
+		l->u.datagram.connid =3D s->sockaddr.u.dgm.connection_id;
+		break;
+	case CAIFPROTO_DATAGRAM_LOOP:
+		l->linktype =3D CFCTRL_SRV_DATAGRAM;
+		l->chtype =3D 0x03;
+		l->endpoint =3D 0x00;
+		l->u.datagram.connid =3D s->sockaddr.u.dgm.connection_id;
+		break;
+	case CAIFPROTO_RFM:
+		l->linktype =3D CFCTRL_SRV_RFM;
+		l->u.datagram.connid =3D s->sockaddr.u.rfm.connection_id;
+		strncpy(l->u.rfm.volume, s->sockaddr.u.rfm.volume,
+			sizeof(l->u.rfm.volume)-1);
+		l->u.rfm.volume[sizeof(l->u.rfm.volume)-1] =3D 0;
+		break;
+	case CAIFPROTO_UTIL:
+		l->linktype =3D CFCTRL_SRV_UTIL;
+		l->endpoint =3D 0x00;
+		l->chtype =3D 0x00;
+		strncpy(l->u.utility.name, s->sockaddr.u.util.service,
+			sizeof(l->u.utility.name)-1);
+		l->u.utility.name[sizeof(l->u.utility.name)-1] =3D 0;
+		caif_assert(sizeof(l->u.utility.name) > 10);
+		l->u.utility.paramlen =3D s->param.size;
+		if (l->u.utility.paramlen > sizeof(l->u.utility.params))
+			l->u.utility.paramlen =3D sizeof(l->u.utility.params);
+
+		memcpy(l->u.utility.params, s->param.data,
+		       l->u.utility.paramlen);
+
+		break;
+	case CAIFPROTO_DEBUG:
+		l->linktype =3D CFCTRL_SRV_DBG;
+		l->endpoint =3D s->sockaddr.u.dbg.service;
+		l->chtype =3D s->sockaddr.u.dbg.type;
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+int caif_connect_client(struct net *net, struct caif_connect_request *=
conn_req,
+			struct cflayer *adap_layer, int *ifindex,
 				int *proto_head,
 				int *proto_tail)
 {
 	struct cflayer *frml;
 	struct cfcnfg_phyinfo *phy;
 	int err;
+	struct cfctrl_link_param param;
+	struct cfcnfg *cfg =3D get_cfcnfg(net);
+	caif_assert(cfg !=3D NULL);
=20
 	rcu_read_lock();
-	phy =3D cfcnfg_get_phyinfo_rcu(cnfg, param->phyid);
+	err =3D caif_connect_req_to_link_param(cfg, conn_req, &param);
+	if (err)
+		goto unlock;
+
+	phy =3D cfcnfg_get_phyinfo_rcu(cfg, param.phyid);
 	if (!phy) {
 		err =3D -ENODEV;
 		goto unlock;
@@ -276,28 +360,29 @@ int cfcnfg_add_adaptation_layer(struct cfcnfg *cn=
fg,
 		pr_err("Specified PHY type does not exist!\n");
 		goto unlock;
 	}
-	caif_assert(param->phyid =3D=3D phy->id);
+	caif_assert(param.phyid =3D=3D phy->id);
 	caif_assert(phy->frm_layer->id =3D=3D
-		     param->phyid);
+		     param.phyid);
 	caif_assert(phy->phy_layer->id =3D=3D
-		     param->phyid);
+		     param.phyid);
=20
 	*ifindex =3D phy->ifindex;
 	*proto_tail =3D 2;
 	*proto_head =3D
-		protohead[param->linktype] + (phy->use_stx ? 1 : 0);
+
+	protohead[param.linktype] + (phy->use_stx ? 1 : 0);
=20
 	rcu_read_unlock();
=20
 	/* FIXME: ENUMERATE INITIALLY WHEN ACTIVATING PHYSICAL INTERFACE */
-	cfctrl_enum_req(cnfg->ctrl, param->phyid);
-	return cfctrl_linkup_request(cnfg->ctrl, param, adap_layer);
+	cfctrl_enum_req(cfg->ctrl, param.phyid);
+	return cfctrl_linkup_request(cfg->ctrl, &param, adap_layer);
=20
 unlock:
 	rcu_read_unlock();
 	return err;
 }
-EXPORT_SYMBOL(cfcnfg_add_adaptation_layer);
+EXPORT_SYMBOL(caif_connect_client);
=20
 static void cfcnfg_reject_rsp(struct cflayer *layer, u8 channel_id,
 			     struct cflayer *adapt_layer)
@@ -389,7 +474,7 @@ unlock:
 void
 cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_typ=
e,
 		     struct net_device *dev, struct cflayer *phy_layer,
-		     u16 *phy_id, enum cfcnfg_phy_preference pref,
+		     enum cfcnfg_phy_preference pref,
 		     bool fcs, bool stx)
 {
 	struct cflayer *frml;
@@ -512,23 +597,26 @@ int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, str=
uct cflayer *phy_layer)
 	phyid =3D phy_layer->id;
 	phyinfo =3D cfcnfg_get_phyinfo_rcu(cnfg, phyid);
=20
-	if (phyinfo =3D=3D NULL)
+	if (phyinfo =3D=3D NULL) {
+		mutex_unlock(&cnfg->lock);
 		return 0;
+	}
 	caif_assert(phyid =3D=3D phyinfo->id);
 	caif_assert(phy_layer =3D=3D phyinfo->phy_layer);
 	caif_assert(phy_layer->id =3D=3D phyid);
 	caif_assert(phyinfo->frm_layer->id =3D=3D phyid);
=20
+	list_del_rcu(&phyinfo->node);
+	synchronize_rcu();
+
 	/* Fail if reference count is not zero */
 	if (cffrml_refcnt_read(phyinfo->frm_layer) !=3D 0) {
 		pr_info("Wait for device inuse\n");
+		list_add_rcu(&phyinfo->node, &cnfg->phys);
 		mutex_unlock(&cnfg->lock);
 		return -EAGAIN;
 	}
=20
-	list_del_rcu(&phyinfo->node);
-	synchronize_rcu();
-
 	frml =3D phyinfo->frm_layer;
 	frml_dn =3D frml->dn;
 	cffrml_set_uplayer(frml, NULL);
@@ -539,8 +627,6 @@ int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struc=
t cflayer *phy_layer)
 	}
 	layer_set_up(phy_layer, NULL);
=20
-
-
 	if (phyinfo->phy_layer !=3D frml_dn)
 		kfree(frml_dn);
=20
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 9ef8f16..1a3398a 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -20,7 +20,6 @@
 #include <linux/caif/if_caif.h>
 #include <net/rtnetlink.h>
 #include <net/caif/caif_layer.h>
-#include <net/caif/cfcnfg.h>
 #include <net/caif/cfpkt.h>
 #include <net/caif/caif_dev.h>
=20
@@ -270,8 +269,9 @@ static int chnl_net_open(struct net_device *dev)
=20
 	if (priv->state !=3D CAIF_CONNECTING) {
 		priv->state =3D CAIF_CONNECTING;
-		result =3D caif_connect_client(&priv->conn_req, &priv->chnl,
-					&llifindex, &headroom, &tailroom);
+		result =3D caif_connect_client(dev_net(dev), &priv->conn_req,
+						&priv->chnl, &llifindex,
+						&headroom, &tailroom);
 		if (result !=3D 0) {
 				pr_debug("err: "
 					 "Unable to register and open device,"
@@ -327,7 +327,7 @@ static int chnl_net_open(struct net_device *dev)
=20
 	if (result =3D=3D 0) {
 		pr_debug("connect timeout\n");
-		caif_disconnect_client(&priv->chnl);
+		caif_disconnect_client(dev_net(dev), &priv->chnl);
 		priv->state =3D CAIF_DISCONNECTED;
 		pr_debug("state disconnected\n");
 		result =3D -ETIMEDOUT;
@@ -343,7 +343,7 @@ static int chnl_net_open(struct net_device *dev)
 	return 0;
=20
 error:
-	caif_disconnect_client(&priv->chnl);
+	caif_disconnect_client(dev_net(dev), &priv->chnl);
 	priv->state =3D CAIF_DISCONNECTED;
 	pr_debug("state disconnected\n");
 	return result;
@@ -357,7 +357,7 @@ static int chnl_net_stop(struct net_device *dev)
 	ASSERT_RTNL();
 	priv =3D netdev_priv(dev);
 	priv->state =3D CAIF_DISCONNECTED;
-	caif_disconnect_client(&priv->chnl);
+	caif_disconnect_client(dev_net(dev), &priv->chnl);
 	return 0;
 }
=20
--=20
1.7.1

