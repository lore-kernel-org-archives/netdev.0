From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net/ipv4: Ensure that location of timestamp option is stored
Date: Mon, 11 Mar 2013 16:43:39 -0400
Message-ID: <1363034619-5887-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX1.LL.MIT.EDU ([129.55.12.45]:51953 "EHLO mx1.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753690Ab3CKVEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 17:04:23 -0400
Received: from LLE2K7-HUB01.mitll.ad.local (LLE2K7-HUB01.mitll.ad.local) by mx1.ll.mit.edu (unknown) with ESMTP id r2BKgG7o005630 for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 16:44:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed in order to detect if the timestamp option appears
more than once in a packet, to remove the option if the packet is
fragmented, etc. My previous change neglected to store the option
location when the router addresses were prespecified and Pointer >
Length. But now the option location is also stored when Flag is an
unrecognized value, to ensure these option handling behaviors are
still performed.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/ipv4/ip_options.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 310a364..ec72645 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -370,7 +370,6 @@ int ip_options_compile(struct net *net,
 				}
 				switch (optptr[3]&0xF) {
 				      case IPOPT_TS_TSONLY:
-					opt->ts = optptr - iph;
 					if (skb)
 						timeptr = &optptr[optptr[2]-1];
 					opt->ts_needtime = 1;
@@ -381,7 +380,6 @@ int ip_options_compile(struct net *net,
 						pp_ptr = optptr + 2;
 						goto error;
 					}
-					opt->ts = optptr - iph;
 					if (rt)  {
 						spec_dst_fill(&spec_dst, skb);
 						memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
@@ -396,7 +394,6 @@ int ip_options_compile(struct net *net,
 						pp_ptr = optptr + 2;
 						goto error;
 					}
-					opt->ts = optptr - iph;
 					{
 						__be32 addr;
 						memcpy(&addr, &optptr[optptr[2]-1], 4);
@@ -429,12 +426,12 @@ int ip_options_compile(struct net *net,
 					pp_ptr = optptr + 3;
 					goto error;
 				}
-				opt->ts = optptr - iph;
 				if (skb) {
 					optptr[3] = (optptr[3]&0xF)|((overflow+1)<<4);
 					opt->is_changed = 1;
 				}
 			}
+			opt->ts = optptr - iph;
 			break;
 		      case IPOPT_RA:
 			if (optlen < 4) {
-- 
1.7.1
