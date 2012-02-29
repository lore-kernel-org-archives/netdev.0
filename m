From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 7/8] neterion/s2io: fix s2io_set_mac_addr() to prevent double checks
Date: Wed, 29 Feb 2012 16:42:55 +0100
Message-ID: <1330530176-24952-8-git-send-email-danny.kukawka@bisect.de>
References: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix s2io_set_mac_addr() to prevent double validation checks from
dev_set_mac_address().

Don't use s2io_set_mac_addr() in s2io_io_resume() since it makes
no sense to copy netdev->dev_addr to itself. Use do_s2io_prog_unicast()
instead since this is what's needed and checked here.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/neterion/s2io.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 22a8de0..cf7b3eb 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5247,9 +5247,6 @@ static int s2io_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	/* store the MAC address in CAM */
@@ -8658,7 +8655,7 @@ static void s2io_io_resume(struct pci_dev *pdev)
 			return;
 		}
 
-		if (s2io_set_mac_addr(netdev, netdev->dev_addr) == FAILURE) {
+		if (do_s2io_prog_unicast(netdev, netdev->dev_addr) == FAILURE) {
 			s2io_card_down(sp);
 			pr_err("Can't restore mac addr after reset.\n");
 			return;
-- 
1.7.8.3
