From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Wed, 02 Sep 2009 18:20:48 +0200
Message-ID: <4A9E9B60.8010408@gmail.com>
References: <4A98132C.8090105@gmail.com>	 <20090828.233858.256193304.davem@davemloft.net>	 <4A9BBD8E.2010303@gmail.com> <20090901.184121.06750444.davem@davemloft.net>	 <4A9E849A.30105@gmail.com> <1251907915.6468.15.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	dlstevens@us.ibm.com, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com, mtk.manpages@gmail.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37429 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbZIBQV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 12:21:26 -0400
In-Reply-To: <1251907915.6468.15.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala a =C3=A9crit :
> On Wed, 2009-09-02 at 16:43 +0200, Eric Dumazet wrote:
>> David Miller a =C3=A9crit :
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Mon, 31 Aug 2009 14:09:50 +0200
>>>
>>>> Re-reading again this stuff, I realized ip6_push_pending_frames()
>>>> was not updating IPSTATS_MIB_OUTDISCARDS, even if IP_RECVERR was s=
et.
>>>>
>>>> May I suggest following path :
>>>>
>>>> 1) Correct ip6_push_pending_frames() to properly
>>>> account for dropped-by-qdisc frames when IP_RECVERR is set
>>> Your patch is  applied to net-next-2.6, thanks!
>>>
>>>> 2) Submit a patch to account for qdisc-dropped frames in SNMP coun=
ters
>>>> but still return a OK to user application, to not break them ?
>>> Sounds good.
>>>
>>> I think if you sample random UDP applications, you will find that s=
uch
>>> errors will upset them terribly, make them log tons of crap to
>>> /var/log/messages et al., and consume tons of CPU.
>>>
>>> And in such cases silent ignoring of drops is entirely appropriate =
and
>>> optimal, which supports our current behavior.
>>>
>>> If we are to make such applications "more sophisticated" such
>>> converted apps can be indicated simply their use of IP_RECVERR.
>>>
>>> If you want to be notified of all asynchronous errors we can detect=
,
>>> you use this, end of story.  It is the only way to handle this
>>> situation without breaking the world.
>>>
>>> As usual, Alexey Kuznetsov's analysis of this situation is timeless=
,
>>> accurate, and wise.  And he understood all of this 10+ years ago.
>> Thanks David, here is the 2nd patch then :
>>
>>
>> [PATCH net-next-2.6] ip: Report qdisc packet drops
>>
>> Christoph Lameter pointed out that packet drops at qdisc level where=
 not
>> accounted in SNMP counters. Only if application sets IP_RECVERR, dro=
ps
>> are reported to user (-ENOBUFS errors) and SNMP counters updated.
>>
>> IP_RECVERR is used to enable extended reliable error message passing=
,
>> but these are not needed to update system wide SNMP stats.
>>
>> This patch changes things a bit to allow SNMP counters to be updated=
,
>> regardless of IP_RECVERR being set or not on the socket.
>>
>> Example after an UDP tx flood
>> # netstat -s=20
>> ...
>> IP:
>>     1487048 outgoing packets dropped
>> ...
>> Udp:
>> ...
>>     SndbufErrors: 1487048
>>
>=20
> Didn't we agree that qdisc drops should not be counted as IP or UDP=20
> drops as David Stevens pointed out?
> I would say that even when IP_RECVERR is set, SNMP counters at IP and
> UDP should not be counted when a packet is dropped at qdisc level,
> but the error can be reported to user.
>=20
> Now that qdisc stats issue is figured out and they can be accounted
> and seen at qdisc level, doesn't it confuse if we count the same drop=
=20
> at IP, UDP and qdisc level?
>=20
> Thanks
> Sridhar
>

Yes, I am aware of David point, but its already not true with current k=
ernel.

Current kernels and an UDP frame sent by application :

if IP_RECVERR not set, no SNMP error logged, IP or UDP level

if IP_RECVERR is set, qdisc drops are reported both to IP and UDP
SNMP counters.



udp_sendmsg()
{
=2E..
out:
        ip_rt_put(rt);
        if (free)
                kfree(ipc.opt);
        if (!err)
                return len;
        /*
         * ENOBUFS =3D no kernel mem, SOCK_NOSPACE =3D no sndbuf space.=
  Reporting
         * ENOBUFS might not be good (it's not tunable per se), but oth=
erwise
         * we don't have a good statistic (IpOutDiscards but it can be =
too many
         * things).  We could add another new stat but at least for now=
 that
         * seems like overkill.
         */
        if (err =3D=3D -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socke=
t->flags)) {
                UDP_INC_STATS_USER(sock_net(sk),
                                UDP_MIB_SNDBUFERRORS, is_udplite);
        }
        return err;
=2E..
}


So what shall we do ?

IMHO, one should not add MIB counters for different domains (IP / UDP),=
 this
makes no sense.

