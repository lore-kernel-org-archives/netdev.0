From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-2.6] bonding: correctly process LACPDUs in non-linear skbs
Date: Fri, 10 Sep 2010 14:04:00 -0700
Message-ID: <22437.1284152640@death>
References: <20100910203845.GW7497@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	stable@kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:59940 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab0IJVEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 17:04:04 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8AKtXTe013925
	for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 14:55:33 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8AL438e210974
	for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 15:04:03 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8AL432e030607
	for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 15:04:03 -0600
In-reply-to: <20100910203845.GW7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>
>It was recently brought to my attention that 802.3ad mode bonds would no
>longer form when using some network hardware after a driver update.
>After snooping around I realized that the particular hardware was using
>page-based skbs and found that skb->data did not contain a valid LACPDU
>as it wasn't stored there.  That explained the inability to form an
>802.3ad-based bond.
>
>This patch fixes the issue in my tests and should be applied to 2.6.36
>and as far back as anyone cares to add it to stable.
>
>Thanks to Alexander Duyck <alexander.h.duyck@intel.com> and Jesse
>Brandeburg <jesse.brandeburg@intel.com> for the suggestions on this one.
>
>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
>CC: stable@kernel.org

	Did you by any chance also test balance-alb mode?  Inspection
suggests that rlb_arp_recv may suffer from the same problem.

	If you agree, could you add that to the patch and resubmit it?

	Either way, the patch looks good.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>---
> drivers/net/bonding/bond_3ad.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 822f586..0ddf4c6 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -2466,6 +2466,9 @@ int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct pac
> 	if (!(dev->flags & IFF_MASTER))
> 		goto out;
>
>+	if (!pskb_may_pull(skb, sizeof(struct lacpdu)))
>+		goto out;
>+
> 	read_lock(&bond->lock);
> 	slave = bond_get_slave_by_dev((struct bonding *)netdev_priv(dev),
> 					orig_dev);
>-- 
>1.7.0.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
