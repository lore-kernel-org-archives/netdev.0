From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/9] net: Remove e_inval label from ip_route_input_slow
Date: Tue, 22 Sep 2015 15:55:16 -0700
Message-ID: <1442962523-3974-3-git-send-email-dsa@cumulusnetworks.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33046 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934878AbbIVWzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 18:55:31 -0400
Received: by pacex6 with SMTP id ex6so21715028pac.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 15:55:31 -0700 (PDT)
In-Reply-To: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e_inval has 1 explicit user and 1 fallthrough user -- martian_destination.
Move setting err to EINVAL before the 2 users and use the goto out label
instead of e_inval.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ef36dfed24da..3c5000db5972 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1775,8 +1775,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 out:	return err;
 
 brd_input:
+	err = -EINVAL;
 	if (skb->protocol != htons(ETH_P_IP))
-		goto e_inval;
+		goto out;
 
 	if (!ipv4_is_zeronet(saddr)) {
 		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
@@ -1842,15 +1843,13 @@ out:	return err;
 	 *	Do not cache martian addresses: they should be logged (RFC1812)
 	 */
 martian_destination:
+	err = -EINVAL;
 	RT_CACHE_STAT_INC(in_martian_dst);
 #ifdef CONFIG_IP_ROUTE_VERBOSE
 	if (IN_DEV_LOG_MARTIANS(in_dev))
 		net_warn_ratelimited("martian destination %pI4 from %pI4, dev %s\n",
 				     &daddr, &saddr, dev->name);
 #endif
-
-e_inval:
-	err = -EINVAL;
 	goto out;
 
 e_nobufs:
-- 
1.9.1
