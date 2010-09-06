From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net/caif: Use pr_fmt
Date: Mon, 06 Sep 2010 00:31:11 -0700
Message-ID: <1283758271.23280.73.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1486 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784Ab0IFHbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 03:31:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch standardizes caif message logging prefixes.

Add #define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
Add missing "\n"s to some logging messages 
Convert pr_warning to pr_warn

This changes the logging message prefix from CAIF: to caif:
for all uses but caif_socket.c and chnl_net.c.  Those now use
their filename without extension.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/caif/caif_dev.c     |   22 ++++++++--------
 net/caif/caif_socket.c  |   19 +++++++--------
 net/caif/cfcnfg.c       |   49 ++++++++++++++++----------------------
 net/caif/cfctrl.c       |   59 ++++++++++++++++++++---------------------------
 net/caif/cfdbgl.c       |    4 ++-
 net/caif/cfdgml.c       |   11 ++++----
 net/caif/cffrml.c       |   14 ++++++----
 net/caif/cfmuxl.c       |   14 ++++++----
 net/caif/cfpkt_skbuff.c |   48 +++++++++++++++++++-------------------
 net/caif/cfrfml.c       |   12 ++++-----
 net/caif/cfserl.c       |    4 ++-
 net/caif/cfsrvl.c       |   17 +++++--------
 net/caif/cfutill.c      |   12 ++++----
 net/caif/cfveil.c       |   11 ++++----
 net/caif/cfvidl.c       |    6 +++-
 net/caif/chnl_net.c     |   46 ++++++++++++++++--------------------
 16 files changed, 167 insertions(+), 181 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 0b586e9..1fdfe70 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -9,6 +9,8 @@
  *  and Sakari Ailus <sakari.ailus@nokia.com>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/version.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -214,7 +216,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 
 	switch (what) {
 	case NETDEV_REGISTER:
-		pr_info("CAIF: %s():register %s\n", __func__, dev->name);
+		pr_info("register %s\n", dev->name);
 		caifd = caif_device_alloc(dev);
 		if (caifd == NULL)
 			break;
@@ -225,14 +227,13 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 		break;
 
 	case NETDEV_UP:
-		pr_info("CAIF: %s(): up %s\n", __func__, dev->name);
+		pr_info("up %s\n", dev->name);
 		caifd = caif_get(dev);
 		if (caifd == NULL)
 			break;
 		caifdev = netdev_priv(dev);
 		if (atomic_read(&caifd->state) == NETDEV_UP) {
-			pr_info("CAIF: %s():%s already up\n",
-				__func__, dev->name);
+			pr_info("%s already up\n", dev->name);
 			break;
 		}
 		atomic_set(&caifd->state, what);
@@ -273,7 +274,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 		caifd = caif_get(dev);
 		if (caifd == NULL)
 			break;
-		pr_info("CAIF: %s():going down %s\n", __func__, dev->name);
+		pr_info("going down %s\n", dev->name);
 
 		if (atomic_read(&caifd->state) == NETDEV_GOING_DOWN ||
 			atomic_read(&caifd->state) == NETDEV_DOWN)
@@ -295,11 +296,10 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 		caifd = caif_get(dev);
 		if (caifd == NULL)
 			break;
-		pr_info("CAIF: %s(): down %s\n", __func__, dev->name);
+		pr_info("down %s\n", dev->name);
 		if (atomic_read(&caifd->in_use))
-			pr_warning("CAIF: %s(): "
-				   "Unregistering an active CAIF device: %s\n",
-				   __func__, dev->name);
+			pr_warn("Unregistering an active CAIF device: %s\n",
+				dev->name);
 		cfcnfg_del_phy_layer(get_caif_conf(), &caifd->layer);
 		dev_put(dev);
 		atomic_set(&caifd->state, what);
@@ -307,7 +307,7 @@ static int caif_device_notify(struct notifier_block *me, unsigned long what,
 
 	case NETDEV_UNREGISTER:
 		caifd = caif_get(dev);
-		pr_info("CAIF: %s(): unregister %s\n", __func__, dev->name);
+		pr_info("unregister %s\n", dev->name);
 		atomic_set(&caifd->state, what);
 		caif_device_destroy(dev);
 		break;
@@ -391,7 +391,7 @@ static int __init caif_device_init(void)
 	int result;
 	cfg = cfcnfg_create();
 	if (!cfg) {
-		pr_warning("CAIF: %s(): can't create cfcnfg.\n", __func__);
+		pr_warn("can't create cfcnfg\n");
 		goto err_cfcnfg_create_failed;
 	}
 	result = register_pernet_device(&caif_net_ops);
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 8ce9047..fd1f5df 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/fs.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -157,8 +159,8 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 		(unsigned)sk->sk_rcvbuf && rx_flow_is_on(cf_sk)) {
-		trace_printk("CAIF: %s():"
-			" sending flow OFF (queue len = %d %d)\n",
+		trace_printk("CAIF: %s(): "
+			"sending flow OFF (queue len = %d %d)\n",
 			__func__,
 			atomic_read(&cf_sk->sk.sk_rmem_alloc),
 			sk_rcvbuf_lowwater(cf_sk));
@@ -172,8 +174,8 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		return err;
 	if (!sk_rmem_schedule(sk, skb->truesize) && rx_flow_is_on(cf_sk)) {
 		set_rx_flow_off(cf_sk);
-		trace_printk("CAIF: %s():"
-			" sending flow OFF due to rmem_schedule\n",
+		trace_printk("CAIF: %s(): "
+			"sending flow OFF due to rmem_schedule\n",
 			__func__);
 		dbfs_atomic_inc(&cnt.num_rx_flow_off);
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
@@ -275,8 +277,7 @@ static void caif_ctrl_cb(struct cflayer *layr,
 		break;
 
 	default:
-		pr_debug("CAIF: %s(): Unexpected flow command %d\n",
-				__func__, flow);
+		pr_debug("Unexpected flow command %d\n", flow);
 	}
 }
 
@@ -536,8 +537,7 @@ static int transmit_skb(struct sk_buff *skb, struct caifsock *cf_sk,
 
 		/* Slight paranoia, probably not needed. */
 		if (unlikely(loopcnt++ > 1000)) {
-			pr_warning("CAIF: %s(): transmit retries failed,"
-				" error = %d\n", __func__, ret);
+			pr_warn("transmit retries failed, error = %d\n", ret);
 			break;
 		}
 
@@ -902,8 +902,7 @@ static int caif_connect(struct socket *sock, struct sockaddr *uaddr,
 	cf_sk->maxframe = dev->mtu - (headroom + tailroom);
 	dev_put(dev);
 	if (cf_sk->maxframe < 1) {
-		pr_warning("CAIF: %s(): CAIF Interface MTU too small (%d)\n",
-			__func__, dev->mtu);
+		pr_warn("CAIF Interface MTU too small (%d)\n", dev->mtu);
 		err = -ENODEV;
 		goto out;
 	}
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 1c29189..ef93a13 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -3,6 +3,9 @@
  * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
  * License terms: GNU General Public License (GPL) version 2
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/kernel.h>
 #include <linux/stddef.h>
 #include <linux/slab.h>
@@ -78,7 +81,7 @@ struct cfcnfg *cfcnfg_create(void)
 	/* Initiate this layer */
 	this = kzalloc(sizeof(struct cfcnfg), GFP_ATOMIC);
 	if (!this) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	this->mux = cfmuxl_create();
@@ -106,7 +109,7 @@ struct cfcnfg *cfcnfg_create(void)
 	layer_set_up(this->ctrl, this);
 	return this;
 out_of_mem:
-	pr_warning("CAIF: %s(): Out of memory\n", __func__);
+	pr_warn("Out of memory\n");
 	kfree(this->mux);
 	kfree(this->ctrl);
 	kfree(this);
@@ -194,7 +197,7 @@ int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
 	caif_assert(adap_layer != NULL);
 	channel_id = adap_layer->id;
 	if (adap_layer->dn == NULL || channel_id == 0) {
-		pr_err("CAIF: %s():adap_layer->id is 0\n", __func__);
+		pr_err("adap_layer->id is 0\n");
 		ret = -ENOTCONN;
 		goto end;
 	}
@@ -204,9 +207,8 @@ int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
 	layer_set_up(servl, NULL);
 	ret = cfctrl_linkdown_req(cnfg->ctrl, channel_id, adap_layer);
 	if (servl == NULL) {
-		pr_err("CAIF: %s(): PROTOCOL ERROR "
-		       "- Error removing service_layer Channel_Id(%d)",
-			__func__, channel_id);
+		pr_err("PROTOCOL ERROR - Error removing service_layer Channel_Id(%d)",
+		       channel_id);
 		ret = -EINVAL;
 		goto end;
 	}
@@ -216,18 +218,14 @@ int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
 
 		phyinfo = cfcnfg_get_phyinfo(cnfg, phyid);
 		if (phyinfo == NULL) {
-			pr_warning("CAIF: %s(): "
-				"No interface to send disconnect to\n",
-				__func__);
+			pr_warn("No interface to send disconnect to\n");
 			ret = -ENODEV;
 			goto end;
 		}
 		if (phyinfo->id != phyid ||
 			phyinfo->phy_layer->id != phyid ||
 			phyinfo->frm_layer->id != phyid) {
-			pr_err("CAIF: %s(): "
-				"Inconsistency in phy registration\n",
-				__func__);
+			pr_err("Inconsistency in phy registration\n");
 			ret = -EINVAL;
 			goto end;
 		}
@@ -276,21 +274,20 @@ int cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
 {
 	struct cflayer *frml;
 	if (adap_layer == NULL) {
-		pr_err("CAIF: %s(): adap_layer is zero", __func__);
+		pr_err("adap_layer is zero\n");
 		return -EINVAL;
 	}
 	if (adap_layer->receive == NULL) {
-		pr_err("CAIF: %s(): adap_layer->receive is NULL", __func__);
+		pr_err("adap_layer->receive is NULL\n");
 		return -EINVAL;
 	}
 	if (adap_layer->ctrlcmd == NULL) {
-		pr_err("CAIF: %s(): adap_layer->ctrlcmd == NULL", __func__);
+		pr_err("adap_layer->ctrlcmd == NULL\n");
 		return -EINVAL;
 	}
 	frml = cnfg->phy_layers[param->phyid].frm_layer;
 	if (frml == NULL) {
-		pr_err("CAIF: %s(): Specified PHY type does not exist!",
-			__func__);
+		pr_err("Specified PHY type does not exist!\n");
 		return -ENODEV;
 	}
 	caif_assert(param->phyid == cnfg->phy_layers[param->phyid].id);
@@ -330,9 +327,7 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 	struct net_device *netdev;
 
 	if (adapt_layer == NULL) {
-		pr_debug("CAIF: %s(): link setup response "
-				"but no client exist, send linkdown back\n",
-				__func__);
+		pr_debug("link setup response but no client exist, send linkdown back\n");
 		cfctrl_linkdown_req(cnfg->ctrl, channel_id, NULL);
 		return;
 	}
@@ -374,13 +369,11 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 		servicel = cfdbgl_create(channel_id, &phyinfo->dev_info);
 		break;
 	default:
-		pr_err("CAIF: %s(): Protocol error. "
-			"Link setup response - unknown channel type\n",
-			__func__);
+		pr_err("Protocol error. Link setup response - unknown channel type\n");
 		return;
 	}
 	if (!servicel) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return;
 	}
 	layer_set_dn(servicel, cnfg->mux);
@@ -418,7 +411,7 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
 		}
 	}
 	if (*phyid == 0) {
-		pr_err("CAIF: %s(): No Available PHY ID\n", __func__);
+		pr_err("No Available PHY ID\n");
 		return;
 	}
 
@@ -427,7 +420,7 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
 		phy_driver =
 		    cfserl_create(CFPHYTYPE_FRAG, *phyid, stx);
 		if (!phy_driver) {
-			pr_warning("CAIF: %s(): Out of memory\n", __func__);
+			pr_warn("Out of memory\n");
 			return;
 		}
 
@@ -436,7 +429,7 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
 		phy_driver = NULL;
 		break;
 	default:
-		pr_err("CAIF: %s(): %d", __func__, phy_type);
+		pr_err("%d\n", phy_type);
 		return;
 		break;
 	}
@@ -455,7 +448,7 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
 	phy_layer->type = phy_type;
 	frml = cffrml_create(*phyid, fcs);
 	if (!frml) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return;
 	}
 	cnfg->phy_layers[*phyid].frm_layer = frml;
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 563145f..08f267a 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
@@ -36,7 +38,7 @@ struct cflayer *cfctrl_create(void)
 	struct cfctrl *this =
 		kmalloc(sizeof(struct cfctrl), GFP_ATOMIC);
 	if (!this) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	caif_assert(offsetof(struct cfctrl, serv.layer) == 0);
@@ -132,9 +134,7 @@ struct cfctrl_request_info *cfctrl_remove_req(struct cfctrl *ctrl,
 	list_for_each_entry_safe(p, tmp, &ctrl->list, list) {
 		if (cfctrl_req_eq(req, p)) {
 			if (p != first)
-				pr_warning("CAIF: %s(): Requests are not "
-					"received in order\n",
-					__func__);
+				pr_warn("Requests are not received in order\n");
 
 			atomic_set(&ctrl->rsp_seq_no,
 					 p->sequence_no);
@@ -177,7 +177,7 @@ void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
 	int ret;
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	if (!pkt) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return;
 	}
 	caif_assert(offsetof(struct cfctrl, serv.layer) == 0);
@@ -189,8 +189,7 @@ void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
 	ret =
 	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
 	if (ret < 0) {
-		pr_err("CAIF: %s(): Could not transmit enum message\n",
-			__func__);
+		pr_err("Could not transmit enum message\n");
 		cfpkt_destroy(pkt);
 	}
 }
@@ -208,7 +207,7 @@ int cfctrl_linkup_request(struct cflayer *layer,
 	char utility_name[16];
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	if (!pkt) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return -ENOMEM;
 	}
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_SETUP);
@@ -253,13 +252,13 @@ int cfctrl_linkup_request(struct cflayer *layer,
 			       param->u.utility.paramlen);
 		break;
 	default:
-		pr_warning("CAIF: %s():Request setup of bad link type = %d\n",
-			   __func__, param->linktype);
+		pr_warn("Request setup of bad link type = %d\n",
+			param->linktype);
 		return -EINVAL;
 	}
 	req = kzalloc(sizeof(*req), GFP_KERNEL);
 	if (!req) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return -ENOMEM;
 	}
 	req->client_layer = user_layer;
@@ -276,8 +275,7 @@ int cfctrl_linkup_request(struct cflayer *layer,
 	ret =
 	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
 	if (ret < 0) {
-		pr_err("CAIF: %s(): Could not transmit linksetup request\n",
-			__func__);
+		pr_err("Could not transmit linksetup request\n");
 		cfpkt_destroy(pkt);
 		return -ENODEV;
 	}
@@ -291,7 +289,7 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8 channelid,
 	struct cfctrl *cfctrl = container_obj(layer);
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	if (!pkt) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return -ENOMEM;
 	}
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_DESTROY);
@@ -300,8 +298,7 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8 channelid,
 	ret =
 	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
 	if (ret < 0) {
-		pr_err("CAIF: %s(): Could not transmit link-down request\n",
-			__func__);
+		pr_err("Could not transmit link-down request\n");
 		cfpkt_destroy(pkt);
 	}
 	return ret;
@@ -313,7 +310,7 @@ void cfctrl_sleep_req(struct cflayer *layer)
 	struct cfctrl *cfctrl = container_obj(layer);
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	if (!pkt) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return;
 	}
 	cfpkt_addbdy(pkt, CFCTRL_CMD_SLEEP);
@@ -330,7 +327,7 @@ void cfctrl_wake_req(struct cflayer *layer)
 	struct cfctrl *cfctrl = container_obj(layer);
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	if (!pkt) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return;
 	}
 	cfpkt_addbdy(pkt, CFCTRL_CMD_WAKE);
@@ -347,7 +344,7 @@ void cfctrl_getstartreason_req(struct cflayer *layer)
 	struct cfctrl *cfctrl = container_obj(layer);
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	if (!pkt) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return;
 	}
 	cfpkt_addbdy(pkt, CFCTRL_CMD_START_REASON);
@@ -364,12 +361,11 @@ void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_layer)
 	struct cfctrl_request_info *p, *tmp;
 	struct cfctrl *ctrl = container_obj(layr);
 	spin_lock(&ctrl->info_list_lock);
-	pr_warning("CAIF: %s(): enter\n", __func__);
+	pr_warn("enter\n");
 
 	list_for_each_entry_safe(p, tmp, &ctrl->list, list) {
 		if (p->client_layer == adap_layer) {
-			pr_warning("CAIF: %s(): cancel req :%d\n", __func__,
-					p->sequence_no);
+			pr_warn("cancel req :%d\n", p->sequence_no);
 			list_del(&p->list);
 			kfree(p);
 		}
@@ -520,9 +516,8 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 				cfpkt_extr_head(pkt, &param, len);
 				break;
 			default:
-				pr_warning("CAIF: %s(): Request setup "
-					   "- invalid link type (%d)",
-					   __func__, serv);
+				pr_warn("Request setup - invalid link type (%d)\n",
+					serv);
 				goto error;
 			}
 
@@ -532,9 +527,7 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 
 			if (CFCTRL_ERR_BIT == (CFCTRL_ERR_BIT & cmdrsp) ||
 				cfpkt_erroneous(pkt)) {
-				pr_err("CAIF: %s(): Invalid O/E bit or parse "
-				       "error on CAIF control channel",
-					__func__);
+				pr_err("Invalid O/E bit or parse error on CAIF control channel\n");
 				cfctrl->res.reject_rsp(cfctrl->serv.layer.up,
 						       0,
 						       req ? req->client_layer
@@ -556,8 +549,7 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 		cfctrl->res.linkdestroy_rsp(cfctrl->serv.layer.up, linkid);
 		break;
 	case CFCTRL_CMD_LINK_ERR:
-		pr_err("CAIF: %s(): Frame Error Indication received\n",
-			__func__);
+		pr_err("Frame Error Indication received\n");
 		cfctrl->res.linkerror_ind();
 		break;
 	case CFCTRL_CMD_ENUM:
@@ -576,7 +568,7 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 		cfctrl->res.radioset_rsp();
 		break;
 	default:
-		pr_err("CAIF: %s(): Unrecognized Control Frame\n", __func__);
+		pr_err("Unrecognized Control Frame\n");
 		goto error;
 		break;
 	}
@@ -595,8 +587,7 @@ static void cfctrl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 	case CAIF_CTRLCMD_FLOW_OFF_IND:
 		spin_lock(&this->info_list_lock);
 		if (!list_empty(&this->list)) {
-			pr_debug("CAIF: %s(): Received flow off in "
-				   "control layer", __func__);
+			pr_debug("Received flow off in control layer\n");
 		}
 		spin_unlock(&this->info_list_lock);
 		break;
@@ -620,7 +611,7 @@ static int handle_loop(struct cfctrl *ctrl, int cmd, struct cfpkt *pkt)
 			if (!ctrl->loop_linkused[linkid])
 				goto found;
 		spin_unlock(&ctrl->loop_linkid_lock);
-		pr_err("CAIF: %s(): Out of link-ids\n", __func__);
+		pr_err("Out of link-ids\n");
 		return -EINVAL;
 found:
 		if (!ctrl->loop_linkused[linkid])
diff --git a/net/caif/cfdbgl.c b/net/caif/cfdbgl.c
index 676648c..496fda9 100644
--- a/net/caif/cfdbgl.c
+++ b/net/caif/cfdbgl.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/stddef.h>
 #include <linux/slab.h>
 #include <net/caif/caif_layer.h>
@@ -17,7 +19,7 @@ struct cflayer *cfdbgl_create(u8 channel_id, struct dev_info *dev_info)
 {
 	struct cfsrvl *dbg = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
 	if (!dbg) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index ed9d53a..d3ed264 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
@@ -26,7 +28,7 @@ struct cflayer *cfdgml_create(u8 channel_id, struct dev_info *dev_info)
 {
 	struct cfsrvl *dgm = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
 	if (!dgm) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
@@ -49,14 +51,14 @@ static int cfdgml_receive(struct cflayer *layr, struct cfpkt *pkt)
 	caif_assert(layr->ctrlcmd != NULL);
 
 	if (cfpkt_extr_head(pkt, &cmd, 1) < 0) {
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		pr_err("Packet is erroneous!\n");
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
 
 	if ((cmd & DGM_CMD_BIT) == 0) {
 		if (cfpkt_extr_head(pkt, &dgmhdr, 3) < 0) {
-			pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+			pr_err("Packet is erroneous!\n");
 			cfpkt_destroy(pkt);
 			return -EPROTO;
 		}
@@ -75,8 +77,7 @@ static int cfdgml_receive(struct cflayer *layr, struct cfpkt *pkt)
 		return 0;
 	default:
 		cfpkt_destroy(pkt);
-		pr_info("CAIF: %s(): Unknown datagram control %d (0x%x)\n",
-			__func__, cmd, cmd);
+		pr_info("Unknown datagram control %d (0x%x)\n", cmd, cmd);
 		return -EPROTO;
 	}
 }
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index e86a4ca..a445043 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -6,6 +6,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
@@ -32,7 +34,7 @@ struct cflayer *cffrml_create(u16 phyid, bool use_fcs)
 {
 	struct cffrml *this = kmalloc(sizeof(struct cffrml), GFP_ATOMIC);
 	if (!this) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	caif_assert(offsetof(struct cffrml, layer) == 0);
@@ -83,7 +85,7 @@ static int cffrml_receive(struct cflayer *layr, struct cfpkt *pkt)
 
 	if (cfpkt_setlen(pkt, len) < 0) {
 		++cffrml_rcv_error;
-		pr_err("CAIF: %s():Framing length error (%d)\n", __func__, len);
+		pr_err("Framing length error (%d)\n", len);
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
@@ -99,14 +101,14 @@ static int cffrml_receive(struct cflayer *layr, struct cfpkt *pkt)
 			cfpkt_add_trail(pkt, &tmp, 2);
 			++cffrml_rcv_error;
 			++cffrml_rcv_checsum_error;
-			pr_info("CAIF: %s(): Frame checksum error "
-				"(0x%x != 0x%x)\n", __func__, hdrchks, pktchks);
+			pr_info("Frame checksum error (0x%x != 0x%x)\n",
+				hdrchks, pktchks);
 			return -EILSEQ;
 		}
 	}
 	if (cfpkt_erroneous(pkt)) {
 		++cffrml_rcv_error;
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		pr_err("Packet is erroneous!\n");
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
@@ -132,7 +134,7 @@ static int cffrml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	cfpkt_add_head(pkt, &tmp, 2);
 	cfpkt_info(pkt)->hdr_len += 2;
 	if (cfpkt_erroneous(pkt)) {
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		pr_err("Packet is erroneous!\n");
 		return -EPROTO;
 	}
 	ret = layr->dn->transmit(layr->dn, pkt);
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 80c8d33..46f34b2 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -3,6 +3,9 @@
  * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
  * License terms: GNU General Public License (GPL) version 2
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
@@ -190,7 +193,7 @@ static int cfmuxl_receive(struct cflayer *layr, struct cfpkt *pkt)
 	u8 id;
 	struct cflayer *up;
 	if (cfpkt_extr_head(pkt, &id, 1) < 0) {
-		pr_err("CAIF: %s(): erroneous Caif Packet\n", __func__);
+		pr_err("erroneous Caif Packet\n");
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
@@ -199,8 +202,8 @@ static int cfmuxl_receive(struct cflayer *layr, struct cfpkt *pkt)
 	up = get_up(muxl, id);
 	spin_unlock(&muxl->receive_lock);
 	if (up == NULL) {
-		pr_info("CAIF: %s():Received data on unknown link ID = %d "
-			"(0x%x)	 up == NULL", __func__, id, id);
+		pr_info("Received data on unknown link ID = %d (0x%x) up == NULL",
+			id, id);
 		cfpkt_destroy(pkt);
 		/*
 		 * Don't return ERROR, since modem misbehaves and sends out
@@ -223,9 +226,8 @@ static int cfmuxl_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	struct caif_payload_info *info = cfpkt_info(pkt);
 	dn = get_dn(muxl, cfpkt_info(pkt)->dev_info);
 	if (dn == NULL) {
-		pr_warning("CAIF: %s(): Send data on unknown phy "
-			   "ID = %d (0x%x)\n",
-			   __func__, info->dev_info->id, info->dev_info->id);
+		pr_warn("Send data on unknown phy ID = %d (0x%x)\n",
+			info->dev_info->id, info->dev_info->id);
 		return -ENOTCONN;
 	}
 	info->hdr_len += 1;
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index c49a669..d7e865e 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/string.h>
 #include <linux/skbuff.h>
 #include <linux/hardirq.h>
@@ -12,11 +14,12 @@
 #define PKT_PREFIX  48
 #define PKT_POSTFIX 2
 #define PKT_LEN_WHEN_EXTENDING 128
-#define PKT_ERROR(pkt, errmsg) do {	   \
-    cfpkt_priv(pkt)->erronous = true;	   \
-    skb_reset_tail_pointer(&pkt->skb);	   \
-    pr_warning("CAIF: " errmsg);\
-  } while (0)
+#define PKT_ERROR(pkt, errmsg)		   \
+do {					   \
+	cfpkt_priv(pkt)->erronous = true;  \
+	skb_reset_tail_pointer(&pkt->skb); \
+	pr_warn(errmsg);		   \
+} while (0)
 
 struct cfpktq {
 	struct sk_buff_head head;
@@ -130,13 +133,13 @@ int cfpkt_extr_head(struct cfpkt *pkt, void *data, u16 len)
 		return -EPROTO;
 
 	if (unlikely(len > skb->len)) {
-		PKT_ERROR(pkt, "cfpkt_extr_head read beyond end of packet\n");
+		PKT_ERROR(pkt, "read beyond end of packet\n");
 		return -EPROTO;
 	}
 
 	if (unlikely(len > skb_headlen(skb))) {
 		if (unlikely(skb_linearize(skb) != 0)) {
-			PKT_ERROR(pkt, "cfpkt_extr_head linearize failed\n");
+			PKT_ERROR(pkt, "linearize failed\n");
 			return -EPROTO;
 		}
 	}
@@ -156,11 +159,11 @@ int cfpkt_extr_trail(struct cfpkt *pkt, void *dta, u16 len)
 		return -EPROTO;
 
 	if (unlikely(skb_linearize(skb) != 0)) {
-		PKT_ERROR(pkt, "cfpkt_extr_trail linearize failed\n");
+		PKT_ERROR(pkt, "linearize failed\n");
 		return -EPROTO;
 	}
 	if (unlikely(skb->data + len > skb_tail_pointer(skb))) {
-		PKT_ERROR(pkt, "cfpkt_extr_trail read beyond end of packet\n");
+		PKT_ERROR(pkt, "read beyond end of packet\n");
 		return -EPROTO;
 	}
 	from = skb_tail_pointer(skb) - len;
@@ -202,7 +205,7 @@ int cfpkt_add_body(struct cfpkt *pkt, const void *data, u16 len)
 
 		/* Make sure data is writable */
 		if (unlikely(skb_cow_data(skb, addlen, &lastskb) < 0)) {
-			PKT_ERROR(pkt, "cfpkt_add_body: cow failed\n");
+			PKT_ERROR(pkt, "cow failed\n");
 			return -EPROTO;
 		}
 		/*
@@ -211,8 +214,7 @@ int cfpkt_add_body(struct cfpkt *pkt, const void *data, u16 len)
 		 * lengths of the top SKB.
 		 */
 		if (lastskb != skb) {
-			pr_warning("CAIF: %s(): Packet is non-linear\n",
-				   __func__);
+			pr_warn("Packet is non-linear\n");
 			skb->len += len;
 			skb->data_len += len;
 		}
@@ -242,14 +244,14 @@ int cfpkt_add_head(struct cfpkt *pkt, const void *data2, u16 len)
 	if (unlikely(is_erronous(pkt)))
 		return -EPROTO;
 	if (unlikely(skb_headroom(skb) < len)) {
-		PKT_ERROR(pkt, "cfpkt_add_head: no headroom\n");
+		PKT_ERROR(pkt, "no headroom\n");
 		return -EPROTO;
 	}
 
 	/* Make sure data is writable */
 	ret = skb_cow_data(skb, 0, &lastskb);
 	if (unlikely(ret < 0)) {
-		PKT_ERROR(pkt, "cfpkt_add_head: cow failed\n");
+		PKT_ERROR(pkt, "cow failed\n");
 		return ret;
 	}
 
@@ -283,7 +285,7 @@ inline u16 cfpkt_iterate(struct cfpkt *pkt,
 	if (unlikely(is_erronous(pkt)))
 		return -EPROTO;
 	if (unlikely(skb_linearize(&pkt->skb) != 0)) {
-		PKT_ERROR(pkt, "cfpkt_iterate: linearize failed\n");
+		PKT_ERROR(pkt, "linearize failed\n");
 		return -EPROTO;
 	}
 	return iter_func(data, pkt->skb.data, cfpkt_getlen(pkt));
@@ -309,7 +311,7 @@ int cfpkt_setlen(struct cfpkt *pkt, u16 len)
 
 	/* Need to expand SKB */
 	if (unlikely(!cfpkt_pad_trail(pkt, len - skb->len)))
-		PKT_ERROR(pkt, "cfpkt_setlen: skb_pad_trail failed\n");
+		PKT_ERROR(pkt, "skb_pad_trail failed\n");
 
 	return cfpkt_getlen(pkt);
 }
@@ -380,8 +382,7 @@ struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 pos)
 		return NULL;
 
 	if (skb->data + pos > skb_tail_pointer(skb)) {
-		PKT_ERROR(pkt,
-			  "cfpkt_split: trying to split beyond end of packet");
+		PKT_ERROR(pkt, "trying to split beyond end of packet\n");
 		return NULL;
 	}
 
@@ -455,17 +456,17 @@ int cfpkt_raw_append(struct cfpkt *pkt, void **buf, unsigned int buflen)
 		return -EPROTO;
 	/* Make sure SKB is writable */
 	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
-		PKT_ERROR(pkt, "cfpkt_raw_append: skb_cow_data failed\n");
+		PKT_ERROR(pkt, "skb_cow_data failed\n");
 		return -EPROTO;
 	}
 
 	if (unlikely(skb_linearize(skb) != 0)) {
-		PKT_ERROR(pkt, "cfpkt_raw_append: linearize failed\n");
+		PKT_ERROR(pkt, "linearize failed\n");
 		return -EPROTO;
 	}
 
 	if (unlikely(skb_tailroom(skb) < buflen)) {
-		PKT_ERROR(pkt, "cfpkt_raw_append: buffer too short - failed\n");
+		PKT_ERROR(pkt, "buffer too short - failed\n");
 		return -EPROTO;
 	}
 
@@ -483,14 +484,13 @@ int cfpkt_raw_extract(struct cfpkt *pkt, void **buf, unsigned int buflen)
 		return -EPROTO;
 
 	if (unlikely(buflen > skb->len)) {
-		PKT_ERROR(pkt, "cfpkt_raw_extract: buflen too large "
-				"- failed\n");
+		PKT_ERROR(pkt, "buflen too large - failed\n");
 		return -EPROTO;
 	}
 
 	if (unlikely(buflen > skb_headlen(skb))) {
 		if (unlikely(skb_linearize(skb) != 0)) {
-			PKT_ERROR(pkt, "cfpkt_raw_extract: linearize failed\n");
+			PKT_ERROR(pkt, "linearize failed\n");
 			return -EPROTO;
 		}
 	}
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index eb16020..6acaeba 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
@@ -48,7 +50,7 @@ struct cflayer *cfrfml_create(u8 channel_id, struct dev_info *dev_info,
 		kzalloc(sizeof(struct cfrfml), GFP_ATOMIC);
 
 	if (!this) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 
@@ -178,9 +180,7 @@ out:
 			cfpkt_destroy(rfml->incomplete_frm);
 		rfml->incomplete_frm = NULL;
 
-		pr_info("CAIF: %s(): "
-				"Connection error %d triggered on RFM link\n",
-				__func__, err);
+		pr_info("Connection error %d triggered on RFM link\n", err);
 
 		/* Trigger connection error upon failure.*/
 		layr->up->ctrlcmd(layr->up, CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND,
@@ -280,9 +280,7 @@ static int cfrfml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 out:
 
 	if (err != 0) {
-		pr_info("CAIF: %s(): "
-				"Connection error %d triggered on RFM link\n",
-				__func__, err);
+		pr_info("Connection error %d triggered on RFM link\n", err);
 		/* Trigger connection error upon failure.*/
 
 		layr->up->ctrlcmd(layr->up, CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND,
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index a11fbd6..9297f7d 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
@@ -34,7 +36,7 @@ struct cflayer *cfserl_create(int type, int instance, bool use_stx)
 {
 	struct cfserl *this = kmalloc(sizeof(struct cfserl), GFP_ATOMIC);
 	if (!this) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	caif_assert(offsetof(struct cfserl, layer) == 0);
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index f40939a..ab5e542 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
@@ -79,8 +81,7 @@ static void cfservl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 		layr->up->ctrlcmd(layr->up, ctrl, phyid);
 		break;
 	default:
-		pr_warning("CAIF: %s(): "
-			   "Unexpected ctrl in cfsrvl (%d)\n", __func__, ctrl);
+		pr_warn("Unexpected ctrl in cfsrvl (%d)\n", ctrl);
 		/* We have both modem and phy flow on, send flow on */
 		layr->up->ctrlcmd(layr->up, ctrl, phyid);
 		service->phy_flow_on = true;
@@ -107,14 +108,12 @@ static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 			u8 flow_on = SRVL_FLOW_ON;
 			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
 			if (!pkt) {
-				pr_warning("CAIF: %s(): Out of memory\n",
-					__func__);
+				pr_warn("Out of memory\n");
 				return -ENOMEM;
 			}
 
 			if (cfpkt_add_head(pkt, &flow_on, 1) < 0) {
-				pr_err("CAIF: %s(): Packet is erroneous!\n",
-					__func__);
+				pr_err("Packet is erroneous!\n");
 				cfpkt_destroy(pkt);
 				return -EPROTO;
 			}
@@ -131,14 +130,12 @@ static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 			u8 flow_off = SRVL_FLOW_OFF;
 			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
 			if (!pkt) {
-				pr_warning("CAIF: %s(): Out of memory\n",
-					__func__);
+				pr_warn("Out of memory\n");
 				return -ENOMEM;
 			}
 
 			if (cfpkt_add_head(pkt, &flow_off, 1) < 0) {
-				pr_err("CAIF: %s(): Packet is erroneous!\n",
-					__func__);
+				pr_err("Packet is erroneous!\n");
 				cfpkt_destroy(pkt);
 				return -EPROTO;
 			}
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index 02795af..efad410 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/slab.h>
@@ -26,7 +28,7 @@ struct cflayer *cfutill_create(u8 channel_id, struct dev_info *dev_info)
 {
 	struct cfsrvl *util = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
 	if (!util) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
@@ -47,7 +49,7 @@ static int cfutill_receive(struct cflayer *layr, struct cfpkt *pkt)
 	caif_assert(layr->up->receive != NULL);
 	caif_assert(layr->up->ctrlcmd != NULL);
 	if (cfpkt_extr_head(pkt, &cmd, 1) < 0) {
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		pr_err("Packet is erroneous!\n");
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
@@ -64,16 +66,14 @@ static int cfutill_receive(struct cflayer *layr, struct cfpkt *pkt)
 		cfpkt_destroy(pkt);
 		return 0;
 	case UTIL_REMOTE_SHUTDOWN:	/* Remote Shutdown Request */
-		pr_err("CAIF: %s(): REMOTE SHUTDOWN REQUEST RECEIVED\n",
-			__func__);
+		pr_err("REMOTE SHUTDOWN REQUEST RECEIVED\n");
 		layr->ctrlcmd(layr, CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND, 0);
 		service->open = false;
 		cfpkt_destroy(pkt);
 		return 0;
 	default:
 		cfpkt_destroy(pkt);
-		pr_warning("CAIF: %s(): Unknown service control %d (0x%x)\n",
-			   __func__, cmd, cmd);
+		pr_warn("Unknown service control %d (0x%x)\n", cmd, cmd);
 		return -EPROTO;
 	}
 }
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index 77cc09f..3b425b1 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/stddef.h>
 #include <linux/slab.h>
 #include <net/caif/caif_layer.h>
@@ -25,7 +27,7 @@ struct cflayer *cfvei_create(u8 channel_id, struct dev_info *dev_info)
 {
 	struct cfsrvl *vei = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
 	if (!vei) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
@@ -47,7 +49,7 @@ static int cfvei_receive(struct cflayer *layr, struct cfpkt *pkt)
 
 
 	if (cfpkt_extr_head(pkt, &cmd, 1) < 0) {
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		pr_err("Packet is erroneous!\n");
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
@@ -67,8 +69,7 @@ static int cfvei_receive(struct cflayer *layr, struct cfpkt *pkt)
 		cfpkt_destroy(pkt);
 		return 0;
 	default:		/* SET RS232 PIN */
-		pr_warning("CAIF: %s():Unknown VEI control packet %d (0x%x)!\n",
-			   __func__, cmd, cmd);
+		pr_warn("Unknown VEI control packet %d (0x%x)!\n", cmd, cmd);
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
@@ -86,7 +87,7 @@ static int cfvei_transmit(struct cflayer *layr, struct cfpkt *pkt)
 	caif_assert(layr->dn->transmit != NULL);
 
 	if (cfpkt_add_head(pkt, &tmp, 1) < 0) {
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		pr_err("Packet is erroneous!\n");
 		return -EPROTO;
 	}
 
diff --git a/net/caif/cfvidl.c b/net/caif/cfvidl.c
index ada6ee2..bf6fef2 100644
--- a/net/caif/cfvidl.c
+++ b/net/caif/cfvidl.c
@@ -4,6 +4,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/slab.h>
@@ -21,7 +23,7 @@ struct cflayer *cfvidl_create(u8 channel_id, struct dev_info *dev_info)
 {
 	struct cfsrvl *vid = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
 	if (!vid) {
-		pr_warning("CAIF: %s(): Out of memory\n", __func__);
+		pr_warn("Out of memory\n");
 		return NULL;
 	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
@@ -38,7 +40,7 @@ static int cfvidl_receive(struct cflayer *layr, struct cfpkt *pkt)
 {
 	u32 videoheader;
 	if (cfpkt_extr_head(pkt, &videoheader, 4) < 0) {
-		pr_err("CAIF: %s(): Packet is erroneous!\n", __func__);
+		pr_err("Packet is erroneous!\n");
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 4293e19..86aac24 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -5,6 +5,8 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
 #include <linux/version.h>
 #include <linux/fs.h>
 #include <linux/init.h>
@@ -29,7 +31,7 @@
 #define CAIF_NET_DEFAULT_QUEUE_LEN 500
 
 #undef pr_debug
-#define pr_debug pr_warning
+#define pr_debug pr_warn
 
 /*This list is protected by the rtnl lock. */
 static LIST_HEAD(chnl_net_list);
@@ -142,8 +144,7 @@ static void chnl_flowctrl_cb(struct cflayer *layr, enum caif_ctrlcmd flow,
 				int phyid)
 {
 	struct chnl_net *priv = container_of(layr, struct chnl_net, chnl);
-	pr_debug("CAIF: %s(): NET flowctrl func called flow: %s\n",
-		__func__,
+	pr_debug("NET flowctrl func called flow: %s\n",
 		flow == CAIF_CTRLCMD_FLOW_ON_IND ? "ON" :
 		flow == CAIF_CTRLCMD_INIT_RSP ? "INIT" :
 		flow == CAIF_CTRLCMD_FLOW_OFF_IND ? "OFF" :
@@ -196,12 +197,12 @@ static int chnl_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv = netdev_priv(dev);
 
 	if (skb->len > priv->netdev->mtu) {
-		pr_warning("CAIF: %s(): Size of skb exceeded MTU\n", __func__);
+		pr_warn("Size of skb exceeded MTU\n");
 		return -ENOSPC;
 	}
 
 	if (!priv->flowenabled) {
-		pr_debug("CAIF: %s(): dropping packets flow off\n", __func__);
+		pr_debug("dropping packets flow off\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -237,7 +238,7 @@ static int chnl_net_open(struct net_device *dev)
 	ASSERT_RTNL();
 	priv = netdev_priv(dev);
 	if (!priv) {
-		pr_debug("CAIF: %s(): chnl_net_open: no priv\n", __func__);
+		pr_debug("chnl_net_open: no priv\n");
 		return -ENODEV;
 	}
 
@@ -246,18 +247,17 @@ static int chnl_net_open(struct net_device *dev)
 		result = caif_connect_client(&priv->conn_req, &priv->chnl,
 					&llifindex, &headroom, &tailroom);
 		if (result != 0) {
-				pr_debug("CAIF: %s(): err: "
-					"Unable to register and open device,"
-					" Err:%d\n",
-					__func__,
-					result);
+				pr_debug("err: "
+					 "Unable to register and open device,"
+					 " Err:%d\n",
+					 result);
 				goto error;
 		}
 
 		lldev = dev_get_by_index(dev_net(dev), llifindex);
 
 		if (lldev == NULL) {
-			pr_debug("CAIF: %s(): no interface?\n", __func__);
+			pr_debug("no interface?\n");
 			result = -ENODEV;
 			goto error;
 		}
@@ -279,9 +279,7 @@ static int chnl_net_open(struct net_device *dev)
 		dev_put(lldev);
 
 		if (mtu < 100) {
-			pr_warning("CAIF: %s(): "
-				"CAIF Interface MTU too small (%d)\n",
-				__func__, mtu);
+			pr_warn("CAIF Interface MTU too small (%d)\n", mtu);
 			result = -ENODEV;
 			goto error;
 		}
@@ -296,33 +294,32 @@ static int chnl_net_open(struct net_device *dev)
 	rtnl_lock();
 
 	if (result == -ERESTARTSYS) {
-		pr_debug("CAIF: %s(): wait_event_interruptible"
-			 " woken by a signal\n", __func__);
+		pr_debug("wait_event_interruptible woken by a signal\n");
 		result = -ERESTARTSYS;
 		goto error;
 	}
 
 	if (result == 0) {
-		pr_debug("CAIF: %s(): connect timeout\n", __func__);
+		pr_debug("connect timeout\n");
 		caif_disconnect_client(&priv->chnl);
 		priv->state = CAIF_DISCONNECTED;
-		pr_debug("CAIF: %s(): state disconnected\n", __func__);
+		pr_debug("state disconnected\n");
 		result = -ETIMEDOUT;
 		goto error;
 	}
 
 	if (priv->state != CAIF_CONNECTED) {
-		pr_debug("CAIF: %s(): connect failed\n", __func__);
+		pr_debug("connect failed\n");
 		result = -ECONNREFUSED;
 		goto error;
 	}
-	pr_debug("CAIF: %s(): CAIF Netdevice connected\n", __func__);
+	pr_debug("CAIF Netdevice connected\n");
 	return 0;
 
 error:
 	caif_disconnect_client(&priv->chnl);
 	priv->state = CAIF_DISCONNECTED;
-	pr_debug("CAIF: %s(): state disconnected\n", __func__);
+	pr_debug("state disconnected\n");
 	return result;
 
 }
@@ -413,7 +410,7 @@ static void caif_netlink_parms(struct nlattr *data[],
 				struct caif_connect_request *conn_req)
 {
 	if (!data) {
-		pr_warning("CAIF: %s: no params data found\n", __func__);
+		pr_warn("no params data found\n");
 		return;
 	}
 	if (data[IFLA_CAIF_IPV4_CONNID])
@@ -442,8 +439,7 @@ static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
 
 	ret = register_netdevice(dev);
 	if (ret)
-		pr_warning("CAIF: %s(): device rtml registration failed\n",
-			   __func__);
+		pr_warn("device rtml registration failed\n");
 	return ret;
 }
 


