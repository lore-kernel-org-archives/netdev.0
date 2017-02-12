From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 2/2] net: Replace custom page based bitmap with IDA
Date: Sun, 12 Feb 2017 13:57:34 +1100
Message-ID: <1486868254-5386-3-git-send-email-me@tobin.cc>
References: <1486868254-5386-1-git-send-email-me@tobin.cc>
Cc: mawilcox@microsoft.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Tobin C. Harding" <me@tobin.cc>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:37679 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751290AbdBLC57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 21:57:59 -0500
In-Reply-To: <1486868254-5386-1-git-send-email-me@tobin.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current implementation of __dev_alloc_name uses a custom bitmap of
a single page to iterate network device id's and allocate an unused id.
This leads to a upper limit of 8 * PAGE_SIZE network device id's (for
each name format i.e eth0).

This patch uses the kernel's IDA as a replacement to the page based
bitmap. This has the effect of simplifying the code and removing
the upper limit.

Signed-off-by: Tobin C. Harding <me@tobin.cc>
---
 net/core/dev.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 29101c9..b16ea84 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1025,39 +1025,31 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 {
 	int i = 0;
 	const char *p;
-	const int max_netdevices = 8*PAGE_SIZE;
-	unsigned long *inuse;
 	struct net_device *d;
+	DEFINE_IDA(ida);
+	const int end = 0;
 
 	p = strnchr(name, IFNAMSIZ-1, '%');
 	if (p) {
-		/*
-		 * Verify the string as this thing may have come from
+		/* Verify the string as this thing may have come from
 		 * the user.  There must be either one "%d" and no other "%"
 		 * characters.
 		 */
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
 
-		/* Use one page as a bit array of possible slots */
-		inuse = (unsigned long *) get_zeroed_page(GFP_ATOMIC);
-		if (!inuse)
-			return -ENOMEM;
-
 		for_each_netdev(net, d) {
 			if (!sscanf(d->name, name, &i))
 				continue;
-			if (i < 0 || i >= max_netdevices)
+			if (i < 0)
 				continue;
 
 			/*  avoid cases where sscanf is not exact inverse of printf */
 			snprintf(buf, IFNAMSIZ, name, i);
 			if (!strncmp(buf, d->name, IFNAMSIZ))
-				set_bit(i, inuse);
+				ida_simple_get(&ida, i, end, GFP_KERNEL);
 		}
-
-		i = find_first_zero_bit(inuse, max_netdevices);
-		free_page((unsigned long) inuse);
+		i = ida_simple_get(&ida, 0, end, GFP_KERNEL);
 	}
 
 	if (buf != name)
-- 
2.7.4
