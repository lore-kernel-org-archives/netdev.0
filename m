From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for 802.3ad mode
Date: Thu, 20 Feb 2014 19:38:26 -0800
Message-ID: <926F1DDD-E3E6-4FB2-8D45-CF01CE8E1956@cumulusnetworks.com>
References: <53034312.1060203@huawei.com> <16121.1392765526@death.nxdomain>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	Thomas Glanzmann <thomas@glanzmann.de>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:33353 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbaBUDj3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 22:39:29 -0500
In-Reply-To: <16121.1392765526@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 18, 2014, at 3:18 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:

> Ding Tianhong <dingtianhong@huawei.com> wrote:
>=20
>> The problem was introduced by the commit 1d3ee88ae0d
>> (bonding: add netlink attributes to slave link dev).
>> The bond_set_active_slave() and bond_set_backup_slave()
>> will use rtmsg_ifinfo to send slave's states, so these
>> two functions should be called in RTNL.
>>=20
>> In 802.3ad mode, acquiring RTNL for the __enable_port and
>> __disable_port cases is difficult, as those calls generally
>> already hold the state machine lock, and cannot unconditionally
>> call rtnl_lock because either they already hold RTNL (for calls
>> via bond_3ad_unbind_slave) or due to the potential for deadlock
>> with bond_3ad_adapter_speed_changed, bond_3ad_adapter_duplex_changed=
,
>> bond_3ad_link_change, or bond_3ad_update_lacp_rate.  All four of
>> those are called with RTNL held, and acquire the state machine lock
>> second.  The calling contexts for __enable_port and __disable_port
>> already hold the state machine lock, and may or may not need RTNL.
>>=20
>> According to the Jay's opinion, I don't think it is a problem that
>> the slave don't send notify message synchronously when the status
>> changed, normally the state machine is running every 100 ms, send
>> the notify message at the end of the state machine if the slave's
>> state changed should be better.
>>=20
>> I fix the problem through these steps:
>>=20
>> 1). add a new function bond_set_slave_state() which could change
>>   the slave's state and call rtmsg_ifinfo() according to the input
>>   parameters called notify.
>>=20
>> 2). Add a new slave parameter which called should_notify, if the sla=
ve's state
>>   changed and don't notify yet, the parameter will be set to 1, and =
then if
>>   the slave's state changed again, the param will be set to 0, it in=
dicate that
>>   the slave's state has been restored, no need to notify any one.
>>=20
>> 3). the __enable_port and __disable_port should not call rtmsg_ifinf=
o
>>   in the state machine lock, any change in the state of slave could
>>   set a flag in the slave, it will indicated that an rtmsg_ifinfo
>>   should be called at the end of the state machine.
>>=20
>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> Cc: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_3ad.c  | 22 ++++++++++++++++++++--
>> drivers/net/bonding/bond_main.c | 30 +++++++++++++++---------------
>> drivers/net/bonding/bonding.h   | 31 ++++++++++++++++++++++++++-----
>> 3 files changed, 61 insertions(+), 22 deletions(-)
>>=20
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bo=
nd_3ad.c
>> index e9edd84..c450d04 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -181,7 +181,7 @@ static inline int __agg_has_partner(struct aggre=
gator *agg)
>> */
>> static inline void __disable_port(struct port *port)
>> {
>> -	bond_set_slave_inactive_flags(port->slave);
>> +	bond_set_slave_inactive_flags(port->slave, false);
>> }
>>=20
>> /**
>> @@ -193,7 +193,7 @@ static inline void __enable_port(struct port *po=
rt)
>> 	struct slave *slave =3D port->slave;
>>=20
>> 	if ((slave->link =3D=3D BOND_LINK_UP) && IS_UP(slave->dev))
>> -		bond_set_slave_active_flags(slave);
>> +		bond_set_slave_active_flags(slave, false);
>> }
>>=20
>> /**
>> @@ -2065,6 +2065,7 @@ void bond_3ad_state_machine_handler(struct wor=
k_struct *work)
>> 	struct list_head *iter;
>> 	struct slave *slave;
>> 	struct port *port;
>> +	int slave_should_notify =3D 0;
>>=20
>> 	read_lock(&bond->lock);
>> 	rcu_read_lock();
>> @@ -2122,8 +2123,25 @@ void bond_3ad_state_machine_handler(struct wo=
rk_struct *work)
>> 	}
>>=20
>> re_arm:
>> +	bond_for_each_slave_rcu(bond, slave, iter) {
>> +		if (slave->should_notify) {
>> +			slave_should_notify =3D 1;
>> +			break;
>> +		}
>> +	}
>> 	rcu_read_unlock();
>> 	read_unlock(&bond->lock);
>> +
>> +	if (slave_should_notify && rtnl_trylock()) {
>> +		bond_for_each_slave(bond, slave, iter) {
>> +			if (slave->should_notify) {
>> +				rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0,
>> +					     GFP_KERNEL);
>> +				slave->should_notify =3D 0;
>> +			}
>> +		}
>> +		rtnl_unlock();
>> +	}
>> 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
>> }
>>=20
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 3bce855..1c14e64 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -829,21 +829,21 @@ void bond_change_active_slave(struct bonding *=
bond, struct slave *new_active)
>> 	if (bond_is_lb(bond)) {
>> 		bond_alb_handle_active_change(bond, new_active);
>> 		if (old_active)
>> -			bond_set_slave_inactive_flags(old_active);
>> +			bond_set_slave_inactive_flags(old_active, true);
>> 		if (new_active)
>> -			bond_set_slave_active_flags(new_active);
>> +			bond_set_slave_active_flags(new_active, true);
>> 	} else {
>> 		rcu_assign_pointer(bond->curr_active_slave, new_active);
>> 	}
>>=20
>> 	if (bond->params.mode =3D=3D BOND_MODE_ACTIVEBACKUP) {
>> 		if (old_active)
>> -			bond_set_slave_inactive_flags(old_active);
>> +			bond_set_slave_inactive_flags(old_active, true);
>>=20
>> 		if (new_active) {
>> 			bool should_notify_peers =3D false;
>>=20
>> -			bond_set_slave_active_flags(new_active);
>> +			bond_set_slave_active_flags(new_active, true);
>>=20
>> 			if (bond->params.fail_over_mac)
>> 				bond_do_fail_over_mac(bond, new_active,
>> @@ -1462,14 +1462,14 @@ int bond_enslave(struct net_device *bond_dev=
, struct net_device *slave_dev)
>>=20
>> 	switch (bond->params.mode) {
>> 	case BOND_MODE_ACTIVEBACKUP:
>> -		bond_set_slave_inactive_flags(new_slave);
>> +		bond_set_slave_inactive_flags(new_slave, true);
>> 		break;
>> 	case BOND_MODE_8023AD:
>> 		/* in 802.3ad mode, the internal mechanism
>> 		 * will activate the slaves in the selected
>> 		 * aggregator
>> 		 */
>> -		bond_set_slave_inactive_flags(new_slave);
>> +		bond_set_slave_inactive_flags(new_slave, true);
>> 		/* if this is the first slave */
>> 		if (!prev_slave) {
>> 			SLAVE_AD_INFO(new_slave).id =3D 1;
>> @@ -1487,7 +1487,7 @@ int bond_enslave(struct net_device *bond_dev, =
struct net_device *slave_dev)
>> 	case BOND_MODE_TLB:
>> 	case BOND_MODE_ALB:
>> 		bond_set_active_slave(new_slave);
>> -		bond_set_slave_inactive_flags(new_slave);
>> +		bond_set_slave_inactive_flags(new_slave, true);
>> 		break;
>> 	default:
>> 		pr_debug("This slave is always active in trunk mode\n");
>> @@ -2009,7 +2009,7 @@ static void bond_miimon_commit(struct bonding =
*bond)
>>=20
>> 			if (bond->params.mode =3D=3D BOND_MODE_ACTIVEBACKUP ||
>> 			    bond->params.mode =3D=3D BOND_MODE_8023AD)
>> -				bond_set_slave_inactive_flags(slave);
>> +				bond_set_slave_inactive_flags(slave, true);
>>=20
>> 			pr_info("%s: link status definitely down for interface %s, disabl=
ing it\n",
>> 				bond->dev->name, slave->dev->name);
>> @@ -2555,7 +2555,7 @@ static void bond_ab_arp_commit(struct bonding =
*bond)
>> 				slave->link =3D BOND_LINK_UP;
>> 				if (bond->current_arp_slave) {
>> 					bond_set_slave_inactive_flags(
>> -						bond->current_arp_slave);
>> +						bond->current_arp_slave, true);
>> 					bond->current_arp_slave =3D NULL;
>> 				}
>>=20
>> @@ -2575,7 +2575,7 @@ static void bond_ab_arp_commit(struct bonding =
*bond)
>> 				slave->link_failure_count++;
>>=20
>> 			slave->link =3D BOND_LINK_DOWN;
>> -			bond_set_slave_inactive_flags(slave);
>> +			bond_set_slave_inactive_flags(slave, true);
>>=20
>> 			pr_info("%s: link status definitely down for interface %s, disabl=
ing it\n",
>> 				bond->dev->name, slave->dev->name);
>> @@ -2650,7 +2650,7 @@ static bool bond_ab_arp_probe(struct bonding *=
bond)
>> 		}
>> 	}
>>=20
>> -	bond_set_slave_inactive_flags(curr_arp_slave);
>> +	bond_set_slave_inactive_flags(curr_arp_slave, true);
>=20
> 	This...
>=20
>> 	bond_for_each_slave(bond, slave, iter) {
>> 		if (!found && !before && IS_UP(slave->dev))
>> @@ -2670,7 +2670,7 @@ static bool bond_ab_arp_probe(struct bonding *=
bond)
>> 			if (slave->link_failure_count < UINT_MAX)
>> 				slave->link_failure_count++;
>>=20
>> -			bond_set_slave_inactive_flags(slave);
>> +			bond_set_slave_inactive_flags(slave, true);
>=20
> 	[ but not this one ]
>=20
>> 			pr_info("%s: backup interface %s is now down\n",
>> 				bond->dev->name, slave->dev->name);
>> @@ -2688,7 +2688,7 @@ static bool bond_ab_arp_probe(struct bonding *=
bond)
>> 	}
>>=20
>> 	new_slave->link =3D BOND_LINK_BACK;
>> -	bond_set_slave_active_flags(new_slave);
>> +	bond_set_slave_active_flags(new_slave, true);
>=20
> 	and this should arguably never send an rtmsg_ifinfo
> notification.
>=20
> 	My presumption is that the notification is to indicate that the
> interface has actually changed state in a meaningful way

[Sorry for late response...my inbox filter let thread slip thru to netd=
ev pile]

That was the original intent: notify (via netlink) that slave state cha=
nged.  Admittedly, I was looking at 802.3ad mode and didn=92t appreciat=
e the locking subtleties with the other modes.  I want notification to =
program real HW that=92s backing the 802.3ad bond.  For an active slave=
, the HW port corresponding to slave would be included in HW hash for e=
gress, as well as rx/tx LACP.  For an inactive slave, the HW port only =
rx/tx LACP.  Inactive port is not included in egress hash.  Delayed not=
ification when it=92s safe (after state machines run) is fine.

Thank you Ding for working thru a safer design.

-scott
