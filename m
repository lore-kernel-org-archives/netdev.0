From: Andre Detsch <adetsch@br.ibm.com>
Subject: [PATCH] tg3: Fix INTx fallback when MSI fails
Date: Fri, 16 Apr 2010 10:15:11 -0300
Message-ID: <201004161015.12089.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:59146 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932148Ab0DPNPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Apr 2010 09:15:15 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3GD3L3F032329
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 09:03:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3GDFEom140516
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 09:15:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3GDFDwi002377
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 09:15:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3: Fix INTx fallback when MSI fails

MSI setup changes the value of some key attributes of struct tg3 *tp.
These attributes must be taken into account and restored before
we try to do a new request_irq for INTx fallback.

In powerpc, the original code was leading to an EINVAL return within
request_irq, because the driver was trying to use the disabled MSI
virtual irq number instead of tp->pdev->irq.

Signed-off-by: Andre Detsch <adetsch@br.ibm.com>

---
Tested on powerpc, but should be safe for other architectures as well.

Index: linux-2.6.34-rc4/drivers/net/tg3.c
===================================================================
--- linux-2.6.34-rc4.orig/drivers/net/tg3.c	2010-04-12 21:41:35.000000000 -0400
+++ linux-2.6.34-rc4/drivers/net/tg3.c	2010-04-15 20:37:41.000000000 -0400
@@ -8633,6 +8633,9 @@ static int tg3_test_msi(struct tg3 *tp)
 	pci_disable_msi(tp->pdev);

 	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
+	tp->irq_cnt = 1;
+	tp->napi[0].irq_vec = tp->pdev->irq;
+	tp->dev->real_num_tx_queues = 1;

 	err = tg3_request_irq(tp, 0);
 	if (err)
