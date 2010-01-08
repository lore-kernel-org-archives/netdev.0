From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/5] e1000e: e1000e_enable_tx_pkt_filtering() returns
	wrong value
Date: Thu, 07 Jan 2010 18:31:54 -0800
Message-ID: <20100108023153.31476.89128.stgit@localhost.localdomain>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:60488
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753031Ab0AHCcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 21:32:13 -0500
In-Reply-To: <20100108023033.31476.4034.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

e1000e_enable_tx_pkt_filtering() will return a non-zero value if the
driver fails to enable the manageability interface on the host for
any reason; instead it should retun zero to indicate filtering has been
disabled.  Also provide a single exit point for the function.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/lib.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 56b59e4..97649bf 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -2301,10 +2301,12 @@ bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	s32 ret_val, hdr_csum, csum;
 	u8 i, len;
 
+	hw->mac.tx_pkt_filtering = true;
+
 	/* No manageability, no filtering */
 	if (!e1000e_check_mng_mode(hw)) {
 		hw->mac.tx_pkt_filtering = false;
-		return 0;
+		goto out;
 	}
 
 	/*
@@ -2312,9 +2314,9 @@ bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	 * reason, disable filtering.
 	 */
 	ret_val = e1000_mng_enable_host_if(hw);
-	if (ret_val != 0) {
+	if (ret_val) {
 		hw->mac.tx_pkt_filtering = false;
-		return ret_val;
+		goto out;
 	}
 
 	/* Read in the header.  Length and offset are in dwords. */
@@ -2333,17 +2335,17 @@ bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
 	 */
 	if ((hdr_csum != csum) || (hdr->signature != E1000_IAMT_SIGNATURE)) {
 		hw->mac.tx_pkt_filtering = true;
-		return 1;
+		goto out;
 	}
 
 	/* Cookie area is valid, make the final check for filtering. */
 	if (!(hdr->status & E1000_MNG_DHCP_COOKIE_STATUS_PARSING)) {
 		hw->mac.tx_pkt_filtering = false;
-		return 0;
+		goto out;
 	}
 
-	hw->mac.tx_pkt_filtering = true;
-	return 1;
+out:
+	return hw->mac.tx_pkt_filtering;
 }
 
 /**

