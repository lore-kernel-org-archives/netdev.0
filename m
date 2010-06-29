From: leitao@linux.vnet.ibm.com
Subject: [PATCH -next] qlge: fix a eeh handler to not add a pending timer
Date: Tue, 29 Jun 2010 12:24:38 -0300
Message-ID: <1277825078-2992-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:40669 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756492Ab0F2PYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 11:24:43 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id o5TFPjLx032410
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 12:25:45 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5TFTLpM1024034
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 12:29:22 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5TFORmn020666
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 12:24:27 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some ocasions the function qlge_io_resume() tries to add a
pending timer, which causes the system to hit the BUG() on
add_timer() function.

This patch only add a new timer if the timer is not pending, if so,
it just reload it.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/qlge/qlge_main.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fa4b24c..7b10521 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4808,8 +4808,14 @@ static void qlge_io_resume(struct pci_dev *pdev)
 		netif_err(qdev, ifup, qdev->ndev,
 			  "Device was not running prior to EEH.\n");
 	}
-	qdev->timer.expires = jiffies + (5*HZ);
-	add_timer(&qdev->timer);
+
+	if (timer_pending(&qdev->timer))
+		mod_timer(&qdev->timer, jiffies + (5*HZ));
+	else{
+		qdev->timer.expires = jiffies + (5*HZ);
+		add_timer(&qdev->timer);
+	}
+
 	netif_device_attach(ndev);
 }
 
-- 
1.6.5.2

