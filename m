From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/10] ipv4: ping make local stuff static
Date: Mon, 16 Dec 2013 10:39:24 -0800
Message-ID: <20131216103924.6a443b9b@nehalam.linuxnetplumber.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:62209 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755539Ab3LPTk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:40:26 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so5919411pbb.4
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 11:40:25 -0800 (PST)
In-Reply-To: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't export ping_table or ping_v4_sendmsg. Both are only used
inside ping code.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/ping.h	2013-12-12 11:48:17.173853412 -0800
+++ b/include/net/ping.h	2013-12-12 11:56:52.357830028 -0800
@@ -42,11 +42,6 @@ struct pingv6_ops {
 			     const struct net_device *dev, int strict);
 };
 
-struct ping_table {
-	struct hlist_nulls_head	hash[PING_HTABLE_SIZE];
-	rwlock_t		lock;
-};
-
 struct ping_iter_state {
 	struct seq_net_private  p;
 	int			bucket;
@@ -54,7 +49,6 @@ struct ping_iter_state {
 };
 
 extern struct proto ping_prot;
-extern struct ping_table ping_table;
 #if IS_ENABLED(CONFIG_IPV6)
 extern struct pingv6_ops pingv6_ops;
 #endif
@@ -81,8 +75,6 @@ int  ping_recvmsg(struct kiocb *iocb, st
 		  size_t len, int noblock, int flags, int *addr_len);
 int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 			 void *user_icmph, size_t icmph_len);
-int  ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		     size_t len);
 int  ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		     size_t len);
 int  ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
--- a/net/ipv4/ping.c	2013-12-12 11:48:17.173853412 -0800
+++ b/net/ipv4/ping.c	2013-12-12 11:56:52.357830028 -0800
@@ -53,8 +53,12 @@
 #include <net/transp_v6.h>
 #endif
 
+struct ping_table {
+	struct hlist_nulls_head	hash[PING_HTABLE_SIZE];
+	rwlock_t		lock;
+};
 
-struct ping_table ping_table;
+static struct ping_table ping_table;
 struct pingv6_ops pingv6_ops;
 EXPORT_SYMBOL_GPL(pingv6_ops);
 
@@ -668,8 +672,8 @@ int ping_common_sendmsg(int family, stru
 }
 EXPORT_SYMBOL_GPL(ping_common_sendmsg);
 
-int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		    size_t len)
+static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+			   size_t len)
 {
 	struct net *net = sock_net(sk);
 	struct flowi4 fl4;
