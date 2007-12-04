From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] don't allow netfilter --setmss to increase mss
Date: Tue, 4 Dec 2007 17:45:35 -0500
Message-ID: <20071204224535.GY27007@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:37165 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbXLDWqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 17:46:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

When terminating DSL connections for an assortment of random customers, I've 
found it necessary to use iptables to clamp the MSS used for connections to 
work around the various ICMP blackholes in the greater net.  Unfortunately, 
the current behaviour in Linux is imperfect and actually make things worse, 
so I'm proposing the following: increasing the MSS in a packet can never be 
a good thing, so make --set-mss only lower the MSS in a packet.

Yes, I am aware of --clamp-mss-to-pmtu, but it doesn't work for outgoing 
connections from clients (ie web traffic), as it only looks at the PMTU on 
the destination route, not the source of the packet (the DSL interfaces in 
question have a 1442 byte MTU while the destination ethernet interface is 
1500 -- there are problematic hosts which use a 1300 byte MTU).  Reworking 
that is probably a good idea at some point, but it's more work than this is.

Thoughts?  Would it be better to add a new flag?

		-ben

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index d40f7e4..411c482 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -88,8 +88,11 @@ tcpmss_mangle_packet(struct sk_buff **pskb,
 
 			oldmss = (opt[i+2] << 8) | opt[i+3];
 
-			if (info->mss == XT_TCPMSS_CLAMP_PMTU &&
-			    oldmss <= newmss)
+			/* Never increase MSS, even when setting it, as
+			 * doing so results in problems for hosts that rely
+			 * on MSS being set correctly.
+			 */
+			if (oldmss <= newmss)
 				return 0;
 
 			opt[i+2] = (newmss & 0xff00) >> 8;
