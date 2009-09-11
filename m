From: Simon Horman <horms@verge.net.au>
Subject: [patch] e1000: Tidy up logic in
	e1000_enable_tx_pkt_filtering()
Date: Fri, 11 Sep 2009 12:17:44 +1000
Message-ID: <20090911021744.GB3221@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Ronciak <john.ronciak@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is purely cosmetic, but to my mind it makes the code a lot easier
to follow.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

Lightly tested.

Index: net-next-2.6/drivers/net/e1000/e1000_hw.c
===================================================================
--- net-next-2.6.orig/drivers/net/e1000/e1000_hw.c	2009-08-31 17:44:07.000000000 +1000
+++ net-next-2.6/drivers/net/e1000/e1000_hw.c	2009-09-09 11:40:14.000000000 +1000
@@ -7604,31 +7604,33 @@ bool e1000_enable_tx_pkt_filtering(struc
 {
     /* called in init as well as watchdog timer functions */
 
-    s32 ret_val, checksum;
-    bool tx_filter = false;
+    s32 checksum;
+    bool tx_filter = true;
     struct e1000_host_mng_dhcp_cookie *hdr = &(hw->mng_cookie);
     u8 *buffer = (u8 *) &(hw->mng_cookie);
 
-    if (e1000_check_mng_mode(hw)) {
-        ret_val = e1000_mng_enable_host_if(hw);
-        if (ret_val == E1000_SUCCESS) {
-            ret_val = e1000_host_if_read_cookie(hw, buffer);
-            if (ret_val == E1000_SUCCESS) {
-                checksum = hdr->checksum;
-                hdr->checksum = 0;
-                if ((hdr->signature == E1000_IAMT_SIGNATURE) &&
-                    checksum == e1000_calculate_mng_checksum((char *)buffer,
-                                               E1000_MNG_DHCP_COOKIE_LENGTH)) {
-                    if (hdr->status &
-                        E1000_MNG_DHCP_COOKIE_STATUS_PARSING_SUPPORT)
-                        tx_filter = true;
-                } else
-                    tx_filter = true;
-            } else
-                tx_filter = true;
-        }
-    }
+    if (!e1000_check_mng_mode(hw))
+        goto out_false;
+
+    if (e1000_mng_enable_host_if(hw) != E1000_SUCCESS)
+        goto out_false;
+
+    if (e1000_host_if_read_cookie(hw, buffer) != E1000_SUCCESS)
+	goto out_true;
 
+    checksum = hdr->checksum;
+    hdr->checksum = 0;
+    if ((hdr->signature != E1000_IAMT_SIGNATURE) ||
+        checksum != e1000_calculate_mng_checksum((char *)buffer,
+                                   E1000_MNG_DHCP_COOKIE_LENGTH))
+	goto out_true;
+
+    if (hdr->status & E1000_MNG_DHCP_COOKIE_STATUS_PARSING_SUPPORT)
+	goto out_true;
+
+out_false:
+    tx_filter = false;
+out_true:
     hw->tx_pkt_filtering = tx_filter;
     return tx_filter;
 }

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
