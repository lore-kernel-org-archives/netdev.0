From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 16/25] ip_generic_getfrag, udplite_getfrag: switch to passing msghdr
Date: Tue,  9 Dec 2014 22:50:29 +0000
Message-ID: <1418165438-2205-16-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37478 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972AbaLIWul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 17:50:41 -0500
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/udplite.h | 3 ++-
 net/ipv4/ip_output.c  | 6 +++---
 net/ipv4/raw.c        | 2 +-
 net/ipv4/udp.c        | 4 ++--
 net/ipv6/raw.c        | 2 +-
 net/ipv6/udp.c        | 2 +-
 net/l2tp/l2tp_ip6.c   | 2 +-
 7 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/net/udplite.h b/include/net/udplite.h
index 9a28a51..d5baaba 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -19,7 +19,8 @@ extern struct udp_table		udplite_table;
 static __inline__ int udplite_getfrag(void *from, char *to, int  offset,
 				      int len, int odd, struct sk_buff *skb)
 {
-	return memcpy_fromiovecend(to, (struct iovec *) from, offset, len);
+	struct msghdr *msg = from;
+	return memcpy_fromiovecend(to, msg->msg_iov, offset, len);
 }
 
 /* Designate sk as UDP-Lite socket */
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4a929ad..cdedcf1 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -752,14 +752,14 @@ EXPORT_SYMBOL(ip_fragment);
 int
 ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
 {
-	struct iovec *iov = from;
+	struct msghdr *msg = from;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		if (memcpy_fromiovecend(to, iov, offset, len) < 0)
+		if (memcpy_fromiovecend(to, msg->msg_iov, offset, len) < 0)
 			return -EFAULT;
 	} else {
 		__wsum csum = 0;
-		if (csum_partial_copy_fromiovecend(to, iov, offset, len, &csum) < 0)
+		if (csum_partial_copy_fromiovecend(to, msg->msg_iov, offset, len, &csum) < 0)
 			return -EFAULT;
 		skb->csum = csum_block_add(skb->csum, csum, odd);
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 5c901eb..5d83bd2 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -478,7 +478,7 @@ static int raw_getfrag(void *from, char *to, int offset, int len, int odd,
 
 	offset -= rfv->hlen;
 
-	return ip_generic_getfrag(rfv->msg->msg_iov, to, offset, len, odd, skb);
+	return ip_generic_getfrag(rfv->msg, to, offset, len, odd, skb);
 }
 
 static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index dd8e006..13b4dcf8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1049,7 +1049,7 @@ back_from_confirm:
 
 	/* Lockless fast path for the non-corking case. */
 	if (!corkreq) {
-		skb = ip_make_skb(sk, fl4, getfrag, msg->msg_iov, ulen,
+		skb = ip_make_skb(sk, fl4, getfrag, msg, ulen,
 				  sizeof(struct udphdr), &ipc, &rt,
 				  msg->msg_flags);
 		err = PTR_ERR(skb);
@@ -1080,7 +1080,7 @@ back_from_confirm:
 
 do_append_data:
 	up->len += ulen;
-	err = ip_append_data(sk, fl4, getfrag, msg->msg_iov, ulen,
+	err = ip_append_data(sk, fl4, getfrag, msg, ulen,
 			     sizeof(struct udphdr), &ipc, &rt,
 			     corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 942f67b..11a9283 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -727,7 +727,7 @@ static int raw6_getfrag(void *from, char *to, int offset, int len, int odd,
 
 	offset -= rfv->hlen;
 
-	return ip_generic_getfrag(rfv->msg->msg_iov, to, offset, len, odd, skb);
+	return ip_generic_getfrag(rfv->msg, to, offset, len, odd, skb);
 }
 
 static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 7f964322..189dc4a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1312,7 +1312,7 @@ do_append_data:
 		dontfrag = np->dontfrag;
 	up->len += ulen;
 	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
-	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
+	err = ip6_append_data(sk, getfrag, msg, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl6,
 		(struct rt6_info *)dst,
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag);
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 2177b96..8611f1b 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -619,7 +619,7 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 back_from_confirm:
 	lock_sock(sk);
-	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
+	err = ip6_append_data(sk, ip_generic_getfrag, msg,
 			      ulen, transhdrlen, hlimit, tclass, opt,
 			      &fl6, (struct rt6_info *)dst,
 			      msg->msg_flags, dontfrag);
-- 
2.1.3
