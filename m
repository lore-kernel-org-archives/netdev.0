From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 1/3] Phonet: zero-copy aligned GPRS RX
Date: Mon,  4 Jan 2010 14:02:47 +0200
Message-ID: <1262606569-3021-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:50114 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694Ab0ADMJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 07:09:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Newer Nokia cellular modems can use aligned payload for their GPRS pipe=
=2E

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    1 +
 net/phonet/pep-gprs.c    |    4 ++--
 net/phonet/pep.c         |    3 +++
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index 4c61cdc..c371625 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -77,6 +77,7 @@ static inline struct pnpipehdr *pnp_hdr(struct sk_buf=
f *skb)
=20
 enum {
 	PNS_PIPE_DATA =3D 0x20,
+	PNS_PIPE_ALIGNED_DATA,
=20
 	PNS_PEP_CONNECT_REQ =3D 0x40,
 	PNS_PEP_CONNECT_RESP,
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index d183509..d012089 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -96,11 +96,11 @@ static int gprs_recv(struct gprs_dev *gp, struct sk=
_buff *skb)
 		goto drop;
 	}
=20
-	if (likely(skb_headroom(skb) & 3)) {
+	if (skb_headroom(skb) & 3) {
 		struct sk_buff *rskb, *fs;
 		int flen =3D 0;
=20
-		/* Phonet Pipe data header is misaligned (3 bytes),
+		/* Phonet Pipe data header may be misaligned (3 bytes),
 		 * so wrap the IP packet as a single fragment of an head-less
 		 * socket buffer. The network stack will pull what it needs,
 		 * but at least, the whole IP payload is not memcpy'd. */
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index b6356f3..e23e309 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -354,6 +354,9 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 		queue =3D &pn->ctrlreq_queue;
 		goto queue;
=20
+	case PNS_PIPE_ALIGNED_DATA:
+		__skb_pull(skb, 1);
+		/* fall through */
 	case PNS_PIPE_DATA:
 		__skb_pull(skb, 3); /* Pipe data header */
 		if (!pn_flow_safe(pn->rx_fc)) {
--=20
1.6.3.3

