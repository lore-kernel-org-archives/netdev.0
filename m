From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] ipv6: don't use tw net when accounting for recycled tw
Date: Thu, 26 Feb 2009 14:31:55 +0300
Message-ID: <49A67DAB.9060203@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47259 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392AbZBZLcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 06:32:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already have a valid net in that place, but this is not just a
cleanup - the tw pointer can be NULL there sometimes, thus causing
an oops in NET_NS=y case.

The same place in ipv4 code already works correctly using existing 
net, rather than tw's one.

The bug exists since 2.6.27.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 8fe267f..1bcc343 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -258,11 +258,11 @@ unique:
 
 	if (twp != NULL) {
 		*twp = tw;
-		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 	} else if (tw != NULL) {
 		/* Silly. Should hash-dance instead... */
 		inet_twsk_deschedule(tw, death_row);
-		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 
 		inet_twsk_put(tw);
 	}
