From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] niu: Cleanup PAGE_SIZE checks a bit
Date: Sat, 20 Oct 2007 14:06:49 -0500
Message-ID: <20071020190649.GA30034@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49822 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758154AbXJTTAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2007 15:00:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I get the following warning from a powerpc allyesconfig of current
mainline:

drivers/net/niu.c: In function 'niu_size_rbr':
drivers/net/niu.c:3113: warning: large integer implicitly truncated to unsigned type

PAGE_SIZE in this case is 64KB, so I don't quite get why gcc can't tell
that the line in question will never be reached.

I suggest the following instead, but I can unfortunately not do anything but
build test it.

Also, the driver does some other checks to make sure that PAGE_SIZE is a
power of two (BUILD_BUG_ON() in niu_init()), doesn't seem like that could
ever be untrue? Or are there really archs with non-power-of-two PAGE_SIZE?


Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index ed1f9bb..795cc68 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3103,31 +3103,12 @@ static int niu_alloc_tx_ring_info(struct niu *np,
 
 static void niu_size_rbr(struct niu *np, struct rx_ring_info *rp)
 {
-	u16 bs;
+	u16 bss;
 
-	switch (PAGE_SIZE) {
-	case 4 * 1024:
-	case 8 * 1024:
-	case 16 * 1024:
-	case 32 * 1024:
-		rp->rbr_block_size = PAGE_SIZE;
-		rp->rbr_blocks_per_page = 1;
-		break;
+	bss = max(PAGE_SHIFT, 15);
 
-	default:
-		if (PAGE_SIZE % (32 * 1024) == 0)
-			bs = 32 * 1024;
-		else if (PAGE_SIZE % (16 * 1024) == 0)
-			bs = 16 * 1024;
-		else if (PAGE_SIZE % (8 * 1024) == 0)
-			bs = 8 * 1024;
-		else if (PAGE_SIZE % (4 * 1024) == 0)
-			bs = 4 * 1024;
-		else
-			BUG();
-		rp->rbr_block_size = bs;
-		rp->rbr_blocks_per_page = PAGE_SIZE / bs;
-	}
+	rp->rbr_block_size = 1 << bss;
+	rp->rbr_blocks_per_page = 1 << (PAGE_SHIFT-bss);
 
 	rp->rbr_sizes[0] = 256;
 	rp->rbr_sizes[1] = 1024;
@@ -7902,12 +7883,7 @@ static int __init niu_init(void)
 {
 	int err = 0;
 
-	BUILD_BUG_ON((PAGE_SIZE < 4 * 1024) ||
-		     ((PAGE_SIZE > 32 * 1024) &&
-		      ((PAGE_SIZE % (32 * 1024)) != 0 &&
-		       (PAGE_SIZE % (16 * 1024)) != 0 &&
-		       (PAGE_SIZE % (8 * 1024)) != 0 &&
-		       (PAGE_SIZE % (4 * 1024)) != 0)));
+	BUILD_BUG_ON(PAGE_SIZE < 4 * 1024);
 
 	niu_debug = netif_msg_init(debug, NIU_MSG_DEFAULT);
 
