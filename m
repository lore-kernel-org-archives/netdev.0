From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix a race condition in calls to slave MII ioctls
Date: Wed, 21 Oct 2009 11:13:46 -0700
Message-ID: <17766.1256148826@death.nxdomain.ibm.com>
References: <20091021130301.GA4762@midget.suse.cz>
Cc: netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:33419 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754690AbZJUSNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2009 14:13:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9LI5w81008382
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 14:05:58 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9LIDtZa250142
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 14:13:55 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9LIDs8r009784
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 14:13:55 -0400
In-reply-to: <20091021130301.GA4762@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>In mii monitor mode, bond_check_dev_link() calls the the ioctl
>handler of slave devices. It stores the ndo_do_ioctl function
>pointer to a static (!) ioctl variable and later uses it to call the
>handler with the IOCTL macro.
>
>If another thread executes bond_check_dev_link() at the same time
>(even with a different bond, which none of the locks prevent), a
>race condition occurs. If the two racing slaves have different
>drivers, this may result in one driver's ioctl handler being
>called with a pointer to a net_device controlled with a different
>driver, resulting in unpredictable breakage.
>
>Unless I am overlooking something, the "static" must be a
>copy'n'paste error (?).

	Heh, I was curious, so I looked it up; this bit was added as-is
in September 2000, when the original "miimon" link monitoring code was
added.  It's interesting that nobody hit this bug back in the days
before netif_carrier; I know I ran a lot of mixed slave environments.

>Signed-off-by: Jiri Bohac <jbohac@suse.cz>

	Anyway, the static is obviously wrong, even without the race.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 69c5b15..5bfdd0c 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -691,7 +691,7 @@ static int bond_check_dev_link(struct bonding *bond,
> 			       struct net_device *slave_dev, int reporting)
> {
> 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
>-	static int (*ioctl)(struct net_device *, struct ifreq *, int);
>+	int (*ioctl)(struct net_device *, struct ifreq *, int);
> 	struct ifreq ifr;
> 	struct mii_ioctl_data *mii;
>
>
>
>
>-- 
>Jiri Bohac <jbohac@suse.cz>
>SUSE Labs, SUSE CZ
>
