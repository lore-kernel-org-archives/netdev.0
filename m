From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] inet: fix possible seqlock deadlocks
Date: Thu, 28 Nov 2013 09:51:22 -0800
Message-ID: <1385661082.5352.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01>
	 <1385659390.5352.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: jongman.heo@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:48483 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab3K1RvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 12:51:24 -0500
In-Reply-To: <1385659390.5352.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit c9e9042994d3 ("ipv4: fix possible seqlock deadlock") I left
another places where IP_INC_STATS_BH() were improperly used.

udp_sendmsg(), ping_v4_sendmsg() and tcp_v4_connect() are called from
process context, not from softirq context.

This was detected by lockdep seqlock support.

Reported-by: jongman heo <jongman.heo@samsung.com>
Fixes: 584bdf8cbdf6 ("[IPV4]: Fix "ipOutNoRoutes" counter error for TCP and UDP")
Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ping.c     |    2 +-
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv4/udp.c      |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 840cf1b9e6ee..242e7f4ed6f4 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -772,7 +772,7 @@ int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		err = PTR_ERR(rt);
 		rt = NULL;
 		if (err == -ENETUNREACH)
-			IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
 		goto out;
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 59a6f8b90cd9..067213924751 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -177,7 +177,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		if (err == -ENETUNREACH)
-			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 		return err;
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 44dfaa09b584..44e3884f9e4c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -999,7 +999,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			err = PTR_ERR(rt);
 			rt = NULL;
 			if (err == -ENETUNREACH)
-				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+				IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
 			goto out;
 		}
 
