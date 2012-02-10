From: Ben Greear <greearb@candelatech.com>
Subject: Re: r8169 crash (probably my fault) in 3.3.0-rc1+ (net-next)
Date: Fri, 10 Feb 2012 09:09:37 -0800
Message-ID: <4F354F51.7070202@candelatech.com>
References: <4F3446AB.2080209@candelatech.com> <20120210093006.GA23710@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050306000208050303000703"
Cc: netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38729 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716Ab2BJRJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 12:09:41 -0500
In-Reply-To: <20120210093006.GA23710@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050306000208050303000703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 02/10/2012 01:30 AM, Francois Romieu wrote:
> Ben Greear<greearb@candelatech.com>  :
> [...]
>> I am hacking on the 8169 code, (adding RX-ALL and RX-FCS support on top
>> of my previously posted patches) so this could easily be my fault..
>> but just in case someone else has seen it, please let me know....
>
> I have never met it before. Neither does the web.
>
> Are you hacking against davem's -next branch ?

Yes.  I was testing the attached patch, and when I enabled the rx-fcs, it crashed
shortly after.  So, my changes must be bad somehow...

Probably something to do with pkt_size being 4 bytes larger when
rx-fcs is enabled (I was hoping that would grab the FCS, as similar
logic seems to work fine in 8139too...)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------050306000208050303000703
Content-Type: text/x-patch;
 name="rtl.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rtl.patch"

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5eb6858..fbd855b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1626,21 +1626,32 @@ static void __rtl8169_set_features(struct net_device *dev,
 				   netdev_features_t features)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-
+	netdev_features_t changed = features ^ dev->features;
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (features & NETIF_F_RXCSUM)
-		tp->cp_cmd |= RxChkSum;
-	else
-		tp->cp_cmd &= ~RxChkSum;
+	if (!(changed & (NETIF_F_RXALL | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX)))
+		return;
 
-	if (dev->features & NETIF_F_HW_VLAN_RX)
-		tp->cp_cmd |= RxVlan;
-	else
-		tp->cp_cmd &= ~RxVlan;
+	if (changed & (NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX)) {
+		if (features & NETIF_F_RXCSUM)
+			tp->cp_cmd |= RxChkSum;
+		else
+			tp->cp_cmd &= ~RxChkSum;
 
-	RTL_W16(CPlusCmd, tp->cp_cmd);
-	RTL_R16(CPlusCmd);
+		if (dev->features & NETIF_F_HW_VLAN_RX)
+			tp->cp_cmd |= RxVlan;
+		else
+			tp->cp_cmd &= ~RxVlan;
+
+		RTL_W16(CPlusCmd, tp->cp_cmd);
+		RTL_R16(CPlusCmd);
+	}
+	if (changed & NETIF_F_RXALL) {
+		int tmp = (RTL_R32(RxConfig) & ~(AcceptErr | AcceptRunt));
+		if (features & NETIF_F_RXALL)
+			tmp |= (AcceptErr | AcceptRunt);
+		RTL_W32(RxConfig, tmp);
+	}
 }
 
 static int rtl8169_set_features(struct net_device *dev,
@@ -4174,6 +4185,9 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
 		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
 
+	dev->hw_features |= NETIF_F_RXALL;
+	dev->hw_features |= NETIF_F_RXFCS;
+
 	tp->hw_start = cfg->hw_start;
 	tp->event_slow = cfg->event_slow;
 
@@ -5747,11 +5761,23 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 				rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 				dev->stats.rx_fifo_errors++;
 			}
+			if ((status & (RxRUNT | RxCRC)) &&
+			    !(status & (RxRWT | RxFOVF)) &&
+			    (dev->features & NETIF_F_RXALL))
+				goto process_pkt;
+
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
 		} else {
 			struct sk_buff *skb;
-			dma_addr_t addr = le64_to_cpu(desc->addr);
-			int pkt_size = (status & 0x00003fff) - 4;
+			dma_addr_t addr;
+			int pkt_size;
+
+process_pkt:
+			addr = le64_to_cpu(desc->addr);
+			if (likely(!(dev->features & NETIF_F_RXFCS)))
+				pkt_size = (status & 0x00003fff) - 4;
+			else
+				pkt_size = status & 0x00003fff;
 
 			/*
 			 * The driver does not support incoming fragmented
@@ -6025,6 +6051,9 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		}
 	}
 
+	if (dev->features & NETIF_F_RXALL)
+		rx_mode |= (AcceptErr | AcceptRunt);
+
 	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
 
 	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {

--------------050306000208050303000703--
