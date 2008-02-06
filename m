From: David Miller <davem@davemloft.net>
Subject: Re: [bug] networking broke, ssh: connect to port 22: Protocol error
Date: Wed, 06 Feb 2008 03:42:43 -0800 (PST)
Message-ID: <20080206.034243.243568099.davem@davemloft.net>
References: <20080206113829.GA14793@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57707
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753627AbYBFLmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 06:42:17 -0500
In-Reply-To: <20080206113829.GA14793@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 6 Feb 2008 12:38:29 +0100

> 
> randconfig qa on x86.git ran into the following new networking related 
> problem on latest -git: with the attached .config the testbox comes up 
> but cannot establish any TCP connections due to -ENOPROTO in 
> sys_connect().

Make sure you have the following fix in your tree.

It might be the cause.

commit 5d8c0aa9433b09387d9021358baef7939f9b32c4
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Tue Feb 5 03:14:44 2008 -0800

    [INET]: Fix accidentally broken inet(6)_hash_connect's port offset calculations.
    
    The port offset calculations depend on the protocol family, but, as
    Adrian noticed, I broke this logic with the commit
    
    	5ee31fc1ecdcbc234c8c56dcacef87c8e09909d8
    	[INET]: Consolidate inet(6)_hash_connect.
    
    Return this logic back, by passing the port offset directly into the
    consolidated function.
    
    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
    Noticed-by: Adrian Bunk <bunk@kernel.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 48ac620..97dc35a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -389,7 +389,7 @@ static inline struct sock *inet_lookup(struct net *net,
 }
 
 extern int __inet_hash_connect(struct inet_timewait_death_row *death_row,
-		struct sock *sk,
+		struct sock *sk, u32 port_offset,
 		int (*check_established)(struct inet_timewait_death_row *,
 			struct sock *, __u16, struct inet_timewait_sock **),
 			       void (*hash)(struct sock *sk));
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 90f422c..9cac6c0 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -398,7 +398,7 @@ out:
 EXPORT_SYMBOL_GPL(inet_unhash);
 
 int __inet_hash_connect(struct inet_timewait_death_row *death_row,
-		struct sock *sk,
+		struct sock *sk, u32 port_offset,
 		int (*check_established)(struct inet_timewait_death_row *,
 			struct sock *, __u16, struct inet_timewait_sock **),
 		void (*hash)(struct sock *sk))
@@ -413,7 +413,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 	if (!snum) {
 		int i, remaining, low, high, port;
 		static u32 hint;
-		u32 offset = hint + inet_sk_port_offset(sk);
+		u32 offset = hint + port_offset;
 		struct hlist_node *node;
 		struct inet_timewait_sock *tw = NULL;
 
@@ -502,7 +502,7 @@ EXPORT_SYMBOL_GPL(__inet_hash_connect);
 int inet_hash_connect(struct inet_timewait_death_row *death_row,
 		      struct sock *sk)
 {
-	return __inet_hash_connect(death_row, sk,
+	return __inet_hash_connect(death_row, sk, inet_sk_port_offset(sk),
 			__inet_check_established, __inet_hash_nolisten);
 }
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 43f3993..99fd25f 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -236,7 +236,7 @@ static inline u32 inet6_sk_port_offset(const struct sock *sk)
 int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 		       struct sock *sk)
 {
-	return __inet_hash_connect(death_row, sk,
+	return __inet_hash_connect(death_row, sk, inet6_sk_port_offset(sk),
 			__inet6_check_established, __inet6_hash);
 }
 
