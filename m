From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 1/2] net/bonding: emit address change event in more places
Date: Tue, 03 Apr 2012 15:28:26 -0700
Message-ID: <9859.1333492106@death.nxdomain>
References: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com> <1333383430-17456-2-git-send-email-ogerlitz@mellanox.com>
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:34761 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502Ab2DCW2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 18:28:32 -0400
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 3 Apr 2012 18:28:31 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 16CF838C8052
	for <netdev@vger.kernel.org>; Tue,  3 Apr 2012 18:28:28 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q33MSSTD267066
	for <netdev@vger.kernel.org>; Tue, 3 Apr 2012 18:28:28 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q33MSRFg025564
	for <netdev@vger.kernel.org>; Tue, 3 Apr 2012 19:28:28 -0300
In-reply-to: <1333383430-17456-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@mellanox.com> wrote:

>From: Shlomo Pongratz <shlomop@mellanox.com>
>
>commit 7d26bb103c4 "bonding: emit event when bonding changes MAC" didn't
>take care to emit the NETDEV_CHANGEADDR event in other places where bonding
>actually changes the mac address (to all zeroes), in bond_release, and
>bond_release_all. As a result the neighbours aren't deleted by the core
>networking code (which does so upon getting that event).

>Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>

	Is the bond_release_all notifier call actually necessary in your
testing?

	The bond itself is destroyed immediately after bond_release_all
returns, so I would expect the neighbours to be deleted then.  For that
path we probably don't need to zero the mac at all (or compute features,
for that matter).

	-J


>---
> drivers/net/bonding/bond_main.c |    5 +++++
> 1 files changed, 5 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index a20b585..b0a278d 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2035,6 +2035,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 	write_unlock_bh(&bond->lock);
> 	unblock_netpoll_tx();
>
>+	if (bond->slave_cnt == 0)
>+		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
>+
> 	bond_compute_features(bond);
> 	if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
> 	    (old_features & NETIF_F_VLAN_CHALLENGED))
>@@ -2218,6 +2221,8 @@ static int bond_release_all(struct net_device *bond_dev)
> out:
> 	write_unlock_bh(&bond->lock);
>
>+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
>+
> 	bond_compute_features(bond);
>
> 	return 0;
>-- 
>1.7.1

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
