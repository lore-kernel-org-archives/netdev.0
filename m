From: Krisztian Ivancso <github-ivan@ivancso.net>
Subject: Re: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad
Date: Fri, 16 Aug 2013 04:07:38 +0200
Message-ID: <520D896A.50902@ivancso.net>
References: <5208C4BA.9020605@ivancso.net> <520986DC.4030805@huawei.com> <5209FA49.6030800@ivancso.net> <5209FEBC.4050305@huawei.com> <520A11CD.8060400@ivancso.net> <19765.1376418334@death.nxdomain> <520AC296.2080503@ivancso.net> <520AE16B.3040705@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhandler.info ([217.116.47.195]:56325 "EHLO mailhandler.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974Ab3HPCHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 22:07:51 -0400
In-Reply-To: <520AE16B.3040705@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2013 03:46 AM, Ding Tianhong wrote:
> On 2013/8/14 7:34, Krisztian Ivancso wrote:
>> On 08/13/2013 08:25 PM, Jay Vosburgh wrote:
>>> Krisztian Ivancso <github-ivan@ivancso.net> wrote:
>>>
>>>> On 08/13/2013 11:39 AM, Ding Tianhong wrote:
>>>>> On 2013/8/13 17:20, Krisztian Ivancso wrote:
>>>>>> On 08/13/2013 03:07 AM, Ding Tianhong wrote:
>>>>>>> On 2013/8/12 19:19, Krisztian Ivancso wrote:
>>>>>>>> >From 472fffa5a8f170daed9e4cc677af8e2560b86be2 Mon Sep 17 00:00:00 2001
>>>>>>>> From: Krisztian Ivancso <github-ivan@ivancso.net>
>>>>>>>> Date: Sun, 11 Aug 2013 20:30:44 +0200
>>>>>>>> Subject: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad ports
>>>>>
>>>>> ok, for example: the bonding has four slave, slave1 and slave2 aggregation to 1 group,
>>>>> and slave3 and slave4 aggregtion to 2 group, how you distinguish the 1 and 2 group by initialize id.
>>>>
>>>> this is not possible, because all slave have to be a member of the same
>>>> aggregation group.
>>>
>>> 	Just on the above point, bonding can group slaves into multiple
>>> aggregators, but only one aggregator will be active at any given time.
>>>
>>> 	To answer the question, the four slaves would each be given
>>> unique port IDs that do not conflict.
>>>
>>>> i think we misunderstood each other.
>>>>
>>>> here is a new example:
>>>> - switch1 is a switch with a configured lag with two members ports
>>>>  (member1 and member2)
>>>> - two linux (linux1 and linux2) box with a configured bonding device
>>>>  (bond0) with the same MAC set in both box and one
>>>>  slave on each
>>>> - lacp_port_id is set to 10 in linux1 and 20 in linux2
>>>>
>>>> you can attach the slave from both linux boxes to the same
>>>> lag on switch1. (slave from linux1 to port member1 and
>>>> slave from linux2 to port member2 on switch1)
>>>>
>>>> port id must be unique within a system.
>>>> bonding implementation set a unique system id for every bonding device
>>>> which is derived from MAC of one of the slave interfaces.
>>>>
>>>> if we use the current bonding implementation second linux box can't be
>>>> a member on switch1 because port id is 1 in both linux bonding device.
>>>>
>>>> if we can set different starting port id for bonding in different boxes
>>>> the second box can be a member also.
>>>
>>> 	I understand what you're trying to do here (permit multiple
>>> instances of bonding on different systems to connect to a single
>>> aggregator on a switch), and I don't really have a problem with it in
>>> general.
>>>
>>> 	I do have some comments:
>>>
>>> 	First, altering the lacp_port_id (via sysfs) should only be
>>> permitted when there are no slaves in the bond, otherwise the
>>> /proc/net/bonding/bond0 output for the first port id will not match the
>>> actual first port id value assigned to the slaves.  As a practical
>>> matter, altering lacp_port_id while slaves are present in the bond has
>>> no effect until all slaves are released and the first new slave is
>>> added, so this is not reducing functionality.

fixed in bonding_store_lacp_port_id():
(        struct slave *first_slave = bond_first_slave(bond);
        if (first_slave) {
                pr_err("%s: Can't set port id because device have slave(s).\n",
                       bond->dev->name);
                return -EPERM;
        }
)

>>>
>>> 	Second, the lacp_port_id is global across all bonds created
>>> within the loaded module, and so multiple bonds will all use the same
>>> starting value.  Setting the lacp_port_id via sysfs has no effect, as it
>>> alters a per-bond value, bond->params.lacp_port_id, that is never
>>> actually used to set the port ID of a first slave in bond_enslave.
>>>
>>> 	The global default value should only be used to initialize the
>>> per-bond value when a bond is created, and that per-bond value should be
>>> used when setting the port id in bond_enslave().  The per-bond value is
>>> already displayed in /proc/net/bonding/bond0, and is the value modified
>>> by the sysfs functions

global default value is used to initialize bonding_defaults.lacp_port_id now.
(params->lacp_port_id = lacp_port_id;)

first slave is initialized by per-bond port id in bond_enslave().
(SLAVE_AD_INFO(new_slave).id = bond->params.lacp_port_id;)

>>>
>>> 	Third, consider adding the port ID to the 803.2ad section in
>>> bond_info_show_slave.

slave port id is shown in bond_info_show_slave():
(seq_printf(seq, "Slave port id: %d\n", SLAVE_AD_INFO(slave).id);)

>>
>> Thanks for these great comments. I'll soon fix sysfs related bug and
>> rework patch.
>>
>>>
>>> 	Lastly, I think this should be tested against systems other than
>>> Cisco to insure that it really interoperates with, for example,
>>> Juniper's methodology for spanning an aggregator across physical
>>> chassis.  I'm not sure why it wouldn't, but once new functionality
>>> becomes part of the kernel, changing it in non-backwards compatible ways
>>> is difficult.
>>
> 
> agreed
> 
> Ding Tianhong
port id overflow check in bond_enslave():
(                        prev_slave = bond_prev_slave(bond, new_slave);
                        if (SLAVE_AD_INFO(prev_slave).id == 65535) {
                                pr_err("%s: Error: Couldn't add new slave (%s) because maximum port id (65535) is reached.\n",
                                       bond_dev->name, slave_dev->name);
                                res = -EPERM;
                                goto err_detach;
                        }
)
i'm not sure "goto err_detach" is the proper jump but it seems to be good.

i hope next week i can test this solution with devices other than cisco.
(older juniper and low-end hp 3com)

btw i welcome any test with any network devices related to this feature.




>From 974763f179cf741a8b9b0459be2e9c84d23e8989 Mon Sep 17 00:00:00 2001
From: Krisztian Ivancso <github-ivan@ivancso.net>
Date: Fri, 16 Aug 2013 02:25:45 +0200
Subject: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad

---
 drivers/net/bonding/bond_main.c   | 24 +++++++++++++++++++++--
 drivers/net/bonding/bond_procfs.c |  2 ++
 drivers/net/bonding/bond_sysfs.c  | 40 +++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h     |  1 +
 4 files changed, 65 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4264a76..3580866 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -110,6 +110,7 @@ static char *fail_over_mac;
 static int all_slaves_active;
 static struct bond_params bonding_defaults;
 static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
+static int lacp_port_id = 1;

 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -150,7 +151,7 @@ module_param(lacp_rate, charp, 0);
 MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner; "
 			    "0 for slow, 1 for fast");
 module_param(ad_select, charp, 0);
-MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic; "
+MODULE_PARM_DESC(ad_select, "802.3ad aggregation selection logic; "
 			    "0 for stable (default), 1 for bandwidth, "
 			    "2 for count");
 module_param(min_links, int, 0);
@@ -181,6 +182,8 @@ MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface"
 module_param(resend_igmp, int, 0);
 MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on "
 			      "link failure");
+module_param(lacp_port_id, int, 0);
+MODULE_PARM_DESC(lacp_port_id, "802.3ad port id to send to switch in LACPDU");

 /*----------------------------- Global variables ----------------------------*/

@@ -1699,7 +1702,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		bond_set_slave_inactive_flags(new_slave);
 		/* if this is the first slave */
 		if (bond_first_slave(bond) == new_slave) {
-			SLAVE_AD_INFO(new_slave).id = 1;
+			SLAVE_AD_INFO(new_slave).id = bond->params.lacp_port_id;
 			/* Initialize AD with the number of times that the AD timer is called in 1 second
 			 * can be called only after the mac address of the bond is set
 			 */
@@ -1708,6 +1711,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			struct slave *prev_slave;

 			prev_slave = bond_prev_slave(bond, new_slave);
+			if (SLAVE_AD_INFO(prev_slave).id == 65535) {
+				pr_err("%s: Error: Couldn't add new slave (%s) because maximum port id (65535) is reached.\n",
+				       bond_dev->name, slave_dev->name);
+				res = -EPERM;
+				goto err_detach;
+			}
 			SLAVE_AD_INFO(new_slave).id =
 				SLAVE_AD_INFO(prev_slave).id + 1;
 		}
@@ -4377,6 +4386,16 @@ static int bond_check_params(struct bond_params *params)
 		resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 	}

+	if (bond_mode == BOND_MODE_8023AD) {
+		/* we set upper limit to 65000 because new slaves will increase port
+                   id so we don't want id to overflow */
+		if (lacp_port_id < 1 || lacp_port_id > 65000) {
+			pr_warning("Warning: lacp_port_id (%d) should be between "
+				   "1 and 65000, resetting to 1\n", lacp_port_id);
+			lacp_port_id = 1;
+		}
+	}
+
 	/* reset values for TLB/ALB */
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
@@ -4565,6 +4584,7 @@ static int bond_check_params(struct bond_params *params)
 	params->all_slaves_active = all_slaves_active;
 	params->resend_igmp = resend_igmp;
 	params->min_links = min_links;
+	params->lacp_port_id = lacp_port_id;

 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 20a6ee2..96977d5 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -129,6 +129,7 @@ static void bond_info_show_master(struct seq_file *seq)
 		seq_printf(seq, "Min links: %d\n", bond->params.min_links);
 		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
 			   ad_select_tbl[bond->params.ad_select].modename);
+		seq_printf(seq, "802.3ad starting port id: %d\n", bond->params.lacp_port_id);

 		if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
@@ -193,6 +194,7 @@ static void bond_info_show_slave(struct seq_file *seq,
 				   agg->aggregator_identifier);
 		else
 			seq_puts(seq, "Aggregator ID: N/A\n");
+		seq_printf(seq, "Slave port id: %d\n", SLAVE_AD_INFO(slave).id);
 	}
 	seq_printf(seq, "Slave queue ID: %d\n", slave->queue_id);
 }
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0f539de..35b4bdd 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -920,6 +920,45 @@ static ssize_t bonding_store_min_links(struct device *d,
 static DEVICE_ATTR(min_links, S_IRUGO | S_IWUSR,
 		   bonding_show_min_links, bonding_store_min_links);

+static ssize_t bonding_show_lacp_port_id(struct device *d,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.lacp_port_id);
+}
+
+static ssize_t bonding_store_lacp_port_id(struct device *d,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
+{
+	struct bonding *bond = to_bond(d);
+	int ret;
+	unsigned int new_value;
+
+	struct slave *first_slave = bond_first_slave(bond);
+	if (first_slave) {
+		pr_err("%s: Can't set port id because device have slave(s).\n",
+		       bond->dev->name);
+		return -EPERM;
+	}
+
+	ret = kstrtouint(buf, 0, &new_value);
+	if ((ret < 0) || (new_value < 1) || (new_value > 65000)) {
+		pr_err("%s: Ignoring invalid 802.3ad port id value %s.\n",
+		       bond->dev->name, buf);
+		return -EINVAL;
+	}
+
+	pr_info("%s: Setting 802.3ad port id value to %u\n",
+		bond->dev->name, new_value);
+	bond->params.lacp_port_id = new_value;
+	return count;
+}
+static DEVICE_ATTR(lacp_port_id, S_IRUGO | S_IWUSR,
+		   bonding_show_lacp_port_id, bonding_store_lacp_port_id);
+
 static ssize_t bonding_show_ad_select(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
@@ -1705,6 +1744,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_all_slaves_active.attr,
 	&dev_attr_resend_igmp.attr,
 	&dev_attr_min_links.attr,
+	&dev_attr_lacp_port_id.attr,
 	NULL,
 };

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4bf52d5..8a078d6 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -176,6 +176,7 @@ struct bond_params {
 	int tx_queues;
 	int all_slaves_active;
 	int resend_igmp;
+	int lacp_port_id;
 };

 struct bond_parm_tbl {
-- 
1.8.3.1
