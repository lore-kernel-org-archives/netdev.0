From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] raw: avoid two atomics in xmit
Date: Fri, 04 Jun 2010 10:23:57 +0200
Message-ID: <1275639837.2482.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57616 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab0FDIYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 04:24:00 -0400
Received: by fxm8 with SMTP id 8so597363fxm.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 01:23:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid two atomic ops per raw_send_hdrinc() call

Avoid two atomic ops per raw6_send_hdrinc() call

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/raw.c |    8 +++++---
 net/ipv6/raw.c |   12 +++++++-----
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2c7a163..66cc3be 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -314,7 +314,7 @@ int raw_rcv(struct sock *sk, struct sk_buff *skb)
 }
 
 static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
-			struct rtable *rt,
+			struct rtable **rtp,
 			unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -323,6 +323,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	struct sk_buff *skb;
 	unsigned int iphlen;
 	int err;
+	struct rtable *rt = *rtp;
 
 	if (length > rt->u.dst.dev->mtu) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport,
@@ -341,7 +342,8 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	skb_dst_set(skb, dst_clone(&rt->u.dst));
+	skb_dst_set(skb, &rt->u.dst);
+	*rtp = NULL;
 
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
@@ -576,7 +578,7 @@ back_from_confirm:
 
 	if (inet->hdrincl)
 		err = raw_send_hdrinc(sk, msg->msg_iov, len,
-					rt, msg->msg_flags);
+					&rt, msg->msg_flags);
 
 	 else {
 		if (!ipc.addr)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 864eb8e..968b964 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -602,13 +602,14 @@ out:
 }
 
 static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
-			struct flowi *fl, struct rt6_info *rt,
+			struct flowi *fl, struct dst_entry **dstp,
 			unsigned int flags)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
 	int err;
+	struct rt6_info *rt = (struct rt6_info *)*dstp;
 
 	if (length > rt->u.dst.dev->mtu) {
 		ipv6_local_error(sk, EMSGSIZE, fl, rt->u.dst.dev->mtu);
@@ -626,7 +627,8 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	skb_dst_set(skb, dst_clone(&rt->u.dst));
+	skb_dst_set(skb, &rt->u.dst);
+	*dstp = NULL;
 
 	skb_put(skb, length);
 	skb_reset_network_header(skb);
@@ -886,9 +888,9 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		goto do_confirm;
 
 back_from_confirm:
-	if (inet->hdrincl) {
-		err = rawv6_send_hdrinc(sk, msg->msg_iov, len, &fl, (struct rt6_info*)dst, msg->msg_flags);
-	} else {
+	if (inet->hdrincl)
+		err = rawv6_send_hdrinc(sk, msg->msg_iov, len, &fl, &dst, msg->msg_flags);
+	else {
 		lock_sock(sk);
 		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
 			len, 0, hlimit, tclass, opt, &fl, (struct rt6_info*)dst,


