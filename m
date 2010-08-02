From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] u32: negative offset fix
Date: Mon, 2 Aug 2010 16:44:13 -0700
Message-ID: <20100802164413.6f327ce6@nehalam>
References: <20100802220030.991706005@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43935 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836Ab0HBXoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 19:44:16 -0400
In-Reply-To: <20100802220030.991706005@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was possible to use a negative offset in a u32 match to reference
the ethernet header or other parts of the link layer header.
This fixes the regression caused by:

commit fbc2e7d9cf49e0bf89b9e91fd60a06851a855c5d
Author: Changli Gao <xiaosuo@gmail.com>
Date:   Wed Jun 2 07:32:42 2010 -0700

    cls_u32: use skb_header_pointer() to dereference data safely


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 Combines change to signed type and check in one patch.


--- a/net/sched/cls_u32.c	2010-08-02 15:02:36.778304996 -0700
+++ b/net/sched/cls_u32.c	2010-08-02 16:25:40.661661091 -0700
@@ -134,10 +134,12 @@ next_knode:
 #endif
 
 		for (i = n->sel.nkeys; i>0; i--, key++) {
-			unsigned int toff;
+			int toff = off + key->off + (off2 & key->offmask);
 			__be32 *data, _data;
+
+			if (skb_headroom(skb) + toff < 0)
+				goto out;
 
-			toff = off + key->off + (off2 & key->offmask);
 			data = skb_header_pointer(skb, toff, 4, &_data);
 			if (!data)
 				goto out;
