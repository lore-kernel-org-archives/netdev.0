From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH] IPv6: fix CoA check in RH2 input handler (mip6_rthdr_input())
Date: Fri, 16 Jul 2010 12:38:44 +0200
Message-ID: <87aapr7lu3.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:56805 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964971Ab0GPKig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 06:38:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The input handler for Type 2 Routing Header (mip6_rthdr_input())
checks if the CoA in the packet matches the CoA in the XFRM state.

Current check is buggy: it compares the adddress in the Type 2
Routing Header, i.e. the HoA, against the expected CoA in the state.
The comparison should be made against the address in the destination
field of the IPv6 header.

The bug remained unnoticed because the main (and possibly only current)
user of the code (UMIP MIPv6 Daemon) initializes the XFRM state with the
unspecified address, i.e. explicitly allows everything.

Yoshifuji-san, can you ack that one?

Cheers,

a+

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 net/ipv6/mip6.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 2794b60..d6e9599 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -347,11 +347,12 @@ static const struct xfrm_type mip6_destopt_type =
 
 static int mip6_rthdr_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct rt2_hdr *rt2 = (struct rt2_hdr *)skb->data;
 	int err = rt2->rt_hdr.nexthdr;
 
 	spin_lock(&x->lock);
-	if (!ipv6_addr_equal(&rt2->addr, (struct in6_addr *)x->coaddr) &&
+	if (!ipv6_addr_equal(&iph->daddr, (struct in6_addr *)x->coaddr) &&
 	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
 		err = -ENOENT;
 	spin_unlock(&x->lock);
-- 
1.7.1

