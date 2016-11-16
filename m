From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 v2 5/9] l2tp: fix L2TP_ATTR_UDP_CSUM handling
Date: Wed, 16 Nov 2016 22:45:22 +0000
Message-ID: <20161116224526.32343-5-asbjorn@asbjorn.st>
References: <20161116224526.32343-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:57394 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941161AbcKPWqg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 17:46:36 -0500
In-Reply-To: <20161116224526.32343-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2TP_ATTR_UDP_CSUM is read by the kernel as a NLA_FLAG value,
but is validated as a NLA_U8, so we will write it as an u8,
but the value isn't actually being read by the kernel.

It is written by the kernel as a NLA_U8, so we will read as
such.

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 ip/ipl2tp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index a7cbd66..03ca0cc 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -120,7 +120,7 @@ static int create_tunnel(struct l2tp_parm *p)
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_SPORT, p->local_udp_port);
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_DPORT, p->peer_udp_port);
 		if (p->udp_csum)
-			addattr(&req.n, 1024, L2TP_ATTR_UDP_CSUM);
+			addattr8(&req.n, 1024, L2TP_ATTR_UDP_CSUM, 1);
 		if (!p->udp6_csum_tx)
 			addattr(&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_TX);
 		if (!p->udp6_csum_rx)
@@ -289,7 +289,9 @@ static int get_response(struct nlmsghdr *n, void *arg)
 	if (attrs[L2TP_ATTR_L2SPEC_LEN])
 		p->l2spec_len = rta_getattr_u8(attrs[L2TP_ATTR_L2SPEC_LEN]);
 
-	p->udp_csum = !!attrs[L2TP_ATTR_UDP_CSUM];
+	if (attrs[L2TP_ATTR_UDP_CSUM])
+		p->udp_csum = !!rta_getattr_u8(attrs[L2TP_ATTR_UDP_CSUM]);
+
 	/*
 	 * Not fetching from L2TP_ATTR_UDP_ZERO_CSUM6_{T,R}X because the
 	 * kernel doesn't send it so just leave it as default value.
-- 
2.10.2
