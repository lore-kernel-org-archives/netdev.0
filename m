From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: fix possible seqlock deadlock
Date: Thu, 28 Nov 2013 09:23:10 -0800
Message-ID: <1385659390.5352.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: jongman.heo@samsung.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:58388 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab3K1RXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 12:23:13 -0500
In-Reply-To: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit c9e9042994d3 ("ipv4: fix possible seqlock deadlock") I left
another spot where IP_INC_STATS_BH() was improperly used.

udp_sendmsg() is called from process context, not from softirq context.

This was detected by lockdep seqlock support.

Reported-by: jongman heo <jongman.heo@samsung.com>
Fixes: 584bdf8cbdf6 ("[IPV4]: Fix "ipOutNoRoutes" counter error for TCP and UDP")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/udp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
 
