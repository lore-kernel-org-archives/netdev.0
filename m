From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: connect() from bound sockets can be faster
Date: Wed, 27 May 2015 10:46:02 -0700
Message-ID: <1432748762.4060.414.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5565E202.8010202@gmail.com>
	 <1432743498.4060.399.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432744246.4060.406.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Crestez Dan Leonard <cdleonard@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:35353 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbbE0RqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:46:04 -0400
Received: by iesa3 with SMTP id a3so19500764ies.2
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 10:46:03 -0700 (PDT)
In-Reply-To: <1432744246.4060.406.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__inet_hash_connect() does not use its third argument (port_offset)
if socket was already bound to a source port.

No need to perform useless but expensive md5 computations.

Reported-by: Crestez Dan Leonard <cdleonard@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_hashtables.c  |    9 +++++++--
 net/ipv6/inet6_hashtables.c |    8 ++++++--
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 185efef0f1251ba9d45fabb3ed51777a8be097a6..e36942f0725d2e2d15f8d248b19a34c3487528ef 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -394,9 +394,10 @@ not_unique:
 	return -EADDRNOTAVAIL;
 }
 
-static inline u32 inet_sk_port_offset(const struct sock *sk)
+static u32 inet_sk_port_offset(const struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
+
 	return secure_ipv4_port_ephemeral(inet->inet_rcv_saddr,
 					  inet->inet_daddr,
 					  inet->inet_dport);
@@ -594,7 +595,11 @@ out:
 int inet_hash_connect(struct inet_timewait_death_row *death_row,
 		      struct sock *sk)
 {
-	return __inet_hash_connect(death_row, sk, inet_sk_port_offset(sk),
+	u32 port_offset = 0;
+
+	if (!inet_sk(sk)->inet_num)
+		port_offset = inet_sk_port_offset(sk);
+	return __inet_hash_connect(death_row, sk, port_offset,
 				   __inet_check_established);
 }
 EXPORT_SYMBOL_GPL(inet_hash_connect);
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 871641bc1ed4eb5b8f5f554c9efb75f2419fe5b6..b4fd96de97e61627003eff220e10bdd05a899e28 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -257,7 +257,7 @@ not_unique:
 	return -EADDRNOTAVAIL;
 }
 
-static inline u32 inet6_sk_port_offset(const struct sock *sk)
+static u32 inet6_sk_port_offset(const struct sock *sk)
 {
 	const struct inet_sock *inet = inet_sk(sk);
 
@@ -269,7 +269,11 @@ static inline u32 inet6_sk_port_offset(const struct sock *sk)
 int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 		       struct sock *sk)
 {
-	return __inet_hash_connect(death_row, sk, inet6_sk_port_offset(sk),
+	u32 port_offset = 0;
+
+	if (!inet_sk(sk)->inet_num)
+		port_offset = inet6_sk_port_offset(sk);
+	return __inet_hash_connect(death_row, sk, port_offset,
 				   __inet6_check_established);
 }
 EXPORT_SYMBOL_GPL(inet6_hash_connect);
