From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 6/9] atl1: add value to check ability of reenabling IRQs
Date: Fri, 13 Apr 2012 20:09:51 +0400
Message-ID: <1334333394-38404-7-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54718 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately it is not clear from code is usage of
IMR register possible or not. So, to prevent possible
side-effects of reading this register i prefer store
interrupts enable flag separately.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.h |    6 ++++++
 drivers/net/ethernet/atheros/atlx/atlx.c |    2 ++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.h b/drivers/net/ethernet/atheros/atlx/atl1.h
index b55084c..5209875 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.h
+++ b/drivers/net/ethernet/atheros/atlx/atl1.h
@@ -782,6 +782,12 @@ struct atl1_adapter {
 	u16 ict;		/* interrupt clear timer (2us resolution */
 	struct mii_if_info mii;	/* MII interface info */
 
+	/*
+	 * Use this value to check is napi handler allowed to
+	 * enable ints or not
+	 */
+	bool int_enabled;
+
 	u32 bd_number;		/* board number */
 	bool pci_using_64;
 	struct atl1_hw hw;
diff --git a/drivers/net/ethernet/atheros/atlx/atlx.c b/drivers/net/ethernet/atheros/atlx/atlx.c
index 6c4a706..b4f3aa4 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -169,6 +169,7 @@ static inline void atlx_imr_set(struct atlx_adapter *adapter,
 static void atlx_irq_enable(struct atlx_adapter *adapter)
 {
 	atlx_imr_set(adapter, IMR_NORMAL_MASK);
+	adapter->int_enabled = true;
 }
 
 /*
@@ -177,6 +178,7 @@ static void atlx_irq_enable(struct atlx_adapter *adapter)
  */
 static void atlx_irq_disable(struct atlx_adapter *adapter)
 {
+	adapter->int_enabled = false;
 	atlx_imr_set(adapter, 0);
 	synchronize_irq(adapter->pdev->irq);
 }
-- 
1.7.1
