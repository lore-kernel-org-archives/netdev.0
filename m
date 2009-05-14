From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 6/7] net: Fix ipoib rtnl_lock sysfs deadlock.
Date: Wed, 13 May 2009 20:01:51 -0700
Message-ID: <m163g4qteo.fsf@fess.ebiederm.org>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53251 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761319AbZENDBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 23:01:53 -0400
In-Reply-To: <m13ab8s8cr.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 13 May 2009 19\:53\:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Network device sysfs files that grab the rtnl_lock unconditionally
will deadlock if accessed when the network device is being
unregistered.  So use trylock and syscall_restart to avoid this
deadlock.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_cm.c   |    6 ++++--
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 47d588b..4248c31 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -1455,13 +1455,15 @@ static ssize_t set_mode(struct device *d, struct device_attribute *attr,
 	struct net_device *dev = to_net_dev(d);
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	/* flush paths if we switch modes so that connections are restarted */
 	if (IPOIB_CM_SUPPORTED(dev->dev_addr) && !strcmp(buf, "connected\n")) {
 		set_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
 		ipoib_warn(priv, "enabling connected mode "
 			   "will cause multicast packet drops\n");
 
-		rtnl_lock();
 		dev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO);
 		rtnl_unlock();
 		priv->tx_wr.send_flags &= ~IB_SEND_IP_CSUM;
@@ -1473,7 +1475,6 @@ static ssize_t set_mode(struct device *d, struct device_attribute *attr,
 	if (!strcmp(buf, "datagram\n")) {
 		clear_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
 
-		rtnl_lock();
 		if (test_bit(IPOIB_FLAG_CSUM, &priv->flags)) {
 			dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 			if (priv->hca_caps & IB_DEVICE_UD_TSO)
@@ -1485,6 +1486,7 @@ static ssize_t set_mode(struct device *d, struct device_attribute *attr,
 
 		return count;
 	}
+	rtnl_unlock();
 
 	return -EINVAL;
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index 4c57f32..e3bf00d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -61,7 +61,8 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 
 	ppriv = netdev_priv(pdev);
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	mutex_lock(&ppriv->vlan_mutex);
 
 	/*
@@ -167,7 +168,8 @@ int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
 
 	ppriv = netdev_priv(pdev);
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	mutex_lock(&ppriv->vlan_mutex);
 	list_for_each_entry_safe(priv, tpriv, &ppriv->child_intfs, list) {
 		if (priv->pkey == pkey) {
-- 
1.6.0.6

