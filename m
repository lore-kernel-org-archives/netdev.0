From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: bond_slave_info_query() fix
Date: Thu, 23 Apr 2009 14:11:22 +0200
Message-ID: <20090423121121.GG29268@psychotron.englab.brq.redhat.com>
References: <49F04FD7.7080508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55988 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752370AbZDWMLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 08:11:32 -0400
Content-Disposition: inline
In-Reply-To: <49F04FD7.7080508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 23, 2009 at 01:24:07PM CEST, dada1@cosmosbay.com wrote:
>bond_slave_info_query() should keep a read lock while accessing slave info,
>or risk accessing stale data and corruption.
>
>Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 63369b6..66697db 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2213,33 +2213,27 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
> 	struct slave *slave;
>-	int i, found = 0;
>+	int i, ret = -ENODEV;
> 
>-	if (info->slave_id < 0) {
>+	if (info->slave_id < 0)
> 		return -ENODEV;

You can return ret; here since -ENODEV is there, but I don't know if it isn't
against policy. Patch looks good anyway.
>-	}
> 
> 	read_lock(&bond->lock);
> 
> 	bond_for_each_slave(bond, slave, i) {
> 		if (i == (int)info->slave_id) {
>-			found = 1;
>+			ret = 0;
>+			strcpy(info->slave_name, slave->dev->name);
>+			info->link = slave->link;
>+			info->state = slave->state;
>+			info->link_failure_count = slave->link_failure_count;
> 			break;
> 		}
> 	}
> 
> 	read_unlock(&bond->lock);
> 
>-	if (found) {
>-		strcpy(info->slave_name, slave->dev->name);
>-		info->link = slave->link;
>-		info->state = slave->state;
>-		info->link_failure_count = slave->link_failure_count;
>-	} else {
>-		return -ENODEV;
>-	}
>-
>-	return 0;
>+	return ret;
> }
> 
> /*-------------------------------- Monitoring -------------------------------*/
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
