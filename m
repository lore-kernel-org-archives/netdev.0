From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next] ip6_tunnel: Fix missing tunnel encapsulation limit option
Date: Wed, 26 Apr 2017 13:07:07 -0400
Message-ID: <20170426170707.165201-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35882 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdDZRHK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 13:07:10 -0400
Received: by mail-qk0-f181.google.com with SMTP id u75so6338961qka.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 10:07:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

The IPv6 tunneling code tries to insert IPV6_TLV_TNL_ENCAP_LIMIT and
IPV6_TLV_PADN options when an encapsulation limit is defined (the
default is a limit of 4).  An MTU adjustment is done to account for
these options as well.  However, the options are never present in the
generated packets.

ipv6_push_nfrag_opts requires that IPV6_RTHDR be present in order to
include any IPV6_DSTOPTS options.  The v6 tunnel code does not
use routing options, so the encap limit options are not included.

A brief reading of RFC 3542 section 9.2 (specifically the 4th paragraph)
makes me believe that this requirement in the kernel is incorrect.

Fixes: 333fad5364d6: ("[IPV6]: Support several new sockopt / ancillary data in Advanced API (RFC3542)")
Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/ipv6/exthdrs.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 25192a3b0cd7..224a89e68a42 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -932,15 +932,12 @@ void ipv6_push_nfrag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
 			  u8 *proto,
 			  struct in6_addr **daddr, struct in6_addr *saddr)
 {
-	if (opt->srcrt) {
+	if (opt->srcrt)
 		ipv6_push_rthdr(skb, proto, opt->srcrt, daddr, saddr);
-		/*
-		 * IPV6_RTHDRDSTOPTS is ignored
-		 * unless IPV6_RTHDR is set (RFC3542).
-		 */
-		if (opt->dst0opt)
-			ipv6_push_exthdr(skb, proto, NEXTHDR_DEST, opt->dst0opt);
-	}
+
+	if (opt->dst0opt)
+		ipv6_push_exthdr(skb, proto, NEXTHDR_DEST, opt->dst0opt);
+
 	if (opt->hopopt)
 		ipv6_push_exthdr(skb, proto, NEXTHDR_HOP, opt->hopopt);
 }
-- 
2.13.0.rc0.306.g87b477812d-goog
