From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: Re: [PATCH linux v2 net-next 2/4] bonding: Allow userspace to set
 actors' macaddr in an AD-system.
Date: Fri, 08 May 2015 16:12:46 +0200
Message-ID: <554CC45E.7040208@blackwall.org>
References: <cover.1430892486.git.jtoppins@cumulusnetworks.com> <b6f58dbe179c52e043540a6de23819d51d7070b5.1430944053.git.jtoppins@cumulusnetworks.com> <554C7D66.20506@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	shm@cumulusnetworks.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38276 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbbEHOMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 10:12:50 -0400
Received: by wiun10 with SMTP id n10so28899105wiu.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 07:12:49 -0700 (PDT)
In-Reply-To: <554C7D66.20506@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2015 11:09 AM, Nikolay Aleksandrov wrote:
> On 05/06/2015 10:41 PM, Jonathan Toppins wrote:
>> From: Mahesh Bandewar <maheshb@google.com>
>>
>> In an AD system, the communication between actor and partner is the
>> business between these two entities. In the current setup anyone on the
>> same L2 can "guess" the LACPDU contents and then possibly send the
>> spoofed LACPDUs and trick the partner causing connectivity issues for
>> the AD system. This patch allows to use a random mac-address obscuring
>> it's identity making it harder for someone in the L2 is do the same thing.
>>
>> This patch allows user-space to choose the mac-address for the AD-system.
>> This mac-address can not be NULL or a Multicast. If the mac-address is set
>> from user-space; kernel will honor it and will not overwrite it. In the
>> absence (value from user space); the logic will default to using the
>> masters' mac as the mac-address for the AD-system.
>>
>> It can be set using example code below -
>>
>>    # modprobe bonding mode=4
>>    # sys_mac_addr=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
>>                     $(( (RANDOM & 0xFE) | 0x02 )) \
>>                     $(( RANDOM & 0xFF )) \
>>                     $(( RANDOM & 0xFF )) \
>>                     $(( RANDOM & 0xFF )) \
>>                     $(( RANDOM & 0xFF )) \
>>                     $(( RANDOM & 0xFF )))
>>    # echo $sys_mac_addr > /sys/class/net/bond0/bonding/ad_actor_system
>>    # echo +eth1 > /sys/class/net/bond0/bonding/slaves
>>    ...
>>    # ip link set bond0 up
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> [jt: fixed up style issues reported by checkpatch, also changed
>>   bond_option_ad_actor_system_set to assume a binary mac so it can
>>   be reused in the netlink option set case]
>> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
>> ---
>> v2:
>>   * rebased
>>
>>  Documentation/networking/bonding.txt |   12 +++++++++++
>>  drivers/net/bonding/bond_3ad.c       |    7 +++++-
>>  drivers/net/bonding/bond_main.c      |    1 +
>>  drivers/net/bonding/bond_options.c   |   21 ++++++++++++++++++
>>  drivers/net/bonding/bond_procfs.c    |    6 ++++++
>>  drivers/net/bonding/bond_sysfs.c     |   39 ++++++++++++++++++++++++++++++++++
>>  include/net/bond_options.h           |    1 +
>>  include/net/bonding.h                |    1 +
>>  8 files changed, 87 insertions(+), 1 deletion(-)
>>
> <<<snip>>>
>>  /* Searches for an option by name */
>> @@ -1375,3 +1384,15 @@ static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
>>  	bond->params.ad_actor_sys_prio = newval->value;
>>  	return 0;
>>  }
>> +
>> +static int bond_option_ad_actor_system_set(struct bonding *bond,
>> +					   const struct bond_opt_value *newval)
>> +{
>> +	if (!is_valid_ether_addr(newval->string)) {
>> +		netdev_err(bond->dev, "Invalid MAC address.\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	ether_addr_copy(bond->params.ad_actor_system, newval->string);
>> +	return 0;
>> +}
>> diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
>> index 1136929..e7f3047 100644
>> --- a/drivers/net/bonding/bond_procfs.c
>> +++ b/drivers/net/bonding/bond_procfs.c
>> @@ -137,6 +137,8 @@ static void bond_info_show_master(struct seq_file *seq)
>>  			   optval->string);
>>  		seq_printf(seq, "System priority: %d\n",
>>  			   BOND_AD_INFO(bond).system.sys_priority);
>> +		seq_printf(seq, "System MAC address: %pM\n",
>> +			   &BOND_AD_INFO(bond).system.sys_mac_addr);
>>  
>>  		if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>>  			seq_printf(seq, "bond %s has no active aggregator\n",
>> @@ -200,6 +202,8 @@ static void bond_info_show_slave(struct seq_file *seq,
>>  			seq_puts(seq, "details actor lacp pdu:\n");
>>  			seq_printf(seq, "    system priority: %d\n",
>>  				   port->actor_system_priority);
>> +			seq_printf(seq, "    system mac address: %pM\n",
>> +				   &port->actor_system);
>>  			seq_printf(seq, "    port key: %d\n",
>>  				   port->actor_oper_port_key);
>>  			seq_printf(seq, "    port priority: %d\n",
>> @@ -212,6 +216,8 @@ static void bond_info_show_slave(struct seq_file *seq,
>>  			seq_puts(seq, "details partner lacp pdu:\n");
>>  			seq_printf(seq, "    system priority: %d\n",
>>  				   port->partner_oper.system_priority);
>> +			seq_printf(seq, "    system mac address: %pM\n",
>> +				   &port->partner_oper.system);
>>  			seq_printf(seq, "    oper key: %d\n",
>>  				   port->partner_oper.key);
>>  			seq_printf(seq, "    port priority: %d\n",
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>> index 4a76266..5e4c2ea 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -706,6 +706,44 @@ static ssize_t bonding_show_ad_actor_sys_prio(struct device *d,
>>  static DEVICE_ATTR(ad_actor_sys_prio, S_IRUGO | S_IWUSR,
>>  		   bonding_show_ad_actor_sys_prio, bonding_sysfs_store_option);
>>  
>> +static ssize_t bonding_show_ad_actor_system(struct device *d,
>> +					    struct device_attribute *attr,
>> +					    char *buf)
>> +{
>> +	struct bonding *bond = to_bond(d);
>> +
>> +	if (BOND_MODE(bond) == BOND_MODE_8023AD)
>> +		return sprintf(buf, "%pM\n", bond->params.ad_actor_system);
>> +
>> +	return 0;
>> +}
>> +
>> +static ssize_t bonding_store_ad_actor_system(struct device *d,
>> +					     struct device_attribute *attr,
>> +					     const char *buffer, size_t count)
>> +{
>> +	struct bonding *bond = to_bond(d);
>> +	u8 macaddr[ETH_ALEN];
>> +	int ret;
>> +
>> +	ret = sscanf(buffer, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
>> +		     &macaddr[0], &macaddr[1], &macaddr[2],
>> +		     &macaddr[3], &macaddr[4], &macaddr[5]);
>> +	if (ret != ETH_ALEN) {
>> +		netdev_err(bond->dev, "Invalid MAC address.\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_AD_ACTOR_SYSTEM, macaddr);
>> +	if (!ret)
>> +		ret = count;
>> +
>> +	return ret;
>> +}
>> +
>> +static DEVICE_ATTR(ad_actor_system, S_IRUGO | S_IWUSR,
>> +		   bonding_show_ad_actor_system, bonding_store_ad_actor_system);
>> +
> Hi,
> I must've missed this part the first time around. Could you please explain
> why can't you do all the checks from the set function and you need a
> special sysfs set one for this option here ?
> The generic bonding sysfs set function was introduced in order to remove
> these and make use of the new option API, and this looks like a step backwards.
> 
> Nik
> 
If you did this to re-use the set function in the netlink code, you can
take a look at how arp_ip_targets is handled (same issue) and do something
similar.


>>  static struct attribute *per_bond_attrs[] = {
>>  	&dev_attr_slaves.attr,
>>  	&dev_attr_mode.attr,
>> @@ -740,6 +778,7 @@ static struct attribute *per_bond_attrs[] = {
>>  	&dev_attr_packets_per_slave.attr,
>>  	&dev_attr_tlb_dynamic_lb.attr,
>>  	&dev_attr_ad_actor_sys_prio.attr,
>> +	&dev_attr_ad_actor_system.attr,
>>  	NULL,
>>  };
>>  
>> diff --git a/include/net/bond_options.h b/include/net/bond_options.h
>> index 894002a..eeeefa1 100644
>> --- a/include/net/bond_options.h
>> +++ b/include/net/bond_options.h
>> @@ -64,6 +64,7 @@ enum {
>>  	BOND_OPT_SLAVES,
>>  	BOND_OPT_TLB_DYNAMIC_LB,
>>  	BOND_OPT_AD_ACTOR_SYS_PRIO,
>> +	BOND_OPT_AD_ACTOR_SYSTEM,
>>  	BOND_OPT_LAST
>>  };
>>  
>> diff --git a/include/net/bonding.h b/include/net/bonding.h
>> index 405cf87..650f386 100644
>> --- a/include/net/bonding.h
>> +++ b/include/net/bonding.h
>> @@ -137,6 +137,7 @@ struct bond_params {
>>  	int tlb_dynamic_lb;
>>  	struct reciprocal_value reciprocal_packets_per_slave;
>>  	u16 ad_actor_sys_prio;
>> +	u8 ad_actor_system[ETH_ALEN];
>>  };
>>  
>>  struct bond_parm_tbl {
>>
> 
