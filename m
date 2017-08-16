From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 01/10] net: early init support for strparser
Date: Tue, 15 Aug 2017 22:30:47 -0700
Message-ID: <20170816053047.15445.21887.stgit@john-Precision-Tower-5810>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, john.fastabend@gmail.com,
        tom@herbertland.com
To: davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32800 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751482AbdHPFbE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:31:04 -0400
Received: by mail-pf0-f195.google.com with SMTP id c65so421242pfl.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:31:04 -0700 (PDT)
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is useful to allow strparser to init sockets before the read_sock
callback has been established.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 net/strparser/strparser.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
index 0d18fbc..434aa66 100644
--- a/net/strparser/strparser.c
+++ b/net/strparser/strparser.c
@@ -373,6 +373,9 @@ static int strp_read_sock(struct strparser *strp)
 	struct socket *sock = strp->sk->sk_socket;
 	read_descriptor_t desc;
 
+	if (unlikely(!sock || !sock->ops || !sock->ops->read_sock))
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
