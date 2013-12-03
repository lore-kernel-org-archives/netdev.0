From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 03 Dec 2013 15:59:59 -0800
Message-ID: <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	 <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	 <20131203.165034.1085515763685633822.davem@davemloft.net>
	 <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:54176 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab3LDAAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 19:00:03 -0500
Received: by mail-yh0-f54.google.com with SMTP id z12so10924333yhz.27
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 16:00:02 -0800 (PST)
In-Reply-To: <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-04 at 01:10 +0200, Or Gerlitz wrote:

> Samples: 883K of event 'skb:kfree_skb', Event count (approx.): 883406
> +  97.13%          swapper  [kernel.kallsyms]  [k] net_tx_action
> +   1.53%            iperf  [kernel.kallsyms]  [k] net_tx_action
> +   1.03%             perf  [kernel.kallsyms]  [k] net_tx_action
> +   0.27%      ksoftirqd/7  [kernel.kallsyms]  [k] net_tx_action
> +   0.03%      kworker/7:1  [kernel.kallsyms]  [k] net_tx_action
> +   0.00%          rpcbind  [kernel.kallsyms]  [k] net_tx_action
> +   0.00%          swapper  [kernel.kallsyms]  [k] kfree_skb
> +   0.00%            sleep  [kernel.kallsyms]  [k] net_tx_action
> +   0.00%  hald-addon-acpi  [kernel.kallsyms]  [k] kfree_skb
> +   0.00%            iperf  [kernel.kallsyms]  [k] kfree_skb
> +   0.00%             perf  [kernel.kallsyms]  [k] kfree_skb
> 

Right, I actually have a patch for that, but was waiting for net-next
being re-opened :

commit 9a731d750dd8bf0b8c20fb1ca53c42317fb4dd37
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Nov 25 13:09:20 2013 -0800

    net-fixes: introduce dev_consume_skb_any()
    
    Some NIC drivers use dev_kfree_skb_any() generic helper to free skbs,
    both for dropped packets and TX completed ones.
    
    To have "perf record -e skb:kfree_skb" give good hints on where
    packets are dropped (if any), we need to separate the two causes.
    
    dev_consume_skb_any() is a helper to free skbs that were properly sent
    to the wire.
    

Signed-off-by: Eric Dumazet <edumazet@google.com>
Google-Bug-Id: 11634401
---
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ec96130533cc..8b8c2171b187 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -209,9 +209,9 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata,
 	if (likely(skb)) {
 		(*pkts_compl)++;
 		(*bytes_compl) += skb->len;
+		dev_consume_skb_any(skb);
 	}
 
-	dev_kfree_skb_any(skb);
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 8d3945ab7334..03081932e519 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1058,7 +1058,7 @@ static void e1000_put_txbuf(struct e1000_ring *tx_ring,
 		buffer_info->dma = 0;
 	}
 	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
+		dev_consume_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
 	buffer_info->time_stamp = 0;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 43aa7acd84a6..294825efb248 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2037,7 +2037,7 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 			bytes_compl += skb->len;
 
 			re->skb = NULL;
-			dev_kfree_skb_any(skb);
+			dev_consume_skb_any(skb);
 
 			sky2->tx_next = RING_NEXT(idx, sky2->tx_ring_size);
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index f54ebd5a1702..653484bfae98 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -317,7 +317,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			}
 		}
 	}
-	dev_kfree_skb_any(skb);
+	dev_consume_skb_any(skb);
 	return tx_info->nr_txbb;
 }
 
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 2d045be4b5cf..d44f7b69a6a0 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2557,7 +2557,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 					u64_stats_update_end(&np->swstats_tx_syncp);
 				}
 				bytes_compl += np->get_tx_ctx->skb->len;
-				dev_kfree_skb_any(np->get_tx_ctx->skb);
+				dev_consume_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
 				tx_work++;
 			}
@@ -2574,7 +2574,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 					u64_stats_update_end(&np->swstats_tx_syncp);
 				}
 				bytes_compl += np->get_tx_ctx->skb->len;
-				dev_kfree_skb_any(np->get_tx_ctx->skb);
+				dev_consume_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
 				tx_work++;
 			}
@@ -2625,7 +2625,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 			}
 
 			bytes_cleaned += np->get_tx_ctx->skb->len;
-			dev_kfree_skb_any(np->get_tx_ctx->skb);
+			dev_consume_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
 			tx_work++;
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 916241d16c67..ab8970693ff3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -755,7 +755,7 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 		stats->tx_packets++;
 		u64_stats_update_end(&stats->tx_syncp);
 
-		dev_kfree_skb_any(skb);
+		dev_consume_skb_any(skb);
 	}
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7f0ed423a360..8a7482fa2656 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2380,6 +2380,13 @@ void dev_kfree_skb_irq(struct sk_buff *skb);
  */
 void dev_kfree_skb_any(struct sk_buff *skb);
 
+#define SKB_CONSUMED_MAGIC ((void *)0xDEAD0001)
+static inline void dev_consume_skb_any(struct sk_buff *skb)
+{
+	skb->dev = SKB_CONSUMED_MAGIC;
+	dev_kfree_skb_any(skb);
+}
+
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
 int netif_receive_skb(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index ba3b7ea5ebb3..b2b0e5776ce9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3306,7 +3306,10 @@ static void net_tx_action(struct softirq_action *h)
 			clist = clist->next;
 
 			WARN_ON(atomic_read(&skb->users));
-			trace_kfree_skb(skb, net_tx_action);
+			if (likely(skb->dev == SKB_CONSUMED_MAGIC))
+				trace_consume_skb(skb);
+			else
+				trace_kfree_skb(skb, net_tx_action);
 			__kfree_skb(skb);
 		}
 	}
