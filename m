From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 2/2] ibmveth: Automatically enable larger rx buffer pools for larger mtu
Date: Wed, 16 May 2007 14:47:19 -0500
Message-ID: <200705161947.l4GJlJBM003022@d01av03.pok.ibm.com>
References: <1179344829825-patch-mail.ibm.com>
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:49108 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757264AbXEPTrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 15:47:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GJlKVO014573
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 15:47:20 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GJlKbw546692
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 15:47:20 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GJlKZe003054
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 15:47:20 -0400
In-Reply-To: <1179344829825-patch-mail.ibm.com>
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
