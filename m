From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 1/4] IP: do not modify ingress packet IP option in ip_options_echo()
Date: Thu,  3 Aug 2017 18:07:05 +0200
Message-ID: <fac6e6cb1a6bf442f0feeaf5824fac68c6138115.1501775813.git.pabeni@redhat.com>
References: <cover.1501775813.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43142 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751010AbdHCQHe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 12:07:34 -0400
In-Reply-To: <cover.1501775813.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While computing the response option set for LSRR, ip_options_echo()
also changes the ingress packet LSRR addresses list, setting
the last one to the dst specific address for the ingress packet
- via memset(start[ ...
The only visible effect of such change - beyond possibly damaging
shared/cloned skbs - is modifying the data carried by ICMP replies
changing the header information for reported the ingress packet,
which violates RFC1122 3.2.2.6.
All the others call sites just ignore the ingress packet IP options
after calling ip_options_echo()
Note that the last element in the LSRR option address list for the
reply packet will be properly set later in the ip output path
via ip_options_build().
This buggy memset() predates git history and apparently was present
into the initial ip_options_echo() implementation in linux 1.3.30 but
still looks wrong.

The removal of the fib_compute_spec_dst() call will help
completely dropping the skb->dst usage by __ip_options_echo() with a
later patch.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/ip_options.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 93157f2f4758..fdda97308c0b 100644
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
2.13.3
