From: sjur.brandeland@stericsson.com
Subject: [net-next 03/11] caif: Fixed potential memory leak
Date: Mon, 25 Jun 2012 19:49:35 +0200
Message-ID: <1340646583-21059-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?=
	<sjur.brandeland@stericssion.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:58023 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587Ab2FYRt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:49:56 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so6807294lbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:49:55 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>

Rearranged the allocation and packet creations to
avoid potential leaks in error path.

Signed-off-by: Kim Lilliestierna <kim.xx.lilliestierna@stericsson.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericssion.com>
---
 net/caif/cfctrl.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 047cd0e..44f270f 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -175,15 +175,17 @@ static void init_info(struct caif_payload_info *i=
nfo, struct cfctrl *cfctrl)
=20
 void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
 {
+	struct cfpkt *pkt;
 	struct cfctrl *cfctrl =3D container_obj(layer);
-	struct cfpkt *pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	struct cflayer *dn =3D cfctrl->serv.layer.dn;
-	if (!pkt)
-		return;
+
 	if (!dn) {
 		pr_debug("not able to send enum request\n");
 		return;
 	}
+	pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	if (!pkt)
+		return;
 	caif_assert(offsetof(struct cfctrl, serv.layer) =3D=3D 0);
 	init_info(cfpkt_info(pkt), cfctrl);
 	cfpkt_info(pkt)->dev_info->id =3D physlinkid;
@@ -302,18 +304,17 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8=
 channelid,
 				struct cflayer *client)
 {
 	int ret;
+	struct cfpkt *pkt;
 	struct cfctrl *cfctrl =3D container_obj(layer);
-	struct cfpkt *pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	struct cflayer *dn =3D cfctrl->serv.layer.dn;
=20
-	if (!pkt)
-		return -ENOMEM;
-
 	if (!dn) {
 		pr_debug("not able to send link-down request\n");
 		return -ENODEV;
 	}
-
+	pkt =3D cfpkt_create(CFPKT_CTRL_PKT_LEN);
+	if (!pkt)
+		return -ENOMEM;
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_DESTROY);
 	cfpkt_addbdy(pkt, channelid);
 	init_info(cfpkt_info(pkt), cfctrl);
--=20
1.7.5.4
