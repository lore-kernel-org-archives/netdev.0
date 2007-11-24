From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: wireless vs. alignment requirements
Date: Sat, 24 Nov 2007 14:11:29 +0100
Message-ID: <20071124131128.GA28785@deine-taler.de>
References: <20071123000922.C44009D4A1F@zog.reactivated.net> <1195850001.4149.165.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:59562 "EHLO deine-taler.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751063AbXKXNlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Nov 2007 08:41:22 -0500
Content-Disposition: inline
In-Reply-To: <1195850001.4149.165.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes,

> Hence, going back to the 802.11 header and the IP header alignment
> requirement, if we get the IP header alignment requirement right now I
> cannot possibly see any way we would use compare_ether_addr() on an
> address that is not at least two-byte aligned as required.

ACK. I agree completely.

The problem with the zd1211rw driver is, that it copies the
complete frame received from the device into the SKB and pulls
later the five bytes ZD1211 uses for the PLCP information.
This causes the 802.11 header to be on an odd address. The
reported problems are caused by this.

The zd1211rw-mac80211 is not affected, because the PLCP header is
not copied into the skb and this way the 802.11 header becomes
correctly aligned.

Here is a patch, which should solve the zd1211rw alignment issues.
It compiles, but it is not tested right now, because I got the
idea while writing this e-mail. An official submission will
follow.

Uli

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a903645..fb54cd7 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1166,15 +1166,22 @@ static void do_rx(unsigned long mac_ptr)
 int zd_mac_rx_irq(struct zd_mac *mac, const u8 *buffer, unsigned int length)
 {
 	struct sk_buff *skb;
+	unsigned int length_to_reserve;
 
-	skb = dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
+	/* This ensures that there is enough place for the radiotap header
+	 * and the the 802.11 header is aligned by four following the
+	 * five-byte ZD1211-specific PLCP header.
+	 */
+	length_to_reserve = ((sizeof(struct zd_rt_hdr) + 3) & ~3) + 3;
+
+	skb = dev_alloc_skb(length_to_reserve + length);
 	if (!skb) {
 		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 		dev_warn(zd_mac_dev(mac), "Could not allocate skb.\n");
 		ieee->stats.rx_dropped++;
 		return -ENOMEM;
 	}
-	skb_reserve(skb, sizeof(struct zd_rt_hdr));
+	skb_reserve(skb, length_to_reserve);
 	memcpy(__skb_put(skb, length), buffer, length);
 	skb_queue_tail(&mac->rx_queue, skb);
 	tasklet_schedule(&mac->rx_tasklet);

-- 
Uli Kunitz
