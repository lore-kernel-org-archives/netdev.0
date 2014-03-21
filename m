From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's
 value to 1.
Date: Fri, 21 Mar 2014 16:41:52 +0800
Message-ID: <532BFB50.7060601@huawei.com>
References: <1395305504-29973-1-git-send-email-zheng.x.li@oracle.com> <3119.1395334953@death.nxdomain> <532BA648.6060600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <andy@greyhouse.net>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<joe.jin@oracle.com>
To: "zheng.li" <zheng.x.li@oracle.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <532BA648.6060600@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/3/21 10:39, zheng.li wrote:
> =E4=BA=8E 2014=E5=B9=B403=E6=9C=8821=E6=97=A5 01:02, Jay Vosburgh =E5=
=86=99=E9=81=93:
>> Zheng Li <zheng.x.li@oracle.com> wrote:
>>
>>> Except bond mode 1, in other bond modes, inactive slaves should kee=
p
>>> inactive flag to 1 to refuse to receive broadcast packets. Now, act=
ive
>>> slave send broadcast packets (for example ARP requests) which will
>>> arrive inactive slaves on same host from switch, but inactive slave=
's
>>> inactive flag is zero that cause bridge receive the broadcast packe=
ts
>>> to produce a wrong entry in forward table. Typical situation is dom=
u
>>> send some ARP request which go out from dom0 bond's active slave, t=
hen
>>> the ARP broadcast request packets go back to inactive slave from
>>> switch, because the inactive slave's inactive flag is zero, kernel =
will
>>> receive the packets and pass them to bridge, that cause dom0's brid=
ge
>>> map domu's MAC address to port of bond, bridge should map domu's MA=
C to
>>> port of vif.
>>
>> 	I suspect this will break LACP (802.3ad) and Etherchannel
>> (balance-xor, balance-rr) modes, as those modes can receive broadcas=
t or
>> multicast on any slave.  In those cases, the switch knows about the
>> aggregation, and will only send the broadcast / multicast to one of =
the
>> ports, but the port selected is not always the same one.
>>
>> 	In which mode are you having trouble?
>>
>> 	-J
>=20
> Except bond mode 1, in other modes (major test in mode 6, and test al=
l
> other mode,  except mode 1, all other modes has the bug), the bridge
> make a wrong entry which map guest MAC to the port of bond, it should
> map guest MAC to the port of vif.
>=20
> Env description: dom0's bridge contains bond1 and vif ports, bond1 as
> port 1 , vif as port 2, bond1 has two slaves which connect a switch.
> when from guest ping others ,the arp broadcast request will go out fr=
om
> bond1's active slave, and then go back to itself inactive slave from
> switch , in function of bond_should_deliver_exact_match will return
> false by inactive is zero, return false will cause bridge receive the
> arp request packets whose original is from guest through vif that let
> bridge consider the SRC MAC of guest is from bond1 by analyzing the a=
rp
> broadcast packets, then make a wrong forward entry "MAC of guest, fro=
m
> port 1 (bond1)" , the correct entry should be "MAC of guest , from po=
rt
> 2 (vif)".
>=20
>=20
> bond_should_deliver_exact_match(struct sk_buff *skb,
> 					    struct slave *slave,
> 					    struct bonding *bond)
> {
> 	if (bond_is_slave_inactive(slave)) {
> 		if (bond->params.mode =3D=3D BOND_MODE_ALB &&
> 		    skb->pkt_type !=3D PACKET_BROADCAST &&
> 		    skb->pkt_type !=3D PACKET_MULTICAST)
> 			return false;
> 		return true;
> 	}
> 	return false;
> }
>=20
> Thanks,
> Zheng Li
>=20


I know the problems of yours, but you can't fix the problem by the foll=
ow way, it will break
the original mode such as 802.3ad, if you want to fix the problem, I th=
ink you need a better
solution.

Ding

>=20
>>
>>>
>>> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>>> ---
>>> drivers/net/bonding/bond_main.c |    2 +-
>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
>>> index e5628fc..2f73f18 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -3063,7 +3063,7 @@ static int bond_open(struct net_device *bond_=
dev)
>>> 				bond_set_slave_inactive_flags(slave,
>>> 							      BOND_SLAVE_NOTIFY_NOW);
>>> 			} else {
>>> -				bond_set_slave_active_flags(slave,
>>> +				bond_set_slave_state(slave, BOND_STATE_ACTIVE,
>>> 							    BOND_SLAVE_NOTIFY_NOW);
>>> 			}
>>> 		}
>>> --=20
>>> 1.7.6.5
>>>
>>
>> ---
>> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> .
>=20
