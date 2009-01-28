From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFT 3/4] netfilter: use sequence number synchronization for
 counters
Date: Wed, 28 Jan 2009 07:35:26 +0100
Message-ID: <497FFCAE.70503@cosmosbay.com>
References: <20090127235310.159946902@vyatta.com>	<20090127235508.952787501@vyatta.com>	<497FF860.9080406@cosmosbay.com> <20090127222837.4ea8b255@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090127222837.4ea8b255@extreme>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =C3=A9crit :
> On Wed, 28 Jan 2009 07:17:04 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>
>  =20
>> Stephen Hemminger a =C3=A9crit :
>>    =20
>>> Change how synchronization is done on the iptables counters. Use se=
qcount
>>> wrapper instead of depending on reader/writer lock.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>>
>>>
>>>  =20
>>> --- a/net/ipv4/netfilter/ip_tables.c	2009-01-27 14:48:41.567879095 =
-0800
>>> +++ b/net/ipv4/netfilter/ip_tables.c	2009-01-27 15:45:05.766673246 =
-0800
>>> @@ -366,7 +366,9 @@ ipt_do_table(struct sk_buff *skb,
>>>  			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) !=3D 0)
>>>  				goto no_match;
>>> =20
>>> +			write_seqcount_begin(&e->seq);
>>>  			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
>>> +			write_seqcount_end(&e->seq);
>>>  =20
>>>      =20
>> Its not very good to do it like this, (one seqcount_t per rule per c=
pu)
>>    =20
>
> If we use one count per table, that solves it, but it becomes a hot
> spot, and on an active machine will never settle.
>
>  =20
One seqcount per table and per cpu.
Only one cpu (the owner) will need to change the seqcount (one incremen=
t=20
when entering ipt_do_table(), one increment when leaving)

This location is only read by the thread doing the "iptables -L". We=20
dont care it spends a few cycles, it's already a big cruncher.

I dont understand your concern, what do you mean by "never settle" ?

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
