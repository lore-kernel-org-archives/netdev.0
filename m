From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 03 Dec 2013 17:23:36 -0800
Message-ID: <1386120216.30495.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	 <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	 <20131203.165034.1085515763685633822.davem@davemloft.net>
	 <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	 <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuzEM957fRjsb5aSG7xHWKp13fy59QxWpsU_=d+-6ydazg@mail.gmail.com>
	 <1386117362.30495.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuy8HA1nOQJTnxy+p7vNFV25zxMAmz1fh2spj0k4hYgh4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:47179 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881Ab3LDBXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 20:23:39 -0500
Received: by mail-yh0-f47.google.com with SMTP id 29so10720498yhl.20
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 17:23:39 -0800 (PST)
In-Reply-To: <CAMEtUuy8HA1nOQJTnxy+p7vNFV25zxMAmz1fh2spj0k4hYgh4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-03 at 16:55 -0800, Alexei Starovoitov wrote:
> On Tue, Dec 3, 2013 at 4:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2013-12-03 at 16:26 -0800, Alexei Starovoitov wrote:
> >
> >>
> >> Could you use some other way to mark skb ?
> >
> > I could ;)
> >
> >> In tracing we might want to examine skb more carefully and not being
> >> able to see the device
> >> will limit the usability of this tracepoint.
> >
> > Unfortunately, using skb->dev as a pointer to device would be buggy or
> > expensive (you would need to take a reference on device in order not
> > letting it disappear, as we escape RCU protection)
> 
> well, yes, you might have an skb around when device is already freed
> when skb_dst_noref.
> but I'm not suggesting anything expensive. Tracing definitely should
> not add overhead by doing rcu_lock() or dev_hold(). Instead it can go
> through skb, skb->dev, skb->dev->xxx via probe_kernel_read(). If dev
> is gone, it's still safe.

Its certainly not safe to 'probe'.

Its not about faulting inexistent memory, that is the least of the
problem.

Any kind of information fetched from skb->dev might have been
overwritten.

You could for example fetch security sensitive data and expose it.


> 
> > Anyway, this magic is pretty easy to change, I am open to suggestions.
> 
> you're the expert :) use skb->mark field, since it's unused during
> freeing path... ?

cache line miss ;)

skb->dev is in the first cache line, where we access skb->next anyway.

I could use skb->cb[] like the following patch :

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
index 7f0ed423a360..8b80a58ec1ac 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2374,11 +2374,38 @@ int netif_get_num_default_rss_queues(void);
  */
 void dev_kfree_skb_irq(struct sk_buff *skb);
 
+void __dev_kfree_skb_any(struct sk_buff *skb);
+
+struct __dev_kfree_skb_cb {
+	unsigned int reason;
+};
+
+static inline struct __dev_kfree_skb_cb *get_kfree_skb_cb(const struct sk_buff *skb)
+{
+	return (struct __dev_kfree_skb_cb *)skb->cb;
+}
+
+enum {
+	SKB_REASON_CONSUMED,
+	SKB_REASON_DROPPED,
+};
+
 /* Use this variant in places where it could be invoked
  * from either hardware interrupt or other context, with hardware interrupts
  * either disabled or enabled.
+ * Note that TX completion should use dev_consume_skb_any()
  */
-void dev_kfree_skb_any(struct sk_buff *skb);
+static inline void dev_kfree_skb_any(struct sk_buff *skb)
+{
+	get_kfree_skb_cb(skb)->reason = SKB_REASON_DROPPED;
+	__dev_kfree_skb_any(skb);
+}
+
+static inline void dev_consume_skb_any(struct sk_buff *skb)
+{
+	get_kfree_skb_cb(skb)->reason = SKB_REASON_CONSUMED;
+	__dev_kfree_skb_any(skb);
+}
 
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index ba3b7ea5ebb3..3170776e53da 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2161,14 +2161,14 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dev_kfree_skb_irq);
 
-void dev_kfree_skb_any(struct sk_buff *skb)
+void __dev_kfree_skb_any(struct sk_buff *skb)
 {
 	if (in_irq() || irqs_disabled())
 		dev_kfree_skb_irq(skb);
 	else
 		dev_kfree_skb(skb);
 }
-EXPORT_SYMBOL(dev_kfree_skb_any);
+EXPORT_SYMBOL(__dev_kfree_skb_any);
 
 
 /**
@@ -3306,7 +3306,10 @@ static void net_tx_action(struct softirq_action *h)
 			clist = clist->next;
 
 			WARN_ON(atomic_read(&skb->users));
-			trace_kfree_skb(skb, net_tx_action);
+			if (likely(get_kfree_skb_cb(skb)->reason == SKB_REASON_CONSUMED))
+				trace_consume_skb(skb);
+			else
+				trace_kfree_skb(skb, net_tx_action);
 			__kfree_skb(skb);
 		}
 	}
