From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 6/10] bonding: rebuild the lock use for bond_activebackup_arp_mon()
Date: Sat, 09 Nov 2013 22:08:53 +0800
Message-ID: <527E41F5.4060608@gmail.com>
References: <527C4784.1030402@huawei.com> <527D0AEF.1060802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:45791 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab3KIOTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 09:19:40 -0500
Received: by mail-pd0-f170.google.com with SMTP id q10so41629pdj.15
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 06:19:39 -0800 (PST)
In-Reply-To: <527D0AEF.1060802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/9 0:01, Nikolay Aleksandrov =E5=86=99=E9=81=93:
> On 11/08/2013 03:08 AM, Ding Tianhong wrote:
>> The bond_activebackup_arp_mon() use the bond lock for read to
>> protect the slave list, it is no effect, and the RTNL is only
>> called for bond_ab_arp_commit() and peer notify, for the performance
>> better, use RCU instead of the bond lock, because the bond slave
>> list need to called in RCU, add a new bond_first_slave_rcu()
>> to get the first slave in RCU protection.
>>
>> When bond_ab_arp_inspect() and should_notify_peers is true, the
>> RTNL will called twice, it is a loss of performance, so make the
>> two RTNL together to avoid performance loss.
>>
>> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   drivers/net/bonding/bond_main.c | 35 +++++++++++++++++++----------=
------
>>   drivers/net/bonding/bonding.h   |  7 +++++++
>>   2 files changed, 26 insertions(+), 16 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 759dcd0..b48ca55 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2524,7 +2524,7 @@ static int bond_ab_arp_inspect(struct bonding =
*bond)
>>   	struct slave *slave;
>>   	int commit =3D 0;
>>  =20
>> -	bond_for_each_slave(bond, slave, iter) {
>> +	bond_for_each_slave_rcu(bond, slave, iter) {
>>   		slave->new_link =3D BOND_LINK_NOCHANGE;
>>   		last_rx =3D slave_last_rx(bond, slave);
>>  =20
>> @@ -2586,7 +2586,7 @@ static int bond_ab_arp_inspect(struct bonding =
*bond)
>>    * Called to commit link state changes noted by inspection step of
>>    * active-backup mode ARP monitor.
>>    *
>> - * Called with RTNL and bond->lock for read.
>> + * Called with RTNL hold.
>>    */
>>   static void bond_ab_arp_commit(struct bonding *bond)
>>   {
>> @@ -2661,7 +2661,7 @@ do_failover:
>>   /*
>>    * Send ARP probes for active-backup mode ARP monitor.
>>    *
>> - * Called with bond->lock held for read.
>> + * Called with rcu_read_lock hold.
>>    */
>>   static void bond_ab_arp_probe(struct bonding *bond)
>>   {
>> @@ -2690,14 +2690,14 @@ static void bond_ab_arp_probe(struct bonding=
 *bond)
>>   	 */
>>  =20
>>   	if (!bond->current_arp_slave) {
>> -		bond->current_arp_slave =3D bond_first_slave(bond);
>> +		bond->current_arp_slave =3D bond_first_slave_rcu(bond);
>>   		if (!bond->current_arp_slave)
>>   			return;
>>   	}
>>  =20
>>   	bond_set_slave_inactive_flags(bond->current_arp_slave);
>>  =20
>> -	bond_for_each_slave(bond, slave, iter) {
>> +	bond_for_each_slave_rcu(bond, slave, iter) {
>>   		if (!found && !before && IS_UP(slave->dev))
>>   			before =3D slave;
>>  =20
>> @@ -2745,43 +2745,46 @@ void bond_activebackup_arp_mon(struct work_s=
truct *work)
>>   	bool should_notify_peers =3D false;
>>   	int delta_in_ticks;
>>  =20
>> -	read_lock(&bond->lock);
>> -
>>   	delta_in_ticks =3D msecs_to_jiffies(bond->params.arp_interval);
>>  =20
>> -	if (!bond_has_slaves(bond))
>> +	rcu_read_lock();
>> +
>> +	if (!bond_has_slaves_rcu(bond)) {
>> +		rcu_read_unlock();
>>   		goto re_arm;
>> +	}
>>  =20
>>   	should_notify_peers =3D bond_should_notify_peers(bond);
> Again, bond_should_notify_peers() is not RCU-safe.

yes.
>>  =20
>>   	if (bond_ab_arp_inspect(bond)) {
>> -		read_unlock(&bond->lock);
>> +		rcu_read_unlock();
>>  =20
>>   		/* Race avoidance with bond_close flush of workqueue */
>>   		if (!rtnl_trylock()) {
>> -			read_lock(&bond->lock);
>>   			delta_in_ticks =3D 1;
>>   			should_notify_peers =3D false;
>>   			goto re_arm;
>>   		}
>>  =20
>> -		read_lock(&bond->lock);
>> -
>>   		bond_ab_arp_commit(bond);
>>  =20
>> -		read_unlock(&bond->lock);
>> +		if (should_notify_peers) {
>> +			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
>> +					bond->dev);
>> +			should_notify_peers =3D false;
>> +		}
>> +
>>   		rtnl_unlock();
>> -		read_lock(&bond->lock);
>> +		rcu_read_lock();
>>   	}
>>  =20
>>   	bond_ab_arp_probe(bond);
> Generally you might be safe in bond_ab_arp_probe() due to the synchro=
nization
> done by netdev_rx_handler_unregister(), but this code may run after t=
hat (and
> after the unlinked slave) but before current_arp_slave is set to NULL=
 and thus
> use it. Now I don't see a direct problem with that, only a complicati=
on that can
> bite us later. I vaguely remember that I re-worked the bond_ab_arp_pr=
obe() and
> the way current_arp_slave works when doing this transition in my patc=
hes.

maybe I miss the patch, pls send me the commit and I will check it agai=
n.
>> +	rcu_read_unlock();
>>  =20
>>   re_arm:
>>   	if (bond->params.arp_interval)
>>   		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
>>  =20
>> -	read_unlock(&bond->lock);
>> -
>>   	if (should_notify_peers) {
>>   		if (!rtnl_trylock())
>>   			return;
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bon=
ding.h
>> index deb9738..90b745c 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -97,6 +97,13 @@
>>   		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
>>   		NULL)
>>  =20
>> +#define bond_first_slave_rcu(bond) \
>> +	({struct list_head *__ptr =3D (bond_slave_list(bond)); \
>> +	 struct list_head *__next =3D ACCESS_ONCE(__ptr->next); \
>> +	 likely(__ptr !=3D __next) ? \
>> +	 netdev_adjacent_get_private_rcu(__next) : NULL; \
>> +	 })
>> +
> Honestly, I don't like this, it sure can be re-written in a more
> straight-forward manner.

ok, I will re-write it and make it more comfortable.

Regards.
Ding

>>   #define bond_is_first_slave(bond, pos) (pos =3D=3D bond_first_slav=
e(bond))
>>   #define bond_is_last_slave(bond, pos) (pos =3D=3D bond_last_slave(=
bond))
>>  =20
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
