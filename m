From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Thu, 11 Mar 2010 11:47:28 -0800
Message-ID: <1268336848.9775.154.camel@nseg_linux_HP1.broadcom.com>
References: <1268263973.9775.95.camel@nseg_linux_HP1.broadcom.com>
 <4B9850DC.9060703@hp.com>
 <1268329796.9775.125.camel@nseg_linux_HP1.broadcom.com>
 <20100311.100519.124285161.davem@davemloft.net>
 <1268332738.9775.133.camel@nseg_linux_HP1.broadcom.com>
 <4B994714.2040108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"bonbons@linux-vserver.org" <bonbons@linux-vserver.org>,
	"Benjamin Li" <benli@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B994714.2040108@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2010-03-11 at 11:40 -0800, Brian Haley wrote:
> I can only reproduce this on one system out of many, so it's either a
> race condition or bad hardware.  The only thing I can confirm at the
> moment is that it's the code at the bottom of bnx2_set_coalesce()
> that's causing it, I'm trying to go through all those codepaths now.
> 

The NETDEV WATCHDOG is caused by stopping the TX queues with
->trans_start older than dev->watchdog_timeo which is set to 5 seconds
in bnx2.  Please try this patch below to update the ->trans_start first
before stopping the TX queues:

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d3f739a..c0f4aa7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -656,7 +656,6 @@ bnx2_netif_stop(struct bnx2 *bp)
 		int i;
 
 		bnx2_napi_disable(bp);
-		netif_tx_disable(bp->dev);
 		/* prevent tx timeout */
 		for (i = 0; i <  bp->dev->num_tx_queues; i++) {
 			struct netdev_queue *txq;
@@ -664,6 +663,7 @@ bnx2_netif_stop(struct bnx2 *bp)
 			txq = netdev_get_tx_queue(bp->dev, i);
 			txq->trans_start = jiffies;
 		}
+		netif_tx_disable(bp->dev);
 	}
 	bnx2_disable_int_sync(bp);
 }
