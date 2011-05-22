From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 1/5] caif: Bugfix add check NULL pointer before calling functions.
Date: Sun, 22 May 2011 23:18:50 +0200
Message-ID: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:47120 "EHLO pmx.vmail.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754586Ab1EVVTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 17:19:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add check on layer->dn !=3D NULL before calling functions in
layer below.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfctrl.c |   35 ++++++++++++++++++++++++++---------
 1 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 0c00a60..f8ac313 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -178,20 +178,23 @@ static void init_info(struct caif_payload_info *i=
nfo, struct cfctrl *cfctrl)
 void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
 {
 	struct cfctrl *cfctrl =3D container_obj(layer);
-	int ret;
 	struct cfpkt *pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	struct cflayer *dn =3D cfctrl->serv.layer.dn;
 	if (!pkt) {
 		pr_warn("Out of memory\n");
 		return;
 	}
+	if (!dn) {
+		pr_debug("not able to send enum request\n");
+		return;
+	}
 	caif_assert(offsetof(struct cfctrl, serv.layer) =3D=3D 0);
 	init_info(cfpkt_info(pkt), cfctrl);
 	cfpkt_info(pkt)->dev_info->id =3D physlinkid;
 	cfctrl->serv.dev_info.id =3D physlinkid;
 	cfpkt_addbdy(pkt, CFCTRL_CMD_ENUM);
 	cfpkt_addbdy(pkt, physlinkid);
-	ret =3D
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	dn->transmit(dn, pkt);
 }
=20
 int cfctrl_linkup_request(struct cflayer *layer,
@@ -206,6 +209,12 @@ int cfctrl_linkup_request(struct cflayer *layer,
 	int ret;
 	char utility_name[16];
 	struct cfpkt *pkt;
+	struct cflayer *dn =3D cfctrl->serv.layer.dn;
+
+	if (!dn) {
+		pr_debug("not able to send linkup request\n");
+		return -ENODEV;
+	}
=20
 	if (cfctrl_cancel_req(layer, user_layer) > 0) {
 		/* Slight Paranoia, check if already connecting */
@@ -282,7 +291,7 @@ int cfctrl_linkup_request(struct cflayer *layer,
 	 */
 	cfpkt_info(pkt)->dev_info->id =3D param->phyid;
 	ret =3D
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	    dn->transmit(dn, pkt);
 	if (ret < 0) {
 		int count;
=20
@@ -301,15 +310,23 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8=
 channelid,
 	int ret;
 	struct cfctrl *cfctrl =3D container_obj(layer);
 	struct cfpkt *pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	struct cflayer *dn =3D cfctrl->serv.layer.dn;
+
 	if (!pkt) {
 		pr_warn("Out of memory\n");
 		return -ENOMEM;
 	}
+
+	if (!dn) {
+		pr_debug("not able to send link-down request\n");
+		return -ENODEV;
+	}
+
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_DESTROY);
 	cfpkt_addbdy(pkt, channelid);
 	init_info(cfpkt_info(pkt), cfctrl);
 	ret =3D
-	    cfctrl->serv.layer.dn->transmit(cfctrl->serv.layer.dn, pkt);
+	    dn->transmit(dn, pkt);
 #ifndef CAIF_NO_LOOP
 	cfctrl->loop_linkused[channelid] =3D 0;
 #endif
@@ -477,7 +494,7 @@ static int cfctrl_recv(struct cflayer *layer, struc=
t cfpkt *pkt)
 				cfpkt_extr_head(pkt, &param, len);
 				break;
 			default:
-				pr_warn("Request setup - invalid link type (%d)\n",
+				pr_warn("Request setup, invalid type (%d)\n",
 					serv);
 				goto error;
 			}
@@ -489,7 +506,8 @@ static int cfctrl_recv(struct cflayer *layer, struc=
t cfpkt *pkt)
=20
 			if (CFCTRL_ERR_BIT =3D=3D (CFCTRL_ERR_BIT & cmdrsp) ||
 				cfpkt_erroneous(pkt)) {
-				pr_err("Invalid O/E bit or parse error on CAIF control channel\n")=
;
+				pr_err("Invalid O/E bit or parse error "
+						"on CAIF control channel\n");
 				cfctrl->res.reject_rsp(cfctrl->serv.layer.up,
 						       0,
 						       req ? req->client_layer
@@ -550,9 +568,8 @@ static void cfctrl_ctrlcmd(struct cflayer *layr, en=
um caif_ctrlcmd ctrl,
 	case _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND:
 	case CAIF_CTRLCMD_FLOW_OFF_IND:
 		spin_lock_bh(&this->info_list_lock);
-		if (!list_empty(&this->list)) {
+		if (!list_empty(&this->list))
 			pr_debug("Received flow off in control layer\n");
-		}
 		spin_unlock_bh(&this->info_list_lock);
 		break;
 	case _CAIF_CTRLCMD_PHYIF_DOWN_IND: {
--=20
1.7.0.4

