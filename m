From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [BUG][AX25] Fwd: SMP with AX.25
Date: Wed, 6 Feb 2008 09:30:50 +0000
Message-ID: <20080206093050.GF4496@ff.dom.local>
References: <20080206074529.GC4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
To: Jann Traschewski <jann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:16188 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759706AbYBFJXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:23:46 -0500
Received: by ug-out-1314.google.com with SMTP id z38so365708ugc.16
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2008 01:23:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080206074529.GC4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 07:45:29AM +0000, Jarek Poplawski wrote:
...
> From: Jann Traschewski <jann@gmx.de>
> Subject: SMP with AX.25
> To: jarkao2@gmail.com

According to one of OOPSes reported by Jann softirq can break
while skb is prepared for netif_rx. The report isn't complete,
so the real reason of the later bug could be different, but
IMHO this locking in ax_bump is wrong.

I attach this patch for testing purpose only.

Jarek P.

---

 drivers/net/hamradio/mkiss.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index cfcd15a..30c9b3b 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -289,7 +289,6 @@ static void ax_bump(struct mkiss *ax)
 			*ax->rbuff &= ~0x20;
 		}
  	}
-	spin_unlock_bh(&ax->buflock);
 
 	count = ax->rcount;
 
@@ -297,17 +296,17 @@ static void ax_bump(struct mkiss *ax)
 		printk(KERN_ERR "mkiss: %s: memory squeeze, dropping packet.\n",
 		       ax->dev->name);
 		ax->stats.rx_dropped++;
+		spin_unlock_bh(&ax->buflock);
 		return;
 	}
 
-	spin_lock_bh(&ax->buflock);
 	memcpy(skb_put(skb,count), ax->rbuff, count);
-	spin_unlock_bh(&ax->buflock);
 	skb->protocol = ax25_type_trans(skb, ax->dev);
 	netif_rx(skb);
 	ax->dev->last_rx = jiffies;
 	ax->stats.rx_packets++;
 	ax->stats.rx_bytes += count;
+	spin_unlock_bh(&ax->buflock);
 }
 
 static void kiss_unesc(struct mkiss *ax, unsigned char s)
