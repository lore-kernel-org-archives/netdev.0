From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 6/6] bonding: Implement user key part of port_key in
 an AD system.
Date: Sat, 7 Feb 2015 11:29:24 -0800
Message-ID: <CAF2d9jjqUTTeOVwh3S0v=nak_a5JFyuubmcbouB40HXNiA+XuA@mail.gmail.com>
References: <1423270317-9352-1-git-send-email-maheshb@google.com> <20150207034029.GE34197@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:38070 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782AbbBGT3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 14:29:45 -0500
Received: by mail-oi0-f42.google.com with SMTP id i138so16935995oig.1
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2015 11:29:44 -0800 (PST)
In-Reply-To: <20150207034029.GE34197@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 6, 2015 at 7:40 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Fri, Feb 06, 2015 at 04:51:57PM -0800, Mahesh Bandewar wrote:
>> The port key has three components - user-key, speed-part, and duplex-part.
>> The LSBit is for the duplex-part, next 5 bits are for the speed while the
>> remaining 10 bits are the user defined key bits. Get these 10 bits
>> from the user-space (through the SysFs interface) and use it to form the
>> admin port-key. Allowed range for the user-key is 0 - 1023 (10 bits). If
>> it is not provided then use zero for the user-key-bits (default).
>>
>> It can set using following example code -
>>
>>    # modprobe bonding mode=4
>>    # usr_port_key=$(( RANDOM & 0x3FF ))
>>    # echo $usr_port_key > /sys/class/net/bond0/bonding/ad_actor_user_port_key
>>    # echo +eth1 > /sys/class/net/bond0/bonding/slaves
>
> If the other ones don't have 'actor' maybe drop it here too.
>
> (Sorry to be picky about these, but as someone who has typed many of
> these options a bunch it would be great to have shorter names in config
> files.)
>
Thanks for the suggestions Andy. Now I don't have to battle with
myself for the correct names :) I wanted to move the naming discussion
in the other thread where I have proposed this to be changed to
'ad_user_portkey'.

>>    ...
>>    # ip link set bond0 up
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>>  drivers/net/bonding/bond_3ad.c     |  6 +++---
>>  drivers/net/bonding/bond_main.c    | 10 ++++++++++
>>  drivers/net/bonding/bond_options.c | 26 ++++++++++++++++++++++++++
>>  drivers/net/bonding/bond_sysfs.c   | 15 +++++++++++++++
>>  include/net/bond_options.h         |  1 +
>>  include/net/bonding.h              |  1 +
>>  6 files changed, 56 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 373d3db3809f..c69c393ba8c5 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -1955,10 +1955,10 @@ void bond_3ad_bind_slave(struct slave *slave)
>>
>>               port->slave = slave;
>>               port->actor_port_number = SLAVE_AD_INFO(slave)->id;
>> -             /* key is determined according to the link speed, duplex and user key(which
>> -              * is yet not supported)
>> +             /* key is determined according to the link speed, duplex and
>> +              * user key
>>                */
>> -             port->actor_admin_port_key = 0;
>> +             port->actor_admin_port_key = bond->params.ad_actor_portkey << 6;
>>               port->actor_admin_port_key |= __get_duplex(port);
>>               port->actor_admin_port_key |= (__get_link_speed(port) << 1);
>>               port->actor_oper_port_key = port->actor_admin_port_key;
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 1a6735ef2ea7..f9f001f35a91 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -4105,6 +4105,7 @@ static int bond_check_params(struct bond_params *params)
>>       const struct bond_opt_value *valptr;
>>       int arp_all_targets_value;
>>       u16 ad_actor_sysprio = 0;
>> +     u16 ad_actor_portkey = 0;
>>
>>       /* Convert string parameters. */
>>       if (mode) {
>> @@ -4409,6 +4410,14 @@ static int bond_check_params(struct bond_params *params)
>>                       return -EINVAL;
>>               }
>>               ad_actor_sysprio = valptr->value;
>> +
>> +             valptr = bond_opt_parse(bond_opt_get(BOND_OPT_AD_ACTOR_PORTKEY),
>> +                                     &newval);
>> +             if (!valptr) {
>> +                     pr_err("Error: No ad_actor_portkey default value");
>> +                     return -EINVAL;
>> +             }
>> +             ad_actor_portkey = valptr->value;
>>       }
>>
>>       if (lp_interval == 0) {
>> @@ -4441,6 +4450,7 @@ static int bond_check_params(struct bond_params *params)
>>       params->tlb_dynamic_lb = 1; /* Default value */
>>       params->ad_actor_sysprio = ad_actor_sysprio;
>>       eth_zero_addr(params->ad_actor_sys_macaddr);
>> +     params->ad_actor_portkey = ad_actor_portkey;
>>       if (packets_per_slave > 0) {
>>               params->reciprocal_packets_per_slave =
>>                       reciprocal_value(packets_per_slave);
>> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>> index 330d48b6a1e6..c3f77c6d0d2e 100644
>> --- a/drivers/net/bonding/bond_options.c
>> +++ b/drivers/net/bonding/bond_options.c
>> @@ -74,6 +74,8 @@ static int bond_option_ad_actor_sysprio_set(struct bonding *bond,
>>                                 const struct bond_opt_value *newval);
>>  static int bond_option_ad_actor_sys_macaddr_set(struct bonding *bond,
>>                                 const struct bond_opt_value *newval);
>> +static int bond_option_ad_actor_portkey_set(struct bonding *bond,
>> +                               const struct bond_opt_value *newval);
>>
>>
>>  static const struct bond_opt_value bond_mode_tbl[] = {
>> @@ -196,6 +198,12 @@ static const struct bond_opt_value bond_ad_actor_sysprio_tbl[] = {
>>       { NULL,      -1,    0},
>>  };
>>
>> +static const struct bond_opt_value bond_ad_actor_portkey_tbl[] = {
>> +     { "minval",  0,     BOND_VALFLAG_MIN | BOND_VALFLAG_DEFAULT},
>> +     { "maxval",  1023,  BOND_VALFLAG_MAX},
>> +     { NULL,      -1,    0},
>> +};
>> +
>>  static const struct bond_option bond_opts[BOND_OPT_LAST] = {
>>       [BOND_OPT_MODE] = {
>>               .id = BOND_OPT_MODE,
>> @@ -405,6 +413,14 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
>>               .flags = BOND_OPTFLAG_RAWVAL | BOND_OPTFLAG_IFDOWN,
>>               .set = bond_option_ad_actor_sys_macaddr_set,
>>       },
>> +     [BOND_OPT_AD_ACTOR_PORTKEY] = {
>> +             .id = BOND_OPT_AD_ACTOR_PORTKEY,
>> +             .name = "ad_actor_user_port_key",
>> +             .unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
>> +             .flags = BOND_OPTFLAG_IFDOWN,
>> +             .values = bond_ad_actor_portkey_tbl,
>> +             .set = bond_option_ad_actor_portkey_set,
>> +     }
>>  };
>>
>>  /* Searches for an option by name */
>> @@ -1405,3 +1421,13 @@ static int bond_option_ad_actor_sys_macaddr_set(struct bonding *bond,
>>
>>       return 0;
>>  }
>> +
>> +static int bond_option_ad_actor_portkey_set(struct bonding *bond,
>> +                                         const struct bond_opt_value *newval)
>> +{
>> +     netdev_info(bond->dev, "Setting ad_actor_portkey to (%llu)\n",
>> +                 newval->value);
>> +
>> +     bond->params.ad_actor_portkey = newval->value;
>> +     return 0;
>> +}
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>> index 91713d0b6685..17d84d5a1608 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -721,6 +721,20 @@ static DEVICE_ATTR(ad_actor_system_mac_address, S_IRUGO | S_IWUSR,
>>                  bonding_show_ad_actor_sys_macaddr,
>>                  bonding_sysfs_store_option);
>>
>> +static ssize_t bonding_show_ad_actor_portkey(struct device *d,
>> +                                          struct device_attribute *attr,
>> +                                          char *buf)
>> +{
>> +     struct bonding *bond = to_bond(d);
>> +
>> +     if (BOND_MODE(bond) == BOND_MODE_8023AD)
>> +             return sprintf(buf, "%hu\n", bond->params.ad_actor_portkey);
>> +
>> +     return 0;
>> +}
>> +static DEVICE_ATTR(ad_actor_user_port_key, S_IRUGO | S_IWUSR,
>> +                bonding_show_ad_actor_portkey, bonding_sysfs_store_option);
>> +
>>  static struct attribute *per_bond_attrs[] = {
>>       &dev_attr_slaves.attr,
>>       &dev_attr_mode.attr,
>> @@ -756,6 +770,7 @@ static struct attribute *per_bond_attrs[] = {
>>       &dev_attr_tlb_dynamic_lb.attr,
>>       &dev_attr_ad_actor_system_priority.attr,
>>       &dev_attr_ad_actor_system_mac_address.attr,
>> +     &dev_attr_ad_actor_user_port_key.attr,
>>       NULL,
>>  };
>>
>> diff --git a/include/net/bond_options.h b/include/net/bond_options.h
>> index 993ef73cd050..4c36455aacb4 100644
>> --- a/include/net/bond_options.h
>> +++ b/include/net/bond_options.h
>> @@ -65,6 +65,7 @@ enum {
>>       BOND_OPT_TLB_DYNAMIC_LB,
>>       BOND_OPT_AD_ACTOR_SYSPRIO,
>>       BOND_OPT_AD_ACTOR_SYS_MACADDR,
>> +     BOND_OPT_AD_ACTOR_PORTKEY,
>>       BOND_OPT_LAST
>>  };
>>
>> diff --git a/include/net/bonding.h b/include/net/bonding.h
>> index cd2092e6bc71..e91db2566437 100644
>> --- a/include/net/bonding.h
>> +++ b/include/net/bonding.h
>> @@ -144,6 +144,7 @@ struct bond_params {
>>       int tlb_dynamic_lb;
>>       struct reciprocal_value reciprocal_packets_per_slave;
>>       u16 ad_actor_sysprio;
>> +     u16 ad_actor_portkey;
>>       u8 ad_actor_sys_macaddr[ETH_ALEN];
>>  };
>>
>> --
>> 2.2.0.rc0.207.ga3a616c
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
