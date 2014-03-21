From: "zheng.li" <zheng.x.li@oracle.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's
 value to 1.
Date: Fri, 21 Mar 2014 10:39:04 +0800
Message-ID: <532BA648.6060600@oracle.com>
References: <1395305504-29973-1-git-send-email-zheng.x.li@oracle.com> <3119.1395334953@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3119.1395334953@death.nxdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=D3=DA 2014=C4=EA03=D4=C221=C8=D5 01:02, Jay Vosburgh =D0=B4=B5=C0:
> Zheng Li <zheng.x.li@oracle.com> wrote:
>=20
>> Except bond mode 1, in other bond modes, inactive slaves should keep
>> inactive flag to 1 to refuse to receive broadcast packets. Now, acti=
ve
>> slave send broadcast packets (for example ARP requests) which will
>> arrive inactive slaves on same host from switch, but inactive slave'=
s
>> inactive flag is zero that cause bridge receive the broadcast packet=
s
>> to produce a wrong entry in forward table. Typical situation is domu
>> send some ARP request which go out from dom0 bond's active slave, th=
en
>> the ARP broadcast request packets go back to inactive slave from
>> switch, because the inactive slave's inactive flag is zero, kernel w=
ill
>> receive the packets and pass them to bridge, that cause dom0's bridg=
e
>> map domu's MAC address to port of bond, bridge should map domu's MAC=
 to
>> port of vif.
>=20
> 	I suspect this will break LACP (802.3ad) and Etherchannel
> (balance-xor, balance-rr) modes, as those modes can receive broadcast=
 or
> multicast on any slave.  In those cases, the switch knows about the
> aggregation, and will only send the broadcast / multicast to one of t=
he
> ports, but the port selected is not always the same one.
>=20
> 	In which mode are you having trouble?
>=20
> 	-J

Except bond mode 1, in other modes (major test in mode 6, and test all
other mode,  except mode 1, all other modes has the bug), the bridge
make a wrong entry which map guest MAC to the port of bond, it should
map guest MAC to the port of vif.

Env description: dom0's bridge contains bond1 and vif ports, bond1 as
port 1 , vif as port 2, bond1 has two slaves which connect a switch.
when from guest ping others ,the arp broadcast request will go out from
bond1's active slave, and then go back to itself inactive slave from
switch , in function of bond_should_deliver_exact_match will return
false by inactive is zero, return false will cause bridge receive the
arp request packets whose original is from guest through vif that let
bridge consider the SRC MAC of guest is from bond1 by analyzing the arp
broadcast packets, then make a wrong forward entry "MAC of guest, from
port 1 (bond1)" , the correct entry should be "MAC of guest , from port
2 (vif)".


bond_should_deliver_exact_match(struct sk_buff *skb,
					    struct slave *slave,
					    struct bonding *bond)
{
	if (bond_is_slave_inactive(slave)) {
		if (bond->params.mode =3D=3D BOND_MODE_ALB &&
		    skb->pkt_type !=3D PACKET_BROADCAST &&
		    skb->pkt_type !=3D PACKET_MULTICAST)
			return false;
		return true;
	}
	return false;
}

Thanks,
Zheng Li


>=20
>>
>> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>> ---
>> drivers/net/bonding/bond_main.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index e5628fc..2f73f18 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -3063,7 +3063,7 @@ static int bond_open(struct net_device *bond_d=
ev)
>> 				bond_set_slave_inactive_flags(slave,
>> 							      BOND_SLAVE_NOTIFY_NOW);
>> 			} else {
>> -				bond_set_slave_active_flags(slave,
>> +				bond_set_slave_state(slave, BOND_STATE_ACTIVE,
>> 							    BOND_SLAVE_NOTIFY_NOW);
>> 			}
>> 		}
>> --=20
>> 1.7.6.5
>>
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
