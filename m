From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] igb: fix link reporting when using sgmii
Date: Fri, 30 Jan 2009 16:54:25 -0800
Message-ID: <20090131005425.1466.60907.stgit@lost.foo-projects.org>
References: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:57835
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753588AbZAaAyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 19:54:45 -0500
In-Reply-To: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

When using sgmii the link was not being properly passed up to the driver
from the underlying link management functions.  This change corrects it so
that get_link_status is cleared when a link has been found.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f5e2e72..13ca73f 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -699,11 +699,18 @@ static s32 igb_check_for_link_82575(struct e1000_hw *hw)
 
 	/* SGMII link check is done through the PCS register. */
 	if ((hw->phy.media_type != e1000_media_type_copper) ||
-	    (igb_sgmii_active_82575(hw)))
+	    (igb_sgmii_active_82575(hw))) {
 		ret_val = igb_get_pcs_speed_and_duplex_82575(hw, &speed,
 		                                             &duplex);
-	else
+		/*
+		 * Use this flag to determine if link needs to be checked or
+		 * not.  If  we have link clear the flag so that we do not
+		 * continue to check for link.
+		 */
+		hw->mac.get_link_status = !hw->mac.serdes_has_link;
+	} else {
 		ret_val = igb_check_for_copper_link(hw);
+	}
 
 	return ret_val;
 }

