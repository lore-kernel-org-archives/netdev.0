From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [PATCH 1/2] atl1: fix resume
Date: Thu, 16 Sep 2010 21:29:46 +0200
Message-ID: <1284665387-10289-2-git-send-email-kronos.it@gmail.com>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	atl1-devel@lists.sourceforge.net, jcliburn@gmail.com,
	chris.snook@gmail.com, jie.yang@atheros.com, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54767 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755962Ab0IPTak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 15:30:40 -0400
Received: by mail-wy0-f174.google.com with SMTP id 22so1697062wyf.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 12:30:39 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
In-Reply-To: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
References: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adapter->cmb.cmb is initialized when the device is opened and freed when
it's closed. Accessing it unconditionally during resume results either
in a crash (NULL pointer dereference, when the interface has not been
opened yet) or data corruption (when the interface has been used and
brought down adapter->cmb.cmb points to a deallocated memory area).

Cc: stable@kernel.org
---
 drivers/net/atlx/atl1.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 63b9ba0..bbd6e30 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2847,10 +2847,11 @@ static int atl1_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	atl1_reset_hw(&adapter->hw);
-	adapter->cmb.cmb->int_stats = 0;
 
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
+		adapter->cmb.cmb->int_stats = 0;
 		atl1_up(adapter);
+	}
 	netif_device_attach(netdev);
 
 	return 0;
-- 
1.7.1

