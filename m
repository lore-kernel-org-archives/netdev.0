From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Avoid rtnl_unlock without rtnl_lock
Date: Sat, 13 Mar 2010 08:11:47 +0900
Message-ID: <4B9ACA33.5060104@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35432 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932279Ab0CLXST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 18:18:19 -0500
Received: by pvg7 with SMTP id 7so334054pvg.19
        for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 15:18:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure we always call rtnl_lock before going down the
error path in sky2_resume, which unlocks the rtnl lock.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 653bdd7..d8ec4c1 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4863,6 +4863,7 @@ static int sky2_resume(struct pci_dev *pdev)
 	if (!hw)
 		return 0;
 
+	rtnl_lock();
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -4884,7 +4885,6 @@ static int sky2_resume(struct pci_dev *pdev)
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
 
-	rtnl_lock();
 	for (i = 0; i < hw->ports; i++) {
 		err = sky2_reattach(hw->dev[i]);
 		if (err)
-- 
1.5.6.5

