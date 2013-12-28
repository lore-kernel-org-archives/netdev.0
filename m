From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/4] bonding: add ad_select attribute netlink
 support
Date: Sat, 28 Dec 2013 22:30:45 +0100
Message-ID: <20131228213045.GC2447@minipsycho>
References: <20131228071548.6296.98915.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:63594 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab3L1Vat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 16:30:49 -0500
Received: by mail-ee0-f42.google.com with SMTP id e53so4540348eek.29
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 13:30:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131228071548.6296.98915.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 28, 2013 at 08:15:48AM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_AD_SELECT to allow get/set of bonding parameter
>ad_select via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
>---
> drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
> drivers/net/bonding/bond_options.c |   22 ++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c   |   29 ++++++++++++-----------------
> drivers/net/bonding/bonding.h      |    1 +
> include/uapi/linux/if_link.h       |    1 +
> 5 files changed, 50 insertions(+), 17 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
>index 45de873..df66dd8 100644
>--- a/drivers/net/bonding/bond_netlink.c
>+++ b/drivers/net/bonding/bond_netlink.c
>@@ -44,6 +44,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
> 	[IFLA_BOND_LP_INTERVAL]		= { .type = NLA_U32 },
> 	[IFLA_BOND_PACKETS_PER_SLAVE]	= { .type = NLA_U32 },
> 	[IFLA_BOND_AD_LACP_RATE]	= { .type = NLA_U8 },
>+	[IFLA_BOND_AD_SELECT]		= { .type = NLA_U8 },
> };
> 
> static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
>@@ -261,6 +262,14 @@ static int bond_changelink(struct net_device *bond_dev,
> 		if (err)
> 			return err;
> 	}
>+	if (data[IFLA_BOND_AD_SELECT]) {
>+		int ad_select =
>+			nla_get_u8(data[IFLA_BOND_AD_SELECT]);
>+
>+		err = bond_option_ad_select_set(bond, ad_select);
>+		if (err)
>+			return err;
>+	}
> 	return 0;
> }
> 
>@@ -300,6 +309,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
> 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_LP_INTERVAL */
> 		nla_total_size(sizeof(u32)) +  /* IFLA_BOND_PACKETS_PER_SLAVE */
> 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_AD_LACP_RATE */
>+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_AD_SELECT */
> 		0;
> }
> 
>@@ -409,6 +419,10 @@ static int bond_fill_info(struct sk_buff *skb,
> 		       bond->params.lacp_fast))
> 		goto nla_put_failure;
> 
>+	if (nla_put_u8(skb, IFLA_BOND_AD_SELECT,
>+		       bond->params.ad_select))
>+		goto nla_put_failure;
>+
> 	return 0;
> 
> nla_put_failure:
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index ad67fbf..6fdb8c0 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -685,3 +685,25 @@ int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate)
> 
> 	return 0;
> }
>+
>+int bond_option_ad_select_set(struct bonding *bond, int ad_select)
>+{
>+	if (bond->dev->flags & IFF_UP) {
>+		pr_err("%s: Unable to update ad_select because interface is up.\n",
>+		       bond->dev->name);
>+		return -EPERM;
>+	}
>+
>+	if (1 <= ad_select && ad_select <= 3) {

I do not like this. I think that we should do something like bond_parse_parm
somehow. Maybe to make a split of bond_parse_parm into multiple
function so we can pass int to it?



>+		bond->params.ad_select = ad_select;
>+		pr_info("%s: Setting ad_select to %s (%d).\n",
>+			bond->dev->name, ad_select_tbl[ad_select].modename,
>+			ad_select);
>+	} else {
>+		pr_err("%s: Ignoring invalid ad_select value %d.\n",
>+		       bond->dev->name, ad_select);
>+		return -EINVAL;
>+	}
>+
>+	return 0;
>+}
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 62d33dc..9a1ea4a 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -733,29 +733,24 @@ static ssize_t bonding_store_ad_select(struct device *d,
> 				       struct device_attribute *attr,
> 				       const char *buf, size_t count)
> {
>-	int new_value, ret = count;
>+	int new_value, ret;
> 	struct bonding *bond = to_bond(d);
> 
>-	if (bond->dev->flags & IFF_UP) {
>-		pr_err("%s: Unable to update ad_select because interface is up.\n",
>-		       bond->dev->name);
>-		ret = -EPERM;
>-		goto out;
>-	}
>-
> 	new_value = bond_parse_parm(buf, ad_select_tbl);
>-
>-	if (new_value != -1) {
>-		bond->params.ad_select = new_value;
>-		pr_info("%s: Setting ad_select to %s (%d).\n",
>-			bond->dev->name, ad_select_tbl[new_value].modename,
>-			new_value);
>-	} else {
>+	if (new_value < 0) {
> 		pr_err("%s: Ignoring invalid ad_select value %.*s.\n",
> 		       bond->dev->name, (int)strlen(buf) - 1, buf);
>-		ret = -EINVAL;
>+		return -EINVAL;
> 	}
>-out:
>+
>+	if (!rtnl_trylock())
>+		return restart_syscall();
>+
>+	ret = bond_option_ad_select_set(bond, new_value);
>+	if (!ret)
>+		ret = count;
>+
>+	rtnl_unlock();
> 	return ret;
> }
> static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR,
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index ef93667..3dec554 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -469,6 +469,7 @@ int bond_option_lp_interval_set(struct bonding *bond, int min_links);
> int bond_option_packets_per_slave_set(struct bonding *bond,
> 				      int packets_per_slave);
> int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate);
>+int bond_option_ad_select_set(struct bonding *bond, int ad_select);
> struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
> struct net_device *bond_option_active_slave_get(struct bonding *bond);
> 
>diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>index 0f8f38f..0fbb018 100644
>--- a/include/uapi/linux/if_link.h
>+++ b/include/uapi/linux/if_link.h
>@@ -350,6 +350,7 @@ enum {
> 	IFLA_BOND_LP_INTERVAL,
> 	IFLA_BOND_PACKETS_PER_SLAVE,
> 	IFLA_BOND_AD_LACP_RATE,
>+	IFLA_BOND_AD_SELECT,
> 	__IFLA_BOND_MAX,
> };
> 
>
