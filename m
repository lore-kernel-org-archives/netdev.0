From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Thu, 10 Jan 2008 14:49:22 -0500
Message-ID: <20080110194922.GF3109@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3807 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbYAJUUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 15:20:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

A couple more fixes for 2.6.24.  The one from Mattias Nissler is already
in your upstream tree...FYI.

Let me know if there are problems!

Thanks,

John

---

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/

---

The following changes since commit 3ce54450461bad18bbe1f9f5aa3ecd2f8e8d1235:
  Linus Torvalds (1):
        Linux 2.6.24-rc7

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Ivo van Doorn (1):
      rt2x00: Corectly initialize rt2500usb MAC

Mattias Nissler (1):
      rt2x00: Allow rt61 to catch up after a missing tx report

 drivers/net/wireless/rt2x00/rt2500usb.c |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c   |   13 +++++++++++++
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 50775f9..18b1f91 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -257,7 +257,7 @@ static const struct rt2x00debug rt2500usb_rt2x00debug = {
 static void rt2500usb_config_mac_addr(struct rt2x00_dev *rt2x00dev,
 				      __le32 *mac)
 {
-	rt2500usb_register_multiwrite(rt2x00dev, MAC_CSR2, &mac,
+	rt2500usb_register_multiwrite(rt2x00dev, MAC_CSR2, mac,
 				      (3 * sizeof(__le16)));
 }
 
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 01dbef1..0d9436d 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1738,6 +1738,7 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00dev)
 {
 	struct data_ring *ring;
 	struct data_entry *entry;
+	struct data_entry *entry_done;
 	struct data_desc *txd;
 	u32 word;
 	u32 reg;
@@ -1791,6 +1792,18 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00dev)
 		    !rt2x00_get_field32(word, TXD_W0_VALID))
 			return;
 
+		entry_done = rt2x00_get_data_entry_done(ring);
+		while (entry != entry_done) {
+			/* Catch up. Just report any entries we missed as
+			 * failed. */
+			WARNING(rt2x00dev,
+				"TX status report missed for entry %p\n",
+				entry_done);
+			rt2x00pci_txdone(rt2x00dev, entry_done, TX_FAIL_OTHER,
+					 0);
+			entry_done = rt2x00_get_data_entry_done(ring);
+		}
+
 		/*
 		 * Obtain the status about this packet.
 		 */
-- 
John W. Linville
linville@tuxdriver.com
