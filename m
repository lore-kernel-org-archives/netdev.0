From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] bnx2: Fix panic in bnx2_poll_work().
Date: Wed, 6 May 2009 10:23:56 -0700
Message-ID: <1241630636-21999-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pmjdebruijn@pcode.nl,
	hnoefer@pironet-ndh.com, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4333 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692AbZEFSPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 14:15:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add barrier() to bnx2_get_hw_{tx|rx}_cons() to fix this issue:

http://bugzilla.kernel.org/show_bug.cgi?id=12698

This issue was reported by multiple i386 users.  Without barrier(),
the compiled code looks like the following where %eax contains the
address of the tx_cons or rx_cons in the DMA status block.  The
status block contents can change between the cmpb and the movzwl
instruction.  The driver would crash if the value was not 0xff during
the cmpb instruction, but changed to 0xff during the movzwl
instruction.

6828:	80 38 ff             	cmpb   $0xff,(%eax)
682b:	0f b7 10             	movzwl (%eax),%edx

With the added barrier(), the compiled code now looks correct:

683d:	0f b7 10             	movzwl (%eax),%edx
6840:	0f b6 c2             	movzbl %dl,%eax
6843:	3d ff 00 00 00       	cmp    $0xff,%eax

Thanks to Pascal de Bruijn <pmjdebruijn@pcode.nl> for reporting the
problem and Holger Noefer <hnoefer@pironet-ndh.com> for patiently
testing test patches for us.

Also updated version to 2.0.1.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d478391..b0cb29d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"2.0.0"
-#define DRV_MODULE_RELDATE	"April 2, 2009"
+#define DRV_MODULE_VERSION	"2.0.1"
+#define DRV_MODULE_RELDATE	"May 6, 2009"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-4.6.16.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-4.6.16.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-4.6.17.fw"
@@ -2600,6 +2600,7 @@ bnx2_get_hw_tx_cons(struct bnx2_napi *bnapi)
 	/* Tell compiler that status block fields can change. */
 	barrier();
 	cons = *bnapi->hw_tx_cons_ptr;
+	barrier();
 	if (unlikely((cons & MAX_TX_DESC_CNT) == MAX_TX_DESC_CNT))
 		cons++;
 	return cons;
@@ -2879,6 +2880,7 @@ bnx2_get_hw_rx_cons(struct bnx2_napi *bnapi)
 	/* Tell compiler that status block fields can change. */
 	barrier();
 	cons = *bnapi->hw_rx_cons_ptr;
+	barrier();
 	if (unlikely((cons & MAX_RX_DESC_CNT) == MAX_RX_DESC_CNT))
 		cons++;
 	return cons;
-- 
1.5.6.GIT


