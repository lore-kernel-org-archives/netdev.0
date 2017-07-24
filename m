From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 5/6] socket: fix set not used warning
Date: Mon, 24 Jul 2017 10:25:22 -0700
Message-ID: <20170724172523.13135-6-sthemmin@microsoft.com>
References: <20170724172523.13135-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        davem@davemloft.net, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35566 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756122AbdGXRZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 13:25:37 -0400
Received: by mail-pf0-f170.google.com with SMTP id h29so14280276pfd.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 10:25:37 -0700 (PDT)
In-Reply-To: <20170724172523.13135-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable owned_by_user is always set, but only used
when kernel is configured with LOCKDEP enabled.

Get rid of the warning by moving the code to put the call
to owned_by_user into the the rcu_protected call.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/socket.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index bf2122691fba..79d9bb964cd8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3404,7 +3404,6 @@ u32 kernel_sock_ip_overhead(struct sock *sk)
 	struct inet_sock *inet;
 	struct ip_options_rcu *opt;
 	u32 overhead = 0;
-	bool owned_by_user;
 #if IS_ENABLED(CONFIG_IPV6)
 	struct ipv6_pinfo *np;
 	struct ipv6_txoptions *optv6 = NULL;
@@ -3413,13 +3412,12 @@ u32 kernel_sock_ip_overhead(struct sock *sk)
 	if (!sk)
 		return overhead;
 
-	owned_by_user = sock_owned_by_user(sk);
 	switch (sk->sk_family) {
 	case AF_INET:
 		inet = inet_sk(sk);
 		overhead += sizeof(struct iphdr);
 		opt = rcu_dereference_protected(inet->inet_opt,
-						owned_by_user);
+						sock_owned_by_user(sk));
 		if (opt)
 			overhead += opt->opt.optlen;
 		return overhead;
@@ -3429,7 +3427,7 @@ u32 kernel_sock_ip_overhead(struct sock *sk)
 		overhead += sizeof(struct ipv6hdr);
 		if (np)
 			optv6 = rcu_dereference_protected(np->opt,
-							  owned_by_user);
+							  sock_owned_by_user(sk));
 		if (optv6)
 			overhead += (optv6->opt_flen + optv6->opt_nflen);
 		return overhead;
-- 
2.11.0
