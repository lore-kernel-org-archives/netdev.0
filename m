From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/3] e1000e: increase skb size to prevent dma over skb
	boundary (v2)
Date: Mon, 7 Dec 2009 11:02:36 -0500
Message-ID: <20091207160236.GF8073@hmsreliant.think-freely.org>
References: <20091207144623.GA8073@hmsreliant.think-freely.org> <20091207144817.GC8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45014 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932705AbZLGQCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 11:02:32 -0500
Content-Disposition: inline
In-Reply-To: <20091207144817.GC8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry to reply to myself, but given the comments regarding the e1000 driver, I
should take the same changes into account here.  New version of the patch, much
cleaner than previously.


Update e1000e driver to not allow dma beyond the end of the allocated sk
    
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


netdev.c |   14 +++++++++++++-
1 file changed, 13 insertions(+), 1 deletion(-)


diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c3105c5..84e1b5d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2332,6 +2332,16 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	/* Setup buffer sizes */
 	rctl &= ~E1000_RCTL_SZ_4096;
 	rctl |= E1000_RCTL_BSEX;
+	/*
+	 * We need to normalize the rx_buffer_len here
+	 * since the hardware only knows about 7 discrete
+	 * frame lengths here.  To accomodate that we need
+	 * to set the rx length in the hardware to the next highest
+	 * size over the rx_buffer_len, then increase rx_buffer_len
+	 * to match it, so that we can get a full mtu sized frame
+	 */
+	adapter->rx_buffer_len = roundup_pow_of_two(adapter->rx_buffer_len);
+
 	switch (adapter->rx_buffer_len) {
 	case 256:
 		rctl |= E1000_RCTL_SZ_256;
@@ -2346,7 +2356,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		rctl &= ~E1000_RCTL_BSEX;
 		break;
 	case 2048:
-	default:
 		rctl |= E1000_RCTL_SZ_2048;
 		rctl &= ~E1000_RCTL_BSEX;
 		break;
@@ -2359,6 +2368,9 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	case 16384:
 		rctl |= E1000_RCTL_SZ_16384;
 		break;
+	default:
+		panic("Bad rx_buffer_len size\n");
+		break;
 	}
 
 	/*
