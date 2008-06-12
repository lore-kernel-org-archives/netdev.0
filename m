From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH 16/19] ibmveth: Automatically enable larger rx buffer pools
	for larger mtu
Date: Thu, 12 Jun 2008 17:22:49 -0500
Message-ID: <20080612222249.GX30916@linux.vnet.ibm.com>
References: <20080612215312.GF30916@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Brian King <brking@linux.vnet.ibm.com>,
	Santiago Leon <santil@us.ibm.com>,
	Nathan Fontenot <nfont@austin.ibm.com>,
	David Darrington <ddarring@linux.vnet.ibm.com>
To: paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:49135 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552AbYFLWYW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 18:24:22 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5CMOK80026738
	for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 18:24:20 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5CMOKJT176486
	for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 16:24:20 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5CMOJvd009081
	for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 16:24:20 -0600
Content-Disposition: inline
In-Reply-To: <20080612215312.GF30916@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santiago Leon <santil@us.ibm.com>

Activates larger rx buffer pools when the MTU is changed to a larger
value.  This patch de-activates the large rx buffer pools when the MTU
changes to a smaller value.

Signed-off-by: Santiago Leon <santil@us.ibm.com>

---

 drivers/net/ibmveth.c |   20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

Index: b/drivers/net/ibmveth.c
===================================================================
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1054,7 +1054,6 @@ static int ibmveth_change_mtu(struct net
 {
 	struct ibmveth_adapter *adapter = dev->priv;
 	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
-	int reinit = 0;
 	int i, rc;
 
 	if (new_mtu < IBMVETH_MAX_MTU)
@@ -1067,15 +1066,21 @@ static int ibmveth_change_mtu(struct net
 	if (i == IbmVethNumBufferPools)
 		return -EINVAL;
 
+	/* Deactivate all the buffer pools so that the next loop can activate
+	   only the buffer pools necessary to hold the new MTU */
+	for(i = 0; i<IbmVethNumBufferPools; i++)
+		if (adapter->rx_buff_pool[i].active) {
+			ibmveth_free_buffer_pool(adapter,
+						 &adapter->rx_buff_pool[i]);
+			adapter->rx_buff_pool[i].active = 0;
+		}
+
 	/* Look for an active buffer pool that can hold the new MTU */
 	for(i = 0; i<IbmVethNumBufferPools; i++) {
-		if (!adapter->rx_buff_pool[i].active) {
-			adapter->rx_buff_pool[i].active = 1;
-			reinit = 1;
-		}
+		adapter->rx_buff_pool[i].active = 1;
 
 		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size) {
-			if (reinit && netif_running(adapter->netdev)) {
+			if (netif_running(adapter->netdev)) {
 				adapter->pool_config = 1;
 				ibmveth_close(adapter->netdev);
 				adapter->pool_config = 0;
@@ -1402,14 +1407,15 @@ const char * buf, size_t count)
 				return -EPERM;
 			}
 
-			pool->active = 0;
 			if (netif_running(netdev)) {
 				adapter->pool_config = 1;
 				ibmveth_close(netdev);
+				pool->active = 0;
 				adapter->pool_config = 0;
 				if ((rc = ibmveth_open(netdev)))
 					return rc;
 			}
+			pool->active = 0;
 		}
 	} else if (attr == &veth_num_attr) {
 		if (value <= 0 || value > IBMVETH_MAX_POOL_COUNT)
