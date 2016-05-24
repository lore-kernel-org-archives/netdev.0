From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net 2/2] net: hwbm: Fix unbalanced spinlock in error case
Date: Tue, 24 May 2016 18:03:26 +0200
Message-ID: <1464105806-439-3-git-send-email-gregory.clement@free-electrons.com>
References: <1464105806-439-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jean-Jacques Hiblot <jjhiblot@traphandler.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	<stable@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:41794 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752768AbcEXQEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 12:04:07 -0400
In-Reply-To: <1464105806-439-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When hwbm_pool_add exited in error the spinlock was not released. This
patch fixes this issue.

Fixes: 8cb2d8bf57e6 ("net: add a hardware buffer management helper API")
Reported-by: Jean-Jacques Hiblot <jjhiblot@traphandler.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 net/core/hwbm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/hwbm.c b/net/core/hwbm.c
index 941c28486896..2cab489ae62e 100644
--- a/net/core/hwbm.c
+++ b/net/core/hwbm.c
@@ -55,18 +55,21 @@ int hwbm_pool_add(struct hwbm_pool *bm_pool, unsigned int buf_num, gfp_t gfp)
 	spin_lock_irqsave(&bm_pool->lock, flags);
 	if (bm_pool->buf_num == bm_pool->size) {
 		pr_warn("pool already filled\n");
+		spin_unlock_irqrestore(&bm_pool->lock, flags);
 		return bm_pool->buf_num;
 	}
 
 	if (buf_num + bm_pool->buf_num > bm_pool->size) {
 		pr_warn("cannot allocate %d buffers for pool\n",
 			buf_num);
+		spin_unlock_irqrestore(&bm_pool->lock, flags);
 		return 0;
 	}
 
 	if ((buf_num + bm_pool->buf_num) < bm_pool->buf_num) {
 		pr_warn("Adding %d buffers to the %d current buffers will overflow\n",
 			buf_num,  bm_pool->buf_num);
+		spin_unlock_irqrestore(&bm_pool->lock, flags);
 		return 0;
 	}
 
-- 
2.5.0
