From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 2/3] [UDP]: memory accounting in IPv4
Date: Sun, 30 Dec 2007 04:02:18 -0500
Message-ID: <47775E9A.40105@redhat.com>
References: <47775D8C.5010104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59538 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753187AbXL3JE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 04:04:29 -0500
In-Reply-To: <47775D8C.5010104@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds UDP memory usage accounting in IPv4. Currently,
receiving buffer accounting is only supported.

This patch is also introduced memory_allocated variable for UDP protocol.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Cc: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/udp.h  |    2 ++
 net/ipv4/af_inet.c |    2 ++
 net/ipv4/udp.c     |   26 ++++++++++++++++++++++++--
 3 files changed, 28 insertions(+), 2 deletions(-)

diff -pruN net-2.6.25-t12t19m-p5/include/net/udp.h net-2.6.25-t12t19m-p6/include/net/udp.h
--- net-2.6.25-t12t19m-p5/include/net/udp.h	2007-12-29 21:10:48.000000000 -0500
+++ net-2.6.25-t12t19m-p6/include/net/udp.h	2007-12-29 21:48:33.000000000 -0500
@@ -65,6 +65,8 @@ extern rwlock_t udp_hash_lock;

 extern struct proto udp_prot;

+extern atomic_t udp_memory_allocated;
+
 /* sysctl variables for udp */
 extern int sysctl_udp_mem[3];
 extern int sysctl_udp_rmem_min;
diff -pruN net-2.6.25-t12t19m-p5/net/ipv4/af_inet.c net-2.6.25-t12t19m-p6/net/ipv4/af_inet.c
--- net-2.6.25-t12t19m-p5/net/ipv4/af_inet.c	2007-12-29 21:09:21.000000000 -0500
+++ net-2.6.25-t12t19m-p6/net/ipv4/af_inet.c	2007-12-29 21:47:31.000000000 -0500
@@ -139,6 +139,8 @@ void inet_sock_destruct(struct sock *sk)
 	__skb_queue_purge(&sk->sk_receive_queue);
 	__skb_queue_purge(&sk->sk_error_queue);

+	sk_mem_reclaim(sk);
+
 	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
 		printk("Attempt to release TCP socket in state %d %p\n",
 		       sk->sk_state, sk);
diff -pruN net-2.6.25-t12t19m-p5/net/ipv4/udp.c net-2.6.25-t12t19m-p6/net/ipv4/udp.c
--- net-2.6.25-t12t19m-p5/net/ipv4/udp.c	2007-12-29 21:12:03.000000000 -0500
+++ net-2.6.25-t12t19m-p6/net/ipv4/udp.c	2007-12-29 21:51:17.000000000 -0500
@@ -127,6 +127,9 @@ EXPORT_SYMBOL(sysctl_udp_mem);
 EXPORT_SYMBOL(sysctl_udp_rmem_min);
 EXPORT_SYMBOL(sysctl_udp_wmem_min);

+atomic_t udp_memory_allocated;
+EXPORT_SYMBOL(udp_memory_allocated);
+
 static inline int __udp_lib_lport_inuse(__u16 num,
 					const struct hlist_head udptable[])
 {
@@ -910,13 +913,17 @@ try_again:
 		err = ulen;

 out_free:
+	lock_sock(sk);
 	skb_free_datagram(sk, skb);
+	release_sock(sk);
 out:
 	return err;

 csum_copy_err:
+	lock_sock(sk);
 	if (!skb_kill_datagram(sk, skb, flags))
 		UDP_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
+	release_sock(sk);

 	if (noblock)
 		return -EAGAIN;
@@ -1081,7 +1088,15 @@ static int __udp4_lib_mcast_deliver(stru
 				skb1 = skb_clone(skb, GFP_ATOMIC);

 			if (skb1) {
-				int ret = udp_queue_rcv_skb(sk, skb1);
+				int ret = 0;
+
+				bh_lock_sock_nested(sk);
+				if (!sock_owned_by_user(sk))
+					ret = udp_queue_rcv_skb(sk, skb1);
+				else
+					sk_add_backlog(sk, skb1);
+				bh_unlock_sock(sk);
+
 				if (ret > 0)
 					/* we should probably re-process instead
 					 * of dropping packets here. */
@@ -1174,7 +1189,13 @@ int __udp4_lib_rcv(struct sk_buff *skb,
 			       inet_iif(skb), udptable);

 	if (sk != NULL) {
-		int ret = udp_queue_rcv_skb(sk, skb);
+		int ret = 0;
+		bh_lock_sock_nested(sk);
+		if (!sock_owned_by_user(sk))
+			ret = udp_queue_rcv_skb(sk, skb);
+		else
+			sk_add_backlog(sk, skb);
+		bh_unlock_sock(sk);
 		sock_put(sk);

 		/* a return value > 0 means to resubmit the input, but
@@ -1469,6 +1490,7 @@ struct proto udp_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
+	.memory_allocated  = &udp_memory_allocated,
 	.sysctl_mem	   = sysctl_udp_mem,
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
-- 
Hitachi Computer Products (America) Inc.
