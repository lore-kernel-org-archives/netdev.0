From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: make sure ethernet header is in transmit skb
Date: Sat, 26 Dec 2009 14:05:44 -0800
Message-ID: <20091226140544.5600b3d1@nehalam>
References: <4B300A2A.8040305@gmail.com>
	<4B300E30.9090707@majjas.com>
	<4B3114E3.1070602@majjas.com>
	<4B329FA3.9090904@majjas.com>
	<20091223230102.4bb0100e.akpm@linux-foundation.org>
	<4B34E847.8010809@majjas.com>
	<20091225152200.1cf11dfe@nehalam>
	<4B3581C7.8000702@majjas.com>
	<20091226095723.7ac82b18@nehalam>
	<4B367409.5060202@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Breuer <mbreuer@majjas.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753817AbZLZWGr@vger.kernel.org>
In-Reply-To: <4B367409.5060202@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When DHCP sends a packet using AF_PACKET, it is possible for driver
to receive a transmit packet with the Ethernet header off in the
skb fragments.  The hardware doesn't handle 0 size DMA's well,
so it gets confused.

Other drivers may have same problem, I really think this ought
to be done at higher level.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-2.6, but same patch applies to -stable as well
(with fuzz).

--- a/drivers/net/sky2.c	2009-12-26 13:39:34.289252942 -0800
+++ b/drivers/net/sky2.c	2009-12-26 13:59:44.548877690 -0800
@@ -1654,6 +1654,14 @@ static netdev_tx_t sky2_xmit_frame(struc
  	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
   		return NETDEV_TX_BUSY;
 
+	/* Make sure there is at least some data for first DMA */
+	if (!pskb_may_pull(skb, ETH_HLEN)) {
+		if (net_ratelimit())
+			pr_info(PFX "%s: packet missing ether header (%d)?",
+				dev->name, skb->len);
+		goto drop;
+	}
+
 	len = skb_headlen(skb);
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
@@ -1799,6 +1807,7 @@ mapping_unwind:
 mapping_error:
 	if (net_ratelimit())
 		dev_warn(&hw->pdev->dev, "%s: tx mapping error\n", dev->name);
+drop:
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
