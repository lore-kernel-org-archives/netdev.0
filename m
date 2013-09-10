From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2] bonding: Make alb learning packet interval
 configurable
Date: Tue, 10 Sep 2013 22:55:42 +0200
Message-ID: <20130910205542.GA31398@redhat.com>
References: <1378822490-28667-1-git-send-email-nhorman@tuxdriver.com>
 <1378845543-14876-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab3IJU5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 16:57:31 -0400
Content-Disposition: inline
In-Reply-To: <1378845543-14876-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 10, 2013 at 04:39:03PM -0400, Neil Horman wrote:
>From: Neil Horman <nhorman@redhat.com>
>
>running bonding in ALB mode requires that learning packets be sent periodically,
>so that the switch knows where to send responding traffic.  However, depending
>on switch configuration, there may not be any need to send traffic at the
>default rate of 3 packets per second, which represents little more than wasted
>data.  Allow the ALB learning packet interval to be made configurable via sysfs
>
>Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: "David S. Miller" <davem@davemloft.net>
>
>---
>Change Notes:
>v2)
>Add documentation

Nice, thank you!

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>---
> Documentation/networking/bonding.txt |  5 +++++
> drivers/net/bonding/bond_alb.c       |  2 +-
> drivers/net/bonding/bond_alb.h       |  8 ++++----
> drivers/net/bonding/bond_main.c      |  1 +
> drivers/net/bonding/bond_sysfs.c     | 39 ++++++++++++++++++++++++++++++++++++
> drivers/net/bonding/bonding.h        |  1 +
> 6 files changed, 51 insertions(+), 5 deletions(-)
>
>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>index 87bbcfe..5928f6f 100644
>--- a/Documentation/networking/bonding.txt
>+++ b/Documentation/networking/bonding.txt
>@@ -1362,6 +1362,11 @@ To add ARP targets:
> To remove an ARP target:
> # echo -192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
>
>+To configure the interval between learning packet transmits:
>+# echo 12 > /sys/class/net/bond0/bonding/lp_interval
>+	NOTE: the lp_inteval is the number of seconds between instances where
>+the bonding driver sends learning packets to each slaves peer switch.
>+
> Example Configuration
> ---------------------
> 	We begin with the same example that is shown in section 3.3,
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index 91f179d..f428ef57 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -1472,7 +1472,7 @@ void bond_alb_monitor(struct work_struct *work)
> 	bond_info->lp_counter++;
>
> 	/* send learning packets */
>-	if (bond_info->lp_counter >= BOND_ALB_LP_TICKS) {
>+	if (bond_info->lp_counter >= BOND_ALB_LP_TICKS(bond)) {
> 		/* change of curr_active_slave involves swapping of mac addresses.
> 		 * in order to avoid this swapping from happening while
> 		 * sending the learning packets, the curr_slave_lock must be held for
>diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>index 28d8e4c..e78fd9b 100644
>--- a/drivers/net/bonding/bond_alb.h
>+++ b/drivers/net/bonding/bond_alb.h
>@@ -36,14 +36,14 @@ struct slave;
> 					 * Used for division - never set
> 					 * to zero !!!
> 					 */
>-#define BOND_ALB_LP_INTERVAL	    1	/* In seconds, periodic send of
>-					 * learning packets to the switch
>-					 */
>+#define BOND_ALB_LP_INTERVAL(bond) (bond->params.lp_interval)	/* In seconds, periodic send of
>+								 * learning packets to the switch
>+								 */
>
> #define BOND_TLB_REBALANCE_TICKS (BOND_TLB_REBALANCE_INTERVAL \
> 				  * ALB_TIMER_TICKS_PER_SEC)
>
>-#define BOND_ALB_LP_TICKS (BOND_ALB_LP_INTERVAL \
>+#define BOND_ALB_LP_TICKS(bond) (BOND_ALB_LP_INTERVAL(bond) \
> 			   * ALB_TIMER_TICKS_PER_SEC)
>
> #define TLB_HASH_TABLE_SIZE 256	/* The size of the clients hash table.
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 39e5b1c..b8c9ec3 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4416,6 +4416,7 @@ static int bond_check_params(struct bond_params *params)
> 	params->all_slaves_active = all_slaves_active;
> 	params->resend_igmp = resend_igmp;
> 	params->min_links = min_links;
>+	params->lp_interval = 1;
>
> 	if (primary) {
> 		strncpy(params->primary, primary, IFNAMSIZ);
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index ce46776..4532259 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1680,6 +1680,44 @@ out:
> static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
> 		   bonding_show_resend_igmp, bonding_store_resend_igmp);
>
>+
>+static ssize_t bonding_show_lp_interval(struct device *d,
>+					struct device_attribute *attr,
>+					char *buf)
>+{
>+	struct bonding *bond = to_bond(d);
>+	return sprintf(buf, "%d\n", bond->params.lp_interval);
>+}
>+
>+static ssize_t bonding_store_lp_interval(struct device *d,
>+					 struct device_attribute *attr,
>+					 const char *buf, size_t count)
>+{
>+	struct bonding *bond = to_bond(d);
>+	int new_value, ret = count;
>+
>+	if (sscanf(buf, "%d", &new_value) != 1) {
>+		pr_err("%s: no lp interval value specified.\n",
>+			bond->dev->name);
>+		ret = -EINVAL;
>+		goto out;
>+	}
>+
>+	if (new_value <= 0) {
>+		pr_err ("%s: lp_interval must be between 1 and %d\n",
>+			bond->dev->name, INT_MAX);
>+		ret = -EINVAL;
>+		goto out;
>+	}
>+
>+	bond->params.lp_interval = new_value;
>+out:
>+	return ret;
>+}
>+
>+static DEVICE_ATTR(lp_interval, S_IRUGO | S_IWUSR,
>+		   bonding_show_lp_interval, bonding_store_lp_interval);
>+
> static struct attribute *per_bond_attrs[] = {
> 	&dev_attr_slaves.attr,
> 	&dev_attr_mode.attr,
>@@ -1710,6 +1748,7 @@ static struct attribute *per_bond_attrs[] = {
> 	&dev_attr_all_slaves_active.attr,
> 	&dev_attr_resend_igmp.attr,
> 	&dev_attr_min_links.attr,
>+	&dev_attr_lp_interval.attr,
> 	NULL,
> };
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index f7ab161..4bd9d5b 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -176,6 +176,7 @@ struct bond_params {
> 	int tx_queues;
> 	int all_slaves_active;
> 	int resend_igmp;
>+	int lp_interval;
> };
>
> struct bond_parm_tbl {
>-- 
>1.8.3.1
>
