From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH] usbnet: mcs7830: improve workaround against unreliable link
 status.
Date: Tue, 4 Jun 2013 20:30:19 +0200
Message-ID: <20130604183019.GB13186@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	OndrejZary <linux@rainbow-software.org>,
	Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>From d4bf85d0c6776bf4b15a0eea7772f9c55cef3daf Mon Sep 17 00:00:00 2001
From: Andreas Mohr <andim2@users.sourceforge.net>
Date: Sun, 2 Jun 2013 22:24:35 +0200
Subject: [PATCH] usbnet: mcs7830: improve workaround against unreliable link
 status.

- to guard against spurious link loss, try to improve precision
  by taking into account full-duplex / 100Mbps bits as well
- add actual status enums rather than using open-coded ints
- MCS7830 status data is word-sized, thus do access it that way
---
 drivers/net/usb/mcs7830.c |   74 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 72 insertions(+), 2 deletions(-)


Realized that link state is unreliable indeed (sometimes causing
some intermediate status changes even with that averaging happening),
thus I was wondering how to improve it.
First thing was to think of something which we might be doing wrong in general, but I couldn't come up with much.
Thus I concentrated on the status bits that were incoming, where I realized
that full-duplex / 100Mbps bits are a strong indication of an actual
link. IOW, update code to consider link lost only if link loss bit is active
and neither full-duplex nor 100Mbps is indicated.
Of course a half-duplex 10Mbps connection (BNC hub?) will not be happy
then. Sucks, but that's life.
Anything else that someone might come up with on why status is that
unreliable? Perhaps that's a common phenomenon with some PHY mechanisms?

Tested on -rc4, checkpath.pl:d.

Signed-off-by: Andreas Mohr <andim2@users.sourceforge.net>

Thanks,

Andreas Mohr


diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 03832d3..0c1543b 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -114,6 +114,43 @@ enum {
 	/* [7:6] reserved */
 };
 
+/* Bits within one status word in status interrupt callback data */
+enum {
+	MCS7830_STATUS_ETHER_FRAME_OK			= 0x0001,
+	MCS7830_STATUS_RETRIES_MORE_THAN_16		= 0x0002,
+	MCS7830_STATUS_COLLISION_OCCURRED_AFTER_64BYTES	= 0x0004,
+	MCS7830_STATUS_PACKET_ABORTED_EXCESS_DEFERRAL	= 0x0008,
+	/* 9:4 reserved (all zeroes) */
+	MCS7830_STATUS_FULL_DUPLEX_EN			= 0x0400,
+	MCS7830_STATUS_SPEED_100MBPS			= 0x0800,
+	MCS7830_STATUS_MIIM_INTERRUPT			= 0x1000,
+	/* Link flag is UNRELIABLE, on both 7830 and 7832!
+	 * While pulling the cable always seems to result in a clean 0x2000,
+	 * sometimes in between (especially when transfers are interfering?)
+	 * there's 0x2XXX values as well, but they always seem to be 0x2cXX
+	 * (at least for full-duplex, 100Mbps operation).
+	 * Thus the only more reliable way to tell apart actual link loss
+	 * from pseudo loss is to query for "link loss" *and*
+	 * "both full-duplex *and* 100Mbps *not set*". Which obviously means
+	 * that a half-duplex, 10Mbps setup
+	 * likely will never be able to indicate link reliably :(
+	 * Plus, I'm wondering whether we (or the kernel?)
+	 * are simply doing something wrong which causes the device to act up
+	 * (e.g., intermingling frame transfers with status transfers
+	 * in a sufficiently problematic way [inner-device race conditions?]).
+	 * Also, averaging several status bools is not very useful since:
+	 * - it directly depends on polling frequency
+	 * - (and thus) that count may still not be enough --> mis-detection
+	 * Perhaps on link loss it's somehow doable to subsequently do
+	 * an actual PHY request (perhaps not in status callback?)
+	 * which would hopefully reliably indicate status.
+	 */
+	MCS7830_STATUS_MIIM_LINK_DOWN__UNRELIABLE	= 0x2000,
+	MCS7830_STATUS_TX_STATUS_VECTOR_BITS_VALID	= 0x4000,
+	MCS7830_STATUS_SRAM_HAS_FRAMES_PENDING		= 0x8000
+};
+
+
 struct mcs7830_data {
 	u8 multi_filter[8];
 	u8 config;
@@ -559,14 +596,47 @@ static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 static void mcs7830_status(struct usbnet *dev, struct urb *urb)
 {
+	/*
+	 * TODO: since status polling is very painful (>> 100 wakeups / second),
+	 * could add a module param
+	 * disable_status_poll
+	 * "Disable polling of status interrupt EP (avoid excessive wakeups)."
+	 * where one would set the .status member to NULL
+	 * (but that's currently not doable since the struct is const).
+	 */
+
 	u8 *buf = urb->transfer_buffer;
-	bool link, link_changed;
+	u16 *statuswords = (u16 *)buf;
+	bool link_might_be_lost, link, link_changed;
 	struct mcs7830_data *data = mcs7830_get_data(dev);
 
 	if (urb->actual_length < 16)
 		return;
 
-	link = !(buf[1] & 0x20);
+	netdev_dbg(dev->net,
+		"status %04x %04x %04x %04x %04x %04x %04x %04x\n",
+		statuswords[0], statuswords[1], statuswords[2], statuswords[3],
+		statuswords[4], statuswords[5], statuswords[6], statuswords[7]);
+
+	/* For a description of the link status nightmare handled here,
+	 * see MCS7830_STATUS_MIIM_LINK_DOWN__UNRELIABLE bit.
+	 */
+	link = true; /* be optimistic :) */
+	/* Side note: MCS7830_STATUS_MIIM_LINK_DOWN__UNRELIABLE is documented
+	 * to be relevant for external-PHY configurations only.
+	 * For now we'll just assume that most (all?) adapters
+	 * do use an external PHY...
+	 */
+	link_might_be_lost =
+	  (statuswords[0] & MCS7830_STATUS_MIIM_LINK_DOWN__UNRELIABLE) != 0;
+	if (link_might_be_lost) {
+		bool special_link_attrs_active =
+		((statuswords[0] &
+		 (MCS7830_STATUS_FULL_DUPLEX_EN|MCS7830_STATUS_SPEED_100MBPS))
+			!= 0);
+		if (!special_link_attrs_active)
+			link = false;
+	}
 	link_changed = netif_carrier_ok(dev->net) != link;
 	if (link_changed) {
 		data->link_counter++;
-- 
1.7.10.4
