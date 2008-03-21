From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH] Fix null dereference in ip_defrag
Date: Fri, 21 Mar 2008 12:09:30 -0700
Message-ID: <20080321190930.GA12940@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZPt4rx8FFjLCG7dd"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:34638
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750844AbYCUTJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 15:09:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Been seeing occasional panics in my testing of 2.6.25-rc in ip_defrag.
Offending line in ip_defrag is here:

	net = skb->dev->nd_net

where dev is NULL.  Bisected the problem down to commit
ac18e7509e7df327e30d6e073a787d922eaf211d ([NETNS][FRAGS]: Make the
inet_frag_queue lookup work in namespaces).  

Below patch (idea from Patrick McHardy) fixes the problem for me.

Signed-off-by: Phil Oester <kernel@linuxace.com>
Acked-by: Patrick McHardy <kaber@trash.net>

Phil



--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-ipfrags

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a2e92f9..3b2e5ad 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -568,7 +568,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMREQDS);
 
-	net = skb->dev->nd_net;
+	net = skb->dev ? skb->dev->nd_net : skb->dst->dev->nd_net;
 	/* Start by cleaning up the memory. */
 	if (atomic_read(&net->ipv4.frags.mem) > net->ipv4.frags.high_thresh)
 		ip_evictor(net);

--ZPt4rx8FFjLCG7dd--
