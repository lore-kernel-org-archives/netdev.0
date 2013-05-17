From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 4/4] bonding: fix multiple 3ad mode sysfs race conditions
Date: Fri, 17 May 2013 09:59:59 -0700
Message-ID: <30362.1368809999@death.nxdomain>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com> <1368621162-6807-5-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:47723 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab3EQRFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 13:05:39 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 17 May 2013 11:05:38 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id F40EA19D8074
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 10:59:56 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4HH02N1341910
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 11:00:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4HH00Rx029552
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 11:00:02 -0600
In-reply-to: <1368621162-6807-5-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>When bond_3ad_get_active_agg_info() is used in all show_ad_ functions
>it is not protected against slave manipulation and since it walks over
>the slaves and uses them, this can easily result in NULL pointer
>dereference or use of freed memory.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_sysfs.c | 21 ++++++++++++++++-----
> 1 file changed, 16 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 77ea237..81ef36a 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1319,6 +1319,17 @@ static ssize_t bonding_show_mii_status(struct device *d,
> }
> static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
>
>+/* Wrapper used to hold bond->lock so no slave manipulation can occur */
>+static int get_active_agg_info(struct bonding *bond, struct ad_info *ad)
>+{
>+	int ret;
>+
>+	read_lock(&bond->lock);
>+	ret = bond_3ad_get_active_agg_info(bond, ad);
>+	read_unlock(&bond->lock);
>+
>+	return ret;
>+}

	I think the patch is functionally fine, but the usual
nomenclature for adding a "wrapper" is to have the "functional" piece be
named "__function", and the "wrapper" piece to be just "function".  In
this case, it would be __bond_3ad_get_active_agg_info for the "inside"
function (the current function that is being wrapped), and
bond_3ad_get_active_agg_info for the wrapper.  Yes, this makes for a
different changeset (as some other calls already hold the locks and will
change to the __ version), but the end result is clearer.

	-J

> /*
>  * Show current 802.3ad aggregator ID.
>@@ -1333,7 +1344,7 @@ static ssize_t bonding_show_ad_aggregator(struct device *d,
> 	if (bond->params.mode == BOND_MODE_8023AD) {
> 		struct ad_info ad_info;
> 		count = sprintf(buf, "%d\n",
>-				(bond_3ad_get_active_agg_info(bond, &ad_info))
>+				(get_active_agg_info(bond, &ad_info))
> 				?  0 : ad_info.aggregator_id);
> 	}
>
>@@ -1355,7 +1366,7 @@ static ssize_t bonding_show_ad_num_ports(struct device *d,
> 	if (bond->params.mode == BOND_MODE_8023AD) {
> 		struct ad_info ad_info;
> 		count = sprintf(buf, "%d\n",
>-				(bond_3ad_get_active_agg_info(bond, &ad_info))
>+				(get_active_agg_info(bond, &ad_info))
> 				?  0 : ad_info.ports);
> 	}
>
>@@ -1377,7 +1388,7 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
> 	if (bond->params.mode == BOND_MODE_8023AD) {
> 		struct ad_info ad_info;
> 		count = sprintf(buf, "%d\n",
>-				(bond_3ad_get_active_agg_info(bond, &ad_info))
>+				(get_active_agg_info(bond, &ad_info))
> 				?  0 : ad_info.actor_key);
> 	}
>
>@@ -1399,7 +1410,7 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
> 	if (bond->params.mode == BOND_MODE_8023AD) {
> 		struct ad_info ad_info;
> 		count = sprintf(buf, "%d\n",
>-				(bond_3ad_get_active_agg_info(bond, &ad_info))
>+				(get_active_agg_info(bond, &ad_info))
> 				?  0 : ad_info.partner_key);
> 	}
>
>@@ -1420,7 +1431,7 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
>
> 	if (bond->params.mode == BOND_MODE_8023AD) {
> 		struct ad_info ad_info;
>-		if (!bond_3ad_get_active_agg_info(bond, &ad_info))
>+		if (!get_active_agg_info(bond, &ad_info))
> 			count = sprintf(buf, "%pM\n", ad_info.partner_system);
> 	}
>
>-- 
>1.8.1.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
