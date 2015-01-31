From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 5/6] udpv6: Add lockless sendmsg() support
Date: Sat, 31 Jan 2015 10:40:17 -0500
Message-ID: <1422718818-21093-6-git-send-email-vyasevic@redhat.com>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Cc: herbert@gondor.apana.org.au, hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:39465 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbbAaPlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 10:41:10 -0500
Received: by mail-qg0-f50.google.com with SMTP id f51so42229350qge.9
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 07:41:09 -0800 (PST)
In-Reply-To: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds the same functionaliy to IPv6 that
commit 903ab86d195cca295379699299c5fc10beba31c7
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Mar 1 02:36:48 2011 +0000

    udp: Add lockless transmit path

added to IPv4.

UDP transmit path can now run without a socket lock,
thus allowing multiple threads to send to a single socket
more efficiently.
This is only used when corking/MSG_MORE is not used.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/ipv6/udp.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 67a3d70..d048d46 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1177,6 +1177,7 @@ do_udp_sendmsg:
 	if (len > INT_MAX - sizeof(struct udphdr))
 		return -EMSGSIZE;
 
+	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	if (up->pending) {
 		/*
 		 * There are pending frames.
@@ -1307,6 +1308,20 @@ do_udp_sendmsg:
 		goto do_confirm;
 back_from_confirm:
 
+	/* Lockless fast path for the non-corking case */
+	if (!corkreq) {
+		struct sk_buff *skb;
+
+		skb = ip6_make_skb(sk, getfrag, msg, ulen,
+				   sizeof(struct udphdr), hlimit, tclass, opt,
+				   &fl6, (struct rt6_info *)dst,
+				   msg->msg_flags, dontfrag);
+		err = PTR_ERR(skb);
+		if (!IS_ERR_OR_NULL(skb))
+			err = udp_v6_send_skb(skb, &fl6);
+		goto release_dst;
+	}
+
 	lock_sock(sk);
 	if (unlikely(up->pending)) {
 		/* The socket is already corked while preparing it. */
@@ -1324,7 +1339,6 @@ do_append_data:
 	if (dontfrag < 0)
 		dontfrag = np->dontfrag;
 	up->len += ulen;
-	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip6_append_data(sk, getfrag, msg, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl6,
 		(struct rt6_info *)dst,
@@ -1336,6 +1350,11 @@ do_append_data:
 	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
 		up->pending = 0;
 
+	if (err > 0)
+		err = np->recverr ? net_xmit_errno(err) : 0;
+	release_sock(sk);
+
+release_dst:
 	if (dst) {
 		if (connected) {
 			ip6_dst_store(sk, dst,
@@ -1352,9 +1371,6 @@ do_append_data:
 		dst = NULL;
 	}
 
-	if (err > 0)
-		err = np->recverr ? net_xmit_errno(err) : 0;
-	release_sock(sk);
 out:
 	dst_release(dst);
 	fl6_sock_release(flowlabel);
-- 
1.9.3
