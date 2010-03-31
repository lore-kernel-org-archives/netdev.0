From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [net-2.6 PATCH] bonding: fix broken multicast with round-robin
	mode
Date: Wed, 31 Mar 2010 10:49:00 -0400
Message-ID: <m2x7b667921003310749v5c8b6e62g7339eff24a51e6d8@mail.gmail.com>
References: <20100325214033.GA28741@gospo.rdu.redhat.com>
	 <1270026517.2103.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lhh@redhat.com, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63611 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab0CaOtE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 10:49:04 -0400
Received: by gyg13 with SMTP id 13so85901gyg.19
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 07:49:01 -0700 (PDT)
In-Reply-To: <1270026517.2103.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 5:08 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 25 mars 2010 =E0 17:40 -0400, Andy Gospodarek a =E9crit :
>> Round-robin (mode 0) does nothing to ensure that any multicast traff=
ic
>> originally destined for the host will continue to arrive at the host=
 when
>> the link that sent the IGMP join or membership report goes down. =A0=
One of
>> the benefits of absolute round-robin transmit.
>>
>> Keeping track of subscribed multicast groups for each slave did not =
seem
>> like a good use of resources, so I decided to simply send on the
>> curr_active slave of the bond (typically the first enslaved device t=
hat
>> is up). =A0This makes failover management simple as IGMP membership
>> reports only need to be sent when the curr_active_slave changes. =A0=
I
>> tested this patch and it appears to work as expected.
>>
>> Originally reported by Lon Hohberger <lhh@redhat.com>.
>>
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>> CC: Lon Hohberger <lhh@redhat.com>
>> CC: Jay Vosburgh <fubar@us.ibm.com>
>>
>> ---
>> =A0drivers/net/bonding/bond_main.c | =A0 34 ++++++++++++++++++++++++=
++--------
>> =A01 files changed, 26 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 430c022..0b38455 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1235,6 +1235,11 @@ void bond_change_active_slave(struct bonding =
*bond, struct slave *new_active)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_lock_bh(&bond->cur=
r_slave_lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> +
>> + =A0 =A0 /* resend IGMP joins since all were sent on curr_active_sl=
ave */
>> + =A0 =A0 if (bond->params.mode =3D=3D BOND_MODE_ROUNDROBIN) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 bond_resend_igmp_join_requests(bond);
>> + =A0 =A0 }
>> =A0}
>>
>> =A0/**
>> @@ -4138,22 +4143,35 @@ static int bond_xmit_roundrobin(struct sk_bu=
ff *skb, struct net_device *bond_dev
>> =A0 =A0 =A0 struct bonding *bond =3D netdev_priv(bond_dev);
>> =A0 =A0 =A0 struct slave *slave, *start_at;
>> =A0 =A0 =A0 int i, slave_no, res =3D 1;
>> + =A0 =A0 struct iphdr *iph =3D ip_hdr(skb);
>>
>> =A0 =A0 =A0 read_lock(&bond->lock);
>>
>> =A0 =A0 =A0 if (!BOND_IS_OK(bond))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> -
>> =A0 =A0 =A0 /*
>> - =A0 =A0 =A0* Concurrent TX may collide on rr_tx_counter; we accept=
 that
>> - =A0 =A0 =A0* as being rare enough not to justify using an atomic o=
p here
>> + =A0 =A0 =A0* Start with the curr_active_slave that joined the bond=
 as the
>> + =A0 =A0 =A0* default for sending IGMP traffic. =A0For failover pur=
poses one
>> + =A0 =A0 =A0* needs to maintain some consistency for the interface =
that will
>> + =A0 =A0 =A0* send the join/membership reports. =A0The curr_active_=
slave found
>> + =A0 =A0 =A0* will send all of this type of traffic.
>> =A0 =A0 =A0 =A0*/
>> - =A0 =A0 slave_no =3D bond->rr_tx_counter++ % bond->slave_cnt;
>> + =A0 =A0 if ((skb->protocol =3D=3D htons(ETH_P_IP)) &&
>> + =A0 =A0 =A0 =A0 (iph->protocol =3D=3D htons(IPPROTO_IGMP))) {
>
> Hmm...
>
> iph->protocol is a u8, how can htons(IPPROTO_IGMP) be equal to
> iph->protocol ?

Heh, this isn't needed for a single-byte check.  Thanks for catching th=
at.

> [PATCH] bonding: bond_xmit_roundrobin() fix
>
> Commit a2fd940f (bonding: fix broken multicast with round-robin mode)
> added a problem on litle endian machines.
>
> drivers/net/bonding/bond_main.c:4159: warning: comparison is always
> false due to limited range of data type

Curious what version of GCC are you using?  Before applying your patch
it compiles without warning on my x86_64 F11-ish system with:

gcc version 4.4.1 20090725 (Red Hat 4.4.1-2) (GCC)

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 5b92fbf..5972a52 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4156,7 +4156,7 @@ static int bond_xmit_roundrobin(struct sk_buff =
*skb, struct net_device *bond_dev
> =A0 =A0 =A0 =A0 * send the join/membership reports. =A0The curr_activ=
e_slave found
> =A0 =A0 =A0 =A0 * will send all of this type of traffic.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if ((iph->protocol =3D=3D htons(IPPROTO_IGMP)) &&
> + =A0 =A0 =A0 if ((iph->protocol =3D=3D IPPROTO_IGMP) &&
> =A0 =A0 =A0 =A0 =A0 =A0(skb->protocol =3D=3D htons(ETH_P_IP))) {
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_lock(&bond->curr_slave_lock);
>
>
>
>
