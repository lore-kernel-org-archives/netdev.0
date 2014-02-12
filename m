From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] ipv4: arp: process only if ipv4 address configured
Date: Wed, 12 Feb 2014 18:27:47 +0100
Message-ID: <1392226067-21736-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39704 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753430AbaBLRbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 12:31:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

8030f54499925d073a88c09f ([IPV4] devinet: Register inetdev earlier.)
changed arp behaviour (2.6.22 onwards).

Before this, inetdev_init() was called only when the first address was
added to the interface, i.e. arp_process always dropped incoming arp
packets as __in_dev_get_rcu() returned NULL when no IP address was set
on the interface.

With >= 2.6.22 we now process arp packets even if no address is assigned.
It can cause issues if the machine has several interfaces in the same
segment; requests receive answers from multiple macs.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
IMO such configurations are just asking for trouble, but it used
to work on older kernels.  Do we care about such setups?

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1a9b99e..8a44ed2 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -738,7 +738,7 @@ static int arp_process(struct sk_buff *skb)
 	 * is ARP'able.
 	 */
 
-	if (in_dev == NULL)
+	if (in_dev == NULL || in_dev->ifa_list == NULL)
 		goto out;
 
 	arp = arp_hdr(skb);
-- 
1.8.1.5
