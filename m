From: "zheng.li" <zheng.x.li@oracle.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's
 value to 1 in tlb and alb mode.
Date: Fri, 28 Mar 2014 16:39:24 +0800
Message-ID: <5335353C.1050409@oracle.com>
References: <1395716407-31601-1-git-send-email-zheng.x.li@oracle.com> <9725.1395940983@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9725.1395940983@death.nxdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=D3=DA 2014=C4=EA03=D4=C228=C8=D5 01:23, Jay Vosburgh =D0=B4=B5=C0:
> Zheng Li <zheng.x.li@oracle.com> wrote:
>=20
>> In bond mode tlb and alb, inactive slaves should keep inactive flag =
to
>> 1 to refuse to receive broadcast packets. Now, active slave send bro=
adcast packets
>> (for example ARP requests) which will arrive inactive slaves on same=
 host from switch,
>> but inactive slave's inactive flag is zero that cause bridge receive=
 the broadcast
>> packets to produce a wrong entry in forward table. Typical situation=
 is domu send some
>> ARP request which go out from dom0 bond's active slave, then the ARP=
 broadcast request
>> packets go back to inactive slave from switch, because the inactive =
slave's inactive
>> flag is zero, kernel will receive the packets and pass them to bridg=
e, that cause dom0's
>> bridge map domu's MAC address to port of bond, bridge should map dom=
u's MAC to port of vif.
>=20
> 	It's probably worth noting that this effect is something that
> happens after the bonding master device is opened with slaves, i.e.,
> it's got a bunch of slaves, and is then set administratively down for
> whatever reason, and is now being set back up, and needs to set the
> active or inactive state of all the slaves.

I think bond_miimon_commit() funciotn will process this situation,
case BOND_LINK_UP:
   if (!bond->curr_active_slave ||
			    (slave =3D=3D bond->primary_slave))
				goto do_failover;

do_failover:
		bond_select_active_slave(bond);

>=20
> 	It'd also be a little easier to read if it was formatted for 80
> columns.
>=20
>> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>> ---
>> drivers/net/bonding/bond_main.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index e5628fc..8761df6 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3062,7 +3062,7 @@ static int bond_open(struct net_device *bond_d=
ev)
>> 				&& (slave !=3D bond->curr_active_slave)) {
>> 				bond_set_slave_inactive_flags(slave,
>> 							      BOND_SLAVE_NOTIFY_NOW);
>> -			} else {
>> +			} else if (!bond_is_lb(bond)) {
>> 				bond_set_slave_active_flags(slave,
>> 							    BOND_SLAVE_NOTIFY_NOW);
>=20
> 	This patch doesn't do anything for the modes that are
> bond_is_lb, i.e., the balance-tlb and -alb modes.  I believe those tw=
o
> should be set similarly to active-backup: the curr_active_slave is
> active, other slaves are inactive.  The "inactive" setting for alb is
> special, and means to not pass broadcast or multicast, but let unicas=
t
> through.

=46rom dmesg and the source code in kernel, every slave of bond default=
 been set to inactive 1 when slave be added in the bond, and then "Link=
 UP" will comes that let bond choose one as cur_active_salve and change=
 it's inactive value to 0 and other slaves will keep their value of ina=
ctive to 1, so it doesn't need set inactive again in bong_open by defau=
lt all salves inactive is 1 when bond add salves.

You can add printk in kernel, will find the flow, my print show the flo=
w:
1 step ) bonding: bond1 is being created...

2 step ) bonding: bond1: Adding slave eth2. // in this stage, every sla=
ve will be set to inactive 1;
          zheng debug set inactive eth2 bond bond1=20
          zheng debug set inactive flag eth2=20

   bonding: bond1: Adding slave eth3.
            zheng2 set slave inactive eth3
            zheng debug set inactive eth3 bond bond1=20
  =20
3 step ) zheng bonding open=20
   //in bond_open function, we just need keep the inactive to 1 for alb=
 and tlb, .i.e don't=20
   clear the inactive is ok, my patch did that.

4 setp)  "LINK UP" will make one slave to cur_active_slave and change i=
t's inactive to 0, other slaves will keep their original inactive value=
 to 1;

e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None

bonding: bond1: link status up for interface eth2, enabling it in 0 ms.

bonding: bond1: link status definitely up for interface eth2, 1000 Mbps=
 full duplex.

bonding: bond1: making interface eth2 the new active one.

device eth2 entered promiscuous mode

zheng1 set new slave active eth2

zheng debug set active flag eth2=20

bonding: bond1: first active interface up!

Thanks,
Zheng Li


> 	-J
>=20
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
