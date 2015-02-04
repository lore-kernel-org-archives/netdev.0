From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v3 02/18] ipv4: raw_send_hdrinc(): pass msghdr
Date: Wed,  4 Feb 2015 06:39:53 +0000
Message-ID: <1423032009-18367-2-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43077 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbbBDGkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:40:11 -0500
In-Reply-To: <20150204063730.GG29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Switch from passing msg->iov_iter.iov to passing msg itself

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/ipv4/raw.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 0bb68df..2c9d252 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -337,7 +337,7 @@ int raw_rcv(struct sock *sk, struct sk_buff *skb)
 }
 
 static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
-			   void *from, size_t length,
+			   struct msghdr *msg, size_t length,
 			   struct rtable **rtp,
 			   unsigned int flags)
 {
@@ -382,7 +382,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
-	if (memcpy_fromiovecend((void *)iph, from, 0, length))
+	if (memcpy_fromiovecend((void *)iph, msg->msg_iter.iov, 0, length))
 		goto error_free;
 
 	iphlen = iph->ihl * 4;
@@ -625,8 +625,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 back_from_confirm:
 
 	if (inet->hdrincl)
-		/* XXX: stripping const */
-		err = raw_send_hdrinc(sk, &fl4, (struct iovec *)msg->msg_iter.iov, len,
+		err = raw_send_hdrinc(sk, &fl4, msg, len,
 				      &rt, msg->msg_flags);
 
 	 else {
-- 
2.1.4
