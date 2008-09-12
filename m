From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: [PATCH 2.6.28] tcp_ipv6: fix use of uninitialized memory
Date: Fri, 12 Sep 2008 09:05:25 +0200
Message-ID: <20080912070525.GA22276@damson.getinternet.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:34210 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbYILHFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 03:05:33 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1048995ugf.37
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 00:05:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 6544c4074aa5dde2e3f4d3e02f5601c1c33b770e Mon Sep 17 00:00:00 2001
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Tue, 9 Sep 2008 07:17:32 +0200
Subject: [PATCH] tcp_ipv6: fix use of uninitialized memory

inet6_rsk() is called on a struct request_sock * before we
have checked whether the socket is an ipv6 socket or a ipv6-
mapped ipv4 socket. The access that triggers this is the
inet_rsk(rsk)->inet6_rsk_offset dereference in inet6_rsk().

This is arguably not a critical error as the inet6_rsk_offset
is only used to compute a pointer which is never really used
(in the code path in question) anyway. But it might be a
latent error, so let's fix it.

Spotted by kmemcheck.

Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
---
 net/ipv6/tcp_ipv6.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5b90b36..c9b6c13 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1286,7 +1286,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 					  struct request_sock *req,
 					  struct dst_entry *dst)
 {
-	struct inet6_request_sock *treq = inet6_rsk(req);
+	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct tcp6_sock *newtcp6sk;
 	struct inet_sock *newinet;
@@ -1350,6 +1350,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		return newsk;
 	}
 
+	treq = inet6_rsk(req);
 	opt = np->opt;
 
 	if (sk_acceptq_is_full(sk))
-- 
1.5.5.1

