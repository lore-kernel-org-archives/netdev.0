From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 17/18] netvsc: simplify get next send section
Date: Tue, 24 Jan 2017 13:06:14 -0800
Message-ID: <20170124210615.18628-18-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33816 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pf0-f179.google.com with SMTP id e4so52411857pfg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:35 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kernel for_each_clear_bit macro to simplify finding next
available send section.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 28 ++++++++--------------------
 1 file changed, 8 insertions(+), 20 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index c70c4ac77b74..5cfdb1a1b4c1 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -680,27 +680,15 @@ static void netvsc_send_completion(struct netvsc_device *net_device,
 
 static u32 netvsc_get_next_send_section(struct netvsc_device *net_device)
 {
-	unsigned long index;
-	u32 max_words = net_device->map_words;
-	unsigned long *map_addr = (unsigned long *)net_device->send_section_map;
-	u32 section_cnt = net_device->send_section_cnt;
-	int ret_val = NETVSC_INVALID_INDEX;
-	int i;
-	int prev_val;
-
-	for (i = 0; i < max_words; i++) {
-		if (!~(map_addr[i]))
-			continue;
-		index = ffz(map_addr[i]);
-		prev_val = sync_test_and_set_bit(index, &map_addr[i]);
-		if (prev_val)
-			continue;
-		if ((index + (i * BITS_PER_LONG)) >= section_cnt)
-			break;
-		ret_val = (index + (i * BITS_PER_LONG));
-		break;
+	unsigned long *map_addr = net_device->send_section_map;
+	unsigned int i;
+
+	for_each_clear_bit(i, map_addr, net_device->map_words) {
+		if (sync_test_and_set_bit(i, map_addr) == 0)
+			return i;
 	}
-	return ret_val;
+
+	return NETVSC_INVALID_INDEX;
 }
 
 static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
-- 
2.11.0
