From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/3] e1000: increase skb size to prevent dma over skb
	boundary
Date: Mon, 7 Dec 2009 09:47:36 -0500
Message-ID: <20091207144736.GB8073@hmsreliant.think-freely.org>
References: <20091207144623.GA8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35014 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757332AbZLGOrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 09:47:32 -0500
Content-Disposition: inline
In-Reply-To: <20091207144623.GA8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update e1000 driver to not allow dma beyond the end of the allocated skb
    
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


e1000_main.c |   34 +++++++++++++++++++++++++++++++++-
1 file changed, 33 insertions(+), 1 deletion(-)


diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7e855f9..7600deb 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1667,6 +1667,19 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 	return err;
 }
 
+static inline u32 normalize_rx_len(u32 len)
+{
+        u32 match, last_match;
+
+
+        for (match = 0x100; match <= 0x4000; match *= 2) {
+                if (len <= match)
+                        return match;
+        }
+
+        return 0;
+}
+
 /**
  * e1000_setup_rctl - configure the receive control registers
  * @adapter: Board private structure
@@ -1675,6 +1688,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
+	u32 normed_rx_len;
 
 	rctl = er32(RCTL);
 
@@ -1697,7 +1711,25 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	/* Setup buffer sizes */
 	rctl &= ~E1000_RCTL_SZ_4096;
 	rctl |= E1000_RCTL_BSEX;
-	switch (adapter->rx_buffer_len) {
+
+	/*
+	 * We need to normalize the rx_buffer_len here
+	 * since the hardware only knows about 7 discrete
+	 * frame lengths here.  To accomodate that we need
+	 * to set the rx length in the hardware to the next highest
+	 * size over the rx_buffer_len, then increase rx_buffer_len
+	 * to match it, so that we can get a full mtu sized frame 
+	 */
+	normed_rx_len = normalize_rx_len(adapter->rx_buffer_len);
+	
+	if (!normed_rx_len) {
+		printk(KERN_ERR "No valid rx len found, assume 2048\n");
+		normed_rx_len = 0x800;
+	}
+
+	adapter->rx_buffer_len = normed_rx_len;
+
+	switch (normed_rx_len) {
 		case E1000_RXBUFFER_256:
 			rctl |= E1000_RCTL_SZ_256;
 			rctl &= ~E1000_RCTL_BSEX;
