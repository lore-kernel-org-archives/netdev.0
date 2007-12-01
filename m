From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Subject: [PATCH] zd1211rw: Fix alignment problems
Date: Sat, 1 Dec 2007 11:26:05 +0100
Message-ID: <20071201102605.GA25387@deine-taler.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4RrovVCs/uTlw@public.gmane.org, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Shaddy Baddah found an alignment problem with zd1211rw driver at
2007-11-19. This patch fixes it, it is based on the patch proposed by
Herbert Xu. The alignment 4 has been the agreed value on the
linux-wireless mailing list.

Notify that the problem does only affect the old zd1211rw softmac
driver and not the zd1211rw-mac80211 driver. Daniel Drake has
already provided a patch for the replacement of the softmac
driver, which this patch will break.

Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
---
 drivers/net/wireless/zd1211rw/zd_mac.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a903645..5298a8b 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1130,6 +1130,8 @@ static void zd_mac_rx(struct zd_mac *mac, struct sk_buff *skb)
 	__skb_trim(skb, skb->len -
 		        (IEEE80211_FCS_LEN + sizeof(struct rx_status)));
 
+	ZD_ASSERT(IS_ALIGNED((unsigned long)skb->data, 4));
+
 	update_qual_rssi(mac, skb->data, skb->len, stats.signal,
 		         status->signal_strength);
 
@@ -1166,15 +1168,19 @@ static void do_rx(unsigned long mac_ptr)
 int zd_mac_rx_irq(struct zd_mac *mac, const u8 *buffer, unsigned int length)
 {
 	struct sk_buff *skb;
+	unsigned int reserved =
+		ALIGN(max_t(unsigned int,
+		            sizeof(struct zd_rt_hdr), ZD_PLCP_HEADER_SIZE), 4) -
+		ZD_PLCP_HEADER_SIZE;
 
-	skb = dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
+	skb = dev_alloc_skb(reserved + length);
 	if (!skb) {
 		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 		dev_warn(zd_mac_dev(mac), "Could not allocate skb.\n");
 		ieee->stats.rx_dropped++;
 		return -ENOMEM;
 	}
-	skb_reserve(skb, sizeof(struct zd_rt_hdr));
+	skb_reserve(skb, reserved);
 	memcpy(__skb_put(skb, length), buffer, length);
 	skb_queue_tail(&mac->rx_queue, skb);
 	tasklet_schedule(&mac->rx_tasklet);
-- 
1.5.3.6
