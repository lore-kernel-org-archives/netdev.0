From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 2/3] caif: Don't resend if dev_queue_xmit fails.
Date: Mon, 11 Apr 2011 22:43:51 +0200
Message-ID: <1302554632-13638-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1302554632-13638-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:46879 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab1DKUoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:44:38 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI00AC09LYVC00@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:44:22 +0200 (CEST)
Received: from localhost.localdomain ([80.203.137.187])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI0082H9LXJMZ0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:44:22 +0200 (CEST)
In-reply-to: <1302554632-13638-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

If CAIF Link Layer returns an error, we no longer try to re-build the
CAIF packet and resend it. Instead, we simply return any transmission
errors to the socket client.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c    |   21 ++++-----------------
 net/caif/caif_socket.c |   35 +++--------------------------------
 net/caif/cfdgml.c      |    7 +------
 net/caif/cffrml.c      |    8 +-------
 net/caif/cfmuxl.c      |    7 +------
 net/caif/cfserl.c      |    7 +------
 net/caif/cfutill.c     |    7 +------
 net/caif/cfveil.c      |    5 +----
 net/caif/cfvidl.c      |    5 +----
 9 files changed, 14 insertions(+), 88 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index b533bb0..a518fdd 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -120,25 +120,12 @@ static int transmit(struct cflayer *layer, struct=
 cfpkt *pkt)
 {
 	struct caif_device_entry *caifd =3D
 	    container_of(layer, struct caif_device_entry, layer);
-	struct sk_buff *skb, *skb2;
-	int ret =3D -EINVAL;
+	struct sk_buff *skb;
+
 	skb =3D cfpkt_tonative(pkt);
 	skb->dev =3D caifd->netdev;
-	/*
-	 * Don't allow SKB to be destroyed upon error, but signal resend
-	 * notification to clients. We can't rely on the return value as
-	 * congestion (NET_XMIT_CN) sometimes drops the packet, sometimes don=
't.
-	 */
-	if (netif_queue_stopped(caifd->netdev))
-		return -EAGAIN;
-	skb2 =3D skb_get(skb);
-
-	ret =3D dev_queue_xmit(skb2);
-
-	if (!ret)
-		kfree_skb(skb);
-	else
-		return -EAGAIN;
+
+	dev_queue_xmit(skb);
=20
 	return 0;
 }
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 8184c03..c7398b6 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -519,43 +519,14 @@ static int transmit_skb(struct sk_buff *skb, stru=
ct caifsock *cf_sk,
 			int noblock, long timeo)
 {
 	struct cfpkt *pkt;
-	int ret, loopcnt =3D 0;
=20
 	pkt =3D cfpkt_fromnative(CAIF_DIR_OUT, skb);
 	memset(cfpkt_info(pkt), 0, sizeof(struct caif_payload_info));
-	do {
-
-		ret =3D -ETIMEDOUT;
=20
-		/* Slight paranoia, probably not needed. */
-		if (unlikely(loopcnt++ > 1000)) {
-			pr_warn("transmit retries failed, error =3D %d\n", ret);
-			break;
-		}
+	if (cf_sk->layer.dn =3D=3D NULL)
+		return -EINVAL;
=20
-		if (cf_sk->layer.dn !=3D NULL)
-			ret =3D cf_sk->layer.dn->transmit(cf_sk->layer.dn, pkt);
-		if (likely(ret >=3D 0))
-			break;
-		/* if transmit return -EAGAIN, then retry */
-		if (noblock && ret =3D=3D -EAGAIN)
-			break;
-		timeo =3D caif_wait_for_flow_on(cf_sk, 0, timeo, &ret);
-		if (signal_pending(current)) {
-			ret =3D sock_intr_errno(timeo);
-			break;
-		}
-		if (ret)
-			break;
-		if (cf_sk->sk.sk_state !=3D CAIF_CONNECTED ||
-			sock_flag(&cf_sk->sk, SOCK_DEAD) ||
-			(cf_sk->sk.sk_shutdown & RCV_SHUTDOWN)) {
-			ret =3D -EPIPE;
-			cf_sk->sk.sk_err =3D EPIPE;
-			break;
-		}
-	} while (ret =3D=3D -EAGAIN);
-	return ret;
+	return cf_sk->layer.dn->transmit(cf_sk->layer.dn, pkt);
 }
=20
 /* Copied from af_unix:unix_dgram_sendmsg, and adapted to CAIF */
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index 27dab26..a4ce294 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -104,10 +104,5 @@ static int cfdgml_transmit(struct cflayer *layr, s=
truct cfpkt *pkt)
 	 */
 	info->hdr_len =3D 4;
 	info->dev_info =3D &service->dev_info;
-	ret =3D layr->dn->transmit(layr->dn, pkt);
-	if (ret < 0) {
-		u32 tmp32;
-		cfpkt_extr_head(pkt, &tmp32, 4);
-	}
-	return ret;
+	return layr->dn->transmit(layr->dn, pkt);
 }
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index a445043..2423fed 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -120,7 +120,6 @@ static int cffrml_transmit(struct cflayer *layr, st=
ruct cfpkt *pkt)
 	int tmp;
 	u16 chks;
 	u16 len;
-	int ret;
 	struct cffrml *this =3D container_obj(layr);
 	if (this->dofcs) {
 		chks =3D cfpkt_iterate(pkt, cffrml_checksum, 0xffff);
@@ -137,12 +136,7 @@ static int cffrml_transmit(struct cflayer *layr, s=
truct cfpkt *pkt)
 		pr_err("Packet is erroneous!\n");
 		return -EPROTO;
 	}
-	ret =3D layr->dn->transmit(layr->dn, pkt);
-	if (ret < 0) {
-		/* Remove header on faulty packet. */
-		cfpkt_extr_head(pkt, &tmp, 2);
-	}
-	return ret;
+	return layr->dn->transmit(layr->dn, pkt);
 }
=20
 static void cffrml_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctr=
l,
diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index eb94826..2ca9806 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -184,7 +184,6 @@ static int cfmuxl_receive(struct cflayer *layr, str=
uct cfpkt *pkt)
=20
 static int cfmuxl_transmit(struct cflayer *layr, struct cfpkt *pkt)
 {
-	int ret;
 	struct cfmuxl *muxl =3D container_obj(layr);
 	u8 linkid;
 	struct cflayer *dn;
@@ -198,11 +197,7 @@ static int cfmuxl_transmit(struct cflayer *layr, s=
truct cfpkt *pkt)
 	info->hdr_len +=3D 1;
 	linkid =3D info->channel_id;
 	cfpkt_add_head(pkt, &linkid, 1);
-	ret =3D dn->transmit(dn, pkt);
-	/* Remove MUX protocol header upon error. */
-	if (ret < 0)
-		cfpkt_extr_head(pkt, &linkid, 1);
-	return ret;
+	return dn->transmit(dn, pkt);
 }
=20
 static void cfmuxl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctr=
l,
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index 8303fe3..2715c84 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -179,15 +179,10 @@ static int cfserl_receive(struct cflayer *l, stru=
ct cfpkt *newpkt)
 static int cfserl_transmit(struct cflayer *layer, struct cfpkt *newpkt=
)
 {
 	struct cfserl *layr =3D container_obj(layer);
-	int ret;
 	u8 tmp8 =3D CFSERL_STX;
 	if (layr->usestx)
 		cfpkt_add_head(newpkt, &tmp8, 1);
-	ret =3D layer->dn->transmit(layer->dn, newpkt);
-	if (ret < 0)
-		cfpkt_extr_head(newpkt, &tmp8, 1);
-
-	return ret;
+	return layer->dn->transmit(layer->dn, newpkt);
 }
=20
 static void cfserl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctr=
l,
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index 315c0d6..98e027d 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -100,10 +100,5 @@ static int cfutill_transmit(struct cflayer *layr, =
struct cfpkt *pkt)
 	 */
 	info->hdr_len =3D 1;
 	info->dev_info =3D &service->dev_info;
-	ret =3D layr->dn->transmit(layr->dn, pkt);
-	if (ret < 0) {
-		u32 tmp32;
-		cfpkt_extr_head(pkt, &tmp32, 4);
-	}
-	return ret;
+	return layr->dn->transmit(layr->dn, pkt);
 }
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index c3b1dec..1a588cd 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -96,8 +96,5 @@ static int cfvei_transmit(struct cflayer *layr, struc=
t cfpkt *pkt)
 	info->channel_id =3D service->layer.id;
 	info->hdr_len =3D 1;
 	info->dev_info =3D &service->dev_info;
-	ret =3D layr->dn->transmit(layr->dn, pkt);
-	if (ret < 0)
-		cfpkt_extr_head(pkt, &tmp, 1);
-	return ret;
+	return layr->dn->transmit(layr->dn, pkt);
 }
diff --git a/net/caif/cfvidl.c b/net/caif/cfvidl.c
index bf6fef2..b2f5989 100644
--- a/net/caif/cfvidl.c
+++ b/net/caif/cfvidl.c
@@ -60,8 +60,5 @@ static int cfvidl_transmit(struct cflayer *layr, stru=
ct cfpkt *pkt)
 	info =3D cfpkt_info(pkt);
 	info->channel_id =3D service->layer.id;
 	info->dev_info =3D &service->dev_info;
-	ret =3D layr->dn->transmit(layr->dn, pkt);
-	if (ret < 0)
-		cfpkt_extr_head(pkt, &videoheader, 4);
-	return ret;
+	return layr->dn->transmit(layr->dn, pkt);
 }
--=20
1.7.0.4

