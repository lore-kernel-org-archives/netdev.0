From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/5] bonding: mc addresses don't get deleted on enslave failure
Date: Thu, 18 Apr 2013 09:58:00 -0700
Message-ID: <14509.1366304280@death.nxdomain>
References: <1366295697-31037-1-git-send-email-nikolay@redhat.com> <1366295697-31037-2-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:58149 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682Ab3DRQ6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 12:58:14 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 18 Apr 2013 12:58:13 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 97EB16E804C
	for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 12:58:08 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3IGw9Fh269106
	for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 12:58:10 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3IGw6NK032715
	for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 12:58:08 -0400
In-reply-to: <1366295697-31037-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>Add dev_mc_del after err_detach as that's the first error path
>after they're added. The main issue is the mc addresses' refcount
>which only gets bumped up.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

	All 5 of these patches look good to me.  The only minor nits are
that the above description says "dev_mc_del," but the actual function
call added is bond_mc_list_flush (which in turn does call dev_mc_dev),
and that this patch (#1) modifies the lacpdu_multicast variable
initialization, which isn't really necessary for the bug fix.

	-J


>---
> drivers/net/bonding/bond_main.c | 11 +++++++----
> 1 file changed, 7 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index a61a760..dc0153b 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1523,6 +1523,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 	struct sockaddr addr;
> 	int link_reporting;
> 	int res = 0;
>+	u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
>
> 	if (!bond->params.use_carrier &&
> 	    slave_dev->ethtool_ops->get_link == NULL &&
>@@ -1726,12 +1727,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 		netif_addr_unlock_bh(bond_dev);
> 	}
>
>-	if (bond->params.mode == BOND_MODE_8023AD) {
>+	if (bond->params.mode == BOND_MODE_8023AD)
> 		/* add lacpdu mc addr to mc list */
>-		u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
>-
> 		dev_mc_add(slave_dev, lacpdu_multicast);
>-	}
>
> 	bond_add_vlans_on_slave(bond, slave_dev);
>
>@@ -1901,6 +1899,11 @@ err_dest_symlinks:
> 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
>
> err_detach:
>+	if (!USES_PRIMARY(bond->params.mode)) {
>+		netif_addr_lock_bh(bond_dev);
>+		bond_mc_list_flush(bond_dev, slave_dev);
>+		netif_addr_unlock_bh(bond_dev);
>+	}
> 	write_lock_bh(&bond->lock);
> 	bond_detach_slave(bond, new_slave);
> 	write_unlock_bh(&bond->lock);
>-- 
>1.8.1.4

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
