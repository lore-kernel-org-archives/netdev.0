From: Joe Perches <joe@perches.com>
Subject: [PATCH] net: Use a more standard macro for INET_ADDR_COOKIE
Date: Tue, 13 May 2014 20:30:07 -0700
Message-ID: <1400038207.24350.83.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0199.hostedemail.com ([216.40.44.199]:42884 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752978AbaENDaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 23:30:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Missing a colon on definition use is a bit odd so
change the macro for the 32 bit case to declare an
__attribute__((unused)) and __deprecated variable.

The __deprecated attribute will cause gcc to emit
an error if the variable is actually used.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/inet_hashtables.h | 8 +++++---
 net/ipv4/inet_hashtables.c    | 4 ++--
 net/ipv4/udp.c                | 2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 1bdb477..dd1950a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -292,12 +292,12 @@ static inline struct sock *inet_lookup_listener(struct net *net,
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr) \
 	const __addrpair __name = (__force __addrpair) ( \
 				   (((__force __u64)(__be32)(__saddr)) << 32) | \
-				   ((__force __u64)(__be32)(__daddr)));
+				   ((__force __u64)(__be32)(__daddr)))
 #else /* __LITTLE_ENDIAN */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr) \
 	const __addrpair __name = (__force __addrpair) ( \
 				   (((__force __u64)(__be32)(__daddr)) << 32) | \
-				   ((__force __u64)(__be32)(__saddr)));
+				   ((__force __u64)(__be32)(__saddr)))
 #endif /* __BIG_ENDIAN */
 #define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)	\
 	(((__sk)->sk_portpair == (__ports))			&&	\
@@ -306,7 +306,9 @@ static inline struct sock *inet_lookup_listener(struct net *net,
 	   ((__sk)->sk_bound_dev_if == (__dif))) 		&& 	\
 	 net_eq(sock_net(__sk), (__net)))
 #else /* 32-bit arch */
-#define INET_ADDR_COOKIE(__name, __saddr, __daddr)
+#define INET_ADDR_COOKIE(__name, __saddr, __daddr) \
+	const int __name __deprecated __attribute__((unused))
+
 #define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif) \
 	(((__sk)->sk_portpair == (__ports))		&&		\
 	 ((__sk)->sk_daddr	== (__saddr))		&&		\
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 8b9cf27..c080aef 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -274,7 +274,7 @@ struct sock *__inet_lookup_established(struct net *net,
 				  const __be32 daddr, const u16 hnum,
 				  const int dif)
 {
-	INET_ADDR_COOKIE(acookie, saddr, daddr)
+	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
 	struct sock *sk;
 	const struct hlist_nulls_node *node;
@@ -327,7 +327,7 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	__be32 daddr = inet->inet_rcv_saddr;
 	__be32 saddr = inet->inet_daddr;
 	int dif = sk->sk_bound_dev_if;
-	INET_ADDR_COOKIE(acookie, saddr, daddr)
+	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
 	struct net *net = sock_net(sk);
 	unsigned int hash = inet_ehashfn(net, daddr, lport,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 54ea0a3..f3ce8d0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1875,7 +1875,7 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 	unsigned int hash2 = udp4_portaddr_hash(net, loc_addr, hnum);
 	unsigned int slot2 = hash2 & udp_table.mask;
 	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
-	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr)
+	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr);
 	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
 
 	rcu_read_lock();
