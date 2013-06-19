From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 6/6] bonding: add an option to fail when any of
 arp_ip_target is inaccessible
Date: Thu, 20 Jun 2013 00:24:59 +0200
Message-ID: <20130619222459.GB10910@redhat.com>
References: <1371663286-12518-7-git-send-email-vfalico@redhat.com>
 <51C2299C.2040403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934961Ab3FSWZW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 18:25:22 -0400
Content-Disposition: inline
In-Reply-To: <51C2299C.2040403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 19, 2013 at 11:58:52PM +0200, Nikolay Aleksandrov wrote:
>On 19/06/13 19:34, Veaceslav Falico wrote:
...snip...
>> @@ -2599,17 +2610,21 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>>
>>  static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32 sip, __be32 tip)
>>  {
>> +	int i;
>> +
>>  	if (!bond_has_this_ip(bond, tip)) {
>>  		pr_debug("bva: tip %pI4 not found\n", &tip);
>>  		return;
>>  	}
>>
>> -	if (bond_get_targets_ip(bond->params.arp_targets, sip) == -1) {
>> +	i = bond_get_targets_ip(bond->params.arp_targets, sip);
>> +	if (i == -1) {
>>  		pr_debug("bva: sip %pI4 not found in targets\n", &sip);
>>  		return;
>>  	}
>>
>>  	slave->last_arp_rx = jiffies;
>> +	slave->target_last_arp_rx[i] = jiffies;
>>  }
>Here again it's probably good to check if sip != 0 (0.0.0.0) because you
>can alter the jiffies of the first free slot otherwise.

Agree, I'll fix it in the previous patch (2/6) in v2.

>>
>>  static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
>> @@ -4381,6 +4396,7 @@ int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
>>  static int bond_check_params(struct bond_params *params)
>>  {
>>  	int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
>> +	int arp_all_targets_value;
>>
>>  	/*
>>  	 * Convert string parameters.
>> @@ -4606,6 +4622,23 @@ static int bond_check_params(struct bond_params *params)
>>  	} else
>>  		arp_validate_value = 0;
>>
>> +	if (arp_all_targets) {
>> +		if (!arp_validate_value) {
>> +			pr_err("arp_all_targets requires arp_validate\n");
>> +			return -EINVAL;
>> +		}
>I don't think it's necessary to prevent module from loading. You can
>just revert to default value with an error message IMO.

Yep, seems logic, will update.

>> +
>> +		arp_all_targets_value = bond_parse_parm(arp_all_targets,
>> +							arp_all_targets_tbl);
>> +
>> +		if (arp_all_targets_value == -1) {
>> +			pr_err("Error: invalid arp_all_targets_value \"%s\"\n",
>> +			       arp_all_targets);
>> +			return -EINVAL;
>> +		}
>Again I think you can just default here, no need to prevent module from
>loading, an error message would be enough IMO.

Ditto.

>> +	} else
>> +		arp_all_targets_value = 0;
>> +
>"else" statement should be in { } since the "if" before is (CodingStyle).

Yep.

>>  	if (miimon) {
>>  		pr_info("MII link monitoring set to %d ms\n", miimon);
>>  	} else if (arp_interval) {
>> @@ -4670,6 +4703,7 @@ static int bond_check_params(struct bond_params *params)
>>  	params->num_peer_notif = num_peer_notif;
>>  	params->arp_interval = arp_interval;
>>  	params->arp_validate = arp_validate_value;
>> +	params->arp_all_targets = arp_all_targets_value;
>>  	params->updelay = updelay;
>>  	params->downdelay = downdelay;
>>  	params->use_carrier = use_carrier;
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>> index e680151..09fb9f7 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -443,6 +443,49 @@ static ssize_t bonding_store_arp_validate(struct device *d,
>>
>>  static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate,
>>  		   bonding_store_arp_validate);
>> +/*
>> + * Show and set arp_all_targets.
>> + */
>> +static ssize_t bonding_show_arp_all_targets(struct device *d,
>> +					 struct device_attribute *attr,
>> +					 char *buf)
>> +{
>> +	struct bonding *bond = to_bond(d);
>> +	int value = bond->params.arp_all_targets;
>> +
>> +	return sprintf(buf, "%s %d\n", arp_all_targets_tbl[value].modename,
>> +		       value);
>> +}
>> +
>> +static ssize_t bonding_store_arp_all_targets(struct device *d,
>> +					  struct device_attribute *attr,
>> +					  const char *buf, size_t count)
>> +{
>> +	int new_value;
>> +	struct bonding *bond = to_bond(d);
>I'd say struct first, int second, but that's just a minor nitpick/opinion.

Yep.

>> +
>> +	new_value = bond_parse_parm(buf, arp_all_targets_tbl);
>> +	if (new_value < 0) {
>> +		pr_err("%s: Ignoring invalid arp_all_targets value %s\n",
>> +		       bond->dev->name, buf);
>> +		return -EINVAL;
>> +	}
>> +	if (new_value && !bond->params.arp_validate) {
>> +		pr_err("%s: arp_all_targets requires arp_validate.\n",
>> +		       bond->dev->name);
>> +		return -EINVAL;
>> +	}
>> +	pr_info("%s: setting arp_all_targets to %s (%d).\n",
>> +		bond->dev->name, arp_all_targets_tbl[new_value].modename,
>> +		new_value);
>> +
>> +	bond->params.arp_all_targets = new_value;
>> +
>> +	return count;
>> +}
>> +
>> +static DEVICE_ATTR(arp_all_targets, S_IRUGO | S_IWUSR,
>> +		   bonding_show_arp_all_targets, bonding_store_arp_all_targets);
>>
>>  /*
>>   * Show and store fail_over_mac.  User only allowed to change the
>> @@ -1625,6 +1668,7 @@ static struct attribute *per_bond_attrs[] = {
>>  	&dev_attr_mode.attr,
>>  	&dev_attr_fail_over_mac.attr,
>>  	&dev_attr_arp_validate.attr,
>> +	&dev_attr_arp_all_targets.attr,
>>  	&dev_attr_arp_interval.attr,
>>  	&dev_attr_arp_ip_target.attr,
>>  	&dev_attr_downdelay.attr,
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index 7feab6c..29fc8d6 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -144,6 +144,7 @@ struct bond_params {
>>  	u8 num_peer_notif;
>>  	int arp_interval;
>>  	int arp_validate;
>> +	int arp_all_targets;
>>  	int use_carrier;
>>  	int fail_over_mac;
>>  	int updelay;
>> @@ -179,6 +180,7 @@ struct slave {
>>  	int    delay;
>>  	unsigned long jiffies;
>>  	unsigned long last_arp_rx;
>> +	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
>This is the part I resist since struct slave is huge as it is, and this
>is just making it bigger. I know it's necessary and all, just saying :-)

Well, I can't think of a better option. We anyway kmalloc the slave
structure, so it's useless to alloc. I'm all ears for better ideas, though
:).

>>  	s8     link;    /* one of BOND_LINK_XXXX */
>>  	s8     new_link;
>>  	u8     backup:1,   /* indicates backup slave. Value corresponds with
>> @@ -322,6 +324,9 @@ static inline bool bond_is_active_slave(struct slave *slave)
>>  #define BOND_FOM_ACTIVE			1
>>  #define BOND_FOM_FOLLOW			2
>>
>> +#define BOND_ARP_TARGETS_ANY		0
>> +#define BOND_ARP_TARGETS_ALL		1
>> +
>>  #define BOND_ARP_VALIDATE_NONE		0
>>  #define BOND_ARP_VALIDATE_ACTIVE	(1 << BOND_STATE_ACTIVE)
>>  #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
>> @@ -334,11 +339,31 @@ static inline int slave_do_arp_validate(struct bonding *bond,
>>  	return bond->params.arp_validate & (1 << bond_slave_state(slave));
>>  }
>>
>> +/* Get the oldest arp which we've received on this slave for bond's
>> + * arp_targets.
>> + */
>> +static inline unsigned long slave_oldest_target_arp_rx(struct bonding *bond,
>> +						       struct slave *slave)
>> +{
>> +	int i = 1;
>> +	unsigned long ret = slave->target_last_arp_rx[0];
>> +
>> +	for (; (i < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i]; i++)
>> +		if (time_before(slave->target_last_arp_rx[i], ret))
>> +			ret = slave->target_last_arp_rx[i];
>> +
>> +	return ret;
>> +}
>> +
>>  static inline unsigned long slave_last_rx(struct bonding *bond,
>>  					struct slave *slave)
>>  {
>> -	if (slave_do_arp_validate(bond, slave))
>> -		return slave->last_arp_rx;
>> +	if (slave_do_arp_validate(bond, slave)) {
>> +		if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
>> +			return slave_oldest_target_arp_rx(bond, slave);
>> +		else
>> +			return slave->last_arp_rx;
>I wonder if there's a chance to return 0 from slave_oldest_target_arp_rx
>here in the case of no arp IP targets or even in the case of adding an
>IP target after the enslaving and prior to receiving an ARP from it,
>since there're places where some values can be decremented from that and
>we'll end up with 0 - something.
>Because in the old case last_arp_rx was set while enslaving.

Great catch! It gets even more interesting when we try to delete an IP
target - cause we don't shift the slave's target_last_arp_rx. Will try to
address that nicely.

And wrt the case of no arp IP targets - we shouldn't get there in the first
place, actually, cause the whole slave_last_rx() depends on arp_validate,
which depends on arp_interval and at least one arp_ip_target. However, I
see that we can do that by removing them one by one via sysfs.

And, btw, we set the target_last_arp_rx in bond_enslave(), the same way as
last_arp_rx :).

Awesome ideas, thank you!

>> +	}
>>
>>  	return slave->dev->last_rx;
>>  }
>> @@ -486,6 +511,7 @@ extern const struct bond_parm_tbl bond_lacp_tbl[];
>>  extern const struct bond_parm_tbl bond_mode_tbl[];
>>  extern const struct bond_parm_tbl xmit_hashtype_tbl[];
>>  extern const struct bond_parm_tbl arp_validate_tbl[];
>> +extern const struct bond_parm_tbl arp_all_targets_tbl[];
>>  extern const struct bond_parm_tbl fail_over_mac_tbl[];
>>  extern const struct bond_parm_tbl pri_reselect_tbl[];
>>  extern struct bond_parm_tbl ad_select_tbl[];
>
