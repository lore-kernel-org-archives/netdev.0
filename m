From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 2/2] ibmveth: Automatically enable larger rx buffer pools for larger mtu
Date: Fri, 08 Jun 2007 14:05:17 -0500
Message-ID: <200706081905.l58J5Lka021044@d01av04.pok.ibm.com>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:60538 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923AbXFHTFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 15:05:22 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l58J5MX2031976
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:05:22 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l58J5MMK523488
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:05:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l58J5L2R021060
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 15:05:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently, ibmveth maintains several rx buffer pools, which can
be modified through sysfs. By default, pools are not allocated by
default such that jumbo frames cannot be supported without first
activating larger rx buffer pools. This results in failures when attempting
to change the mtu. This patch makes ibmveth automatically allocate
these larger buffer pools when the mtu is changed.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |   27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

diff -puN drivers/net/ibmveth.c~ibmveth_large_mtu drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_large_mtu	2007-05-16 10:47:54.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-05-16 10:47:54.000000000 -0500
@@ -915,17 +915,36 @@ static int ibmveth_change_mtu(struct net
 {
 	struct ibmveth_adapter *adapter = dev->priv;
 	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
-	int i;
+	int reinit = 0;
+	int i, rc;
 
 	if (new_mtu < IBMVETH_MAX_MTU)
 		return -EINVAL;
 
+	for (i = 0; i < IbmVethNumBufferPools; i++)
+		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size)
+			break;
+
+	if (i == IbmVethNumBufferPools)
+		return -EINVAL;
+
 	/* Look for an active buffer pool that can hold the new MTU */
 	for(i = 0; i<IbmVethNumBufferPools; i++) {
-		if (!adapter->rx_buff_pool[i].active)
-			continue;
+		if (!adapter->rx_buff_pool[i].active) {
+			adapter->rx_buff_pool[i].active = 1;
+			reinit = 1;
+		}
+
 		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size) {
-			dev->mtu = new_mtu;
+			if (reinit && netif_running(adapter->netdev)) {
+				adapter->pool_config = 1;
+				ibmveth_close(adapter->netdev);
+				adapter->pool_config = 0;
+				dev->mtu = new_mtu;
+				if ((rc = ibmveth_open(adapter->netdev)))
+					return rc;
+			} else
+				dev->mtu = new_mtu;
 			return 0;
 		}
 	}
_
