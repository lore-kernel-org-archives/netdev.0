From: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Subject: [PATCH 2/4] bonding: L2DA mode intergated
Date: Thu, 21 Nov 2013 16:55:36 +0200
Message-ID: <1385045738-29726-3-git-send-email-Anton.Nayshtut@wilocity.com>
References: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Anton Nayshtut <Anton.Nayshtut@wilocity.com>,
	Erez Kirshenbaum <Erez.Kirshenbaum@wilocity.com>,
	Boris Lapshin <Boris.Lapshin@wilocity.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1385045738-29726-1-git-send-email-Anton.Nayshtut@wilocity.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L2DA bonding module integration, including module parameters, sysfs entries and
module calls.

Signed-off-by: Anton Nayshtut <Anton.Nayshtut@wilocity.com>
Signed-off-by: Erez Kirshenbaum <Erez.Kirshenbaum@wilocity.com>
Signed-off-by: Boris Lapshin <Boris.Lapshin@wilocity.com>
---
 drivers/net/bonding/bond_main.c    |  51 ++++++++-
 drivers/net/bonding/bond_options.c |  17 ++-
 drivers/net/bonding/bond_sysfs.c   | 223 ++++++++++++++++++++++++++++++++++++-
 drivers/net/bonding/bonding.h      |   5 +
 include/uapi/linux/if_bonding.h    |   1 +
 5 files changed, 290 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4dd5ee2..33733be 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -138,7 +138,7 @@ module_param(mode, charp, 0);
 MODULE_PARM_DESC(mode, "Mode of operation; 0 for balance-rr, "
 		       "1 for active-backup, 2 for balance-xor, "
 		       "3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, "
-		       "6 for balance-alb");
+		       "6 for balance-alb, 7 for l2da");
 module_param(primary, charp, 0);
 MODULE_PARM_DESC(primary, "Primary network device to use");
 module_param(primary_reselect, charp, 0);
@@ -218,6 +218,7 @@ const struct bond_parm_tbl bond_mode_tbl[] = {
 {	"802.3ad",		BOND_MODE_8023AD},
 {	"balance-tlb",		BOND_MODE_TLB},
 {	"balance-alb",		BOND_MODE_ALB},
+{	"l2da",			BOND_MODE_L2DA },
 {	NULL,			-1},
 };
 
@@ -282,9 +283,10 @@ const char *bond_mode_name(int mode)
 		[BOND_MODE_8023AD] = "IEEE 802.3ad Dynamic link aggregation",
 		[BOND_MODE_TLB] = "transmit load balancing",
 		[BOND_MODE_ALB] = "adaptive load balancing",
+		[BOND_MODE_L2DA] = "l2 DA matrix",
 	};
 
-	if (mode < BOND_MODE_ROUNDROBIN || mode > BOND_MODE_ALB)
+	if (mode < BOND_MODE_ROUNDROBIN || mode > BOND_MODE_L2DA)
 		return "unknown";
 
 	return names[mode];
@@ -1546,6 +1548,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		bond_set_active_slave(new_slave);
 		bond_set_slave_inactive_flags(new_slave);
 		break;
+	case BOND_MODE_L2DA:
+		bond_set_slave_active_flags(new_slave);
+		bond_l2da_slave_init(bond, new_slave);
+		break;
 	default:
 		pr_debug("This slave is always active in trunk mode\n");
 
@@ -1760,7 +1766,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 		write_unlock_bh(&bond->lock);
 		bond_alb_deinit_slave(bond, slave);
 		write_lock_bh(&bond->lock);
-	}
+	} else if (bond_is_l2da(bond))
+		bond_l2da_slave_deinit(bond, slave);
 
 	if (all) {
 		rcu_assign_pointer(bond->curr_active_slave, NULL);
@@ -2058,6 +2065,9 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_UP);
 
+			if (bond_is_l2da(bond))
+				bond_l2da_handle_link_change(bond, slave);
+
 			if (!bond->curr_active_slave ||
 			    (slave == bond->primary_slave))
 				goto do_failover;
@@ -2085,6 +2095,9 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_DOWN);
 
+			if (bond_is_l2da(bond))
+				bond_l2da_handle_link_change(bond, slave);
+
 			if (slave == bond->curr_active_slave)
 				goto do_failover;
 
@@ -3778,6 +3791,8 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 	case BOND_MODE_ALB:
 	case BOND_MODE_TLB:
 		return bond_alb_xmit(skb, dev);
+	case BOND_MODE_L2DA:
+		return bond_l2da_xmit(skb, dev);
 	default:
 		/* Should never happen, mode already checked */
 		pr_err("%s: Error: Unknown bonding mode %d\n",
@@ -3969,6 +3984,9 @@ static void bond_uninit(struct net_device *bond_dev)
 	list_del(&bond->bond_list);
 
 	bond_debug_unregister(bond);
+
+	if (bond_is_l2da(bond))
+		bond_l2da_deinitialize(bond);
 }
 
 /*------------------------- Module initialization ---------------------------*/
@@ -4041,7 +4059,8 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (lacp_rate) {
-		if (bond_mode != BOND_MODE_8023AD) {
+		if (bond_mode != BOND_MODE_8023AD ||
+			bond_mode != BOND_MODE_L2DA) {
 			pr_info("lacp_rate param is irrelevant in mode %s\n",
 				bond_mode_name(bond_mode));
 		} else {
@@ -4128,6 +4147,19 @@ static int bond_check_params(struct bond_params *params)
 		all_slaves_active = 0;
 	}
 
+	if (bond_mode == BOND_MODE_L2DA) {
+		if (!all_slaves_active) {
+			pr_warning("Warning: all_slaves_active must be specified, otherwise bonding will not be able to route packets that is essential for l2da operation\n");
+			pr_warning("Forcing all_slaves_active to 1\n");
+			all_slaves_active = 1;
+		}
+		if (!miimon) {
+			pr_warning("Warning: miimon must be specified, otherwise bonding will not detect link failure and link speed which are essential for l2da operation\n");
+			pr_warning("Forcing miimon to 100msec\n");
+			miimon = 100;
+		}
+	}
+
 	if (resend_igmp < 0 || resend_igmp > 255) {
 		pr_warning("Warning: resend_igmp (%d) should be between "
 			   "0 and 255, resetting to %d\n",
@@ -4372,6 +4404,7 @@ static int bond_init(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	int ret;
 
 	pr_debug("Begin bond_init for %s\n", bond_dev->name);
 
@@ -4384,6 +4417,16 @@ static int bond_init(struct net_device *bond_dev)
 	spin_lock_init(&(bond_info->tx_hashtbl_lock));
 	spin_lock_init(&(bond_info->rx_hashtbl_lock));
 
+	if (bond_is_l2da(bond)) {
+		ret = bond_l2da_initialize(bond);
+		if (ret) {
+			pr_err("%s: %s mode cannot be initialized.\n",
+					bond->dev->name,
+					bond_mode_tbl[BOND_MODE_L2DA].modename);
+			return ret;
+		}
+	}
+
 	bond->wq = create_singlethread_workqueue(bond_dev->name);
 	if (!bond->wq)
 		return -ENOMEM;
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 9a5223c..b413665 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -45,12 +45,27 @@ int bond_option_mode_set(struct bonding *bond, int mode)
 		return -EPERM;
 	}
 
-	if (BOND_MODE_IS_LB(mode) && bond->params.arp_interval) {
+	if ((BOND_MODE_IS_LB(mode) || bond_is_l2da(bond)) &&
+	    bond->params.arp_interval) {
 		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
 		       bond->dev->name, bond_mode_tbl[mode].modename);
 		return -EINVAL;
 	}
 
+	if (bond->params.mode == mode)
+		;
+	else if (mode == BOND_MODE_L2DA) {
+		int ret = bond_l2da_initialize(bond);
+		if (ret) {
+			pr_err("%s: %s mode cannot be initialized.\n",
+			       bond->dev->name,
+			       bond_mode_tbl[mode].modename);
+			return ret;
+		}
+	} else if (bond_is_l2da(bond))
+		bond_l2da_deinitialize(bond);
+
+
 	/* don't cache arp_validate between modes */
 	bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
 	bond->params.mode = mode;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0ec2a7e..d4727d2 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -525,8 +525,9 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 	}
 	if (bond->params.mode == BOND_MODE_ALB ||
 	    bond->params.mode == BOND_MODE_TLB ||
-	    bond->params.mode == BOND_MODE_8023AD) {
-		pr_info("%s: ARP monitoring cannot be used with ALB/TLB/802.3ad. Only MII monitoring is supported on %s.\n",
+	    bond->params.mode == BOND_MODE_8023AD ||
+	    bond->params.mode == BOND_MODE_L2DA) {
+		pr_info("%s: ARP monitoring cannot be used with ALB/TLB/802.3ad/L2DA. Only MII monitoring is supported on %s.\n",
 			bond->dev->name, bond->dev->name);
 		ret = -EINVAL;
 		goto out;
@@ -1679,6 +1680,222 @@ static DEVICE_ATTR(packets_per_slave, S_IRUGO | S_IWUSR,
 		   bonding_show_packets_per_slave,
 		   bonding_store_packets_per_slave);
 
+static ssize_t bonding_show_l2da_default_slave(struct device *d,
+					struct device_attribute *attr,
+					char *buf)
+{
+	struct bonding *bond = to_bond(d);
+	char ifname[IFNAMSIZ + 1];
+	int ret;
+
+	read_lock(&bond->lock);
+	ret = bond_l2da_get_default_slave_name(bond, ifname, sizeof(ifname));
+	read_unlock(&bond->lock);
+
+	ifname[IFNAMSIZ] = 0;
+
+	return sprintf(buf, "%s\n", ifname);
+}
+
+static ssize_t bonding_store_l2da_default_slave(struct device *d,
+					 struct device_attribute *attr,
+					 const char *buf, size_t count)
+{
+	int ret = -EINVAL;
+	struct slave *slave;
+	struct bonding *bond = to_bond(d);
+	char ifname[IFNAMSIZ];
+	struct list_head *iter;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (sscanf(buf, "%15s", ifname) != 1) {/* IFNAMSIZ */
+		pr_info("%s: no L2DA slave name specified\n",
+			netdev_name(bond->dev));
+		goto rtnl_out;
+	}
+
+	block_netpoll_tx();
+	read_lock(&bond->lock);
+
+	if (!bond_is_l2da(bond)) {
+		pr_info("%s: Unable to set default slave ; %s is in mode %d\n",
+			netdev_name(bond->dev), netdev_name(bond->dev),
+			bond->params.mode);
+		goto out;
+	}
+
+	bond_for_each_slave(bond, slave, iter) {
+		if (strncmp(netdev_name(slave->dev), ifname, IFNAMSIZ) == 0) {
+			if (slave->link == BOND_LINK_UP && IS_UP(slave->dev)) {
+				bond_l2da_set_default_slave(bond, slave);
+				ret = count;
+			} else
+				pr_warn("%s: cannot set %s as default slave\n",
+					netdev_name(bond->dev),
+					netdev_name(slave->dev));
+
+			break;
+		}
+	}
+
+	if (ret < 0)
+		pr_warn("%s: Unable to to set %.*s as default slave.\n",
+			netdev_name(bond->dev), (int)strlen(buf) - 1, buf);
+
+out:
+	read_unlock(&bond->lock);
+	unblock_netpoll_tx();
+rtnl_out:
+	rtnl_unlock();
+
+	return ret;
+}
+
+static DEVICE_ATTR(l2da_default_slave, S_IRUGO | S_IWUSR,
+		   bonding_show_l2da_default_slave,
+		   bonding_store_l2da_default_slave);
+
+struct bonding_show_l2da_table_clb_ctx {
+	char *buf;
+	int   res;
+};
+
+static int bonding_show_l2da_table_clb(const unsigned char *da,
+		struct slave *slave, void *_ctx)
+{
+	struct bonding_show_l2da_table_clb_ctx *ctx = _ctx;
+	if (ctx->res > (PAGE_SIZE - 18 - IFNAMSIZ)) {
+		/* not enough space for another da@interface_name pair */
+		if ((PAGE_SIZE - ctx->res) > 9)
+			ctx->res = PAGE_SIZE - 9;
+		ctx->res += sprintf(ctx->buf + ctx->res, "++more++");
+		return 1;
+	}
+	ctx->res += sprintf(ctx->buf + ctx->res, "%pM@%s\n",
+		       da, netdev_name(slave->dev));
+	return 0;
+}
+
+static ssize_t bonding_show_l2da_table(struct device *d,
+					struct device_attribute *attr,
+					char *buf)
+{
+	struct bonding *bond = to_bond(d);
+	struct bonding_show_l2da_table_clb_ctx ctx = {
+		.buf = buf,
+	};
+
+	read_lock(&bond->lock);
+	bond_l2da_call_foreach(bond, bonding_show_l2da_table_clb, &ctx);
+	read_unlock(&bond->lock);
+	if (ctx.res)
+		buf[ctx.res-1] = '\n'; /* eat the leftover space */
+
+	return ctx.res;
+}
+
+static ssize_t bonding_store_l2da_table(struct device *d,
+					 struct device_attribute *attr,
+					 const char *buf, size_t count)
+{
+	struct slave *slave;
+	struct bonding *bond = to_bond(d);
+	int ret = -EINVAL;
+	char *delim;
+	unsigned char da[ETH_ALEN];
+	struct net_device *sdev = NULL;
+	struct list_head *iter;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	/* Check command syntax and extract parameters */
+	if (buf[0] == '+') {
+		unsigned char ifname[IFNAMSIZ] = {0, };
+		/* delim will point to slave interface name if successful */
+		delim = strchr(buf, '@');
+		if (!delim) {
+			pr_err("%s: Invalid L2DA command string: %s\n",
+			    netdev_name(bond->dev), buf);
+			goto out;
+		}
+		/* Terminate string that points to device name and bump it
+		 * up one, so we can read the destination address there.
+		 */
+		*delim = '\0';
+		if (sscanf(delim + 1, "%15s", ifname) != 1) { /* IFNAMSIZ */
+			pr_err("%s: no L2DA slave name specified\n",
+			    netdev_name(bond->dev));
+			ret = -EINVAL;
+			goto out;
+		}
+
+		/* Check valid ifname */
+		if (!dev_valid_name(ifname)) {
+			pr_err("%s: Invalid L2DA slave name: '%s'\n",
+			    netdev_name(bond->dev), ifname);
+			ret = -EINVAL;
+			goto out;
+
+		}
+
+		/* Get the pointer to that interface if it exists */
+		sdev = __dev_get_by_name(dev_net(bond->dev), ifname);
+		if (!sdev) {
+			pr_err("%s: No L2DA slave found: %s\n",
+			    netdev_name(bond->dev), ifname);
+			ret = -EINVAL;
+			goto out;
+		}
+	} else if (buf[0] != '-') {
+		pr_err("%s: Invalid L2DA command string: %s\n",
+		    netdev_name(bond->dev), buf);
+		goto out;
+	}
+
+	if (!mac_pton(buf + 1, da)) {
+		pr_err("%s: Invalid L2DA MAC address string: %s\n",
+		    netdev_name(bond->dev), buf + 1);
+		goto out;
+	}
+
+	if (!is_valid_ether_addr(da)) {
+		pr_err("%s: Invalid L2DA MAC address: %pM\n",
+		    netdev_name(bond->dev), da);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	block_netpoll_tx();
+	read_lock(&bond->lock);
+
+	if (!bond_is_l2da(bond))
+		pr_info("%s: Unable to set default slave ; %s is in mode %d\n",
+			netdev_name(bond->dev), netdev_name(bond->dev),
+			bond->params.mode);
+	else if (buf[0] == '-')
+		ret = bond_l2da_del_da(bond, da);
+	else {
+		bond_for_each_slave(bond, slave, iter) {
+			if (sdev == slave->dev) {
+				ret = bond_l2da_set_da_slave(bond, da, slave);
+				break;
+			}
+		}
+	}
+
+	read_unlock(&bond->lock);
+	unblock_netpoll_tx();
+out:
+	rtnl_unlock();
+	return ret ? ret : count;
+}
+
+static DEVICE_ATTR(l2da_table, S_IRUGO | S_IWUSR,
+		   bonding_show_l2da_table, bonding_store_l2da_table);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -1711,6 +1928,8 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_min_links.attr,
 	&dev_attr_lp_interval.attr,
 	&dev_attr_packets_per_slave.attr,
+	&dev_attr_l2da_default_slave.attr,
+	&dev_attr_l2da_table.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2069584..6c8c851 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -273,6 +273,11 @@ static inline bool bond_is_lb(const struct bonding *bond)
 	return BOND_MODE_IS_LB(bond->params.mode);
 }
 
+static inline bool bond_is_l2da(const struct bonding *bond)
+{
+	return bond->params.mode == BOND_MODE_L2DA;
+}
+
 static inline void bond_set_active_slave(struct slave *slave)
 {
 	slave->backup = 0;
diff --git a/include/uapi/linux/if_bonding.h b/include/uapi/linux/if_bonding.h
index 9635a62..b70ff3e 100644
--- a/include/uapi/linux/if_bonding.h
+++ b/include/uapi/linux/if_bonding.h
@@ -70,6 +70,7 @@
 #define BOND_MODE_8023AD        4
 #define BOND_MODE_TLB           5
 #define BOND_MODE_ALB		6 /* TLB + RLB (receive load balancing) */
+#define BOND_MODE_L2DA          7
 
 /* each slave's link has 4 states */
 #define BOND_LINK_UP    0           /* link is up and running */
-- 
1.8.3.1
