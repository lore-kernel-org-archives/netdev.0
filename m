From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: Fix ethtool register test code
Date: Thu, 04 Oct 2007 15:00:08 -0700
Message-ID: <20071004220008.3344.59536.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19316 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759320AbXJDWFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 18:05:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A merge/cleanup code accidentally dropped 8254x code in and removed
8257x code here. Undo this mistake and use the pci-e relevant register
test similar as to what is in e1000.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 3423f33..2e8218f 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -784,10 +784,16 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	REG_SET_AND_CHECK(E1000_RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(E1000_TCTL, 0xFFFFFFFF, 0x00000000);
 
-	REG_SET_AND_CHECK(E1000_RCTL, 0xFFFFFFFF, 0x01FFFFFF);
-	REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFF000, 0xFFFFFFFF);
-	REG_PATTERN_TEST(E1000_TXCW, 0x0000FFFF, 0x0000FFFF);
-	REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFF000, 0xFFFFFFFF);
+	REG_SET_AND_CHECK(E1000_RCTL, before, 0xFFFFFFFF);
+	REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
+	if ((mac->type != e1000_ich8lan) &&
+	    (mac->type != e1000_ich9lan))
+		REG_PATTERN_TEST(E1000_TXCW, 0xC000FFFF, 0x0000FFFF);
+	REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
+	REG_PATTERN_TEST(E1000_TIDV, 0x0000FFFF, 0x0000FFFF);
+	for (i = 0; i < mac->rar_entry_count; i++)
+		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1),
+				       0x8003FFFF, 0xFFFFFFFF);
 
 	for (i = 0; i < mac->mta_reg_count; i++)
 		REG_PATTERN_TEST_ARRAY(E1000_MTA, i, 0xFFFFFFFF, 0xFFFFFFFF);
