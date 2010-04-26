From: Andre Detsch <adetsch@br.ibm.com>
Subject: [PATCH v2] tg3: Fix INTx fallback when MSI fails
Date: Mon, 26 Apr 2010 14:27:07 -0300
Message-ID: <201004261427.07099.adetsch@br.ibm.com>
References: <201004161015.12089.adetsch@br.ibm.com> <20100421.161751.94080129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:52649 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752098Ab0DZR1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 13:27:12 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3QHBhYA018126
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 13:11:43 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3QHR82p266256
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 13:27:10 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3QHR8RP009640
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 13:27:08 -0400
In-Reply-To: <20100421.161751.94080129.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3: Fix INTx fallback when MSI fails

MSI setup changes the value of irq_vec in struct tg3 *tp.
This attribute must be taken into account and restored before
we try to do a new request_irq for INTx fallback.

In powerpc, the original code was leading to an EINVAL return within
request_irq, because the driver was trying to use the disabled MSI
virtual irq number instead of tp->pdev->irq.

Signed-off-by: Andre Detsch <adetsch@br.ibm.com>

---
Tested on powerpc, but should be safe for other architectures as well.
v2: removed unnecessary changes

Index: linux-2.6.34-rc5/drivers/net/tg3.c
===================================================================
--- linux-2.6.34-rc5.orig/drivers/net/tg3.c	2010-04-19 20:29:56.000000000 -0300
+++ linux-2.6.34-rc5/drivers/net/tg3.c	2010-04-26 14:10:42.000000000 -0300
@@ -8633,6 +8633,7 @@ static int tg3_test_msi(struct tg3 *tp)
 	pci_disable_msi(tp->pdev);
 
 	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
+	tp->napi[0].irq_vec = tp->pdev->irq;
 
 	err = tg3_request_irq(tp, 0);
 	if (err)
