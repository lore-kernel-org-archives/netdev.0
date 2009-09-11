From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 v2] bonding: introduce primary_passive option
Date: Thu, 10 Sep 2009 17:08:45 -0700
Message-ID: <24804.1252627725@death.nxdomain.ibm.com>
References: <20090910182059.GC2972@psychotron.redhat.com> <4AA97855.8070301@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bonding-devel@lists.sourceforge.net
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:45349 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbZIKAIt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 20:08:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8B03XqW010812
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 18:03:33 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8B08q2Q227840
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 18:08:52 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8B08pXC010124
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 18:08:52 -0600
In-reply-to: <4AA97855.8070301@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:

>Jiri Pirko wrote:
>> (updated 2)
>>
>> In some cases there is not desirable to switch back to primary inter=
face when
>> it's link recovers and rather stay with currently active one. We nee=
d to avoid
>> packetloss as much as we can in some cases. This is solved by introd=
ucing
>> primary_passive option. Note that enslaved primary slave is set as c=
urrent
>> active no matter what.
>>
>> This patch depends on the following one:
>> [net-next-2.6] bonding: make ab_arp select active slaves as other mo=
des
>> http://patchwork.ozlabs.org/patch/32684/
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>
>> diff --git a/Documentation/networking/bonding.txt b/Documentation/ne=
tworking/bonding.txt
>> index d5181ce..e5f2c31 100644
>> --- a/Documentation/networking/bonding.txt
>> +++ b/Documentation/networking/bonding.txt
>> @@ -614,6 +614,32 @@ primary
>>   	The primary option is only valid for active-backup mode.
>>  +primary_passive
>> +
>> +	Specifies the behavior of the current active slave when the primar=
y was
>> +	down and comes back up.  This option is designed to prevent
>> +	flip-flopping between the primary slave and other slaves.  The pos=
sible
>> +	values and their respective effects are:
>> +
>> +	disabled or 0 (default)
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
>> +	always or 2
>> +
>> +		The primary slave becomes the active slave only if the current
>> +		active slave fails and the primary slave is up.
>> +
>> +	When no slave are active, if the primary comes back up, it becomes=
 the
>> +	active slave, regardless of the value of primary_return
>> +
>>  updelay
>
>My feeling is that using primary_passive=3Ddisabled/better/always is f=
ar
>less clear than primary_return=3Dalways/better/failure_only.
>
>The normal (current) behavior is to always return to primay if it is
>up. You want to add the ability to return to it only on failure of the
>current active slave and I suggested to add the ability the return to =
it
>if it is "better" than the current active slave.

	Since this has changed from a real option to a "modify behavior
of another option" option, I'd call it something along the lines of
"primary_reselect" with the "always / better / failure" set of choices.

	Also, if "better" isn't implemented, leave it out entirely
(don't define the label or option stuff).  In the future, then, it can
be added in a complete patch, rather than splitting it across two
patches.

>Hence the suggested name for the option and option values.
>
>>   	Specifies the time, in milliseconds, to wait before enabling a
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index a7e731f..193eca4 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -94,6 +94,7 @@ static int downdelay;
>>  static int use_carrier	=3D 1;
>>  static char *mode;
>>  static char *primary;
>> +static char *primary_passive;
>>  static char *lacp_rate;
>>  static char *ad_select;
>>  static char *xmit_hash_policy;
>> @@ -126,6 +127,13 @@ MODULE_PARM_DESC(mode, "Mode of operation : 0 f=
or balance-rr, "
>>  		       "6 for balance-alb");
>>  module_param(primary, charp, 0);
>>  MODULE_PARM_DESC(primary, "Primary network device to use");
>> +module_param(primary_passive, charp, 0);
>> +MODULE_PARM_DESC(primary_passive, "Do not set primary slave active =
"
>> +				  "once it comes up; "
>> +				  "0 for disabled (default), "
>> +				  "1 for on only if speed of primary is not "
>> +				  "better, "
>> +				  "2 for always on");
>
>You have a double negative assertion here : a "do not" option whose va=
lue
>is "disabled". For clarity, I suggest to have a "do" option whose valu=
e is
>"enabled".
>
>This is probably the reason why I suggested primary_return instead of
>primary_passive. primary_passive means "refuse to return to primary" a=
nd
>when disabled, it becomes "don't refuse to return to primary", which
>should be "accept to return to primary" instead :-)
>
>It might be seen as not being that important, but having an option who=
se
>name and values are easy to understand leads to an easy to use
>option... :-)
>
>>  module_param(lacp_rate, charp, 0);
>>  MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad=
 partner "
>>  			    "(slow/fast)");
>> @@ -200,6 +208,13 @@ const struct bond_parm_tbl fail_over_mac_tbl[] =
=3D {
>>  {	NULL,			-1},
>>  };
>>  +const struct bond_parm_tbl pri_passive_tbl[] =3D {
>> +{	"disabled",		BOND_PRI_PASSIVE_DISABLED},
>> +{	"better",		BOND_PRI_PASSIVE_BETTER},
>> +{	"always",		BOND_PRI_PASSIVE_ALWAYS},
>> +{	NULL,			-1},
>> +};
>> +
>>  struct bond_parm_tbl ad_select_tbl[] =3D {
>>  {	"stable",	BOND_AD_STABLE},
>>  {	"bandwidth",	BOND_AD_BANDWIDTH},
>> @@ -1070,6 +1085,25 @@ out:
>>   }
>>  +static bool bond_should_loose_active(struct bonding *bond)

	I'm not sure what this function name means (beyond the
misspelling of "lose"); it's really "bond_should_change_active" as a
question, correct?

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
>> +	if (bond->params.primary_passive =3D=3D 1 &&
>
>You should use the constants you defined in bonding.h and used in pri_=
passive_tbl :
>
>if (bond->params.primary_passive =3D=3D BOND_PRI_PASSIVE_BETTER &&
>
>> +	    (prim->speed < curr->speed ||
>> +	     (prim->speed =3D=3D curr->speed && prim->duplex <=3D curr->du=
plex)))
>> +		return false;
>> +	if (bond->params.primary_passive =3D=3D 2)

	Ah, ok, passive really is implemented; I just hunted for the
BETTER label.  So, yes, use the defined labels.

>You should use the constants you defined in bonding.h and used in pri_=
passive_tbl :
>
>if (bond->params.primary_passive =3D=3D BOND_PRI_PASSIVE_ALWAYS)
>
>> +		return false;
>> +	return true;
>> +}
>>   /**
>>   * find_best_interface - select the best available slave to be the =
active one
>> @@ -1093,15 +1127,9 @@ static struct slave *bond_find_best_slave(str=
uct bonding *bond)
>>  			return NULL; /* still no slave, return NULL */
>>  	}
>>  -	/*
>> -	 * first try the primary link; if arping, a link must tx/rx
>> -	 * traffic before it can be considered the curr_active_slave.
>> -	 * also, we would skip slaves between the curr_active_slave
>> -	 * and primary_slave that may be up and able to arp
>> -	 */
>>  	if ((bond->primary_slave) &&
>> -	    (!bond->params.arp_interval) &&
>> -	    (IS_UP(bond->primary_slave->dev))) {
>> +	    bond->primary_slave->link =3D=3D BOND_LINK_UP &&
>> +	    bond_should_loose_active(bond)) {
>>  		new_active =3D bond->primary_slave;
>>  	}
>>  @@ -1109,15 +1137,14 @@ static struct slave
>> *bond_find_best_slave(struct bonding *bond)
>>  	old_active =3D new_active;
>>   	bond_for_each_slave_from(bond, new_active, i, old_active) {
>> -		if (IS_UP(new_active->dev)) {
>> -			if (new_active->link =3D=3D BOND_LINK_UP) {
>> -				return new_active;
>> -			} else if (new_active->link =3D=3D BOND_LINK_BACK) {
>> -				/* link up, but waiting for stabilization */
>> -				if (new_active->delay < mintime) {
>> -					mintime =3D new_active->delay;
>> -					bestslave =3D new_active;
>> -				}
>> +		if (new_active->link =3D=3D BOND_LINK_UP) {
>> +			return new_active;
>> +		} else if (new_active->link =3D=3D BOND_LINK_BACK &&
>> +			   IS_UP(new_active->dev)) {
>> +			/* link up, but waiting for stabilization */
>> +			if (new_active->delay < mintime) {
>> +				mintime =3D new_active->delay;
>> +				bestslave =3D new_active;
>>  			}
>>  		}
>>  	}
>> @@ -1683,8 +1710,10 @@ int bond_enslave(struct net_device *bond_dev,=
 struct net_device *slave_dev)
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
>> @@ -2929,18 +2958,6 @@ static int bond_ab_arp_inspect(struct bonding=
 *bond, int delta_in_ticks)
>>  		}
>>  	}
>>  -	read_lock(&bond->curr_slave_lock);
>> -
>> -	/*
>> -	 * Trigger a commit if the primary option setting has changed.
>> -	 */
>> -	if (bond->primary_slave &&
>> -	    (bond->primary_slave !=3D bond->curr_active_slave) &&
>> -	    (bond->primary_slave->link =3D=3D BOND_LINK_UP))
>> -		commit++;
>> -
>> -	read_unlock(&bond->curr_slave_lock);
>> -
>>  	return commit;
>>  }
>>  @@ -2961,90 +2978,58 @@ static void bond_ab_arp_commit(struct bondi=
ng
>> *bond, int delta_in_ticks)
>>  			continue;
>>   		case BOND_LINK_UP:
>> -			write_lock_bh(&bond->curr_slave_lock);
>> -
>> -			if (!bond->curr_active_slave &&
>> -			    time_before_eq(jiffies, dev_trans_start(slave->dev) +
>> -					   delta_in_ticks)) {
>> +			if ((!bond->curr_active_slave &&
>> +			     time_before_eq(jiffies,
>> +					    dev_trans_start(slave->dev) +
>> +					    delta_in_ticks)) ||
>> +			    bond->curr_active_slave !=3D slave) {
>>  				slave->link =3D BOND_LINK_UP;
>> -				bond_change_active_slave(bond, slave);
>>  				bond->current_arp_slave =3D NULL;
>>   				pr_info(DRV_NAME
>> -				       ": %s: %s is up and now the "
>> -				       "active interface\n",
>> -				       bond->dev->name, slave->dev->name);
>> -
>> -			} else if (bond->curr_active_slave !=3D slave) {
>> -				/* this slave has just come up but we
>> -				 * already have a current slave; this can
>> -				 * also happen if bond_enslave adds a new
>> -				 * slave that is up while we are searching
>> -				 * for a new slave
>> -				 */
>> -				slave->link =3D BOND_LINK_UP;
>> -				bond_set_slave_inactive_flags(slave);
>> -				bond->current_arp_slave =3D NULL;
>> +					": %s: link status definitely "
>> +					"up for interface %s.\n",
>> +					bond->dev->name, slave->dev->name);
>>  -				pr_info(DRV_NAME
>> -				       ": %s: backup interface %s is now up\n",
>> -				       bond->dev->name, slave->dev->name);
>> -			}
>> +				if (!bond->curr_active_slave ||
>> +				    (slave =3D=3D bond->primary_slave))
>> +					goto do_failover;
>>  -			write_unlock_bh(&bond->curr_slave_lock);
>> +			}
>>  -			break;
>> +			continue;
>>   		case BOND_LINK_DOWN:
>>  			if (slave->link_failure_count < UINT_MAX)
>>  				slave->link_failure_count++;
>>   			slave->link =3D BOND_LINK_DOWN;
>> +			bond_set_slave_inactive_flags(slave);
>>  -			if (slave =3D=3D bond->curr_active_slave) {
>> -				pr_info(DRV_NAME
>> -				       ": %s: link status down for active "
>> -				       "interface %s, disabling it\n",
>> -				       bond->dev->name, slave->dev->name);
>> -
>> -				bond_set_slave_inactive_flags(slave);
>> -
>> -				write_lock_bh(&bond->curr_slave_lock);
>> -
>> -				bond_select_active_slave(bond);
>> -				if (bond->curr_active_slave)
>> -					bond->curr_active_slave->jiffies =3D
>> -						jiffies;
>> -
>> -				write_unlock_bh(&bond->curr_slave_lock);
>> +			pr_info(DRV_NAME
>> +				": %s: link status definitely down for "
>> +				"interface %s, disabling it\n",
>> +				bond->dev->name, slave->dev->name);
>>  +			if (slave =3D=3D bond->curr_active_slave) {
>>  				bond->current_arp_slave =3D NULL;
>> -
>> -			} else if (slave->state =3D=3D BOND_STATE_BACKUP) {
>> -				pr_info(DRV_NAME
>> -				       ": %s: backup interface %s is now down\n",
>> -				       bond->dev->name, slave->dev->name);
>> -
>> -				bond_set_slave_inactive_flags(slave);
>> +				goto do_failover;
>>  			}
>> -			break;
>> +
>> +			continue;
>>   		default:
>>  			pr_err(DRV_NAME
>>  			       ": %s: impossible: new_link %d on slave %s\n",
>>  			       bond->dev->name, slave->new_link,
>>  			       slave->dev->name);
>> +			continue;
>>  		}
>> -	}
>>  -	/*
>> -	 * No race with changes to primary via sysfs, as we hold rtnl.
>> -	 */
>> -	if (bond->primary_slave &&
>> -	    (bond->primary_slave !=3D bond->curr_active_slave) &&
>> -	    (bond->primary_slave->link =3D=3D BOND_LINK_UP)) {
>> +do_failover:
>> +		ASSERT_RTNL();
>>  		write_lock_bh(&bond->curr_slave_lock);
>> -		bond_change_active_slave(bond, bond->primary_slave);
>> +		bond_select_active_slave(bond);
>>  		write_unlock_bh(&bond->curr_slave_lock);
>>  	}
>>  @@ -4695,7 +4680,7 @@ int bond_parse_parm(const char *buf, const st=
ruct
>> bond_parm_tbl *tbl)
>>   static int bond_check_params(struct bond_params *params)
>>  {
>> -	int arp_validate_value, fail_over_mac_value;
>> +	int arp_validate_value, fail_over_mac_value, primary_passive_value=
;
>>   	/*
>>  	 * Convert string parameters.
>> @@ -4994,6 +4979,20 @@ static int bond_check_params(struct bond_para=
ms *params)
>>  		primary =3D NULL;
>>  	}
>>  +	if (primary && primary_passive) {
>> +		primary_passive_value =3D bond_parse_parm(primary_passive,
>> +							pri_passive_tbl);
>> +		if (primary_passive_value =3D=3D -1) {
>> +			pr_err(DRV_NAME
>> +			       ": Error: Invalid primary_passive \"%s\"\n",
>> +			       primary_passive =3D=3D
>> +					NULL ? "NULL" : primary_passive);
>> +			return -EINVAL;
>> +		}
>> +	} else {
>> +		primary_passive_value =3D BOND_PRI_PASSIVE_DISABLED;
>> +	}
>> +
>>  	if (fail_over_mac) {
>>  		fail_over_mac_value =3D bond_parse_parm(fail_over_mac,
>>  						      fail_over_mac_tbl);
>> @@ -5025,6 +5024,7 @@ static int bond_check_params(struct bond_param=
s *params)
>>  	params->use_carrier =3D use_carrier;
>>  	params->lacp_fast =3D lacp_fast;
>>  	params->primary[0] =3D 0;
>> +	params->primary_passive =3D primary_passive_value;
>>  	params->fail_over_mac =3D fail_over_mac_value;
>>   	if (primary) {
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/=
bond_sysfs.c
>> index 6044e12..84ce933 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -1212,6 +1212,59 @@ static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR=
,
>>  		   bonding_show_primary, bonding_store_primary);
>>   /*
>> + * Show and set the primary_passive flag.
>> + */
>> +static ssize_t bonding_show_primary_passive(struct device *d,
>> +					    struct device_attribute *attr,
>> +					    char *buf)
>> +{
>> +	struct bonding *bond =3D to_bond(d);
>> +
>> +	return sprintf(buf, "%s %d\n",
>> +		       pri_passive_tbl[bond->params.primary_passive].modename,
>> +		       bond->params.primary_passive);
>> +}
>> +
>> +static ssize_t bonding_store_primary_passive(struct device *d,
>> +					     struct device_attribute *attr,
>> +					     const char *buf, size_t count)
>> +{
>> +	int new_value, ret =3D count;
>> +	struct bonding *bond =3D to_bond(d);
>> +
>> +	if (!rtnl_trylock())
>> +		return restart_syscall();
>> +
>> +	new_value =3D bond_parse_parm(buf, pri_passive_tbl);
>> +	if (new_value < 0)  {
>> +		pr_err(DRV_NAME
>> +		       ": %s: Ignoring invalid primary_passive value %.*s.\n",
>> +		       bond->dev->name,
>> +		       (int) strlen(buf) - 1, buf);
>> +		ret =3D -EINVAL;
>> +		goto out;
>> +	} else {
>> +		bond->params.primary_passive =3D new_value;
>> +		pr_info(DRV_NAME ": %s: setting primary_passive to %s (%d).\n",
>> +		       bond->dev->name, pri_passive_tbl[new_value].modename,
>> +		       new_value);
>> +		if (new_value =3D=3D 0 || new_value =3D=3D 1) {

	Magic numbers again, but this test shouldn't be necessary.  The
new_value is known to be valid if bond_parse_parm didn't return failure=
=2E

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
>> +static DEVICE_ATTR(primary_passive, S_IRUGO | S_IWUSR,
>> +		   bonding_show_primary_passive, bonding_store_primary_passive);
>> +
>> +/*
>>   * Show and set the use_carrier flag.
>>   */
>>  static ssize_t bonding_show_carrier(struct device *d,
>> @@ -1500,6 +1553,7 @@ static struct attribute *per_bond_attrs[] =3D =
{
>>  	&dev_attr_num_unsol_na.attr,
>>  	&dev_attr_miimon.attr,
>>  	&dev_attr_primary.attr,
>> +	&dev_attr_primary_passive.attr,
>>  	&dev_attr_use_carrier.attr,
>>  	&dev_attr_active_slave.attr,
>>  	&dev_attr_mii_status.attr,
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bon=
ding.h
>> index 6824771..9a9e0c7 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -131,6 +131,7 @@ struct bond_params {
>>  	int lacp_fast;
>>  	int ad_select;
>>  	char primary[IFNAMSIZ];
>> +	int primary_passive;
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
>>  +#define BOND_PRI_PASSIVE_DISABLED	0
>> +#define BOND_PRI_PASSIVE_BETTER		1
>> +#define BOND_PRI_PASSIVE_ALWAYS		2
>> +
>>  #define BOND_FOM_NONE			0
>>  #define BOND_FOM_ACTIVE			1
>>  #define BOND_FOM_FOLLOW			2
>> @@ -348,6 +354,7 @@ extern const struct bond_parm_tbl bond_mode_tbl[=
];
>>  extern const struct bond_parm_tbl xmit_hashtype_tbl[];
>>  extern const struct bond_parm_tbl arp_validate_tbl[];
>>  extern const struct bond_parm_tbl fail_over_mac_tbl[];
>> +extern const struct bond_parm_tbl pri_passive_tbl[];
>>  extern struct bond_parm_tbl ad_select_tbl[];
>>   #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>
>
>	Nicolas.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
