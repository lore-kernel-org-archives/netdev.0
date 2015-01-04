From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] qlcnic: Fix dump_skb output
Date: Sat, 03 Jan 2015 17:50:16 -0800
Message-ID: <1420336216.2619.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0041.hostedemail.com ([216.40.44.41]:39899 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751478AbbADBuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 20:50:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use normal facilities to avoid printing each byte
on a separate line.

Now emits at KERN_DEBUG instead of KERN_INFO.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 18e5de7..d166e53 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -10,6 +10,7 @@
 #include <net/ip.h>
 #include <linux/ipv6.h>
 #include <net/checksum.h>
+#include <linux/printk.h>
 
 #include "qlcnic.h"
 
@@ -1465,14 +1466,14 @@ void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 
 static void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
 {
-	int i;
-	unsigned char *data = skb->data;
-
-	pr_info(KERN_INFO "\n");
-	for (i = 0; i < skb->len; i++) {
-		QLCDB(adapter, DRV, "%02x ", data[i]);
-		if ((i & 0x0f) == 8)
-			pr_info(KERN_INFO "\n");
+	if (adapter->ahw->msg_enable & NETIF_MSG_DRV) {
+		char prefix[30];
+
+		scnprintf(prefix, sizeof(prefix), "%s: %s: ",
+			  dev_name(&adapter->pdev->dev), __func__);
+
+		print_hex_dump_debug(prefix, DUMP_PREFIX_NONE, 16, 1,
+				     skb->data, skb->len, true);
 	}
 }
 
