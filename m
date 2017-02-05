From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: properly cope with csum errors
Date: Sun, 05 Feb 2017 09:25:24 -0800
Message-ID: <1486315524.7793.22.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33375 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdBERZ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 12:25:27 -0500
Received: by mail-io0-f194.google.com with SMTP id 101so7077477iom.0
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 09:25:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dmitry reported that UDP sockets being destroyed would trigger the
WARN_ON(atomic_read(&sk->sk_rmem_alloc)); in inet_sock_destruct()

It turns out we do not properly destroy skb(s) that have wrong UDP
checksum.

Thanks again to syzkaller team.

Fixes : 7c13f97ffde6 ("udp: do fwd memory scheduling on dequeue")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h  |    4 +++-
 net/core/datagram.c |    8 ++++++--
 net/ipv4/udp.c      |    2 +-
 net/ipv6/udp.c      |    2 +-
 4 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index f0e867f58722..c4f5e6fca17c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2006,7 +2006,9 @@ void sk_reset_timer(struct sock *sk, struct timer_list *timer,
 void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 
 int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
-			unsigned int flags);
+			unsigned int flags,
+			void (*destructor)(struct sock *sk,
+					   struct sk_buff *skb));
 int __sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 662bea587165..ea633342ab0d 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -332,7 +332,9 @@ void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len)
 EXPORT_SYMBOL(__skb_free_datagram_locked);
 
 int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
-			unsigned int flags)
+			unsigned int flags,
+			void (*destructor)(struct sock *sk,
+					   struct sk_buff *skb))
 {
 	int err = 0;
 
@@ -342,6 +344,8 @@ int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
 		if (skb == skb_peek(&sk->sk_receive_queue)) {
 			__skb_unlink(skb, &sk->sk_receive_queue);
 			atomic_dec(&skb->users);
+			if (destructor)
+				destructor(sk, skb);
 			err = 0;
 		}
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
@@ -375,7 +379,7 @@ EXPORT_SYMBOL(__sk_queue_drop_skb);
 
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 {
-	int err = __sk_queue_drop_skb(sk, skb, flags);
+	int err = __sk_queue_drop_skb(sk, skb, flags, NULL);
 
 	kfree_skb(skb);
 	sk_mem_reclaim_partial(sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1307a7c2e544..8aab7d78d25b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1501,7 +1501,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	return err;
 
 csum_copy_err:
-	if (!__sk_queue_drop_skb(sk, skb, flags)) {
+	if (!__sk_queue_drop_skb(sk, skb, flags, udp_skb_destructor)) {
 		UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 		UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4d5c4eee4b3f..8990856f5101 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -441,7 +441,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	return err;
 
 csum_copy_err:
-	if (!__sk_queue_drop_skb(sk, skb, flags)) {
+	if (!__sk_queue_drop_skb(sk, skb, flags, udp_skb_destructor)) {
 		if (is_udp4) {
 			UDP_INC_STATS(sock_net(sk),
 				      UDP_MIB_CSUMERRORS, is_udplite);
