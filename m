From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 3/8] bonding: add downdelay netlink support
Date: Thu, 7 Nov 2013 12:02:31 +0100
Message-ID: <20131107110231.GH19702@redhat.com>
References: <20131107094308.15846.58301.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260Ab3KGLEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 06:04:43 -0500
Content-Disposition: inline
In-Reply-To: <20131107094308.15846.58301.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 01:43:08AM -0800, Scott Feldman wrote:
>Add IFLA_BOND_DOWNDELAY to allow get/set of bonding parameter
>downdelay via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
>---
> drivers/net/bonding/bond_netlink.c |   12 +++++++++++
> drivers/net/bonding/bond_options.c |   29 +++++++++++++++++++++++++++
> drivers/net/bonding/bond_sysfs.c   |   38 +++++++++---------------------------
> drivers/net/bonding/bonding.h      |    1 +
> include/uapi/linux/if_link.h       |    1 +
> 5 files changed, 52 insertions(+), 29 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
>index 9ba5431..e684713 100644
>--- a/drivers/net/bonding/bond_netlink.c
>+++ b/drivers/net/bonding/bond_netlink.c
>@@ -26,6 +26,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
> 	[IFLA_BOND_ACTIVE_SLAVE]	= { .type = NLA_U32 },
> 	[IFLA_BOND_MIIMON]		= { .type = NLA_U32 },
> 	[IFLA_BOND_UPDELAY]		= { .type = NLA_U32 },
>+	[IFLA_BOND_DOWNDELAY]		= { .type = NLA_U32 },
> };
>
> static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
>@@ -85,6 +86,13 @@ static int bond_changelink(struct net_device *bond_dev,
> 		if (err)
> 			return err;
> 	}
>+	if (data[IFLA_BOND_DOWNDELAY]) {
>+		int downdelay = nla_get_u32(data[IFLA_BOND_DOWNDELAY]);
>+
>+		err = bond_option_downdelay_set(bond, downdelay);
>+		if (err)
>+			return err;
>+	}
> 	return 0;
> }
>
>@@ -106,6 +114,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
> 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ACTIVE_SLAVE */
> 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIIMON */
> 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_UPDELAY */
>+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_DOWNDELAY */
> 		0;
> }
>
>@@ -128,6 +137,9 @@ static int bond_fill_info(struct sk_buff *skb,
> 	if (nla_put_u32(skb, IFLA_BOND_UPDELAY, bond->params.updelay))
> 		goto nla_put_failure;
>
>+	if (nla_put_u32(skb, IFLA_BOND_DOWNDELAY, bond->params.downdelay))
>+		goto nla_put_failure;
>+
> 	return 0;
>
> nla_put_failure:
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index c0fea66..738be5f 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -211,3 +211,32 @@ int bond_option_updelay_set(struct bonding *bond, int updelay)
>
> 	return 0;
> }
>+
>+int bond_option_downdelay_set(struct bonding *bond, int downdelay)
>+{
>+	if (!(bond->params.miimon)) {
>+		pr_err("%s: Unable to set down delay as MII monitoring is disabled\n", bond->dev->name);

Maybe get bond->dev->name on the next line?

>+		return -EPERM;
>+	}
>+
>+	if (downdelay < 0) {
>+		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
>+		       bond->dev->name, downdelay, 0, INT_MAX);
>+		return -EINVAL;
>+	} else {
>+		if ((downdelay % bond->params.miimon) != 0) {
>+			pr_warn("%s: Warning: down delay (%d) is not a multiple of miimon (%d), delay rounded to %d ms\n",
>+				bond->dev->name, downdelay,
>+				bond->params.miimon,
>+				(downdelay / bond->params.miimon) *
>+				bond->params.miimon);
>+		}
>+		bond->params.downdelay = downdelay / bond->params.miimon;
>+		pr_info("%s: Setting down delay to %d.\n",
>+			bond->dev->name,
>+			bond->params.downdelay * bond->params.miimon);
>+
>+	}
>+
>+	return 0;
>+}
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 1125bef..41a62ac 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -706,42 +706,22 @@ static ssize_t bonding_store_downdelay(struct device *d,
> 				       struct device_attribute *attr,
> 				       const char *buf, size_t count)
> {
>-	int new_value, ret = count;
>+	int new_value, ret;
> 	struct bonding *bond = to_bond(d);
>
>-	if (!(bond->params.miimon)) {
>-		pr_err("%s: Unable to set down delay as MII monitoring is disabled\n",
>-		       bond->dev->name);
>-		ret = -EPERM;
>-		goto out;
>-	}
>-
> 	if (sscanf(buf, "%d", &new_value) != 1) {
> 		pr_err("%s: no down delay value specified.\n", bond->dev->name);
>-		ret = -EINVAL;
>-		goto out;
>+		return -EINVAL;
> 	}
>-	if (new_value < 0) {
>-		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
>-		       bond->dev->name, new_value, 0, INT_MAX);
>-		ret = -EINVAL;
>-		goto out;
>-	} else {
>-		if ((new_value % bond->params.miimon) != 0) {
>-			pr_warning("%s: Warning: down delay (%d) is not a multiple of miimon (%d), delay rounded to %d ms\n",
>-				   bond->dev->name, new_value,
>-				   bond->params.miimon,
>-				   (new_value / bond->params.miimon) *
>-				   bond->params.miimon);
>-		}
>-		bond->params.downdelay = new_value / bond->params.miimon;
>-		pr_info("%s: Setting down delay to %d.\n",
>-			bond->dev->name,
>-			bond->params.downdelay * bond->params.miimon);
>
>-	}
>+	if (!rtnl_trylock())
>+		return restart_syscall();
>
>-out:
>+	ret = bond_option_downdelay_set(bond, new_value);
>+	if (!ret)
>+		ret = count;
>+
>+	rtnl_unlock();
> 	return ret;
> }
> static DEVICE_ATTR(downdelay, S_IRUGO | S_IWUSR,
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 408e6c2..40987f3 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -430,6 +430,7 @@ int bond_option_mode_set(struct bonding *bond, int mode);
> int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
> int bond_option_miimon_set(struct bonding *bond, int miimon);
> int bond_option_updelay_set(struct bonding *bond, int updelay);
>+int bond_option_downdelay_set(struct bonding *bond, int downdelay);
> struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
> struct net_device *bond_option_active_slave_get(struct bonding *bond);
>
>diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>index 361414e..a372831 100644
>--- a/include/uapi/linux/if_link.h
>+++ b/include/uapi/linux/if_link.h
>@@ -333,6 +333,7 @@ enum {
> 	IFLA_BOND_ACTIVE_SLAVE,
> 	IFLA_BOND_MIIMON,
> 	IFLA_BOND_UPDELAY,
>+	IFLA_BOND_DOWNDELAY,
> 	__IFLA_BOND_MAX,
> };
>
>
