From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neighbour table RCU
Date: Tue, 01 Sep 2009 18:13:40 +0200
Message-ID: <4A9D4834.4090902@gmail.com>
References: <20090831150453.3437a65c@nehalam>	<4A9CC429.5020803@gmail.com> <20090901085921.2c836dac@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44648 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbZIAQNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 12:13:39 -0400
In-Reply-To: <20090901085921.2c836dac@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> On Tue, 01 Sep 2009 08:50:17 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Stephen Hemminger a =C3=A9crit :
>>> Looking at the neighbour table, it should be possible to get
>>> rid of the two reader/writer locks.  The hash table lock is pretty
>>> amenable to RCU, but the dynamic resizing makes it non-trivial.
>>> Thinking of using a combination of RCU and sequence counts so that =
the
>>> reader would just rescan if resize was in progress.
>> I am not sure neigh_tbl_lock rwlock should be changed, I did not
>> see any contention on it.
>>
>>> The reader/writer lock on the neighbour entry is more of a problem.
>>> Probably would be simpler/faster to change it into a spinlock and
>>> be done with it.
>>>
>>> The reader/writer lock is also used for the proxy list hash table,
>>> but that can just be a simple spinlock.
>>>
>> This is probably is the only thing we want to do at this moment,
>> halving atomic ops on neigh_resolve_output()
>>
>> But why neigh_resolve_output() was called so much in the bench
>> is the question...
>>
>=20
> Every packet has to have an ARP resolution.
>=20

Sure, but I thought we had a cache ?

static inline int ip_finish_output2(struct sk_buff *skb)
{
=2E..
	if (dst->hh)
		return neigh_hh_output(dst->hh, skb);
	else if (dst->neighbour)
		return dst->neighbour->output(skb);  << should fill cache first time =
>>
=2E..
}

in my pktgen benches, I always hit same dst so should take the hh cache=
 ?
