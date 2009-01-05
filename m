From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/5] qlge: Fix sparse endian warning for inbound packet control block flags.
Date: Mon,  5 Jan 2009 14:27:29 -0800
Message-ID: <1231194452-10671-2-git-send-email-ron.mercer@qlogic.com>
References: <20090105222600.GA4232@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:42213 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbZAEW1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 17:27:36 -0500
In-Reply-To: <20090105222600.GA4232@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed flags element from __le32 to 3 reserved bytes and one byte of
flags.  Changed flags bit definitions to reflect byte width instead of
__le32 width.

Warnings:
drivers/net/qlge/qlge_main.c:1206:16: warning: restricted degrades to integer
drivers/net/qlge/qlge_main.c:1207:16: warning: restricted degrades to integer
drivers/net/qlge/qlge_main.c:1233:17: warning: restricted degrades to integer
drivers/net/qlge/qlge_main.c:1276:17: warning: restricted degrades to integer
drivers/net/qlge/qlge_main.c:1349:19: warning: restricted degrades to integer

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h     |    9 +++++----
 drivers/net/qlge/qlge_dbg.c |   13 +++++--------
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 97321bb..71cc487 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -979,10 +979,11 @@ struct ib_mac_iocb_rsp {
 
 	__le16 reserved1;
 	__le32 reserved2[6];
-	__le32 flags4;
-#define IB_MAC_IOCB_RSP_HV	0x20000000	/* */
-#define IB_MAC_IOCB_RSP_HS	0x40000000	/* */
-#define IB_MAC_IOCB_RSP_HL	0x80000000	/* */
+	u8 reserved3[3];
+	u8 flags4;
+#define IB_MAC_IOCB_RSP_HV	0x20
+#define IB_MAC_IOCB_RSP_HS	0x40
+#define IB_MAC_IOCB_RSP_HL	0x80
 	__le32 hdr_len;		/* */
 	__le32 hdr_addr_lo;	/* */
 	__le32 hdr_addr_hi;	/* */
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 47df304..3f5e02d 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -821,14 +821,11 @@ void ql_dump_ib_mac_rsp(struct ib_mac_iocb_rsp *ib_mac_rsp)
 		       le16_to_cpu(ib_mac_rsp->vlan_id));
 
 	printk(KERN_ERR PFX "flags4 = %s%s%s.\n",
-	       le32_to_cpu(ib_mac_rsp->
-			   flags4) & IB_MAC_IOCB_RSP_HV ? "HV " : "",
-	       le32_to_cpu(ib_mac_rsp->
-			   flags4) & IB_MAC_IOCB_RSP_HS ? "HS " : "",
-	       le32_to_cpu(ib_mac_rsp->
-			   flags4) & IB_MAC_IOCB_RSP_HL ? "HL " : "");
-
-	if (le32_to_cpu(ib_mac_rsp->flags4) & IB_MAC_IOCB_RSP_HV) {
+		ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV ? "HV " : "",
+		ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HS ? "HS " : "",
+		ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HL ? "HL " : "");
+
+	if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV) {
 		printk(KERN_ERR PFX "hdr length	= %d.\n",
 		       le32_to_cpu(ib_mac_rsp->hdr_len));
 		printk(KERN_ERR PFX "hdr addr_hi    = 0x%x.\n",
-- 
1.6.0

