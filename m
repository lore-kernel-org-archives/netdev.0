From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udplite: call proper backlog handlers
Date: Tue, 22 Nov 2016 09:06:45 -0800
Message-ID: <1479834405.8455.437.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+zZSc28e4LMg-YvEztKO4X0VVxqCStkZW8LL4ZA_rYyMQ@mail.gmail.com>
         <CANn89iKewy1iMa=dUGpE=8UjHUi4o=s=6P_-ngLr_S_ZDByTwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@google.com>,
        samanthakumar <samanthakumar@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Benjamin LaHaise <bcrl@kvack.org>,
        Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iKewy1iMa=dUGpE=8UjHUi4o=s=6P_-ngLr_S_ZDByTwg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

In commits 93821778def10 ("udp: Fix rcv socket locking") and
f7ad74fef3af ("net/ipv6/udp: UDP encapsulation: break backlog_rcv into
__udpv6_queue_rcv_skb") UDP backlog handlers were renamed, but UDPlite
was forgotten.

This leads to crashes if UDPlite header is pulled twice, which happens
starting from commit e6afc8ace6dd ("udp: remove headers from UDP packets
before queueing")

Bug found by syzkaller team, thanks a lot guys !

Note that backlog use in UDP/UDPlite is scheduled to be removed starting
from linux-4.10, so this patch is only needed up to linux-4.9

Fixes: 93821778def1 ("udp: Fix rcv socket locking")
Fixes: f7ad74fef3af ("net/ipv6/udp: UDP encapsulation: break backlog_rcv into __udpv6_queue_rcv_skb")
Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/ipv4/udp.c      |    2 +-
 net/ipv4/udp_impl.h |    2 +-
 net/ipv4/udplite.c  |    2 +-
 net/ipv6/udp.c      |    2 +-
 net/ipv6/udp_impl.h |    2 +-
 net/ipv6/udplite.c  |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0de9d5d2b9ae..5bab6c3f7a2f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1455,7 +1455,7 @@ static void udp_v4_rehash(struct sock *sk)
 	udp_lib_rehash(sk, new_hash);
 }
 
-static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 7e0fe4bdd967..feb50a16398d 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -25,7 +25,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		int flags, int *addr_len);
 int udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
-int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
+int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void udp_destroy_sock(struct sock *sk);
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index af817158d830..ff450c2aad9b 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -50,7 +50,7 @@ struct proto 	udplite_prot = {
 	.sendmsg	   = udp_sendmsg,
 	.recvmsg	   = udp_recvmsg,
 	.sendpage	   = udp_sendpage,
-	.backlog_rcv	   = udp_queue_rcv_skb,
+	.backlog_rcv	   = __udp_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e5056d4873d1..e4a8000d59ad 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -514,7 +514,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	return;
 }
 
-static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index f6eb1ab34f4b..e78bdc76dcc3 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -26,7 +26,7 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
 int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		  int flags, int *addr_len);
-int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
+int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void udpv6_destroy_sock(struct sock *sk);
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 47d0d2b87106..2f5101a12283 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -45,7 +45,7 @@ struct proto udplitev6_prot = {
 	.getsockopt	   = udpv6_getsockopt,
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
-	.backlog_rcv	   = udpv6_queue_rcv_skb,
+	.backlog_rcv	   = __udpv6_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
