From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next 3/5] bonding: add min_links attribute netlink support
Date: Tue, 17 Dec 2013 21:30:23 -0800
Message-ID: <20131218053023.13529.82243.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45820 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab3LRFa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:30:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_BOND_MIN_LINKS to allow get/set of bonding parameter
min_links via netlink.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |   14 ++++++++++++++
 drivers/net/bonding/bond_options.c |    9 +++++++++
 drivers/net/bonding/bond_sysfs.c   |   13 +++++++++----
 drivers/net/bonding/bonding.h      |    1 +
 include/uapi/linux/if_link.h       |    1 +
 5 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index ebc600f..1b65118 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -39,6 +39,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_RESEND_IGMP]		= { .type = NLA_U32 },
 	[IFLA_BOND_NUM_PEER_NOTIF]	= { .type = NLA_U8 },
 	[IFLA_BOND_ALL_SLAVES_ACTIVE]	= { .type = NLA_U8 },
+	[IFLA_BOND_MIN_LINKS]		= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -223,6 +224,14 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_MIN_LINKS]) {
+		int min_links =
+			nla_get_u32(data[IFLA_BOND_MIN_LINKS]);
+
+		err = bond_option_min_links_set(bond, min_links);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -258,6 +267,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_RESEND_IGMP */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_NUM_PEER_NOTIF */
 		nla_total_size(sizeof(u8)) +   /* IFLA_BOND_ALL_SLAVES_ACTIVE */
+		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_MIN_LINKS */
 		0;
 }
 
@@ -346,6 +356,10 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.all_slaves_active))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, IFLA_BOND_MIN_LINKS,
+			bond->params.min_links))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index cbd8322..da49ac4 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -611,3 +611,12 @@ int bond_option_all_slaves_active_set(struct bonding *bond,
 
 	return 0;
 }
+
+int bond_option_min_links_set(struct bonding *bond, int min_links)
+{
+	pr_info("%s: Setting min links value to %u\n",
+		bond->dev->name, min_links);
+	bond->params.min_links = min_links;
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 9a37125..359adda 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -722,10 +722,15 @@ static ssize_t bonding_store_min_links(struct device *d,
 		return ret;
 	}
 
-	pr_info("%s: Setting min links value to %u\n",
-		bond->dev->name, new_value);
-	bond->params.min_links = new_value;
-	return count;
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = bond_option_min_links_set(bond, new_value);
+	if (!ret)
+		ret = count;
+
+	rtnl_unlock();
+	return ret;
 }
 static DEVICE_ATTR(min_links, S_IRUGO | S_IWUSR,
 		   bonding_show_min_links, bonding_store_min_links);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 3701e7d..7d7ad1c 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -464,6 +464,7 @@ int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
 int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
 int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
+int bond_option_min_links_set(struct bonding *bond, int min_links);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 93e9c1b..c7a0f89 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -346,6 +346,7 @@ enum {
 	IFLA_BOND_RESEND_IGMP,
 	IFLA_BOND_NUM_PEER_NOTIF,
 	IFLA_BOND_ALL_SLAVES_ACTIVE,
+	IFLA_BOND_MIN_LINKS,
 	__IFLA_BOND_MAX,
 };
 
