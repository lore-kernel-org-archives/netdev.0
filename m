From: nschichan@freebox.fr
Subject: [PATCH] e1000: always call e1000_check_for_link() on e1000_ce4100 MACs.
Date: Thu,  7 Jul 2011 15:16:57 +0200
Message-ID: <1310044617-22978-1-git-send-email-nschichan@freebox.fr>
Cc: Florian Fainelli <ffainelli@freebox.fr>, stable@kernel.org,
	Nicolas Schichan <nschichan@freebox.fr>
To: Nicolas Schichan <nschichan@freebox.fr>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Dirk Brandewie <dirk.j.brandewie@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:58355 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755764Ab1GGNRO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 09:17:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Schichan <nschichan@freebox.fr>

Interrupts about link lost or rx sequence errors are not reported by
the ce4100 hardware, leading to transitions from link UP to link DOWN
never being reported.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 drivers/net/e1000/e1000_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 76e8af0..a02333f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2357,13 +2357,16 @@ bool e1000_has_link(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	bool link_active = false;
 
-	/* get_link_status is set on LSC (link status) interrupt or
-	 * rx sequence error interrupt.  get_link_status will stay
-	 * false until the e1000_check_for_link establishes link
-	 * for copper adapters ONLY
+	/* get_link_status is set on LSC (link status) interrupt or rx
+	 * sequence error interrupt (except on intel ce4100).
+	 * get_link_status will stay false until the
+	 * e1000_check_for_link establishes link for copper adapters
+	 * ONLY
 	 */
 	switch (hw->media_type) {
 	case e1000_media_type_copper:
+		if (hw->mac_type == e1000_ce4100)
+			hw->get_link_status = 1;
 		if (hw->get_link_status) {
 			e1000_check_for_link(hw);
 			link_active = !hw->get_link_status;
-- 
1.7.1

