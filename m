From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH RT 2/2] net/core: skbuf use local lock in __netdev_alloc_skb()
Date: Fri, 15 Jan 2016 17:20:15 +0100
Message-ID: <20160115162015.GB3781@linutronix.de>
References: <20160115161841.GA3781@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: linux-rt-users@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160115161841.GA3781@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

local_irq_save() was introduced in v4.2-rc1 via 9451980a6646
("net: Use cached copy of pfmemalloc to avoid accessing page").
This is only v4.1-RT..v4.4-RT fallout.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/core/skbuff.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7c422e441f1c..53f10c2d7718 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -434,13 +434,13 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
 	if (sk_memalloc_socks())
 		gfp_mask |= __GFP_MEMALLOC;
 
-	local_irq_save(flags);
+	local_lock_irqsave(netdev_alloc_lock, flags);
 
 	nc = this_cpu_ptr(&netdev_alloc_cache);
 	data = __alloc_page_frag(nc, len, gfp_mask);
 	pfmemalloc = nc->pfmemalloc;
 
-	local_irq_restore(flags);
+	local_unlock_irqrestore(netdev_alloc_lock, flags);
 
 	if (unlikely(!data))
 		return NULL;
-- 
2.7.0.rc3
