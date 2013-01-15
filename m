From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] net: increase fragment memory usage limits
Date: Tue, 15 Jan 2013 18:16:35 +0100
Message-ID: <20130115171635.23951.37626.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21350 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757068Ab3AORNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2013 12:13:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase the amount of memory usage limits for incomplete
IP fragments.

Arguing for new thresh high/low values:

 High threshold = 4 MBytes
 Low  threshold = 3 MBytes

The fragmentation memory accounting code, tries to account for the
real memory usage, by measuring both the size of frag queue struct
(inet_frag_queue (ipv4:ipq/ipv6:frag_queue)) and the SKB's truesize.

We want to be able to handle/hold-on-to enough fragments, to ensure
good performance, without causing incomplete fragments to hurt
scalability, by causing the number of inet_frag_queue to grow too much
(resulting longer searches for frag queues).

For IPv4, how much memory does the largest frag consume.

Maximum size fragment is 64K, which is approx 44 fragments with
MTU(1500) sized packets. Sizeof(struct ipq) is 200.  A 1500 byte
packet results in a truesize of 2944 (not 2048 as I first assumed)

  (44*2944)+200 = 129736 bytes

The current default high thresh of 262144 bytes, is obviously
problematic, as only two 64K fragments can fit in the queue at the
same time.

How many 64K fragment can we fit into 4 MBytes:

  4*2^20/((44*2944)+200) = 32.34 fragment in queues

An attacker could send a separate/distinct fake fragment packets per
queue, causing us to allocate one inet_frag_queue per packet, and thus
attacking the hash table and its lists.

How many frag queue do we need to store, and given a current hash size
of 64, what is the average list length.

Using one MTU sized fragment per inet_frag_queue, each consuming
(2944+200) 3144 bytes.

  4*2^20/(2944+200) = 1334 frag queues -> 21 avg list length

An attack could send small fragments, the smallest packet I could send
resulted in a truesize of 896 bytes (I'm a little surprised by this).

  4*2^20/(896+200)  = 3827 frag queues -> 59 avg list length

When increasing these number, we also need to followup with
improvements, that is going to help scalability.  Simply increasing
the hash size, is not enough as the current implementation does not
have a per hash bucket locking.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/ipv6.h     |    4 ++--
 net/ipv4/ip_fragment.c |   22 +++++++++++++++-------
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ed67208..e6e65fb 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -292,8 +292,8 @@ static inline int ip6_frag_mem(struct net *net)
 }
 #endif
 
-#define IPV6_FRAG_HIGH_THRESH	(256 * 1024)	/* 262144 */
-#define IPV6_FRAG_LOW_THRESH	(192 * 1024)	/* 196608 */
+#define IPV6_FRAG_HIGH_THRESH	(4 * 1024*1024)	/* 4194304 */
+#define IPV6_FRAG_LOW_THRESH	(3 * 1024*1024)	/* 3145728 */
 #define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
 
 extern int __ipv6_addr_type(const struct in6_addr *addr);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index eb9d63a..f55a4e6 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -851,14 +851,22 @@ static inline void ip4_frags_ctl_register(void)
 
 static int __net_init ipv4_frags_init_net(struct net *net)
 {
-	/*
-	 * Fragment cache limits. We will commit 256K at one time. Should we
-	 * cross that limit we will prune down to 192K. This should cope with
-	 * even the most extreme cases without allowing an attacker to
-	 * measurably harm machine performance.
+	/* Fragment cache limits.
+	 *
+	 * The fragment memory accounting code, (tries to) account for
+	 * the real memory usage, by measuring both the size of frag
+	 * queue struct (inet_frag_queue (ipv4:ipq/ipv6:frag_queue))
+	 * and the SKB's truesize.
+	 *
+	 * A 64K fragment consumes 129736 bytes (44*2944)+200
+	 * (1500 truesize == 2944, sizeof(struct ipq) == 200)
+	 *
+	 * We will commit 4MB at one time. Should we cross that limit
+	 * we will prune down to 3MB, making room for approx 8 big 64K
+	 * fragments 8x128k.
 	 */
-	net->ipv4.frags.high_thresh = 256 * 1024;
-	net->ipv4.frags.low_thresh = 192 * 1024;
+	net->ipv4.frags.high_thresh = 4 * 1024 * 1024;
+	net->ipv4.frags.low_thresh  = 3 * 1024 * 1024;
 	/*
 	 * Important NOTE! Fragment queue must be destroyed before MSL expires.
 	 * RFC791 is wrong proposing to prolongate timer each fragment arrival
