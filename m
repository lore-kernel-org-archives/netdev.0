From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net V1 2/2] net/bonding: correctly proxy slave neigh param setup ndo function
Date: Wed, 04 Apr 2012 10:00:21 -0700
Message-ID: <17509.1333558821@death.nxdomain>
References: <1333529780-28421-1-git-send-email-ogerlitz@mellanox.com> <1333529780-28421-3-git-send-email-ogerlitz@mellanox.com>
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:35576 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756893Ab2DDRGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 13:06:30 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 4 Apr 2012 11:06:29 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 6AB2BC90052
	for <netdev@vger.kernel.org>; Wed,  4 Apr 2012 13:06:00 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q34H5tvV141292
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2012 13:05:57 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q34H5sla022395
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2012 14:05:54 -0300
In-reply-to: <1333529780-28421-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@mellanox.com> wrote:

>From: Shlomo Pongratz <shlomop@mellanox.com>
>
>The current implemenation was buggy for slaves who use ndo_neigh_setup,
>since the networking stack invokes the bonding device ndo entry (from
>neigh_params_alloc) before any devices are enslaved, and the bonding
>driver can't further delegate the call at that point in time. As a
>result when bonding IPoIB devices, the neigh_cleanup hasn't been called.
>
>Fix that by deferring the actual call into the slave ndo_neigh_setup
>from the time the bonding neigh_setup is called.
>
>Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_main.c |   51 ++++++++++++++++++++++++++++++++------
> 1 files changed, 43 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index d38f635..c8dc1a5 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3705,17 +3705,52 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
> 	read_unlock(&bond->lock);
> }
>
>-static int bond_neigh_setup(struct net_device *dev, struct neigh_parms *parms)
>+static int bond_neigh_init(struct neighbour *n)
> {
>-	struct bonding *bond = netdev_priv(dev);
>+	struct bonding *bond = netdev_priv(n->dev);
> 	struct slave *slave = bond->first_slave;
>+	const struct net_device_ops *slave_ops;
>+	struct neigh_parms parms;
>+	int ret;
>+
>+	if (!slave)
>+		return 0;
>+
>+	slave_ops = slave->dev->netdev_ops;
>+
>+	if (!slave_ops->ndo_neigh_setup)
>+		return 0;
>+
>+	parms.neigh_setup = NULL;
>+	parms.neigh_cleanup = NULL;
>+	ret = slave_ops->ndo_neigh_setup(slave->dev, &parms);
>+	if (ret)
>+		return ret;
>+
>+	/*
>+	 * Assign slave's neigh_cleanup to neighbour in case cleanup is called
>+	 * after the last slave has been detached.  Assumes that all slaves
>+	 * utilize the same neigh_cleanup (true at this writing as only user
>+	 * is ipoib).
>+	 */
>+	n->parms->neigh_cleanup = parms.neigh_cleanup;
>+
>+	if (!parms.neigh_setup)
>+		return 0;
>+
>+	return parms.neigh_setup(n);
>+}
>+
>+/*
>+ * The bonding ndo_neigh_setup is called at init time beofre any
>+ * slave exists. So we must declare proxy setup function which will
>+ * be used at run time to resolve the actual slave neigh param setup.
>+ */
>+static int bond_neigh_setup(struct net_device *dev,
>+			    struct neigh_parms *parms)
>+{
>+	parms->neigh_setup   = bond_neigh_init;
>
>-	if (slave) {
>-		const struct net_device_ops *slave_ops
>-			= slave->dev->netdev_ops;
>-		if (slave_ops->ndo_neigh_setup)
>-			return slave_ops->ndo_neigh_setup(slave->dev, parms);
>-	}
> 	return 0;
> }
>
>-- 
>1.7.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
