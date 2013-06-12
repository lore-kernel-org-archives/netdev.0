From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net,stable 1/2] l2tp: Fix PPP header erasure and memory leak
Date: Wed, 12 Jun 2013 16:07:23 +0200
Message-ID: <20130612140723.GB3500@alphalink.fr>
References: <cover.1371044671.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:39421 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753181Ab3FLOSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 10:18:15 -0400
Content-Disposition: inline
In-Reply-To: <cover.1371044671.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Copy user data after PPP framing header. This prevents erasure of the
added PPP header and avoids leaking two bytes of uninitialised memory
at the end of skb's data buffer.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 637a341..681c626 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -346,12 +346,12 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	skb_put(skb, 2);
 
 	/* Copy user data into skb */
-	error = memcpy_fromiovec(skb->data, m->msg_iov, total_len);
+	error = memcpy_fromiovec(skb_put(skb, total_len), m->msg_iov,
+				 total_len);
 	if (error < 0) {
 		kfree_skb(skb);
 		goto error_put_sess_tun;
 	}
-	skb_put(skb, total_len);
 
 	l2tp_xmit_skb(session, skb, session->hdr_len);
 
-- 
1.7.10.4
