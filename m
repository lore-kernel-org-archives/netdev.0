From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipv6: fix source routing
Date: Tue, 25 Apr 2017 15:56:50 +0200
Message-ID: <1d451d4d6c04c259280dee65caeabf3e00e0eb94.1493128459.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Lebrun <david.lebrun@uclouvain.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35972 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1947159AbdDYN5C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 09:57:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a149e7c7ce81 ("ipv6: sr: add support for SRH injection through
setsockopt") introduced handling of IPV6_SRCRT_TYPE_4, but at the same
time restricted it to only IPV6_SRCRT_TYPE_0 and
IPV6_SRCRT_TYPE_4. Previously, ipv6_push_exthdr() and fl6_update_dst()
would also handle other values (ie STRICT and TYPE_2).

Restore previous source routing behavior, by handling IPV6_SRCRT_STRICT
and IPV6_SRCRT_TYPE_2 the same way as IPV6_SRCRT_TYPE_0 in
ipv6_push_exthdr() and fl6_update_dst().

Fixes: a149e7c7ce81 ("ipv6: sr: add support for SRH injection through setsockopt")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/exthdrs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 25192a3b0cd7..d32e2110aff2 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -909,6 +909,8 @@ static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
 {
 	switch (opt->type) {
 	case IPV6_SRCRT_TYPE_0:
+	case IPV6_SRCRT_STRICT:
+	case IPV6_SRCRT_TYPE_2:
 		ipv6_push_rthdr0(skb, proto, opt, addr_p, saddr);
 		break;
 	case IPV6_SRCRT_TYPE_4:
@@ -1163,6 +1165,8 @@ struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 
 	switch (opt->srcrt->type) {
 	case IPV6_SRCRT_TYPE_0:
+	case IPV6_SRCRT_STRICT:
+	case IPV6_SRCRT_TYPE_2:
 		fl6->daddr = *((struct rt0_hdr *)opt->srcrt)->addr;
 		break;
 	case IPV6_SRCRT_TYPE_4:
-- 
2.12.2
