From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] bonding: add min links parameter to 802.3ad
Date: Wed, 22 Jun 2011 12:54:39 -0700
Message-ID: <20110622125439.44e47a2c@nehalam.ftrdhcpuser.net>
References: <20110622105408.06fd4788@nehalam.ftrdhcpuser.net>
	<4E02452E.2030307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60184 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758014Ab1FVTyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 15:54:50 -0400
In-Reply-To: <4E02452E.2030307@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for a configuring the minimum number of links that
must be active before asserting carrier. It is similar to the Cisco
EtherChannel min-links feature. This allows setting the minimum number
of member ports that must be up (link-up state) before marking the
bond device as up (carrier on). This is useful for situations where
higher level services such as clustering want to ensure a minimum
number of low bandwidth links are active before switchover.

See:
   http://bugzilla.vyatta.com/show_bug.cgi?id=7196

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - need to transition to carrier_off if insufficient number of links
     and whitespace cleanup

 drivers/net/bonding/bond_3ad.c    |    8 ++++++--
 drivers/net/bonding/bond_main.c   |    5 +++++
 drivers/net/bonding/bond_procfs.c |    1 +
 drivers/net/bonding/bond_sysfs.c  |   35 +++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h     |    1 +
 5 files changed, 48 insertions(+), 2 deletions(-)

--- a/drivers/net/bonding/bond_main.c	2011-06-22 09:06:40.895998636 -0700
+++ b/drivers/net/bonding/bond_main.c	2011-06-22 10:11:52.855974841 -0700
@@ -98,6 +98,7 @@ static char *mode;
 static char *primary;
 static char *primary_reselect;
 static char *lacp_rate;
+static int min_links;
 static char *ad_select;
 static char *xmit_hash_policy;
 static int arp_interval = BOND_LINK_ARP_INTERV;
@@ -150,6 +151,9 @@ module_param(ad_select, charp, 0);
 MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic; "
 			    "0 for stable (default), 1 for bandwidth, "
 			    "2 for count");
+module_param(min_links, int, 0);
+MODULE_PARM_DESC(min_links, "Minimum number of available links before turning on carrier");
+
 module_param(xmit_hash_policy, charp, 0);
 MODULE_PARM_DESC(xmit_hash_policy, "balance-xor and 802.3ad hashing method; "
 				   "0 for layer 2 (default), 1 for layer 3+4, "
@@ -4798,6 +4802,7 @@ static int bond_check_params(struct bond
 	params->tx_queues = tx_queues;
 	params->all_slaves_active = all_slaves_active;
 	params->resend_igmp = resend_igmp;
+	params->min_links = min_links;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
--- a/drivers/net/bonding/bond_procfs.c	2011-06-22 09:17:04.391998454 -0700
+++ b/drivers/net/bonding/bond_procfs.c	2011-06-22 09:27:09.815997950 -0700
@@ -125,6 +125,7 @@ static void bond_info_show_master(struct
 		seq_puts(seq, "\n802.3ad info\n");
 		seq_printf(seq, "LACP rate: %s\n",
 			   (bond->params.lacp_fast) ? "fast" : "slow");
+		seq_printf(seq, "Min links: %d\n", bond->params.min_links);
 		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
 			   ad_select_tbl[bond->params.ad_select].modename);
 
--- a/drivers/net/bonding/bond_sysfs.c	2011-06-22 09:04:50.295998865 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2011-06-22 12:46:57.123624800 -0700
@@ -819,6 +819,38 @@ out:
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR,
 		   bonding_show_lacp, bonding_store_lacp);
 
+static ssize_t bonding_show_min_links(struct device *d,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.min_links);
+}
+
+static ssize_t bonding_store_min_links(struct device *d,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
+{
+	struct bonding *bond = to_bond(d);
+	int ret;
+	unsigned int new_value;
+
+	ret = kstrtouint(buf, 0, &new_value);
+	if (ret < 0) {
+		pr_err("%s: Ignoring invalid min links value %s.\n",
+		       bond->dev->name, buf);
+		return ret;
+	}
+
+	pr_info("%s: Setting min links value to %u\n",
+		bond->dev->name, new_value);
+	bond->params.min_links = new_value;
+	return count;
+}
+static DEVICE_ATTR(min_links, S_IRUGO | S_IWUSR,
+		   bonding_show_min_links, bonding_store_min_links);
+
 static ssize_t bonding_show_ad_select(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
@@ -1601,6 +1633,7 @@ static struct attribute *per_bond_attrs[
 	&dev_attr_queue_id.attr,
 	&dev_attr_all_slaves_active.attr,
 	&dev_attr_resend_igmp.attr,
+	&dev_attr_min_links.attr,
 	NULL,
 };
 
--- a/drivers/net/bonding/bonding.h	2011-06-22 09:05:32.351998841 -0700
+++ b/drivers/net/bonding/bonding.h	2011-06-22 09:27:23.959999290 -0700
@@ -147,6 +147,7 @@ struct bond_params {
 	int updelay;
 	int downdelay;
 	int lacp_fast;
+	unsigned int min_links;
 	int ad_select;
 	char primary[IFNAMSIZ];
 	int primary_reselect;
--- a/drivers/net/bonding/bond_3ad.c	2011-06-22 08:43:25.599999586 -0700
+++ b/drivers/net/bonding/bond_3ad.c	2011-06-22 12:51:43.431614028 -0700
@@ -2342,8 +2342,17 @@ void bond_3ad_handle_link_change(struct
  */
 int bond_3ad_set_carrier(struct bonding *bond)
 {
-	if (__get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator))) {
-		if (!netif_carrier_ok(bond->dev)) {
+	struct aggregator *active;
+
+	active = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
+	if (active) {
+		/* are enough slaves available to consider link up? */
+		if (active->num_of_ports < bond->params.min_links) {
+			if (netif_carrier_ok(bond->dev)) {
+				netif_carrier_off(bond->dev);
+				return 1;
+			}
+		} else if (!netif_carrier_ok(bond->dev)) {
 			netif_carrier_on(bond->dev);
 			return 1;
 		}
