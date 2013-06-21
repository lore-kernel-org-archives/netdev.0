From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Fri, 21 Jun 2013 21:21:43 +0200
Message-ID: <20130621192143.GB30542@redhat.com>
References: <1371820284-13280-7-git-send-email-vfalico@redhat.com>
 <9312.1371838880@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	linux@8192.net, nicolas.2p.debian@free.fr, rick.jones2@hp.com,
	nikolay@redhat.com, mkubecek@suse.cz
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423686Ab3FUTWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 15:22:14 -0400
Content-Disposition: inline
In-Reply-To: <9312.1371838880@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 11:21:20AM -0700, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@redhat.com> wrote:
...snip...
>>--- a/Documentation/networking/bonding.txt
>>+++ b/Documentation/networking/bonding.txt
>>@@ -321,6 +321,23 @@ arp_validate
>>
>> 	This option was added in bonding version 3.1.0.
>>
>>+arp_all_targets
>>+
>>+	Specifies whether, in active-backup mode with arp validation,
>>+	any of the arp_ip_targets should be up to keep the slave up
>>+	(default) or it should go down if at least one of
>>+	arp_ip_targets doesn't reply to arp requests.
>
>	I would write the above as:
>
>	Specifies the quantity of arp_ip_targets that must be reachable
>	in order for the ARP monitor to consider a slave as being up.
>	This option affects only active-backup mode for slaves with
>	arp_validation enabled.

Yeah, a lot more clear. However, doesn't "the quantity" suggest some
number, but not binary (as we have it)?

Hrm, it's an interesting idea btw, to make it accept the exact quantity of
reachable arp_ip_targets to be up, instead of any/all, though I don't think
it'll find use in real world situation. It's easy to implement btw, we
just need to get the n-th least fresh arp_ip_target in slave_last_rx(). And
we can have -1 for all.

If you think that it's viable - I can add it to the next version.

>
>>+
>>+	Possible values are:
>>+
>>+	any or 0
>>+
>>+		consider the slave up if any of the arp_ip_targets is up
>>+
>>+	all or 1
>>+
>>+		consider the slave up if all of the arp_ip_targets are up
>
>	Instead of "if" here I would use "only when" to make the
>distinction clearer.  Instead of "up," I would use "reachable."

Yep, thank you.

>
>>+
>> downdelay
>>
>> 	Specifies the time, in milliseconds, to wait before disabling
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>index f51c379..8a94b21 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -104,6 +104,7 @@ static char *xmit_hash_policy;
>> static int arp_interval = BOND_LINK_ARP_INTERV;
>> static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
>> static char *arp_validate;
>>+static char *arp_all_targets;
>> static char *fail_over_mac;
>> static int all_slaves_active = 0;
>> static struct bond_params bonding_defaults;
>>@@ -166,6 +167,8 @@ module_param(arp_validate, charp, 0);
>> MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes; "
>> 			       "0 for none (default), 1 for active, "
>> 			       "2 for backup, 3 for all");
>>+module_param(arp_all_targets, charp, 0);
>>+MODULE_PARM_DESC(arp_all_targets, "fail on any/all arp targets timeout; 0 for any (default), 1 for all");
>> module_param(fail_over_mac, charp, 0);
>> MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to "
>> 				"the same MAC; 0 for none (default), "
>>@@ -216,6 +219,12 @@ const struct bond_parm_tbl xmit_hashtype_tbl[] = {
>> {	NULL,			-1},
>> };
>>
>>+const struct bond_parm_tbl arp_all_targets_tbl[] = {
>>+{	"any",			BOND_ARP_TARGETS_ANY},
>>+{	"all",			BOND_ARP_TARGETS_ALL},
>>+{	NULL,			-1},
>>+};
>>+
>> const struct bond_parm_tbl arp_validate_tbl[] = {
>> {	"none",			BOND_ARP_VALIDATE_NONE},
>> {	"active",		BOND_ARP_VALIDATE_ACTIVE},
>>@@ -1483,7 +1492,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>> 	struct slave *new_slave = NULL;
>> 	struct sockaddr addr;
>> 	int link_reporting;
>>-	int res = 0;
>>+	int res = 0, i;
>>
>> 	if (!bond->params.use_carrier &&
>> 	    slave_dev->ethtool_ops->get_link == NULL &&
>>@@ -1712,6 +1721,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>
>> 	new_slave->last_arp_rx = jiffies -
>> 		(msecs_to_jiffies(bond->params.arp_interval) + 1);
>>+	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
>>+		new_slave->target_last_arp_rx[i] = new_slave->last_arp_rx;
>>
>> 	if (bond->params.miimon && !bond->params.use_carrier) {
>> 		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
>>@@ -2610,16 +2621,20 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>>
>> static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32 sip, __be32 tip)
>> {
>>+	int i;
>>+
>> 	if (!sip || !bond_has_this_ip(bond, tip)) {
>> 		pr_debug("bva: sip %pI4 tip %pI4 not found\n", &sip, &tip);
>> 		return;
>> 	}
>>
>>-	if (bond_get_targets_ip(bond->params.arp_targets, sip) == -1) {
>>+	i = bond_get_targets_ip(bond->params.arp_targets, sip);
>>+	if (i == -1) {
>> 		pr_debug("bva: sip %pI4 not found in targets\n", &sip);
>> 		return;
>> 	}
>> 	slave->last_arp_rx = jiffies;
>>+	slave->target_last_arp_rx[i] = jiffies;
>> }
>>
>> static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>>@@ -4407,6 +4422,7 @@ int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
>> static int bond_check_params(struct bond_params *params)
>> {
>> 	int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
>>+	int arp_all_targets_value;
>>
>> 	/*
>> 	 * Convert string parameters.
>>@@ -4632,6 +4648,21 @@ static int bond_check_params(struct bond_params *params)
>> 	} else
>> 		arp_validate_value = 0;
>>
>>+	if (arp_all_targets && arp_validate_value) {
>>+		arp_all_targets_value = bond_parse_parm(arp_all_targets,
>>+							arp_all_targets_tbl);
>>+
>>+		if (arp_all_targets_value == -1) {
>>+			pr_err("Error: invalid arp_all_targets_value \"%s\"\n",
>>+			       arp_all_targets);
>>+			arp_all_targets_value = 0;
>>+		}
>>+	} else {
>>+		if (arp_all_targets && !arp_validate_value)
>>+			pr_err("arp_all_targets requires arp_validate\n");
>>+		arp_all_targets_value = 0;
>>+	}
>
>	I would not make setting arp_all_targets conditional on having
>arp_validate also specified.  It should be permissible to set it
>independently of arp_validate, with arp_all_targets having no effect if
>arp_validate is not set.

Yep, thank you, I've also shifted to this idea.

>
>>+
>> 	if (miimon) {
>> 		pr_info("MII link monitoring set to %d ms\n", miimon);
>> 	} else if (arp_interval) {
>>@@ -4696,6 +4727,7 @@ static int bond_check_params(struct bond_params *params)
>> 	params->num_peer_notif = num_peer_notif;
>> 	params->arp_interval = arp_interval;
>> 	params->arp_validate = arp_validate_value;
>>+	params->arp_all_targets = arp_all_targets_value;
>> 	params->updelay = updelay;
>> 	params->downdelay = downdelay;
>> 	params->use_carrier = use_carrier;
>>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>>index ece57f1..c390905 100644
>>--- a/drivers/net/bonding/bond_sysfs.c
>>+++ b/drivers/net/bonding/bond_sysfs.c
>>@@ -443,6 +443,49 @@ static ssize_t bonding_store_arp_validate(struct device *d,
>>
>> static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate,
>> 		   bonding_store_arp_validate);
>>+/*
>>+ * Show and set arp_all_targets.
>>+ */
>>+static ssize_t bonding_show_arp_all_targets(struct device *d,
>>+					 struct device_attribute *attr,
>>+					 char *buf)
>>+{
>>+	struct bonding *bond = to_bond(d);
>>+	int value = bond->params.arp_all_targets;
>>+
>>+	return sprintf(buf, "%s %d\n", arp_all_targets_tbl[value].modename,
>>+		       value);
>>+}
>>+
>>+static ssize_t bonding_store_arp_all_targets(struct device *d,
>>+					  struct device_attribute *attr,
>>+					  const char *buf, size_t count)
>>+{
>>+	struct bonding *bond = to_bond(d);
>>+	int new_value;
>>+
>>+	new_value = bond_parse_parm(buf, arp_all_targets_tbl);
>>+	if (new_value < 0) {
>>+		pr_err("%s: Ignoring invalid arp_all_targets value %s\n",
>>+		       bond->dev->name, buf);
>>+		return -EINVAL;
>>+	}
>>+	if (new_value && !bond->params.arp_validate) {
>>+		pr_err("%s: arp_all_targets requires arp_validate.\n",
>>+		       bond->dev->name);
>>+		return -EINVAL;
>>+	}
>
>	Same comment here re: arp_validate being required.  The current
>restriction adds an ordering requirement (validate must come first), and
>the implementation is such that having arp_all_targets set without
>arp_validate has no effect, so there is no reason to impose this
>restriction.

Yep, thank you.

>
>>+	pr_info("%s: setting arp_all_targets to %s (%d).\n",
>>+		bond->dev->name, arp_all_targets_tbl[new_value].modename,
>>+		new_value);
>>+
>>+	bond->params.arp_all_targets = new_value;
>>+
>>+	return count;
>>+}
>>+
>>+static DEVICE_ATTR(arp_all_targets, S_IRUGO | S_IWUSR,
>>+		   bonding_show_arp_all_targets, bonding_store_arp_all_targets);
>>
>> /*
>>  * Show and store fail_over_mac.  User only allowed to change the
>>@@ -590,10 +633,11 @@ static ssize_t bonding_store_arp_targets(struct device *d,
>> 					 struct device_attribute *attr,
>> 					 const char *buf, size_t count)
>> {
>>-	__be32 newtarget;
>>-	int i = 0, ret = -EINVAL;
>> 	struct bonding *bond = to_bond(d);
>>-	__be32 *targets;
>>+	struct slave *slave;
>>+	__be32 newtarget, *targets;
>>+	unsigned long *targets_rx;
>>+	int ind, i, j, ret = -EINVAL;
>>
>> 	targets = bond->params.arp_targets;
>> 	newtarget = in_aton(buf + 1);
>>@@ -611,8 +655,8 @@ static ssize_t bonding_store_arp_targets(struct device *d,
>> 			goto out;
>> 		}
>>
>>-		i = bond_get_targets_ip(targets, 0); /* first free slot */
>>-		if (i == -1) {
>>+		ind = bond_get_targets_ip(targets, 0); /* first free slot */
>>+		if (ind == -1) {
>> 			pr_err("%s: ARP target table is full!\n",
>> 			       bond->dev->name);
>> 			goto out;
>>@@ -620,7 +664,12 @@ static ssize_t bonding_store_arp_targets(struct device *d,
>>
>> 		pr_info("%s: adding ARP target %pI4.\n", bond->dev->name,
>> 			 &newtarget);
>>-		targets[i] = newtarget;
>>+		/* not to race with bond_arp_rcv */
>>+		write_lock_bh(&bond->lock);
>>+		bond_for_each_slave(bond, slave, i)
>>+			slave->target_last_arp_rx[ind] = jiffies;
>>+		targets[ind] = newtarget;
>>+		write_unlock_bh(&bond->lock);
>> 	} else if (buf[0] == '-')	{
>> 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
>> 			pr_err("%s: invalid ARP target %pI4 specified for removal\n",
>>@@ -628,18 +677,32 @@ static ssize_t bonding_store_arp_targets(struct device *d,
>> 			goto out;
>> 		}
>>
>>-		i = bond_get_targets_ip(targets, newtarget);
>>-		if (i == -1) {
>>-			pr_info("%s: unable to remove nonexistent ARP target %pI4.\n",
>>+		ind = bond_get_targets_ip(targets, newtarget);
>>+		if (ind == -1) {
>>+			pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
>> 				bond->dev->name, &newtarget);
>> 			goto out;
>> 		}
>>
>>+		if (ind == 0 && !targets[1] && bond->params.arp_validate)
>>+			pr_warn("%s: removing last arp target with arp_validate on\n",
>>+				bond->dev->name);
>>+
>
>	There's no warning in the current code for removing the last
>arp_ip_target; I don't think adding one is necessary, particularly if it
>is just for the validate case.

My logic was - if we're currently configured to be up by the arp_validate -
and we removing the last arp_ip_target - then we're either in the process
of shutting down the interface or something is really wrong. And, btw,
there's such an pr_info() for bonding_store_arp_interval():

  588                 if (!bond->params.arp_targets[0])
  589                         pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
  590                                 bond->dev->name);

So, maybe, only change to bond->params.arp_interval instead of arp_validate?

Thank you very much for the review!

>
>	-J
>
>> 		pr_info("%s: removing ARP target %pI4.\n", bond->dev->name,
>> 			&newtarget);
>>-		for (; (i < BOND_MAX_ARP_TARGETS-1) && targets[i+1]; i++)
>>+
>>+		write_lock_bh(&bond->lock);
>>+		bond_for_each_slave(bond, slave, i) {
>>+			targets_rx = slave->target_last_arp_rx;
>>+			j = ind;
>>+			for (; (j < BOND_MAX_ARP_TARGETS-1) && targets[j+1]; j++)
>>+				targets_rx[j] = targets_rx[j+1];
>>+			targets_rx[j] = 0;
>>+		}
>>+		for (i = ind; (i < BOND_MAX_ARP_TARGETS-1) && targets[i+1]; i++)
>> 			targets[i] = targets[i+1];
>> 		targets[i] = 0;
>>+		write_unlock_bh(&bond->lock);
>> 	} else {
>> 		pr_err("no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
>> 		       bond->dev->name);
>>@@ -649,6 +712,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
>>
>> 	ret = count;
>> out:
>>+	rtnl_unlock();
>> 	return ret;
>> }
>> static DEVICE_ATTR(arp_ip_target, S_IRUGO | S_IWUSR , bonding_show_arp_targets, bonding_store_arp_targets);
>>@@ -1623,6 +1687,7 @@ static struct attribute *per_bond_attrs[] = {
>> 	&dev_attr_mode.attr,
>> 	&dev_attr_fail_over_mac.attr,
>> 	&dev_attr_arp_validate.attr,
>>+	&dev_attr_arp_all_targets.attr,
>> 	&dev_attr_arp_interval.attr,
>> 	&dev_attr_arp_ip_target.attr,
>> 	&dev_attr_downdelay.attr,
>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>>index 486e532..3fb73cc 100644
>>--- a/drivers/net/bonding/bonding.h
>>+++ b/drivers/net/bonding/bonding.h
>>@@ -144,6 +144,7 @@ struct bond_params {
>> 	u8 num_peer_notif;
>> 	int arp_interval;
>> 	int arp_validate;
>>+	int arp_all_targets;
>> 	int use_carrier;
>> 	int fail_over_mac;
>> 	int updelay;
>>@@ -179,6 +180,7 @@ struct slave {
>> 	int    delay;
>> 	unsigned long jiffies;
>> 	unsigned long last_arp_rx;
>>+	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
>> 	s8     link;    /* one of BOND_LINK_XXXX */
>> 	s8     new_link;
>> 	u8     backup:1,   /* indicates backup slave. Value corresponds with
>>@@ -322,6 +324,9 @@ static inline bool bond_is_active_slave(struct slave *slave)
>> #define BOND_FOM_ACTIVE			1
>> #define BOND_FOM_FOLLOW			2
>>
>>+#define BOND_ARP_TARGETS_ANY		0
>>+#define BOND_ARP_TARGETS_ALL		1
>>+
>> #define BOND_ARP_VALIDATE_NONE		0
>> #define BOND_ARP_VALIDATE_ACTIVE	(1 << BOND_STATE_ACTIVE)
>> #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
>>@@ -334,11 +339,31 @@ static inline int slave_do_arp_validate(struct bonding *bond,
>> 	return bond->params.arp_validate & (1 << bond_slave_state(slave));
>> }
>>
>>+/* Get the oldest arp which we've received on this slave for bond's
>>+ * arp_targets.
>>+ */
>>+static inline unsigned long slave_oldest_target_arp_rx(struct bonding *bond,
>>+						       struct slave *slave)
>>+{
>>+	int i = 1;
>>+	unsigned long ret = slave->target_last_arp_rx[0];
>>+
>>+	for (; (i < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i]; i++)
>>+		if (time_before(slave->target_last_arp_rx[i], ret))
>>+			ret = slave->target_last_arp_rx[i];
>>+
>>+	return ret;
>>+}
>>+
>> static inline unsigned long slave_last_rx(struct bonding *bond,
>> 					struct slave *slave)
>> {
>>-	if (slave_do_arp_validate(bond, slave))
>>-		return slave->last_arp_rx;
>>+	if (slave_do_arp_validate(bond, slave)) {
>>+		if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
>>+			return slave_oldest_target_arp_rx(bond, slave);
>>+		else
>>+			return slave->last_arp_rx;
>>+	}
>>
>> 	return slave->dev->last_rx;
>> }
>>@@ -486,6 +511,7 @@ extern const struct bond_parm_tbl bond_lacp_tbl[];
>> extern const struct bond_parm_tbl bond_mode_tbl[];
>> extern const struct bond_parm_tbl xmit_hashtype_tbl[];
>> extern const struct bond_parm_tbl arp_validate_tbl[];
>>+extern const struct bond_parm_tbl arp_all_targets_tbl[];
>> extern const struct bond_parm_tbl fail_over_mac_tbl[];
>> extern const struct bond_parm_tbl pri_reselect_tbl[];
>> extern struct bond_parm_tbl ad_select_tbl[];
>>--
>>1.7.1
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
