From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][AX25] mkiss: ax_bump() locking fix
Date: Wed, 13 Feb 2008 11:17:58 +0000
Message-ID: <20080213111758.GA2867@ff.dom.local>
References: <20080206074529.GC4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jann Traschewski <jann@gmx.de>, Ralf Baechle <ralf@linux-mips.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:33588 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbYBMLKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 06:10:48 -0500
Received: by ug-out-1314.google.com with SMTP id z38so713031ugc.16
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 03:10:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080206074529.GC4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is unchanged patch previously sent here for testing.
I think it should be applied.

Thanks,
Jarek P.

---------------->

Subject: [PATCH][AX25] mkiss: ax_bump() locking fix

According to one of OOPSes reported by Jann softirq can break
while skb is prepared for netif_rx. The report isn't complete,
so the real reason of the later bug could be different, but
IMHO this locking break in ax_bump is unsafe and unnecessary.

Reported-and-tested-by: Jann Traschewski <jann@gmx.de>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

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
