From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 5/9] net: Move martian_destination to helper
Date: Tue, 22 Sep 2015 15:55:19 -0700
Message-ID: <1442962523-3974-6-git-send-email-dsa@cumulusnetworks.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36784 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934972AbbIVWzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 18:55:35 -0400
Received: by pacbt3 with SMTP id bt3so3398631pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 15:55:35 -0700 (PDT)
In-Reply-To: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move stat and logging for martian_destination error into helper function
similar to ip_handle_martian_source. Code move only; no functional change.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 79c4cecdb7a1..3ee37835e1f5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1531,6 +1531,20 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	return err;
 }
 
+/*
+ *	Do not cache martian addresses: they should be logged (RFC1812)
+ */
+static void ip_handle_martian_dest(struct net_device *dev,
+				   struct in_device *in_dev,
+				   __be32 daddr, __be32 saddr)
+{
+	RT_CACHE_STAT_INC(in_martian_dst);
+#ifdef CONFIG_IP_ROUTE_VERBOSE
+	if (IN_DEV_LOG_MARTIANS(in_dev))
+		net_warn_ratelimited("martian destination %pI4 from %pI4, dev %s\n",
+				     &daddr, &saddr, dev->name);
+#endif
+}
 
 static void ip_handle_martian_source(struct net_device *dev,
 				     struct in_device *in_dev,
@@ -1857,17 +1871,9 @@ out:	return err;
 	res.table = NULL;
 	goto local_input;
 
-	/*
-	 *	Do not cache martian addresses: they should be logged (RFC1812)
-	 */
 martian_destination:
 	err = -EINVAL;
-	RT_CACHE_STAT_INC(in_martian_dst);
-#ifdef CONFIG_IP_ROUTE_VERBOSE
-	if (IN_DEV_LOG_MARTIANS(in_dev))
-		net_warn_ratelimited("martian destination %pI4 from %pI4, dev %s\n",
-				     &daddr, &saddr, dev->name);
-#endif
+	ip_handle_martian_dest(dev, in_dev, daddr, saddr);
 	goto out;
 
 martian_source:
-- 
1.9.1
