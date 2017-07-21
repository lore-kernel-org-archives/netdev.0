From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH] IP: do not modify ingress packet IP option in ip_options_echo()
Date: Fri, 21 Jul 2017 15:55:18 +0200
Message-ID: <f5758b6b7199d2d2a218b0ad36f1e5ef108eac43.1500642854.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42418 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750858AbdGUNzb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 09:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While computing the response option set for LRSS, ip_options_echo()
also changes the ingress packet LRSS addresses list, setting
the last one to the dst specific address for the ingress packet
- via memset(start[ ...
The only visible effect of such change - beyond possibly damaging
shared/cloned skbs - is modifying the data carried by ICMP replies
changing the header information for reported the ingress packet,
whichi violates RFC1122 3.2.2.6.
All the others call sites just ignore the ingress packet IP options
after calling ip_options_echo().
This behavior predates git history and apparently was present into
the initial ip_options_echo() implementation in linux 1.3.30 but
still looks wrong.

Removing the fib_compute_spec_dst() call will allow completely
removing, with a later patch, skb->dst usage in ip_options_echo(),
so that we can release the dst entry early in the rx path and
drop a couple of related hacks.

This will evenutally target net-next.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/ip_options.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 93157f2..fdda973 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -174,9 +174,6 @@ int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
 				doffset -= 4;
 		}
 		if (doffset > 3) {
-			__be32 daddr = fib_compute_spec_dst(skb);
-
-			memcpy(&start[doffset-1], &daddr, 4);
 			dopt->faddr = faddr;
 			dptr[0] = start[0];
 			dptr[1] = doffset+3;
-- 
2.9.4
