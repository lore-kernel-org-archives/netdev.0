From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next] bonding: convert num_grat_arp to the new
 bonding option API
Date: Sat, 25 Jul 2015 15:08:38 +0200
Message-ID: <20150725130838.GA29168@vps.falico.eu>
References: <1437745831-10273-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com,
	gospo@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36781 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbbGYNIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 09:08:42 -0400
Received: by igbij6 with SMTP id ij6so33094818igb.1
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2015 06:08:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437745831-10273-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2015 at 03:50:31PM +0200, Nikolay Aleksandrov wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>num_grat_arp wasn't converted to the new bonding option API, so do this
>now and remove the specific sysfs store option in order to use the
>standard one. num_grat_arp is the same as num_unsol_na so add it as an
>alias with the same option settings. An important difference is the option
>name which is matched in bond_sysfs_store_option().
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>---
> drivers/net/bonding/bond_options.c |  7 +++++++
> drivers/net/bonding/bond_sysfs.c   | 20 +++-----------------
> include/net/bond_options.h         |  1 +
> 3 files changed, 11 insertions(+), 17 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index e9c624d54dd4..6dda57e2e724 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -420,6 +420,13 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
> 		.flags = BOND_OPTFLAG_IFDOWN,
> 		.values = bond_ad_user_port_key_tbl,
> 		.set = bond_option_ad_user_port_key_set,
>+	},
>+	[BOND_OPT_NUM_PEER_NOTIF_ALIAS] = {
>+		.id = BOND_OPT_NUM_PEER_NOTIF_ALIAS,
>+		.name = "num_grat_arp",
>+		.desc = "Number of peer notifications to send on failover event",
>+		.values = bond_num_peer_notif_tbl,
>+		.set = bond_option_num_peer_notif_set
> 	}
> };
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 31835a4dab57..f4ae72086215 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -380,7 +380,7 @@ static ssize_t bonding_show_ad_select(struct device *d,
> static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR,
> 		   bonding_show_ad_select, bonding_sysfs_store_option);
>
>-/* Show and set the number of peer notifications to send after a failover event. */
>+/* Show the number of peer notifications to send after a failover event. */
> static ssize_t bonding_show_num_peer_notif(struct device *d,
> 					   struct device_attribute *attr,
> 					   char *buf)
>@@ -388,24 +388,10 @@ static ssize_t bonding_show_num_peer_notif(struct device *d,
> 	struct bonding *bond = to_bond(d);
> 	return sprintf(buf, "%d\n", bond->params.num_peer_notif);
> }
>-
>-static ssize_t bonding_store_num_peer_notif(struct device *d,
>-					    struct device_attribute *attr,
>-					    const char *buf, size_t count)
>-{
>-	struct bonding *bond = to_bond(d);
>-	int ret;
>-
>-	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_NUM_PEER_NOTIF, (char *)buf);
>-	if (!ret)
>-		ret = count;
>-
>-	return ret;
>-}
> static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR,
>-		   bonding_show_num_peer_notif, bonding_store_num_peer_notif);
>+		   bonding_show_num_peer_notif, bonding_sysfs_store_option);
> static DEVICE_ATTR(num_unsol_na, S_IRUGO | S_IWUSR,
>-		   bonding_show_num_peer_notif, bonding_store_num_peer_notif);
>+		   bonding_show_num_peer_notif, bonding_sysfs_store_option);
>
> /* Show the MII monitor interval. */
> static ssize_t bonding_show_miimon(struct device *d,
>diff --git a/include/net/bond_options.h b/include/net/bond_options.h
>index c28aca25320e..1797235cd590 100644
>--- a/include/net/bond_options.h
>+++ b/include/net/bond_options.h
>@@ -66,6 +66,7 @@ enum {
> 	BOND_OPT_AD_ACTOR_SYS_PRIO,
> 	BOND_OPT_AD_ACTOR_SYSTEM,
> 	BOND_OPT_AD_USER_PORT_KEY,
>+	BOND_OPT_NUM_PEER_NOTIF_ALIAS,
> 	BOND_OPT_LAST
> };
>
>-- 
>2.4.3
>
