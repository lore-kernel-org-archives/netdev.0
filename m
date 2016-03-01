From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] ipv6: re-enable fragment header matching in ipv6_find_hdr
Date: Tue,  1 Mar 2016 16:15:16 +0100
Message-ID: <1456845316-26269-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49238 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753593AbcCAPO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 10:14:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ipv6_find_hdr is used to find a fragment header
(caller specifies target NEXTHDR_FRAGMENT) we erronously return
-ENOENT for all fragments with nonzero offset.

Before commit 9195bb8e381d, when target was specified, we did not
enter the exthdr walk loop as nexthdr == target so this used to work.

Now we do (so we can skip empty route headers). When we then stumble upon
a frag with nonzero frag_off we must return -ENOENT ("header not found")
only if the caller did not specifically request NEXTHDR_FRAGMENT.

This allows nfables exthdr expression to match ipv6 fragments, e.g. via

nft add rule ip6 filter input frag frag-off gt 0

Fixes: 9195bb8e381d ("ipv6: improve ipv6_find_hdr() to skip empty routing headers")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/exthdrs_core.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 5c5d23e..9508a20 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -257,7 +257,11 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 						*fragoff = _frag_off;
 					return hp->nexthdr;
 				}
-				return -ENOENT;
+				if (!found)
+					return -ENOENT;
+				if (fragoff)
+					*fragoff = _frag_off;
+				break;
 			}
 			hdrlen = 8;
 		} else if (nexthdr == NEXTHDR_AUTH) {
-- 
2.4.10
