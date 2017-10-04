From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v2 net-next] ravb: RX checksum offload
Date: Wed,  4 Oct 2017 09:54:27 +0200
Message-ID: <1507103667-6084-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Simon Horman <horms+renesas@verge.net.au>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for RX checksum offload. This is enabled by default and
may be disabled and re-enabled using ethtool:

 # ethtool -K eth0 rx off
 # ethtool -K eth0 rx on

The RAVB provides a simple checksumming scheme which appears to be
completely compatible with CHECKSUM_COMPLETE: sum of all packet data after
the L2 header is appended to packet data; this may be trivially read by the
driver and used to update the skb accordingly.

In terms of performance throughput is close to gigabit line-rate both with
and without RX checksum offload enabled. Perf output, however, appears to
indicate that significantly less time is spent in do_csum(). This is as
expected.

Test results with RX checksum offload enabled:
 # /usr/bin/perf_3.16 record -o /run/perf.data -a netperf -t TCP_MAERTS -H 10.4.3.162
 MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.4.3.162 () port 0 AF_INET : demo
 enable_enobufs failed: getprotobyname
 Recv   Send    Send
 Socket Socket  Message  Elapsed
 Size   Size    Size     Time     Throughput
 bytes  bytes   bytes    secs.    10^6bits/sec

  87380  16384  16384    10.00     937.54

 Summary of output of perf report:
    18.28%      ksoftirqd/0  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore
    10.34%      ksoftirqd/0  [kernel.kallsyms]  [k] __pi_memcpy
     9.83%      ksoftirqd/0  [kernel.kallsyms]  [k] ravb_poll
     7.89%      ksoftirqd/0  [kernel.kallsyms]  [k] skb_put
     4.01%      ksoftirqd/0  [kernel.kallsyms]  [k] dev_gro_receive
     3.37%          netperf  [kernel.kallsyms]  [k] __arch_copy_to_user
     3.17%          swapper  [kernel.kallsyms]  [k] arch_cpu_idle
     2.55%          swapper  [kernel.kallsyms]  [k] tick_nohz_idle_enter
     2.04%      ksoftirqd/0  [kernel.kallsyms]  [k] __pi___inval_dcache_area
     2.03%          swapper  [kernel.kallsyms]  [k] _raw_spin_unlock_irq
     1.96%      ksoftirqd/0  [kernel.kallsyms]  [k] __netdev_alloc_skb
     1.59%      ksoftirqd/0  [kernel.kallsyms]  [k] __slab_alloc.isra.83

Test results without RX checksum offload enabled:
 # /usr/bin/perf_3.16 record -o /run/perf.data -a netperf -t TCP_MAERTS -H 10.4.3.162
 MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.4.3.162 () port 0 AF_INET : demo
 enable_enobufs failed: getprotobyname
 Recv   Send    Send
 Socket Socket  Message  Elapsed
 Size   Size    Size     Time     Throughput
 bytes  bytes   bytes    secs.    10^6bits/sec

  87380  16384  16384    10.00     940.20

 Summary of output of perf report:
    17.10%    ksoftirqd/0  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore
    10.99%    ksoftirqd/0  [kernel.kallsyms]  [k] __pi_memcpy
     8.87%    ksoftirqd/0  [kernel.kallsyms]  [k] ravb_poll
     8.16%    ksoftirqd/0  [kernel.kallsyms]  [k] skb_put
     7.42%    ksoftirqd/0  [kernel.kallsyms]  [k] do_csum
     3.91%    ksoftirqd/0  [kernel.kallsyms]  [k] dev_gro_receive
     2.31%        swapper  [kernel.kallsyms]  [k] arch_cpu_idle
     2.16%    ksoftirqd/0  [kernel.kallsyms]  [k] __pi___inval_dcache_area
     2.14%    ksoftirqd/0  [kernel.kallsyms]  [k] __netdev_alloc_skb
     1.93%        netperf  [kernel.kallsyms]  [k] __arch_copy_to_user
     1.79%        swapper  [kernel.kallsyms]  [k] tick_nohz_idle_enter
     1.63%    ksoftirqd/0  [kernel.kallsyms]  [k] __slab_alloc.isra.83

Above results collected on an R-Car Gen 3 Salvator-X/r8a7796 ES1.0.
Also tested on a R-Car Gen 3 Salvator-X/r8a7795 ES1.0.

By inspection this also appears to be compatible with the ravb found
on R-Car Gen 2 SoCs, however, this patch is currently untested on such
hardware.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v2
Address review of v1 by Sergei Shtylyov
* set features rather than oring them with (zero) existing values:
* Set/unset using a single call to ravb_modify()
---
 drivers/net/ethernet/renesas/ravb_main.c | 55 +++++++++++++++++++++++++++++++-
 1 file changed, 54 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index fdf30bfa403b..a8822a756e08 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -403,8 +403,9 @@ static void ravb_emac_init(struct net_device *ndev)
 	/* Receive frame limit set register */
 	ravb_write(ndev, ndev->mtu + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN, RFLR);
 
-	/* PAUSE prohibition */
+	/* EMAC Mode: PAUSE prohibition; Duplex; RX Checksum; TX; RX */
 	ravb_write(ndev, ECMR_ZPF | (priv->duplex ? ECMR_DM : 0) |
+		   (ndev->features & NETIF_F_RXCSUM ? ECMR_RCSC : 0) |
 		   ECMR_TE | ECMR_RE, ECMR);
 
 	ravb_set_rate(ndev);
@@ -520,6 +521,19 @@ static void ravb_get_tx_tstamp(struct net_device *ndev)
 	}
 }
 
+static void ravb_rx_csum(struct sk_buff *skb)
+{
+	u8 *hw_csum;
+
+	/* The hardware checksum is 2 bytes appended to packet data */
+	if (unlikely(skb->len < 2))
+		return;
+	hw_csum = skb_tail_pointer(skb) - 2;
+	skb->csum = csum_unfold((__force __sum16)get_unaligned_le16(hw_csum));
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	skb_trim(skb, skb->len - 2);
+}
+
 /* Packet receive function for Ethernet AVB */
 static bool ravb_rx(struct net_device *ndev, int *quota, int q)
 {
@@ -587,8 +601,11 @@ static bool ravb_rx(struct net_device *ndev, int *quota, int q)
 				ts.tv_nsec = le32_to_cpu(desc->ts_n);
 				shhwtstamps->hwtstamp = timespec64_to_ktime(ts);
 			}
+
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
+			if (ndev->features & NETIF_F_RXCSUM)
+				ravb_rx_csum(skb);
 			napi_gro_receive(&priv->napi[q], skb);
 			stats->rx_packets++;
 			stats->rx_bytes += pkt_len;
@@ -1842,6 +1859,38 @@ static int ravb_do_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
 	return phy_mii_ioctl(phydev, req, cmd);
 }
 
+static void ravb_set_rx_csum(struct net_device *ndev, bool enable)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	/* Disable TX and RX */
+	ravb_rcv_snd_disable(ndev);
+
+	/* Modify RX Checksum setting */
+	ravb_modify(ndev, ECMR, ECMR_RCSC, enable ? ECMR_RCSC : 0);
+
+	/* Enable TX and RX */
+	ravb_rcv_snd_enable(ndev);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+}
+
+static int ravb_set_features(struct net_device *ndev,
+			     netdev_features_t features)
+{
+	netdev_features_t changed = ndev->features ^ features;
+
+	if (changed & NETIF_F_RXCSUM)
+		ravb_set_rx_csum(ndev, features & NETIF_F_RXCSUM);
+
+	ndev->features = features;
+
+	return 0;
+}
+
 static const struct net_device_ops ravb_netdev_ops = {
 	.ndo_open		= ravb_open,
 	.ndo_stop		= ravb_close,
@@ -1853,6 +1902,7 @@ static const struct net_device_ops ravb_netdev_ops = {
 	.ndo_do_ioctl		= ravb_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_features	= ravb_set_features,
 };
 
 /* MDIO bus init function */
@@ -2004,6 +2054,9 @@ static int ravb_probe(struct platform_device *pdev)
 	if (!ndev)
 		return -ENOMEM;
 
+	ndev->features = NETIF_F_RXCSUM;
+	ndev->hw_features = NETIF_F_RXCSUM;
+
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_get_sync(&pdev->dev);
 
-- 
2.1.4
