From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 08/10] caif: Handle dev_queue_xmit errors.
Date: Fri, 13 May 2011 14:44:06 +0200
Message-ID: <1305290648-9613-9-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:39064 "EHLO
	slow2.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759119Ab1EMNCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:02:38 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow2.isp.as2116.net (Postfix) with ESMTP id 3E98E40B24
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:11 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do proper handling of dev_queue_xmit errors in order to
avoid double free of skb and leaks in error conditions.
In cfctrl pending requests are removed when CAIF Link layer goes down.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cfctrl.h |    3 +-
 net/caif/caif_dev.c       |    7 ++-
 net/caif/caif_socket.c    |    8 ++-
 net/caif/cfcnfg.c         |    2 +-
 net/caif/cfctrl.c         |  121 +++++++++++++++++++++++++++++++------=
-------
 net/caif/cffrml.c         |   17 ++++++-
 net/caif/cfveil.c         |    8 ++-
 7 files changed, 119 insertions(+), 47 deletions(-)

diff --git a/include/net/caif/cfctrl.h b/include/net/caif/cfctrl.h
index d84416f..9e5425b 100644
--- a/include/net/caif/cfctrl.h
+++ b/include/net/caif/cfctrl.h
@@ -124,6 +124,7 @@ int  cfctrl_linkdown_req(struct cflayer *cfctrl, u8=
 linkid,
=20
 struct cflayer *cfctrl_create(void);
 struct cfctrl_rsp *cfctrl_get_respfuncs(struct cflayer *layer);
-void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_laye=
r);
+int cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_layer=
);
+void cfctrl_remove(struct cflayer *layr);
=20
 #endif				/* CFCTRL_H_ */
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 0e651cf..366ca0f 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -118,6 +118,7 @@ static struct caif_device_entry *caif_get(struct ne=
t_device *dev)
=20
 static int transmit(struct cflayer *layer, struct cfpkt *pkt)
 {
+	int err;
 	struct caif_device_entry *caifd =3D
 	    container_of(layer, struct caif_device_entry, layer);
 	struct sk_buff *skb;
@@ -125,9 +126,11 @@ static int transmit(struct cflayer *layer, struct =
cfpkt *pkt)
 	skb =3D cfpkt_tonative(pkt);
 	skb->dev =3D caifd->netdev;
=20
-	dev_queue_xmit(skb);
+	err =3D dev_queue_xmit(skb);
+	if (err > 0)
+		err =3D -EIO;
=20
-	return 0;
+	return err;
 }
=20
 /*
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 653db75..7baae11 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -604,7 +604,9 @@ static int caif_seqpkt_sendmsg(struct kiocb *kiocb,=
 struct socket *sock,
 		goto err;
 	ret =3D transmit_skb(skb, cf_sk, noblock, timeo);
 	if (ret < 0)
-		goto err;
+		/* skb is already freed */
+		return ret;
+
 	return len;
 err:
 	kfree_skb(skb);
@@ -933,9 +935,9 @@ static int caif_release(struct socket *sock)
 	 * caif_queue_rcv_skb checks SOCK_DEAD holding the queue lock,
 	 * this ensures no packets when sock is dead.
 	 */
-	spin_lock(&sk->sk_receive_queue.lock);
+	spin_lock_bh(&sk->sk_receive_queue.lock);
 	sock_set_flag(sk, SOCK_DEAD);
-	spin_unlock(&sk->sk_receive_queue.lock);
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	sock->sk =3D NULL;
=20
 	dbfs_atomic_inc(&cnt.num_disconnect);
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index e857d89..4230099 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -126,7 +126,7 @@ void cfcnfg_remove(struct cfcnfg *cfg)
 		synchronize_rcu();
=20
 		kfree(cfg->mux);
-		kfree(cfg->ctrl);
+		cfctrl_remove(cfg->ctrl);
 		kfree(cfg);
 	}
 }
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 397a2c0..0c00a60 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -17,7 +17,6 @@
 #define UTILITY_NAME_LENGTH 16
 #define CFPKT_CTRL_PKT_LEN 20
=20
-
 #ifdef CAIF_NO_LOOP
 static int handle_loop(struct cfctrl *ctrl,
 			      int cmd, struct cfpkt *pkt){
@@ -51,13 +50,29 @@ struct cflayer *cfctrl_create(void)
 	this->serv.layer.receive =3D cfctrl_recv;
 	sprintf(this->serv.layer.name, "ctrl");
 	this->serv.layer.ctrlcmd =3D cfctrl_ctrlcmd;
+#ifndef CAIF_NO_LOOP
 	spin_lock_init(&this->loop_linkid_lock);
+	this->loop_linkid =3D 1;
+#endif
 	spin_lock_init(&this->info_list_lock);
 	INIT_LIST_HEAD(&this->list);
-	this->loop_linkid =3D 1;
 	return &this->serv.layer;
 }
=20
+void cfctrl_remove(struct cflayer *layer)
+{
+	struct cfctrl_request_info *p, *tmp;
+	struct cfctrl *ctrl =3D container_obj(layer);
+
+	spin_lock_bh(&ctrl->info_list_lock);
+	list_for_each_entry_safe(p, tmp, &ctrl->list, list) {
+		list_del(&p->list);
+		kfree(p);
+	}
+	spin_unlock_bh(&ctrl->info_list_lock);
+	kfree(layer);
+}
+
 static bool param_eq(const struct cfctrl_link_param *p1,
 			const struct cfctrl_link_param *p2)
 {
@@ -116,11 +131,11 @@ static bool cfctrl_req_eq(const struct cfctrl_req=
uest_info *r1,
 static void cfctrl_insert_req(struct cfctrl *ctrl,
 			      struct cfctrl_request_info *req)
 {
-	spin_lock(&ctrl->info_list_lock);
+	spin_lock_bh(&ctrl->info_list_lock);
 	atomic_inc(&ctrl->req_seq_no);
 	req->sequence_no =3D atomic_read(&ctrl->req_seq_no);
 	list_add_tail(&req->list, &ctrl->list);
-	spin_unlock(&ctrl->info_list_lock);
+	spin_unlock_bh(&ctrl->info_list_lock);
 }
=20
 /* Compare and remove request */
@@ -129,7 +144,6 @@ static struct cfctrl_request_info *cfctrl_remove_re=
q(struct cfctrl *ctrl,
 {
 	struct cfctrl_request_info *p, *tmp, *first;
=20
-	spin_lock(&ctrl->info_list_lock);
 	first =3D list_first_entry(&ctrl->list, struct cfctrl_request_info, l=
ist);
=20
 	list_for_each_entry_safe(p, tmp, &ctrl->list, list) {
@@ -145,7 +159,6 @@ static struct cfctrl_request_info *cfctrl_remove_re=
q(struct cfctrl *ctrl,
 	}
 	p =3D NULL;
 out:
-	spin_unlock(&ctrl->info_list_lock);
 	return p;
 }
=20
@@ -179,10 +192,6 @@ void cfctrl_enum_req(struct cflayer *layer, u8 phy=
slinkid)
 	cfpkt_addbdy(pkt, physlinkid);
 	ret =3D
 	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
-	if (ret < 0) {
-		pr_err("Could not transmit enum message\n");
-		cfpkt_destroy(pkt);
-	}
 }
=20
 int cfctrl_linkup_request(struct cflayer *layer,
@@ -196,14 +205,23 @@ int cfctrl_linkup_request(struct cflayer *layer,
 	struct cfctrl_request_info *req;
 	int ret;
 	char utility_name[16];
-	struct cfpkt *pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	struct cfpkt *pkt;
+
+	if (cfctrl_cancel_req(layer, user_layer) > 0) {
+		/* Slight Paranoia, check if already connecting */
+		pr_err("Duplicate connect request for same client\n");
+		WARN_ON(1);
+		return -EALREADY;
+	}
+
+	pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	if (!pkt) {
 		pr_warn("Out of memory\n");
 		return -ENOMEM;
 	}
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_SETUP);
-	cfpkt_addbdy(pkt, (param->chtype << 4) + param->linktype);
-	cfpkt_addbdy(pkt, (param->priority << 3) + param->phyid);
+	cfpkt_addbdy(pkt, (param->chtype << 4) | param->linktype);
+	cfpkt_addbdy(pkt, (param->priority << 3) | param->phyid);
 	cfpkt_addbdy(pkt, param->endpoint & 0x03);
=20
 	switch (param->linktype) {
@@ -266,9 +284,13 @@ int cfctrl_linkup_request(struct cflayer *layer,
 	ret =3D
 	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
 	if (ret < 0) {
-		pr_err("Could not transmit linksetup request\n");
-		cfpkt_destroy(pkt);
-		return -ENODEV;
+		int count;
+
+		count =3D cfctrl_cancel_req(&cfctrl->serv.layer,
+						user_layer);
+		if (count !=3D 1)
+			pr_err("Could not remove request (%d)", count);
+			return -ENODEV;
 	}
 	return 0;
 }
@@ -288,28 +310,29 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8=
 channelid,
 	init_info(cfpkt_info(pkt), cfctrl);
 	ret =3D
 	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
-	if (ret < 0) {
-		pr_err("Could not transmit link-down request\n");
-		cfpkt_destroy(pkt);
-	}
+#ifndef CAIF_NO_LOOP
+	cfctrl->loop_linkused[channelid] =3D 0;
+#endif
 	return ret;
 }
=20
-void cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_laye=
r)
+int cfctrl_cancel_req(struct cflayer *layr, struct cflayer *adap_layer=
)
 {
 	struct cfctrl_request_info *p, *tmp;
 	struct cfctrl *ctrl =3D container_obj(layr);
-	spin_lock(&ctrl->info_list_lock);
+	int found =3D 0;
+	spin_lock_bh(&ctrl->info_list_lock);
=20
 	list_for_each_entry_safe(p, tmp, &ctrl->list, list) {
 		if (p->client_layer =3D=3D adap_layer) {
-			pr_debug("cancel req :%d\n", p->sequence_no);
 			list_del(&p->list);
 			kfree(p);
+			found++;
 		}
 	}
=20
-	spin_unlock(&ctrl->info_list_lock);
+	spin_unlock_bh(&ctrl->info_list_lock);
+	return found;
 }
=20
 static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
@@ -461,6 +484,7 @@ static int cfctrl_recv(struct cflayer *layer, struc=
t cfpkt *pkt)
=20
 			rsp.cmd =3D cmd;
 			rsp.param =3D linkparam;
+			spin_lock_bh(&cfctrl->info_list_lock);
 			req =3D cfctrl_remove_req(cfctrl, &rsp);
=20
 			if (CFCTRL_ERR_BIT =3D=3D (CFCTRL_ERR_BIT & cmdrsp) ||
@@ -480,6 +504,8 @@ static int cfctrl_recv(struct cflayer *layer, struc=
t cfpkt *pkt)
=20
 			if (req !=3D NULL)
 				kfree(req);
+
+			spin_unlock_bh(&cfctrl->info_list_lock);
 		}
 		break;
 	case CFCTRL_CMD_LINK_DESTROY:
@@ -523,12 +549,29 @@ static void cfctrl_ctrlcmd(struct cflayer *layr, =
enum caif_ctrlcmd ctrl,
 	switch (ctrl) {
 	case _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND:
 	case CAIF_CTRLCMD_FLOW_OFF_IND:
-		spin_lock(&this->info_list_lock);
+		spin_lock_bh(&this->info_list_lock);
 		if (!list_empty(&this->list)) {
 			pr_debug("Received flow off in control layer\n");
 		}
-		spin_unlock(&this->info_list_lock);
+		spin_unlock_bh(&this->info_list_lock);
 		break;
+	case _CAIF_CTRLCMD_PHYIF_DOWN_IND: {
+		struct cfctrl_request_info *p, *tmp;
+
+		/* Find all connect request and report failure */
+		spin_lock_bh(&this->info_list_lock);
+		list_for_each_entry_safe(p, tmp, &this->list, list) {
+			if (p->param.phyid =3D=3D phyid) {
+				list_del(&p->list);
+				p->client_layer->ctrlcmd(p->client_layer,
+						CAIF_CTRLCMD_INIT_FAIL_RSP,
+						phyid);
+				kfree(p);
+			}
+		}
+		spin_unlock_bh(&this->info_list_lock);
+		break;
+	}
 	default:
 		break;
 	}
@@ -538,27 +581,33 @@ static void cfctrl_ctrlcmd(struct cflayer *layr, =
enum caif_ctrlcmd ctrl,
 static int handle_loop(struct cfctrl *ctrl, int cmd, struct cfpkt *pkt=
)
 {
 	static int last_linkid;
+	static int dec;
 	u8 linkid, linktype, tmp;
 	switch (cmd) {
 	case CFCTRL_CMD_LINK_SETUP:
-		spin_lock(&ctrl->loop_linkid_lock);
-		for (linkid =3D last_linkid + 1; linkid < 255; linkid++)
-			if (!ctrl->loop_linkused[linkid])
-				goto found;
+		spin_lock_bh(&ctrl->loop_linkid_lock);
+		if (!dec) {
+			for (linkid =3D last_linkid + 1; linkid < 255; linkid++)
+				if (!ctrl->loop_linkused[linkid])
+					goto found;
+		}
+		dec =3D 1;
 		for (linkid =3D last_linkid - 1; linkid > 0; linkid--)
 			if (!ctrl->loop_linkused[linkid])
 				goto found;
-		spin_unlock(&ctrl->loop_linkid_lock);
-		pr_err("Out of link-ids\n");
-		return -EINVAL;
+		spin_unlock_bh(&ctrl->loop_linkid_lock);
+
 found:
+		if (linkid < 10)
+			dec =3D 0;
+
 		if (!ctrl->loop_linkused[linkid])
 			ctrl->loop_linkused[linkid] =3D 1;
=20
 		last_linkid =3D linkid;
=20
 		cfpkt_add_trail(pkt, &linkid, 1);
-		spin_unlock(&ctrl->loop_linkid_lock);
+		spin_unlock_bh(&ctrl->loop_linkid_lock);
 		cfpkt_peek_head(pkt, &linktype, 1);
 		if (linktype =3D=3D  CFCTRL_SRV_UTIL) {
 			tmp =3D 0x01;
@@ -568,10 +617,10 @@ found:
 		break;
=20
 	case CFCTRL_CMD_LINK_DESTROY:
-		spin_lock(&ctrl->loop_linkid_lock);
+		spin_lock_bh(&ctrl->loop_linkid_lock);
 		cfpkt_peek_head(pkt, &linkid, 1);
 		ctrl->loop_linkused[linkid] =3D 0;
-		spin_unlock(&ctrl->loop_linkid_lock);
+		spin_unlock_bh(&ctrl->loop_linkid_lock);
 		break;
 	default:
 		break;
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index 4f4f756..04204b2 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -33,7 +33,6 @@ static void cffrml_ctrlcmd(struct cflayer *layr, enum=
 caif_ctrlcmd ctrl,
 static u32 cffrml_rcv_error;
 static u32 cffrml_rcv_checsum_error;
 struct cflayer *cffrml_create(u16 phyid, bool use_fcs)
-
 {
 	struct cffrml *this =3D kmalloc(sizeof(struct cffrml), GFP_ATOMIC);
 	if (!this) {
@@ -128,6 +127,13 @@ static int cffrml_receive(struct cflayer *layr, st=
ruct cfpkt *pkt)
 		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
+
+	if (layr->up =3D=3D NULL) {
+		pr_err("Layr up is missing!\n");
+		cfpkt_destroy(pkt);
+		return -EINVAL;
+	}
+
 	return layr->up->receive(layr->up, pkt);
 }
=20
@@ -150,15 +156,22 @@ static int cffrml_transmit(struct cflayer *layr, =
struct cfpkt *pkt)
 	cfpkt_info(pkt)->hdr_len +=3D 2;
 	if (cfpkt_erroneous(pkt)) {
 		pr_err("Packet is erroneous!\n");
+		cfpkt_destroy(pkt);
 		return -EPROTO;
 	}
+
+	if (layr->dn =3D=3D NULL) {
+		cfpkt_destroy(pkt);
+		return -ENODEV;
+
+	}
 	return layr->dn->transmit(layr->dn, pkt);
 }
=20
 static void cffrml_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctr=
l,
 					int phyid)
 {
-	if (layr->up->ctrlcmd)
+	if (layr->up && layr->up->ctrlcmd)
 		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
 }
=20
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index 1a588cd..3ec83fb 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -82,13 +82,14 @@ static int cfvei_transmit(struct cflayer *layr, str=
uct cfpkt *pkt)
 	int ret;
 	struct cfsrvl *service =3D container_obj(layr);
 	if (!cfsrvl_ready(service, &ret))
-		return ret;
+		goto err;
 	caif_assert(layr->dn !=3D NULL);
 	caif_assert(layr->dn->transmit !=3D NULL);
=20
 	if (cfpkt_add_head(pkt, &tmp, 1) < 0) {
 		pr_err("Packet is erroneous!\n");
-		return -EPROTO;
+		ret =3D -EPROTO;
+		goto err;
 	}
=20
 	/* Add info-> for MUX-layer to route the packet out. */
@@ -97,4 +98,7 @@ static int cfvei_transmit(struct cflayer *layr, struc=
t cfpkt *pkt)
 	info->hdr_len =3D 1;
 	info->dev_info =3D &service->dev_info;
 	return layr->dn->transmit(layr->dn, pkt);
+err:
+	cfpkt_destroy(pkt);
+	return ret;
 }
--=20
1.7.1

