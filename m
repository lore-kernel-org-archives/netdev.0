From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/5] soreuseport: UDP/IPv6 implementation
Date: Tue, 22 Jan 2013 11:50:44 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301221142150.26252@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="296491395-476528805-1358884244=:26252"
Cc: netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:36141 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754455Ab3AVTup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:50:45 -0500
Received: by mail-qa0-f74.google.com with SMTP id r4so5983qaq.1
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 11:50:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--296491395-476528805-1358884244=:26252
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

Motivation for soreuseport would be something like a DNS server.  An
alternative would be to recv on the same socket from multiple threads.
As in the case of TCP, the load across these threads tends to be
disproportionate and we also see a lot of contection on the socket lock.
Note that SO_REUSEADDR already allows multiple UDP sockets to bind to
the same port, however there is no provision to prevent hijacking and
nothing to distribute packets across all the sockets sharing the same
bound port.  This patch does not change the semantics of SO_REUSEADDR,
but provides usable functionality of it for unicast.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/udp.c |   30 +++++++++++++++++++++++++++---
 1 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1afb635..cb5bf49 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -45,6 +45,7 @@
 #include <net/tcp_states.h>
 #include <net/ip6_checksum.h>
 #include <net/xfrm.h>
+#include <net/inet6_hashtables.h>
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -203,7 +204,8 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
-	int score, badness;
+	int score, badness, matches = 0, reuseport = 0;
+	u32 hash = 0;
 
 begin:
 	result = NULL;
@@ -214,8 +216,18 @@ begin:
 		if (score > badness) {
 			result = sk;
 			badness = score;
-			if (score == SCORE2_MAX)
+			reuseport = sk->sk_reuseport;
+			if (reuseport) {
+				hash = inet6_ehashfn(net, daddr, hnum,
+						     saddr, sport);
+				matches = 1;
+			} else if (score == SCORE2_MAX)
 				goto exact_match;
+		} else if (score == badness && reuseport) {
+			matches++;
+			if (((u64)hash * matches) >> 32 == 0)
+				result = sk;
+			hash = next_pseudo_random32(hash);
 		}
 	}
 	/*
@@ -249,7 +261,8 @@ struct sock *__udp6_lib_lookup(struct net *net,
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
-	int score, badness;
+	int score, badness, matches = 0, reuseport = 0;
+	u32 hash = 0;
 
 	rcu_read_lock();
 	if (hslot->count > 10) {
@@ -284,6 +297,17 @@ begin:
 		if (score > badness) {
 			result = sk;
 			badness = score;
+			reuseport = sk->sk_reuseport;
+			if (reuseport) {
+				hash = inet6_ehashfn(net, daddr, hnum,
+						     saddr, sport);
+				matches = 1;
+			}
+		} else if (score == badness && reuseport) {
+			matches++;
+			if (((u64)hash * matches) >> 32 == 0)
+				result = sk;
+			hash = next_pseudo_random32(hash);
 		}
 	}
 	/*
-- 
1.7.7.3

--296491395-476528805-1358884244=:26252--
