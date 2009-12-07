From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/3] e1000e: increase skb size to prevent dma over skb
	boundary
Date: Mon, 7 Dec 2009 09:48:17 -0500
Message-ID: <20091207144817.GC8073@hmsreliant.think-freely.org>
References: <20091207144623.GA8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35024 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757631AbZLGOsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 09:48:12 -0500
Content-Disposition: inline
In-Reply-To: <20091207144623.GA8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update e1000e driver to not allow dma beyond the end of the allocated skb

Signed-off-by: Neil Horman <nhorman@tuxdrvier.com>


netdev.c |   38 +++++++++++++++++++++++++++++++++++++-
1 file changed, 37 insertions(+), 1 deletion(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c3105c5..370bb0f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2276,6 +2276,20 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	adapter->tx_queue_len = adapter->netdev->tx_queue_len;
 }
 
+
+static inline u32 normalize_rx_len(u32 len)
+{
+	u32 match, last_match;
+
+
+	for (match = 0x100; match <= 0x4000; match *= 2) {
+		if (len <= match)
+			return match;
+	}
+
+	return 0;
+}
+
 /**
  * e1000_setup_rctl - configure the receive control registers
  * @adapter: Board private structure
@@ -2288,6 +2302,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	u32 rctl, rfctl;
 	u32 psrctl = 0;
 	u32 pages = 0;
+	u32 normed_rx_length;
 
 	/* Program MC offset vector base */
 	rctl = er32(RCTL);
@@ -2332,7 +2347,28 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	/* Setup buffer sizes */
 	rctl &= ~E1000_RCTL_SZ_4096;
 	rctl |= E1000_RCTL_BSEX;
-	switch (adapter->rx_buffer_len) {
+	/*
+	 * We need to normalize the rx_buffer_len here
+	 * since the hardware only knows about 7 discrete
+	 * frame lengths here.  To accomodate that we need
+	 * to set the rx length in the hardware to the next highest
+	 * size over the rx_buffer_len, then increase rx_buffer_len
+	 * to match it, so that we can get a full mtu sized frame 
+	 */
+	normed_rx_length = normalize_rx_len(adapter->rx_buffer_len);
+
+	if (!normed_rx_length) {
+		printk(KERN_ERR "No valid rx len found, assume 2048\n");
+		normed_rx_length = 0x800;
+	}
+
+	/*
+ 	 * Now we need to bump the rx_len value up so that we allocate
+ 	 * enough data for us to dma into
+ 	 */
+	adapter->rx_buffer_len = normed_rx_length;
+		
+	switch (normed_rx_length) {
 	case 256:
 		rctl |= E1000_RCTL_SZ_256;
 		rctl &= ~E1000_RCTL_BSEX;
