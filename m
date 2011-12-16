From: Alexandru Juncu <ajuncu@ixiacom.com>
Subject: [PATCH] llc_cmsg_rcv was getting called after sk_eat_skb.
Date: Fri, 16 Dec 2011 11:01:25 +0200
Message-ID: <1324026085-11812-1-git-send-email-ajuncu@ixiacom.com>
Cc: alex.juncu@rosedu.org, Alexandru Juncu <ajuncu@ixiacom.com>,
	Kunjan Naik <knaik@ixiacom.com>
To: acme@ghostprotocols.net, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55703 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab1LPJBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 04:01:46 -0500
Received: by eekc4 with SMTP id c4so2984510eek.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 01:01:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Received non stream protocol packets were calling llc_cmsg_rcv that used a
skb after that skb was released by sk_eat_skb. This caused received STP
packets to generate kernel panics.

Signed-off-by: Alexandru Juncu <ajuncu@ixiacom.com>
Signed-off-by: Kunjan Naik <knaik@ixiacom.com>
---
 net/llc/af_llc.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index dfd3a64..a18e6c3 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -833,15 +833,15 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 		copied += used;
 		len -= used;
 
+		/* For non stream protcols we get one packet per recvmsg call */
+		if (sk->sk_type != SOCK_STREAM)
+			goto copy_uaddr;
+
 		if (!(flags & MSG_PEEK)) {
 			sk_eat_skb(sk, skb, 0);
 			*seq = 0;
 		}
 
-		/* For non stream protcols we get one packet per recvmsg call */
-		if (sk->sk_type != SOCK_STREAM)
-			goto copy_uaddr;
-
 		/* Partial read */
 		if (used + offset < skb->len)
 			continue;
@@ -857,6 +857,12 @@ copy_uaddr:
 	}
 	if (llc_sk(sk)->cmsg_flags)
 		llc_cmsg_rcv(msg, skb);
+
+	if (!(flags & MSG_PEEK)) {
+			sk_eat_skb(sk, skb, 0);
+			*seq = 0;
+	}
+
 	goto out;
 }
 
-- 
1.7.4.1
