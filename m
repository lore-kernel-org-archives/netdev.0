From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 2/2] net/bonding: correctly proxy slave neigh param setup ndo function
Date: Tue, 03 Apr 2012 15:53:46 -0700
Message-ID: <10209.1333493626@death.nxdomain>
References: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com> <1333383430-17456-3-git-send-email-ogerlitz@mellanox.com>
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:51765 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737Ab2DCWyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:54:15 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 3 Apr 2012 16:54:14 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0BB023E40036
	for <netdev@vger.kernel.org>; Tue,  3 Apr 2012 16:53:49 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q33MrmMZ146574
	for <netdev@vger.kernel.org>; Tue, 3 Apr 2012 16:53:49 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q33Mrl1Y031764
	for <netdev@vger.kernel.org>; Tue, 3 Apr 2012 16:53:48 -0600
In-reply-to: <1333383430-17456-3-git-send-email-ogerlitz@mellanox.com>
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
>---
> drivers/net/bonding/bond_main.c |   51 ++++++++++++++++++++++++++++++++------
> 1 files changed, 43 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index b0a278d..2eed155 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3707,17 +3707,52 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
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
>+	 * must bind here to the slave clenaup. Since when last slave is removed
>+	 * there will be no slave device to dereference in a bonding
>+	 * neigh_cleanup function that we have could add.
>+	 */
>+	n->parms->neigh_cleanup = parms.neigh_cleanup;

	I'd write this comment as:

	/* Assign slave's neigh_cleanup to neighbour in case cleanup is
	 * called after bond has been destroyed.  Assumes that all slaves
	 * utilize the same neigh_cleanup (true at this writing as only user
	 * is ipoib).
	 */

	I.e., this logic works only because there cannot currently be a
situation wherein two slaves have different neigh_cleanup functions
(including one slave with a neigh_cleanup, and another without).

>+	/* Does slave implement neigh_setup ? */
>+	if (!parms.neigh_setup)
>+		return 0;

	I don't think this comment is necessary.

	-J

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

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
