From: Florian Westphal <fw@strlen.de>
Subject: Re: 2.6.29.1 pktgen crash
Date: Thu, 21 May 2009 23:59:15 +0200
Message-ID: <20090521215915.GA32737@Chamillionaire.breakpoint.cc>
References: <20090520202450.GA12896@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:53876 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753083AbZEUV7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 17:59:15 -0400
Content-Disposition: inline
In-Reply-To: <20090520202450.GA12896@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladimir Ivashchenko <hazard@francoudi.com> wrote:
> The attached script leads to a crash when you run it for 2-3 times on 2.6.29.1. The server still remains reachable, but starts misbehaving.
>
> May 20 21:09:03 tshape-phome2 kernel: BUG: unable to handle kernel paging request at f8bbc008
> May 20 21:09:03 tshape-phome2 kernel: IP: [<f863ab01>] pktgen_remove_device+0x88/0xdc [pktgen]
> May 20 21:09:03 tshape-phome2 kernel: *pde = 31030067 *pte = 00000000 
> May 20 21:09:03 tshape-phome2 kernel: Oops: 0000 [#1] SMP 
[..]

This should fix it:

>From bca277bb59b865a4e9516953dfc9818af1a7deea Mon Sep 17 00:00:00 2001
From: Florian Westphal <fw@strlen.de>
Date: Thu, 21 May 2009 23:52:17 +0200
Subject: [PATCH] pktgen: do not access flows[] beyond its length

typo -- pkt_dev->nflows is for stats only, the number of concurrent
flows is stored in cflows.

Reported-By: Vladimir Ivashchenko <hazard@francoudi.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 3779c14..8445075 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2447,7 +2447,7 @@ static inline void free_SAs(struct pktgen_dev *pkt_dev)
 	if (pkt_dev->cflows) {
 		/* let go of the SAs if we have them */
 		int i = 0;
-		for (;  i < pkt_dev->nflows; i++){
+		for (;  i < pkt_dev->cflows; i++) {
 			struct xfrm_state *x = pkt_dev->flows[i].x;
 			if (x) {
 				xfrm_state_put(x);
-- 
1.6.0.6

