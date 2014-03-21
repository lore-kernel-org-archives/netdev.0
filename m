From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's value to 1.
Date: Fri, 21 Mar 2014 10:43:05 -0700
Message-ID: <13028.1395423785@death.nxdomain>
References: <1395305504-29973-1-git-send-email-zheng.x.li@oracle.com> <3119.1395334953@death.nxdomain> <532BA648.6060600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: "zheng.li" <zheng.x.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:43747 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbaCURnL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 13:43:11 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 21 Mar 2014 13:43:10 -0400
In-reply-to: <532BA648.6060600@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

zheng.li <zheng.x.li@oracle.com> wrote:

>=E4=BA=8E 2014=E5=B9=B403=E6=9C=8821=E6=97=A5 01:02, Jay Vosburgh =E5=86=
=99=E9=81=93:
>> Zheng Li <zheng.x.li@oracle.com> wrote:
>>=20
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
>>=20
>> 	I suspect this will break LACP (802.3ad) and Etherchannel
>> (balance-xor, balance-rr) modes, as those modes can receive broadcas=
t or
>> multicast on any slave.  In those cases, the switch knows about the
>> aggregation, and will only send the broadcast / multicast to one of =
the
>> ports, but the port selected is not always the same one.
>>=20
>> 	In which mode are you having trouble?
>>=20
>> 	-J
>
>Except bond mode 1, in other modes (major test in mode 6, and test all
>other mode,  except mode 1, all other modes has the bug), the bridge
>make a wrong entry which map guest MAC to the port of bond, it should
>map guest MAC to the port of vif.
>
>Env description: dom0's bridge contains bond1 and vif ports, bond1 as
>port 1 , vif as port 2, bond1 has two slaves which connect a switch.
>when from guest ping others ,the arp broadcast request will go out fro=
m
>bond1's active slave, and then go back to itself inactive slave from
>switch , in function of bond_should_deliver_exact_match will return
>false by inactive is zero, return false will cause bridge receive the
>arp request packets whose original is from guest through vif that let
>bridge consider the SRC MAC of guest is from bond1 by analyzing the ar=
p
>broadcast packets, then make a wrong forward entry "MAC of guest, from
>port 1 (bond1)" , the correct entry should be "MAC of guest , from por=
t
>2 (vif)".

	I believe I understand; the crux of the problem is that the
broadcast is looped by the switch to the other bond port, which then
processes it as a received packet.

	For the tlb and alb modes, you're logically correct; the slaves
other than the active slave should be set to inactive when the bond is
opened.  This is how they are set when configured normally to limit
inbound broadcast and multicast traffic to just one slave (because thes=
e
modes do not configure the switch ports into channel groups or
aggregators; the switch has no knowledge of the bond).

	Your patch is still incorrect, though; the slaves should be set
to actually be inactive via bond_set_slave_inactive_flags, not left
"semi-active," i.e., BOND_STATE_ACTIVE but slave->inactive set. More on
the slave->inactive flag handling later, though.

	For the balance-rr/-xor and 802.3ad modes, I suspect you have a
configuration problem of some sort.  For those modes, the switch should
not loop back the broadcast as you describe when correctly configured.

	The balance-rr/-xor modes should be connected to switch ports
that are configured into a single Etherchannel group (static link
aggregation).  If they are not, the looping back behavior you describe
is expected, as the switch will flood the broadcast to all ports.

	Similarly, the 802.3ad mode should be connected to a switch with
the ports configured for LACP, in which case the ports will
automatically configure into one or more aggregators, and again, the
switch will limit broadcast and multicast traffic to just one member of
an aggregator.

	The -rr/-xor/802.3ad modes must have all slaves set to active in
order for them to correctly process incoming broadcast and multicast
traffic in their proper configuration.  Setting them to inactive will
cause packet loss in those configurations.

	The 802.3ad mode is probably the easiest to examine; if you
configure the switch ports for LACP mode, the /proc/net/bonding/bond0
file should indicate that all the slaves are in the same aggregator
(have the same Aggregator ID), and that that aggregator is the active
one.  The switch should have similar indications, although the format i=
s
vendor-specific.  If your switch is configured for LACP and you still
have issues, please post the /proc/net/bonding/bond0 contents.

	Finally, getting back to the slave->inactive flag.  The only
difference between bond_set_slave_active_flags or _inactive_flags and
bond_set_slave_state is that the slave->inactive flag (whose only
purpose is duplicate suppression for incoming packets) is cleared by th=
e
first (_flags variant), but not by the second.  Right now, the only
caller of _set_slave_state are the _active/_inactive_flags functions, s=
o
it all works.  If _set_slave_state is called independently, then the
slave->inactive flag and the actual state may become unsynchronized.

	In summary, it looks to me like:

	(a) bond_set_slave_state should fix slave->inactive to match the
slave state if there are going to be callers other than
bond_set_slave_active_flags or _inactive_flags, or remove the
slave->inactive field entirely and have bond_is_slave_inactive use
slave->back directly.

	and, the immediate problem here,

	(b) bond_open should call bond_set_slave_active_flags or
_inactive_flags based on the mode and whether or not the slave is the
curr_active_slave.  For active-backup, alb and tlb modes, the active
slave is active, the others are inactive; for -rr, -xor and 802.3ad
modes, all slaves are active.  I dunno what to do with broadcast mode;
make 'em all active, I guess.

	-J

>bond_should_deliver_exact_match(struct sk_buff *skb,
>					    struct slave *slave,
>					    struct bonding *bond)
>{
>	if (bond_is_slave_inactive(slave)) {
>		if (bond->params.mode =3D=3D BOND_MODE_ALB &&
>		    skb->pkt_type !=3D PACKET_BROADCAST &&
>		    skb->pkt_type !=3D PACKET_MULTICAST)
>			return false;
>		return true;
>	}
>	return false;
>}
>
>Thanks,
>Zheng Li
>
>
>>=20
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

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
