From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] bonding: introduce primary_reselect option
Date: Fri, 18 Sep 2009 21:52:29 +0200
Message-ID: <20090918195228.GA32154@psychotron.redhat.com>
References: <20090918153006.GC2801@psychotron.redhat.com> <4AB3E03B.3070205@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771AbZIRTwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 15:52:45 -0400
Content-Disposition: inline
In-Reply-To: <4AB3E03B.3070205@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Sep 18, 2009 at 09:32:11PM CEST, nicolas.2p.debian@free.fr wrote=
:
> Jiri Pirko a =E9crit :
>> (updated 3)
>>
>> In some cases there is not desirable to switch back to primary inter=
face when
>> it's link recovers and rather stay with currently active one. We nee=
d to avoid
>> packetloss as much as we can in some cases. This is solved by introd=
ucing
>> primary_reselect option. Note that enslaved primary slave is set as =
current
>> active no matter what.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>
>> diff --git a/Documentation/networking/bonding.txt b/Documentation/ne=
tworking/bonding.txt
>> index d5181ce..fd650e0 100644
>> --- a/Documentation/networking/bonding.txt
>> +++ b/Documentation/networking/bonding.txt
>> @@ -614,6 +614,32 @@ primary
>>   	The primary option is only valid for active-backup mode.
>>  +primary_reselect
>> +
>> +	Specifies the behavior of the current active slave when the primar=
y was
>> +	down and comes back up.  This option is designed to prevent
>> +	flip-flopping between the primary slave and other slaves.  The pos=
sible
>> +	values and their respective effects are:
>> +
>> +	always or 0 (default)
>> +
>> +		The primary slave becomes the active slave whenever it comes
>> +		back up.
>> +
>> +	better or 1
>> +
>> +		The primary slave becomes the active slave when it comes back
>> +		up, if the speed and duplex of the primary slave is better
>> +		than the speed and duplex of the current active slave.
>> +
>> +	failure or 2
>> +
>> +		The primary slave becomes the active slave only if the current
>> +		active slave fails and the primary slave is up.
>> +
>> +	When no slave are active, if the primary comes back up, it becomes=
 the
>> +	active slave, regardless of the value of primary_reselect.
>> +
>>  updelay
>>   	Specifies the time, in milliseconds, to wait before enabling a
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 699bfdd..1127361 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -94,6 +94,7 @@ static int downdelay;
>>  static int use_carrier	=3D 1;
>>  static char *mode;
>>  static char *primary;
>> +static char *primary_reselect;
>>  static char *lacp_rate;
>>  static char *ad_select;
>>  static char *xmit_hash_policy;
>> @@ -126,6 +127,13 @@ MODULE_PARM_DESC(mode, "Mode of operation : 0 f=
or balance-rr, "
>>  		       "6 for balance-alb");
>>  module_param(primary, charp, 0);
>>  MODULE_PARM_DESC(primary, "Primary network device to use");
>> +module_param(primary_reselect, charp, 0);
>> +MODULE_PARM_DESC(primary_reselect, "Reselect primary slave "
>> +				   "once it comes up; "
>> +				   "0 for always (default), "
>> +				   "1 for only if speed of primary is not "
>> +				   "better, "
>> +				   "2 for never");
>
> You should remove "not" for option value 1 and use the word failure f=
or=20
> option value 2.
>
> MODULE_PARM_DESC(primary_reselect, "Reselect primary slave "
> 				   "once it comes up; "
> 				   "0 for always (default), "
> 				   "1 for only if speed of primary is "
> 				   "better, "
> 				   "2 for only on active slave "
> 				   "failure");

Okay, I wasn't sure how to put it here. This sounds good, going to rese=
nd.
Thanks Nicolas.

>
> Apart from this small detail, this sounds good for me.
>
>>  module_param(lacp_rate, charp, 0);
>>  MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad=
 partner "
>>  			    "(slow/fast)");
>> @@ -200,6 +208,13 @@ const struct bond_parm_tbl fail_over_mac_tbl[] =
=3D {
>>  {	NULL,			-1},
>>  };
>>  +const struct bond_parm_tbl pri_reselect_tbl[] =3D {
>> +{	"always",		BOND_PRI_RESELECT_ALWAYS},
>> +{	"better",		BOND_PRI_RESELECT_BETTER},
>> +{	"failure",		BOND_PRI_RESELECT_FAILURE},
>> +{	NULL,			-1},
>> +};
>> +
>>  struct bond_parm_tbl ad_select_tbl[] =3D {
>>  {	"stable",	BOND_AD_STABLE},
>>  {	"bandwidth",	BOND_AD_BANDWIDTH},
>> @@ -1070,6 +1085,25 @@ out:
>>   }
>>  +static bool bond_should_change_active(struct bonding *bond)
>> +{
>> +	struct slave *prim =3D bond->primary_slave;
>> +	struct slave *curr =3D bond->curr_active_slave;
>> +
>> +	if (!prim || !curr || curr->link !=3D BOND_LINK_UP)
>> +		return true;
>> +	if (bond->force_primary) {
>> +		bond->force_primary =3D false;
>> +		return true;
>> +	}
>> +	if (bond->params.primary_reselect =3D=3D BOND_PRI_RESELECT_BETTER =
&&
>> +	    (prim->speed < curr->speed ||
>> +	     (prim->speed =3D=3D curr->speed && prim->duplex <=3D curr->du=
plex)))
>> +		return false;
>> +	if (bond->params.primary_reselect =3D=3D BOND_PRI_RESELECT_FAILURE=
)
>> +		return false;
>> +	return true;
>> +}
>>   /**
>>   * find_best_interface - select the best available slave to be the =
active one
>> @@ -1094,7 +1128,8 @@ static struct slave *bond_find_best_slave(stru=
ct bonding *bond)
>>  	}
>>   	if ((bond->primary_slave) &&
>> -	    bond->primary_slave->link =3D=3D BOND_LINK_UP) {
>> +	    bond->primary_slave->link =3D=3D BOND_LINK_UP &&
>> +	    bond_should_change_active(bond)) {
>>  		new_active =3D bond->primary_slave;
>>  	}
>>  @@ -1675,8 +1710,10 @@ int bond_enslave(struct net_device *bond_dev=
,=20
>> struct net_device *slave_dev)
>>   	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
>>  		/* if there is a primary slave, remember it */
>> -		if (strcmp(bond->params.primary, new_slave->dev->name) =3D=3D 0)
>> +		if (strcmp(bond->params.primary, new_slave->dev->name) =3D=3D 0) =
{
>>  			bond->primary_slave =3D new_slave;
>> +			bond->force_primary =3D true;
>> +		}
>>  	}
>>   	write_lock_bh(&bond->curr_slave_lock);
>> @@ -4643,7 +4680,7 @@ int bond_parse_parm(const char *buf, const str=
uct bond_parm_tbl *tbl)
>>   static int bond_check_params(struct bond_params *params)
>>  {
>> -	int arp_validate_value, fail_over_mac_value;
>> +	int arp_validate_value, fail_over_mac_value, primary_reselect_valu=
e;
>>   	/*
>>  	 * Convert string parameters.
>> @@ -4942,6 +4979,20 @@ static int bond_check_params(struct bond_para=
ms *params)
>>  		primary =3D NULL;
>>  	}
>>  +	if (primary && primary_reselect) {
>> +		primary_reselect_value =3D bond_parse_parm(primary_reselect,
>> +							 pri_reselect_tbl);
>> +		if (primary_reselect_value =3D=3D -1) {
>> +			pr_err(DRV_NAME
>> +			       ": Error: Invalid primary_reselect \"%s\"\n",
>> +			       primary_reselect =3D=3D
>> +					NULL ? "NULL" : primary_reselect);
>> +			return -EINVAL;
>> +		}
>> +	} else {
>> +		primary_reselect_value =3D BOND_PRI_RESELECT_ALWAYS;
>> +	}
>> +
>>  	if (fail_over_mac) {
>>  		fail_over_mac_value =3D bond_parse_parm(fail_over_mac,
>>  						      fail_over_mac_tbl);
>> @@ -4973,6 +5024,7 @@ static int bond_check_params(struct bond_param=
s *params)
>>  	params->use_carrier =3D use_carrier;
>>  	params->lacp_fast =3D lacp_fast;
>>  	params->primary[0] =3D 0;
>> +	params->primary_reselect =3D primary_reselect_value;
>>  	params->fail_over_mac =3D fail_over_mac_value;
>>   	if (primary) {
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/=
bond_sysfs.c
>> index 6044e12..42c44f2 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -1212,6 +1212,61 @@ static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR=
,
>>  		   bonding_show_primary, bonding_store_primary);
>>   /*
>> + * Show and set the primary_reselect flag.
>> + */
>> +static ssize_t bonding_show_primary_reselect(struct device *d,
>> +					     struct device_attribute *attr,
>> +					     char *buf)
>> +{
>> +	struct bonding *bond =3D to_bond(d);
>> +
>> +	return sprintf(buf, "%s %d\n",
>> +		       pri_reselect_tbl[bond->params.primary_reselect].modename,
>> +		       bond->params.primary_reselect);
>> +}
>> +
>> +static ssize_t bonding_store_primary_reselect(struct device *d,
>> +					      struct device_attribute *attr,
>> +					      const char *buf, size_t count)
>> +{
>> +	int new_value, ret =3D count;
>> +	struct bonding *bond =3D to_bond(d);
>> +
>> +	if (!rtnl_trylock())
>> +		return restart_syscall();
>> +
>> +	new_value =3D bond_parse_parm(buf, pri_reselect_tbl);
>> +	if (new_value < 0)  {
>> +		pr_err(DRV_NAME
>> +		       ": %s: Ignoring invalid primary_reselect value %.*s.\n",
>> +		       bond->dev->name,
>> +		       (int) strlen(buf) - 1, buf);
>> +		ret =3D -EINVAL;
>> +		goto out;
>> +	} else {
>> +		bond->params.primary_reselect =3D new_value;
>> +		pr_info(DRV_NAME ": %s: setting primary_reselect to %s (%d).\n",
>> +		       bond->dev->name, pri_reselect_tbl[new_value].modename,
>> +		       new_value);
>> +		if (new_value =3D=3D BOND_PRI_RESELECT_ALWAYS ||
>> +		    new_value =3D=3D BOND_PRI_RESELECT_BETTER) {
>> +			bond->force_primary =3D true;
>> +			read_lock(&bond->lock);
>> +			write_lock_bh(&bond->curr_slave_lock);
>> +			bond_select_active_slave(bond);
>> +			write_unlock_bh(&bond->curr_slave_lock);
>> +			read_unlock(&bond->lock);
>> +		}
>> +	}
>> +out:
>> +	rtnl_unlock();
>> +	return ret;
>> +}
>> +static DEVICE_ATTR(primary_reselect, S_IRUGO | S_IWUSR,
>> +		   bonding_show_primary_reselect,
>> +		   bonding_store_primary_reselect);
>> +
>> +/*
>>   * Show and set the use_carrier flag.
>>   */
>>  static ssize_t bonding_show_carrier(struct device *d,
>> @@ -1500,6 +1555,7 @@ static struct attribute *per_bond_attrs[] =3D =
{
>>  	&dev_attr_num_unsol_na.attr,
>>  	&dev_attr_miimon.attr,
>>  	&dev_attr_primary.attr,
>> +	&dev_attr_primary_reselect.attr,
>>  	&dev_attr_use_carrier.attr,
>>  	&dev_attr_active_slave.attr,
>>  	&dev_attr_mii_status.attr,
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bon=
ding.h
>> index 6824771..b5b1530 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -131,6 +131,7 @@ struct bond_params {
>>  	int lacp_fast;
>>  	int ad_select;
>>  	char primary[IFNAMSIZ];
>> +	int primary_reselect;
>>  	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
>>  };
>>  @@ -190,6 +191,7 @@ struct bonding {
>>  	struct   slave *curr_active_slave;
>>  	struct   slave *current_arp_slave;
>>  	struct   slave *primary_slave;
>> +	bool     force_primary;
>>  	s32      slave_cnt; /* never change this value outside the attach/=
detach wrappers */
>>  	rwlock_t lock;
>>  	rwlock_t curr_slave_lock;
>> @@ -258,6 +260,10 @@ static inline bool bond_is_lb(const struct bond=
ing *bond)
>>  		|| bond->params.mode =3D=3D BOND_MODE_ALB;
>>  }
>>  +#define BOND_PRI_RESELECT_ALWAYS	0
>> +#define BOND_PRI_RESELECT_BETTER	1
>> +#define BOND_PRI_RESELECT_FAILURE	2
>> +
>>  #define BOND_FOM_NONE			0
>>  #define BOND_FOM_ACTIVE			1
>>  #define BOND_FOM_FOLLOW			2
>> @@ -348,6 +354,7 @@ extern const struct bond_parm_tbl bond_mode_tbl[=
];
>>  extern const struct bond_parm_tbl xmit_hashtype_tbl[];
>>  extern const struct bond_parm_tbl arp_validate_tbl[];
>>  extern const struct bond_parm_tbl fail_over_mac_tbl[];
>> +extern const struct bond_parm_tbl pri_reselect_tbl[];
>>  extern struct bond_parm_tbl ad_select_tbl[];
>>   #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>
>
> 	Nicolas.
