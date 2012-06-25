From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 5/8] LLDP: Output routines
Date: Mon, 25 Jun 2012 20:28:17 +0200
Message-ID: <1340648900-6547-6-git-send-email-eldad@fogrefinery.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:57839 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab2FYS2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:28:54 -0400
Received: by mail-gh0-f174.google.com with SMTP id r11so3094761ghr.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:28:53 -0700 (PDT)
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handles the transmission of LLDPDUs.

Gets the TLV list, allocates the sk_buff according to the
space requirements of the TLV list, writes it to the sk_buff and
if all goes well, sends it to the wire.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/lldp/lldp_output.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)
 create mode 100644 net/lldp/lldp_output.c

diff --git a/net/lldp/lldp_output.c b/net/lldp/lldp_output.c
new file mode 100644
index 0000000..45e6293
--- /dev/null
+++ b/net/lldp/lldp_output.c
@@ -0,0 +1,67 @@
+/* LLDP		Link Layer Discovery Protocol impementation for Linux
+ *		IEEE Std 802.1ab
+ *
+ * Author:	Eldad Zack <eldad@fogrefinery.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/if_ether.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include "lldp.h"
+
+static u8 lldp_dst_address[] = LLDP_MULTICAST_ADDR;
+
+inline struct sk_buff *lldp_create(struct net_device *dev, bool is_shutdown)
+{
+	struct sk_buff *skb;
+	struct list_head head;
+	int head_len = LL_RESERVED_SPACE(dev);
+	int tail_len = dev->needed_tailroom;
+	int lldp_len;
+
+	INIT_LIST_HEAD(&head);
+
+	lldp_tlv_construct_list(&head, dev, is_shutdown);
+	lldp_len = lldp_tlv_list_len(&head);
+
+	skb = alloc_skb(head_len + lldp_len + tail_len, GFP_ATOMIC);
+	if (skb == NULL)
+		goto done;
+
+	skb_reserve(skb, head_len);
+	skb_reset_network_header(skb);
+
+	lldp_tlv_put_skb_list(skb, &head);
+
+	skb->dev = dev;
+	skb->protocol = htons(ETH_P_LLDP);
+
+	if (dev_hard_header(skb, dev, ETH_P_LLDP, lldp_dst_address,
+		dev->dev_addr, skb->len) < 0) {
+		kfree_skb(skb);
+		skb = NULL;
+	}
+
+done:
+	lldp_tlv_destruct_list(&head);
+	return skb;
+}
+
+void __lldp_send(struct net_device *dev, bool is_shutdown)
+{
+	struct sk_buff *skb;
+
+	skb = lldp_create(dev, is_shutdown);
+
+	if (skb == NULL)
+		return;
+
+	dev_queue_xmit(skb);
+}
-- 
1.7.10
