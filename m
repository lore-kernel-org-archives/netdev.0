From: Florian Westphal <fw@strlen.de>
Subject: Re: next-20151207 - crash in IPv6 code
Date: Tue, 8 Dec 2015 12:34:09 +0100
Message-ID: <20151208113409.GA31055@breakpoint.cc>
References: <3884.1449551563@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pablo@netfilter.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40571 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbbLHLeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 06:34:15 -0500
Content-Disposition: inline
In-Reply-To: <3884.1449551563@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valdis Kletnieks <Valdis.Kletnieks@vt.edu> wrote:

[ CC Pablo ]

> Seen this in 2 boots out of two on next-20151207 when IPV6 networking
> was available.  It was stable when no net was available. Also, next-20161127 is OK.
> Haven't bisected it yet - this ring any bells?

Thanks for the report, my fault -- its caused by
029f7f3b8701cc7aca8bdb which is only in Pablos nf-next tree.

This should fix this bug (proper patch w. changelog coming
after more testing):

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -441,11 +441,14 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_devic
 			return false;
 
 		fp->next = prev->next;
-		skb_queue_walk(head, iter) {
-			if (iter->next != prev)
-				continue;
-			iter->next = fp;
-			break;
+
+		iter = head;
+		while (iter) {
+			if (iter->next == prev) {
+				iter->next = fp;
+				break;
+			}
+			iter = iter->next;
 		}
 
 		skb_morph(prev, head);
