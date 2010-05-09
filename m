From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/11] netdev: bfin_mac: deduce
	Ethernet FCS from hardware IP payload checksum
Date: Sun,  9 May 2010 06:18:50 -0400
Message-ID: <1273400337-26501-4-git-send-email-vapier@gentoo.org>
References: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <1273400337-26501-1-git-send-email-vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sonic Zhang <sonic.zhang-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>

IP checksum is based on 16-bit one's complement algorithm.
To deduce a value from checksum is equal to add its complement.

Signed-off-by: Sonic Zhang <sonic.zhang-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/bfin_mac.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index f9ba598..5b00fc8 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -994,6 +994,10 @@ static void bfin_mac_rx(struct net_device *dev)
 	struct sk_buff *skb, *new_skb;
 	unsigned short len;
 	struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
+#if defined(BFIN_MAC_CSUM_OFFLOAD)
+	unsigned int i;
+	unsigned char fcs[ETH_FCS_LEN + 1];
+#endif
 
 	/* check if frame status word reports an error condition
 	 * we which case we simply drop the packet
@@ -1027,6 +1031,8 @@ static void bfin_mac_rx(struct net_device *dev)
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
 
 	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
+	/* Deduce Ethernet FCS length from Ethernet payload length */
+	len -= ETH_FCS_LEN;
 	skb_put(skb, len);
 
 	skb->protocol = eth_type_trans(skb, dev);
@@ -1035,6 +1041,23 @@ static void bfin_mac_rx(struct net_device *dev)
 
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	skb->csum = current_rx_ptr->status.ip_payload_csum;
+	/*
+	 * Deduce Ethernet FCS from hardware generated IP payload checksum.
+	 * IP checksum is based on 16-bit one's complement algorithm.
+	 * To deduce a value from checksum is equal to add its inversion.
+	 * If the IP payload len is odd, the inversed FCS should also
+	 * begin from odd address and leave first byte zero.
+	 */
+	if (skb->len % 2) {
+		fcs[0] = 0;
+		for (i = 0; i < ETH_FCS_LEN; i++)
+			fcs[i + 1] = ~skb->data[skb->len + i];
+		skb->csum = csum_partial(fcs, ETH_FCS_LEN + 1, skb->csum);
+	} else {
+		for (i = 0; i < ETH_FCS_LEN; i++)
+			fcs[i] = ~skb->data[skb->len + i];
+		skb->csum = csum_partial(fcs, ETH_FCS_LEN, skb->csum);
+	}
 	skb->ip_summed = CHECKSUM_COMPLETE;
 #endif
 
-- 
1.7.1
