From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Wed, 10 Aug 2016 10:41:13 -0700
Message-ID: <29728.1470850873@famine>
References: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com> <57A9DA8D.3010407@huawei.com> <20160809180830.GM22974@cork> <20160809.120636.2039586307820412288.davem@davemloft.net> <20160809211058.GP22974@cork> <20075.1470786664@famine> <57AAF39C.3050907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: =?us-ascii?Q?=3D=3FUTF-8=3FQ=3FJ=3Dc3=3Db6rn=5FEngel=3F=3D?=
	<joern@purestorage.com>, David Miller <davem@davemloft.net>,
	zyjzyj2000@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38503 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932849AbcHJSRQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:17:16 -0400
In-reply-to: <57AAF39C.3050907@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>On 2016/8/10 7:51, Jay Vosburgh wrote:
>> Jörn Engel <joern@purestorage.com> wrote:
>> 
>>> On Tue, Aug 09, 2016 at 12:06:36PM -0700, David Miller wrote:
>>>>> On Tue, Aug 09, 2016 at 09:28:45PM +0800, Ding Tianhong wrote:
>>>>>
>>>>> Simply not checking errors when setting the mac address solves the
>>>>> problem for me.  No new features needed.
>>>>
>>>> But it only works in certain modes.
>>>>
>>>> So the best we can do is enforce the MAC address setting in the
>>>> modes that absolutely require it.  We cannot ignore the MAC
>>>> address setting unilaterally.
>>>
>>> Something like this?
>>>
>>> [PATCH] bonding: Allow tun-interfaces as slaves in balance-rr mode
>>>
>>> Up until 00503b6f702e (part of 3.14-rc1), the bonding driver could be
>>> used to enslave tun-interfaces.  00503b6f702e broke that behaviour,
>>> afaics as an unintended side-effect.
>>>
>>> For the purpose of bond-over-tun in balance-rr mode, simply ignoring the
>>> error from dev_set_mac_address() is good enough.
>>>
>>> Signed-off-by: Joern Engel <joern@purestorage.com>
>>> ---
>>> drivers/net/bonding/bond_main.c | 3 ++-
>>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>> index 1f276fa30ba6..2f686bfe4304 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -1490,7 +1490,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>> 		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
>>> 		addr.sa_family = slave_dev->type;
>>> 		res = dev_set_mac_address(slave_dev, &addr);
>>> -		if (res) {
>>> +		/* round-robin mode works fine without a mac address */
>>> +		if (res && BOND_MODE(bond) != BOND_MODE_ROUNDROBIN) {
>> 
>> 	This will cause balance-rr to add the slave to the bond if any
>> device's dev_set_mac_address call fails.
>> 
>> 	If a bond of regular Ethernet devices is connected to a static
>> link aggregation (Etherchannel channel group), a set_mac failure would
>> result in that slave having a different MAC address than the bond, which
>> in turn would cause traffic inbound from the switch to that slave to be
>> dropped (as the destination MAC would not pass the device MAC filters).
>> 
>> 	The failure check for the set_mac call serves a legitimate
>> purpose, and I don't believe we should bypass it without making the
>> bypass an option that is explicitly enabled for those special cases that
>> need it.
>> 
>> 	E.g., something like the following (which I have not tested);
>> this would also need documentation and iproute2 updates to go with it.
>> This would be enabled with "fail_over_mac=keepmac".
>> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 1f276fa30ba6..d2283fc23b16 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1483,7 +1483,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>  	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
>>  
>>  	if (!bond->params.fail_over_mac ||
>> -	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
>> +	    (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP &&
>> +	     bond->params.fail_over_mac != BOND_FOM_KEEPMAC)) {
>>  		/* Set slave to master's mac address.  The application already
>>  		 * set the master's mac address to that of the first slave
>>  		 */
>> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>> index 577e57cad1dc..f9653fe4d622 100644
>> --- a/drivers/net/bonding/bond_options.c
>> +++ b/drivers/net/bonding/bond_options.c
>> @@ -125,6 +125,7 @@ static const struct bond_opt_value bond_fail_over_mac_tbl[] = {
>>  	{ "none",   BOND_FOM_NONE,   BOND_VALFLAG_DEFAULT},
>>  	{ "active", BOND_FOM_ACTIVE, 0},
>>  	{ "follow", BOND_FOM_FOLLOW, 0},
>> +	{ "keepmac", BOND_FOM_KEEPMAC, 0},
>>  	{ NULL,     -1,              0},
>>  };
>>  
>> diff --git a/include/net/bonding.h b/include/net/bonding.h
>> index 6360c259da6d..ec3442b3aa83 100644
>> --- a/include/net/bonding.h
>> +++ b/include/net/bonding.h
>> @@ -420,6 +420,7 @@ static inline bool bond_slave_can_tx(struct slave *slave)
>>  #define BOND_FOM_NONE			0
>>  #define BOND_FOM_ACTIVE			1
>>  #define BOND_FOM_FOLLOW			2
>> +#define BOND_FOM_KEEPMAC		3
>>  
>>  #define BOND_ARP_TARGETS_ANY		0
>>  #define BOND_ARP_TARGETS_ALL		1
>> 
>> 
>> 	-J
>> 
>Hi jorn:
>
>Could you please test this patch? I build this patch base on Jay's suggestion and I think it could fix your problem.
>
>---
> drivers/net/bonding/bond_main.c    | 24 +++++++++---------------
> drivers/net/bonding/bond_options.c |  3 ++-
> include/net/bonding.h              |  1 +
> 3 files changed, 12 insertions(+), 16 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 1f276fa..dd4a8eb 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -174,9 +174,9 @@ MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes; "
> module_param(arp_all_targets, charp, 0);
> MODULE_PARM_DESC(arp_all_targets, "fail on any/all arp targets timeout; 0 for any (default), 1 for all");
> module_param(fail_over_mac, charp, 0);
>-MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to "
>-				"the same MAC; 0 for none (default), "
>-				"1 for active, 2 for follow");
>+MODULE_PARM_DESC(fail_over_mac, "Do not set all slaves to the same MAC; "
>+				"0 for none (default), 1 for active, "
>+				"2 for follow, 3 for keepmac");
> module_param(all_slaves_active, int, 0);
> MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface "
> 				     "by setting active flag for all slaves; "
>@@ -1482,8 +1482,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 	 */
> 	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
> 
>-	if (!bond->params.fail_over_mac ||
>-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
>+	if (bond->params.fail_over_mac == BOND_FOM_NONE) {

	I'm not sure we can make the change this way; I structured the
test as:

 	if (!bond->params.fail_over_mac ||
-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
+	    (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP &&
+	     bond->params.fail_over_mac != BOND_FOM_KEEPMAC)) {

	deliberately, because the current implementation permits setting
f_o_m at any time, but it only takes effect in active-backup mode.  This
is done to reduce ordering restrictions when setting up the bond,
however, a user today could set f_o_m to "active" or "follow" in modes
other than active-backup and it would have no effect, but your change
would cause that identically configured bond to now behave differently.

	The test has to be structured such that f_o_m set to "active" or
"follow" affects only active-backup mode, and f_o_m "keepmac" affects
any mode.  We probably should move this into a helper, something like

bool bond_fom_enabled(bond)
{
	if (bond->mode == BOND_MODE_ACTIVEBACKUP)
		return bond->params.fail_over_mac != BOND_FOM_NONE;
	else
		return bond->params.fail_over_mac == BOND_FOM_KEEPMAC;
}

	then the complicated test becomes

	if (!bond_fom_enabled(bond)) {
		[ change the MAC address stuff ]
	}


	-J

> 		/* Set slave to master's mac address.  The application already
> 		 * set the master's mac address to that of the first slave
> 		 */
>@@ -1766,8 +1765,7 @@ err_close:
> 
> err_restore_mac:
> 	slave_dev->flags &= ~IFF_SLAVE;
>-	if (!bond->params.fail_over_mac ||
>-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
>+	if (bond->params.fail_over_mac == BOND_FOM_NONE) {
> 		/* XXX TODO - fom follow mode needs to change master's
> 		 * MAC if this slave's MAC is in use by the bond, or at
> 		 * least print a warning.
>@@ -1867,8 +1865,7 @@ static int __bond_release_one(struct net_device *bond_dev,
> 
> 	RCU_INIT_POINTER(bond->current_arp_slave, NULL);
> 
>-	if (!all && (!bond->params.fail_over_mac ||
>-		     BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP)) {
>+	if (!all && bond->params.fail_over_mac == BOND_FOM_NONE) {
> 		if (ether_addr_equal_64bits(bond_dev->dev_addr, slave->perm_hwaddr) &&
> 		    bond_has_slaves(bond))
> 			netdev_warn(bond_dev, "the permanent HWaddr of %s - %pM - is still in use by %s - set the HWaddr of %s to a different address to avoid conflicts\n",
>@@ -1949,8 +1946,8 @@ static int __bond_release_one(struct net_device *bond_dev,
> 	/* close slave before restoring its mac address */
> 	dev_close(slave_dev);
> 
>-	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE ||
>-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
>+	if (bond->params.fail_over_mac == BOND_FOM_FOLLOW ||
>+	    bond->params.fail_over_mac == BOND_FOM_NONE) {
> 		/* restore original ("permanent") mac address */
> 		ether_addr_copy(addr.sa_data, slave->perm_hwaddr);
> 		addr.sa_family = slave_dev->type;
>@@ -3634,8 +3631,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
> 	/* If fail_over_mac is enabled, do nothing and return success.
> 	 * Returning an error causes ifenslave to fail.
> 	 */
>-	if (bond->params.fail_over_mac &&
>-	    BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP)
>+	if (bond->params.fail_over_mac)
> 		return 0;
> 
> 	if (!is_valid_ether_addr(sa->sa_data))
>@@ -4543,8 +4539,6 @@ static int bond_check_params(struct bond_params *params)
> 			return -EINVAL;
> 		}
> 		fail_over_mac_value = valptr->value;
>-		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
>-			pr_warn("Warning: fail_over_mac only affects active-backup mode\n");
> 	} else {
> 		fail_over_mac_value = BOND_FOM_NONE;
> 	}
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 577e57c..9038be5 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -125,6 +125,7 @@ static const struct bond_opt_value bond_fail_over_mac_tbl[] = {
> 	{ "none",   BOND_FOM_NONE,   BOND_VALFLAG_DEFAULT},
> 	{ "active", BOND_FOM_ACTIVE, 0},
> 	{ "follow", BOND_FOM_FOLLOW, 0},
>+	{ "keepmac", BOND_FOM_KEEPMAC, 0},
> 	{ NULL,     -1,              0},
> };
> 
>@@ -247,7 +248,7 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
> 	[BOND_OPT_FAIL_OVER_MAC] = {
> 		.id = BOND_OPT_FAIL_OVER_MAC,
> 		.name = "fail_over_mac",
>-		.desc = "For active-backup, do not set all slaves to the same MAC",
>+		.desc = "Do not set all slaves to the same MAC",
> 		.flags = BOND_OPTFLAG_NOSLAVES,
> 		.values = bond_fail_over_mac_tbl,
> 		.set = bond_option_fail_over_mac_set
>diff --git a/include/net/bonding.h b/include/net/bonding.h
>index 6360c25..ec3442b 100644
>--- a/include/net/bonding.h
>+++ b/include/net/bonding.h
>@@ -420,6 +420,7 @@ static inline bool bond_slave_can_tx(struct slave *slave)
> #define BOND_FOM_NONE			0
> #define BOND_FOM_ACTIVE			1
> #define BOND_FOM_FOLLOW			2
>+#define BOND_FOM_KEEPMAC		3
> 
> #define BOND_ARP_TARGETS_ANY		0
> #define BOND_ARP_TARGETS_ALL		1
>-- 
>1.9.0

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
