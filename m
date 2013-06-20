From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 2/2] netdev: octeon_mgmt: Fix structure layout for little-endian.
Date: Wed, 19 Jun 2013 17:40:20 -0700
Message-ID: <1371688820-4585-3-git-send-email-ddaney.cavm@gmail.com>
References: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:63606 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935427Ab3FTAkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 20:40:32 -0400
Received: by mail-pd0-f170.google.com with SMTP id x11so5623275pdj.29
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 17:40:31 -0700 (PDT)
In-Reply-To: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

The C ABI reverses the bitfield fill order when compiled as
little-endian.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 1ef4148..622aa75 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -46,17 +46,25 @@
 union mgmt_port_ring_entry {
 	u64 d64;
 	struct {
-		u64    reserved_62_63:2;
+#define RING_ENTRY_CODE_DONE 0xf
+#define RING_ENTRY_CODE_MORE 0x10
+#ifdef __BIG_ENDIAN_BITFIELD
+		u64 reserved_62_63:2;
 		/* Length of the buffer/packet in bytes */
-		u64    len:14;
+		u64 len:14;
 		/* For TX, signals that the packet should be timestamped */
-		u64    tstamp:1;
+		u64 tstamp:1;
 		/* The RX error code */
-		u64    code:7;
-#define RING_ENTRY_CODE_DONE 0xf
-#define RING_ENTRY_CODE_MORE 0x10
+		u64 code:7;
 		/* Physical address of the buffer */
-		u64    addr:40;
+		u64 addr:40;
+#else
+		u64 addr:40;
+		u64 code:7;
+		u64 tstamp:1;
+		u64 len:14;
+		u64 reserved_62_63:2;
+#endif
 	} s;
 };
 
-- 
1.7.11.7
