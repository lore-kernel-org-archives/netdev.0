From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 1/2] caif: Fix for a race in socket transmit with flow control.
Date: Sun, 11 Mar 2012 21:28:31 +0100
Message-ID: <1331497712-13534-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:34588 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751582Ab2CKU2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 16:28:47 -0400
Received: by lahj13 with SMTP id j13so3064310lah.19
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2012 13:28:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>

Kill faulty checks on flow-off leading to connection drop at race condi=
tions.
caif_socket checks for flow-on before transmitting and goes to sleep or
return -EAGAIN upon flow stop. Remove faulty subsequent checks on flow-=
off
leading to connection drop. Also fix memory leaks on some of the errors=
 paths.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfdbgl.c  |    4 +++-
 net/caif/cfdgml.c  |    9 +++++++--
 net/caif/cfrfml.c  |   25 +++++++++++--------------
 net/caif/cfsrvl.c  |    6 +-----
 net/caif/cfutill.c |    5 ++++-
 net/caif/cfvidl.c  |    6 +++++-
 6 files changed, 31 insertions(+), 24 deletions(-)

diff --git a/net/caif/cfdbgl.c b/net/caif/cfdbgl.c
index 65d6ef3..2914659 100644
--- a/net/caif/cfdbgl.c
+++ b/net/caif/cfdbgl.c
@@ -41,8 +41,10 @@ static int cfdbgl_transmit(struct cflayer *layr, str=
uct cfpkt *pkt)
 	struct caif_payload_info *info;
 	int ret;
=20
-	if (!cfsrvl_ready(service, &ret))
+	if (!cfsrvl_ready(service, &ret)) {
+		cfpkt_destroy(pkt);
 		return ret;
+	}
=20
 	/* Add info for MUX-layer to route the packet out */
 	info =3D cfpkt_info(pkt);
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index 0f5ff27..a63f4a5 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -86,12 +86,17 @@ static int cfdgml_transmit(struct cflayer *layr, st=
ruct cfpkt *pkt)
 	struct caif_payload_info *info;
 	struct cfsrvl *service =3D container_obj(layr);
 	int ret;
-	if (!cfsrvl_ready(service, &ret))
+
+	if (!cfsrvl_ready(service, &ret)) {
+		cfpkt_destroy(pkt);
 		return ret;
+	}
=20
 	/* STE Modem cannot handle more than 1500 bytes datagrams */
-	if (cfpkt_getlen(pkt) > DGM_MTU)
+	if (cfpkt_getlen(pkt) > DGM_MTU) {
+		cfpkt_destroy(pkt);
 		return -EMSGSIZE;
+	}
=20
 	cfpkt_add_head(pkt, &zero, 3);
 	packet_type =3D 0x08; /* B9 set - UNCLASSIFIED */
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 6dc75d4..2b563ad 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -184,6 +184,11 @@ out:
 					rfml->serv.dev_info.id);
 	}
 	spin_unlock(&rfml->sync);
+
+	if (unlikely(err =3D=3D -EAGAIN))
+		/* It is not possible to recover after drop of a fragment */
+		err =3D -EIO;
+
 	return err;
 }
=20
@@ -218,7 +223,7 @@ static int cfrfml_transmit(struct cflayer *layr, st=
ruct cfpkt *pkt)
 	caif_assert(layr->dn->transmit !=3D NULL);
=20
 	if (!cfsrvl_ready(&rfml->serv, &err))
-		return err;
+		goto out;
=20
 	err =3D -EPROTO;
 	if (cfpkt_getlen(pkt) <=3D RFM_HEAD_SIZE-1)
@@ -251,8 +256,11 @@ static int cfrfml_transmit(struct cflayer *layr, s=
truct cfpkt *pkt)
=20
 		err =3D cfrfml_transmit_segment(rfml, frontpkt);
=20
-		if (err !=3D 0)
+		if (err !=3D 0) {
+			frontpkt =3D NULL;
 			goto out;
+		}
+
 		frontpkt =3D rearpkt;
 		rearpkt =3D NULL;
=20
@@ -286,19 +294,8 @@ out:
 		if (rearpkt)
 			cfpkt_destroy(rearpkt);
=20
-		if (frontpkt && frontpkt !=3D pkt) {
-
+		if (frontpkt)
 			cfpkt_destroy(frontpkt);
-			/*
-			 * Socket layer will free the original packet,
-			 * but this packet may already be sent and
-			 * freed. So we have to return 0 in this case
-			 * to avoid socket layer to re-free this packet.
-			 * The return of shutdown indication will
-			 * cause connection to be invalidated anyhow.
-			 */
-			err =3D 0;
-		}
 	}
=20
 	return err;
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index b99f5b2..4aa33d4 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -174,15 +174,11 @@ void cfsrvl_init(struct cfsrvl *service,
=20
 bool cfsrvl_ready(struct cfsrvl *service, int *err)
 {
-	if (service->open && service->modem_flow_on && service->phy_flow_on)
-		return true;
 	if (!service->open) {
 		*err =3D -ENOTCONN;
 		return false;
 	}
-	caif_assert(!(service->modem_flow_on && service->phy_flow_on));
-	*err =3D -EAGAIN;
-	return false;
+	return true;
 }
=20
 u8 cfsrvl_getphyid(struct cflayer *layer)
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index 53e49f3..86d2dad 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -84,8 +84,11 @@ static int cfutill_transmit(struct cflayer *layr, st=
ruct cfpkt *pkt)
 	caif_assert(layr !=3D NULL);
 	caif_assert(layr->dn !=3D NULL);
 	caif_assert(layr->dn->transmit !=3D NULL);
-	if (!cfsrvl_ready(service, &ret))
+
+	if (!cfsrvl_ready(service, &ret)) {
+		cfpkt_destroy(pkt);
 		return ret;
+	}
=20
 	cfpkt_add_head(pkt, &zero, 1);
 	/* Add info for MUX-layer to route the packet out. */
diff --git a/net/caif/cfvidl.c b/net/caif/cfvidl.c
index e3f37db..a8e2a2d 100644
--- a/net/caif/cfvidl.c
+++ b/net/caif/cfvidl.c
@@ -50,8 +50,12 @@ static int cfvidl_transmit(struct cflayer *layr, str=
uct cfpkt *pkt)
 	struct caif_payload_info *info;
 	u32 videoheader =3D 0;
 	int ret;
-	if (!cfsrvl_ready(service, &ret))
+
+	if (!cfsrvl_ready(service, &ret)) {
+		cfpkt_destroy(pkt);
 		return ret;
+	}
+
 	cfpkt_add_head(pkt, &videoheader, 4);
 	/* Add info for MUX-layer to route the packet out */
 	info =3D cfpkt_info(pkt);
--=20
1.7.0.4
