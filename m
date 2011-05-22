From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 3/5] caif: Fix freezes when running CAIF loopback device
Date: Sun, 22 May 2011 23:18:52 +0200
Message-ID: <1306099134-12989-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:32571 "EHLO pmx.vmail.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755363Ab1EVVTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 17:19:07 -0400
In-Reply-To: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix spinlock bugs when running out of link-ids in loopback tests and
avoid allocating link-id when error is set in link-setup-response.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfctrl.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index f8ac313..e22671b 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -368,7 +368,8 @@ static int cfctrl_recv(struct cflayer *layer, struc=
t cfpkt *pkt)
 	cfpkt_extr_head(pkt, &cmdrsp, 1);
 	cmd =3D cmdrsp & CFCTRL_CMD_MASK;
 	if (cmd !=3D CFCTRL_CMD_LINK_ERR
-	    && CFCTRL_RSP_BIT !=3D (CFCTRL_RSP_BIT & cmdrsp)) {
+	    && CFCTRL_RSP_BIT !=3D (CFCTRL_RSP_BIT & cmdrsp)
+		&& CFCTRL_ERR_BIT !=3D (CFCTRL_ERR_BIT & cmdrsp)) {
 		if (handle_loop(cfctrl, cmd, pkt) !=3D 0)
 			cmdrsp |=3D CFCTRL_ERR_BIT;
 	}
@@ -604,16 +605,16 @@ static int handle_loop(struct cfctrl *ctrl, int c=
md, struct cfpkt *pkt)
 	case CFCTRL_CMD_LINK_SETUP:
 		spin_lock_bh(&ctrl->loop_linkid_lock);
 		if (!dec) {
-			for (linkid =3D last_linkid + 1; linkid < 255; linkid++)
+			for (linkid =3D last_linkid + 1; linkid < 254; linkid++)
 				if (!ctrl->loop_linkused[linkid])
 					goto found;
 		}
 		dec =3D 1;
-		for (linkid =3D last_linkid - 1; linkid > 0; linkid--)
+		for (linkid =3D last_linkid - 1; linkid > 1; linkid--)
 			if (!ctrl->loop_linkused[linkid])
 				goto found;
 		spin_unlock_bh(&ctrl->loop_linkid_lock);
-
+		return -1;
 found:
 		if (linkid < 10)
 			dec =3D 0;
--=20
1.7.0.4

