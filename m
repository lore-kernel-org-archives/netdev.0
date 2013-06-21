From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 6/6] bonding: add an option to fail when any
 of arp_ip_target is inaccessible
Date: Fri, 21 Jun 2013 20:53:51 +0200
Message-ID: <20130621185351.GA30542@redhat.com>
References: <1371820284-13280-7-git-send-email-vfalico@redhat.com>
 <51C49666.1030407@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com, mkubecek@suse.cz
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423424Ab3FUSyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 14:54:39 -0400
Content-Disposition: inline
In-Reply-To: <51C49666.1030407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 08:07:34PM +0200, Nikolay Aleksandrov wrote:
>On 06/21/2013 03:11 PM, Veaceslav Falico wrote:
...snip...
>>  out:
>>+	rtnl_unlock();
>A leftover rtnl_unlock here.

Great catch, thank you!

>
>Nik
>
>>  	return ret;
>>  }
>>  static DEVICE_ATTR(arp_ip_target, S_IRUGO | S_IWUSR , bonding_show_arp_targets, bonding_store_arp_targets);
>>@@ -1623,6 +1687,7 @@ static struct attribute *per_bond_attrs[] = {
>>  	&dev_attr_mode.attr,
>>  	&dev_attr_fail_over_mac.attr,
>>  	&dev_attr_arp_validate.attr,
>>+	&dev_attr_arp_all_targets.attr,
>>  	&dev_attr_arp_interval.attr,
>>  	&dev_attr_arp_ip_target.attr,
>>  	&dev_attr_downdelay.attr,
>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>>index 486e532..3fb73cc 100644
>>--- a/drivers/net/bonding/bonding.h
>>+++ b/drivers/net/bonding/bonding.h
>>@@ -144,6 +144,7 @@ struct bond_params {
>>  	u8 num_peer_notif;
>>  	int arp_interval;
>>  	int arp_validate;
>>+	int arp_all_targets;
>>  	int use_carrier;
>>  	int fail_over_mac;
>>  	int updelay;
>>@@ -179,6 +180,7 @@ struct slave {
>>  	int    delay;
>>  	unsigned long jiffies;
>>  	unsigned long last_arp_rx;
>>+	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
>>  	s8     link;    /* one of BOND_LINK_XXXX */
>>  	s8     new_link;
>>  	u8     backup:1,   /* indicates backup slave. Value corresponds with
>>@@ -322,6 +324,9 @@ static inline bool bond_is_active_slave(struct slave *slave)
>>  #define BOND_FOM_ACTIVE			1
>>  #define BOND_FOM_FOLLOW			2
>>
>>+#define BOND_ARP_TARGETS_ANY		0
>>+#define BOND_ARP_TARGETS_ALL		1
>>+
>>  #define BOND_ARP_VALIDATE_NONE		0
>>  #define BOND_ARP_VALIDATE_ACTIVE	(1 << BOND_STATE_ACTIVE)
>>  #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
>>@@ -334,11 +339,31 @@ static inline int slave_do_arp_validate(struct bonding *bond,
>>  	return bond->params.arp_validate & (1 << bond_slave_state(slave));
>>  }
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
>>  static inline unsigned long slave_last_rx(struct bonding *bond,
>>  					struct slave *slave)
>>  {
>>-	if (slave_do_arp_validate(bond, slave))
>>-		return slave->last_arp_rx;
>>+	if (slave_do_arp_validate(bond, slave)) {
>>+		if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
>>+			return slave_oldest_target_arp_rx(bond, slave);
>>+		else
>>+			return slave->last_arp_rx;
>>+	}
>>
>>  	return slave->dev->last_rx;
>>  }
>>@@ -486,6 +511,7 @@ extern const struct bond_parm_tbl bond_lacp_tbl[];
>>  extern const struct bond_parm_tbl bond_mode_tbl[];
>>  extern const struct bond_parm_tbl xmit_hashtype_tbl[];
>>  extern const struct bond_parm_tbl arp_validate_tbl[];
>>+extern const struct bond_parm_tbl arp_all_targets_tbl[];
>>  extern const struct bond_parm_tbl fail_over_mac_tbl[];
>>  extern const struct bond_parm_tbl pri_reselect_tbl[];
>>  extern struct bond_parm_tbl ad_select_tbl[];
>>
>
