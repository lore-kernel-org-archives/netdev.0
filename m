From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/1] myri10ge: correctly detect when TSO should be used
Date: Tue, 27 Mar 2007 21:54:53 +0200
Message-ID: <4609768D.8020309@myri.com>
References: <46097617.8050407@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:2026 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965084AbXC0T41 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 15:56:27 -0400
In-Reply-To: <46097617.8050407@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correctly detect when TSO should be used on transmit by looking at the
skb->gso_size rather than seeing if the frame was larger than our MTU.
The old method causes problems when a host with a large (jumbo) MTU is
sending to a host with a small (standard) MTU.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-26 01:34:08.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-27 21:44:27.000000000 +0200
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.0-1.226"
+#define MYRI10GE_VERSION_STR "1.3.0-1.227"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -2015,10 +2015,9 @@
 	mss = 0;
 	max_segments = MXGEFW_MAX_SEND_DESC;
 
-	if (skb->len > (dev->mtu + ETH_HLEN)) {
+	if (skb_is_gso(skb)) {
 		mss = skb_shinfo(skb)->gso_size;
-		if (mss != 0)
-			max_segments = MYRI10GE_MAX_SEND_DESC_TSO;
+		max_segments = MYRI10GE_MAX_SEND_DESC_TSO;
 	}
 
 	if ((unlikely(avail < max_segments))) {


