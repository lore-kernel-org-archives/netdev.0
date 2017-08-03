From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 1/6] net: early init support for strparser
Date: Thu, 03 Aug 2017 16:36:52 -0700
Message-ID: <20170803233652.12107.81136.stgit@john-Precision-Tower-5810>
References: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: davem@davemloft.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:38821 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHCXhI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:37:08 -0400
Received: by mail-pg0-f67.google.com with SMTP id 123so126662pga.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:37:07 -0700 (PDT)
In-Reply-To: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is useful to allow strparser to init sockets before the read_sock
callback has been established.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 net/strparser/strparser.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
index 0d18fbc..749f1cb 100644
--- a/net/strparser/strparser.c
+++ b/net/strparser/strparser.c
@@ -373,6 +373,9 @@ static int strp_read_sock(struct strparser *strp)
 	struct socket *sock = strp->sk->sk_socket;
 	read_descriptor_t desc;
 
+	if (unlikely(!sock->ops || !sock->ops->read_sock))
+		return -EBUSY;
+
 	desc.arg.data = strp;
 	desc.error = 0;
 	desc.count = 1; /* give more than one skb per call */
@@ -486,12 +489,7 @@ int strp_init(struct strparser *strp, struct sock *sk,
 	 * The upper layer calls strp_process for each skb to be parsed.
 	 */
 
-	if (sk) {
-		struct socket *sock = sk->sk_socket;
-
-		if (!sock->ops->read_sock || !sock->ops->peek_len)
-			return -EAFNOSUPPORT;
-	} else {
+	if (!sk) {
 		if (!cb->lock || !cb->unlock)
 			return -EINVAL;
 	}
