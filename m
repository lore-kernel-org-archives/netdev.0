From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/11] ibmvnic: Halt TX and report carrier off on
 H_CLOSED return code
Date: Fri, 26 May 2017 10:30:42 -0400
Message-ID: <20170526143042.63648.73253.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:37939 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1030490AbdEZOm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:28 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEdnY8005715
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:27 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2ap8vrgetx-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:27 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:26 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

This patch disables transmissions and reports carrier off if xmit
function returns that the hardware TX queue is closed. The driver can
then await a signal from firmware to determine the correct reset method.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index def867a..1c3f1ed 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1111,8 +1111,14 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		dev_kfree_skb_any(skb);
 		tx_buff->skb = NULL;
 
-		if (lpar_rc == H_CLOSED)
-			netif_stop_subqueue(netdev, queue_num);
+		if (lpar_rc == H_CLOSED) {
+			/* Disable TX and report carrier off if queue is closed.
+			 * Firmware guarantees that a signal will be sent to the
+			 * driver, triggering a reset or some other action.
+			 */
+			netif_tx_stop_all_queues(netdev);
+			netif_carrier_off(netdev);
+		}
 
 		tx_send_failed++;
 		tx_dropped++;
