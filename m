From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 2/2] net/cxgb4: Don't retrieve stats during recovery
Date: Mon, 20 Jan 2014 11:05:44 +0800
Message-ID: <1390187144-15495-2-git-send-email-shangw@linux.vnet.ibm.com>
References: <1390187144-15495-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: dm@chelsio.com, Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:46940 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbaATDFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:05:54 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 19 Jan 2014 20:05:53 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C23D61FF001E
	for <netdev@vger.kernel.org>; Sun, 19 Jan 2014 20:05:19 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0K13QAN10355170
	for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 02:03:26 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0K35oVQ003281
	for <netdev@vger.kernel.org>; Sun, 19 Jan 2014 20:05:51 -0700
In-Reply-To: <1390187144-15495-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We possiblly retrieve the adapter's statistics during EEH recovery
and that should be disallowed. Otherwise, it would possibly incur
replicate EEH error and EEH recovery is going to fail eventually.
The patch checks if the PCI device is off-line before statistic
retrieval.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c8eafbf..b0e72fb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4288,6 +4288,17 @@ static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
 	struct port_info *p = netdev_priv(dev);
 	struct adapter *adapter = p->adapter;
 
+	/*
+	 * We possibly retrieve the statistics while the PCI
+	 * device is off-line. That would cause the recovery
+	 * on off-lined PCI device going to fail. So it's
+	 * reasonable to block it during the recovery period.
+	 */
+	if (pci_channel_offline(adapter->pdev)) {
+		memset(ns, 0, sizeof(*ns));
+		return ns;
+	}
+
 	spin_lock(&adapter->stats_lock);
 	t4_get_port_stats(adapter, p->tx_chan, &stats);
 	spin_unlock(&adapter->stats_lock);
-- 
1.7.10.4
