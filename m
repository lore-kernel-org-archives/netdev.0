From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 2/2] net/cxgb4: Don't retrieve stats during recovery
Date: Thu, 23 Jan 2014 12:27:35 +0800
Message-ID: <1390451256-11486-2-git-send-email-shangw@linux.vnet.ibm.com>
References: <1390451256-11486-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: dm@chelsio.com, ben@decadent.org.uk, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:32833 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815AbaAWE1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 23:27:46 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 22 Jan 2014 21:27:45 -0700
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A6F266E8041
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 23:27:38 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0N4RgJk8913282
	for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 04:27:42 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0N4RfF2031784
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 23:27:42 -0500
In-Reply-To: <1390451256-11486-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We possibly retrieve the adapter's statistics during EEH recovery
and that should be disallowed. Otherwise, it would possibly incur
replicate EEH error and EEH recovery is going to fail eventually.

The patch reuses statistics lock and checks net_device is attached
before going to retrieve statistics, so that the problem can be
avoided.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c8eafbf..139a704 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4288,7 +4288,15 @@ static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
 	struct port_info *p = netdev_priv(dev);
 	struct adapter *adapter = p->adapter;
 
+	/* Block retrieving statistics during EEH error
+	 * recovery. Otherwise, the recovery might fail
+	 * and the PCI device will be removed permanently
+	 */
 	spin_lock(&adapter->stats_lock);
+	if (!netif_device_present(dev)) {
+		spin_unlock(&adapter->stats_lock);
+		return ns;
+	}
 	t4_get_port_stats(adapter, p->tx_chan, &stats);
 	spin_unlock(&adapter->stats_lock);
 
@@ -5496,12 +5504,14 @@ static pci_ers_result_t eeh_err_detected(struct pci_dev *pdev,
 	rtnl_lock();
 	adap->flags &= ~FW_OK;
 	notify_ulds(adap, CXGB4_STATE_START_RECOVERY);
+	spin_lock(&adap->stats_lock);
 	for_each_port(adap, i) {
 		struct net_device *dev = adap->port[i];
 
 		netif_device_detach(dev);
 		netif_carrier_off(dev);
 	}
+	spin_unlock(&adap->stats_lock);
 	if (adap->flags & FULL_INIT_DONE)
 		cxgb_down(adap);
 	rtnl_unlock();
-- 
1.7.10.4
