From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/6] tg3: Reset chip when changing MAC address
Date: Fri, 28 Apr 2006 16:35:35 -0700
Message-ID: <1146267335.4780.16.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:56842 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932464AbWD2BPi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 21:15:38 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do the full chip reset when changing MAC address if ASF is enabled.

ASF sometimes uses a different MAC address than the driver. Without
the reset, the ASF MAC address may be overwritten when the driver's
MAC address is changed.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a307340..0ccfb63 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5732,9 +5732,23 @@ static int tg3_set_mac_addr(struct net_d
 	if (!netif_running(dev))
 		return 0;
 
-	spin_lock_bh(&tp->lock);
-	__tg3_set_mac_addr(tp);
-	spin_unlock_bh(&tp->lock);
+	if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) {
+		/* Reset chip so that ASF can re-init any MAC addresses it
+		 * needs.
+		 */
+		tg3_netif_stop(tp);
+		tg3_full_lock(tp, 1);
+
+		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
+		tg3_init_hw(tp);
+
+		tg3_netif_start(tp);
+		tg3_full_unlock(tp);
+	} else {
+		spin_lock_bh(&tp->lock);
+		__tg3_set_mac_addr(tp);
+		spin_unlock_bh(&tp->lock);
+	}
 
 	return 0;
 }


