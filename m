From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net v2] ibmveth: Disable tx queue while changing mtu
Date: Thu, 11 Aug 2016 15:01:19 -0500
Message-ID: <1470945679-29133-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jstancek@redhat.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:3837 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932273AbcHKUB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 16:01:28 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7BJxXTf137794
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 16:01:27 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24ru3052hy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 16:01:26 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Thu, 11 Aug 2016 14:01:26 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the device is running while the MTU is changed, ibmveth
is closed and the bounce buffer is freed. If a transmission
is sent before ibmveth can be reopened, ibmveth_start_xmit
tries to copy to the null bounce buffer, leading to a kernel
oops. The proposed solution disables the tx queue until
ibmveth is restarted.

The error recovery mechanism is revised to revert back to
the original MTU configuration in case there is a failure
when restarting the device.

Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v2: rewrote error checking mechanism to revert to original MTU 
configuration on failure in accordance with David Miller's comments
---
 drivers/net/ethernet/ibm/ibmveth.c | 43 +++++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index ebe6071..e735525 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1346,6 +1346,8 @@ static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	struct vio_dev *viodev = adapter->vdev;
 	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
+	int old_active_pools[IBMVETH_NUM_BUFF_POOLS];
+	int old_mtu = dev->mtu;
 	int i, rc;
 	int need_restart = 0;
 
@@ -1361,33 +1363,44 @@ static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 
 	/* Deactivate all the buffer pools so that the next loop can activate
 	   only the buffer pools necessary to hold the new MTU */
-	if (netif_running(adapter->netdev)) {
+	if (netif_running(dev)) {
+		/* save old active pool settings */
+		for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
+			old_active_pools[i] = adapter->rx_buff_pool[i].active;
+		netif_tx_disable(dev);
 		need_restart = 1;
 		adapter->pool_config = 1;
-		ibmveth_close(adapter->netdev);
+		ibmveth_close(dev);
 		adapter->pool_config = 0;
 	}
 
 	/* Look for an active buffer pool that can hold the new MTU */
 	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		adapter->rx_buff_pool[i].active = 1;
+		if (new_mtu_oh <= adapter->rx_buff_pool[i].buff_size)
+			break;
+	}
 
-		if (new_mtu_oh <= adapter->rx_buff_pool[i].buff_size) {
-			dev->mtu = new_mtu;
-			vio_cmo_set_dev_desired(viodev,
-						ibmveth_get_desired_dma
-						(viodev));
-			if (need_restart) {
-				return ibmveth_open(adapter->netdev);
-			}
-			return 0;
-		}
+	dev->mtu = new_mtu;
+	vio_cmo_set_dev_desired(viodev, ibmveth_get_desired_dma(viodev));
+
+	if (need_restart) {
+		rc = ibmveth_open(dev);
+		if (rc)
+			goto revert_mtu;
 	}
 
-	if (need_restart && (rc = ibmveth_open(adapter->netdev)))
-		return rc;
+	return 0;
 
-	return -EINVAL;
+revert_mtu:
+	/* revert active buffers, mtu, and desired resources */
+	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++)
+		adapter->rx_buff_pool[i].active = old_active_pools[i];
+	dev->mtu = old_mtu;
+	vio_cmo_set_dev_desired(viodev, ibmveth_get_desired_dma(viodev));
+	/* attempt to restart device with original configuration */
+	rc = ibmveth_open(dev);
+	return rc ? rc : -EINVAL;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.8.3.1
