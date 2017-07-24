From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Check for transport event on driver resume
Date: Mon, 24 Jul 2017 13:26:06 -0500
Message-ID: <9202073a-a9bb-5aa3-c6ea-3b16e35084db@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:39400 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753515AbdGXS0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 14:26:11 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6OIQ0n0072130
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 14:26:10 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2bwp0vgccg-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 14:26:10 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Mon, 24 Jul 2017 14:26:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On resume, the ibmvnic driver will fail to resume normal operation.
The main crq gets closed on suspend by the vnic server and doesn't get
reopened again as the interrupt for the transport event that would reset
the main crq comes in after the driver has been suspended.

This patch resolves the issue by removing the calls to kick the receive
interrupts handlers and instead directly invoking the main crq interrupt
handler. This will ensure that we see the transport event necessary to
properly resume the driver.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index a3e694679635..9d8af464dc44 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3851,10 +3851,7 @@ static int ibmvnic_resume(struct device *dev)
 	if (adapter->state != VNIC_OPEN)
 		return 0;

-	/* kick the interrupt handlers just in case we lost an interrupt */
-	for (i = 0; i < adapter->req_rx_queues; i++)
-		ibmvnic_interrupt_rx(adapter->rx_scrq[i]->irq,
-				     adapter->rx_scrq[i]);
+	tasklet_schedule(&adapter->tasklet);

 	return 0;
 }
