From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 3/4] Use mod_timer_noact to remove nf_conntrack_lock
Date: Wed, 18 Feb 2009 15:27:58 +0100
Message-ID: <499C1AEE.3050709@trash.net>
References: <20090218051906.174295181@vyatta.com> <20090218052747.555811553@vyatta.com> <499C14AF.60704@cosmosbay.com> <499C155B.9010200@trash.net> <499C19BE.7090407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	tglx@linutronix.de, netfilter-devel@vger.kernel.org,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499C19BE.7090407@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> Eric Dumazet wrote:
>>> Unfortunatly, this patch changes nothing, as most of the time, do_a=
cct
>>> is true.
>>>
>>> We also need to fine lock the accounting part as well.
>>>
>>>     spin_lock_bh(&ct->some_lock);
>>>     acct =3D nf_conn_acct_find(ct);
>>>     if (acct) {
>>>         acct[CTINFO2DIR(ctinfo)].packets++;
>>>         acct[CTINFO2DIR(ctinfo)].bytes +=3D
>>>             skb->len - skb_network_offset(skb);
>>>     }
>>>     spin_unlock_bh(&ct->some_lock);
>>>
>> Its currently still enabled by default, but we intend to change that=
=2E
>> After that I guess almost nobody will have it enabled.
>>=20
> Really ? I find this accounting stuff really useful and always enable=
 it :)

You usually need extra userspace daemons to make something useful
out of the data and I doubt many people are running them. It doesn't
hurt to optimize it anyways of course :)

But I'm somewhat doubtful that we're actually having lock contention
here. One thing we could do with your lock hash change is to perform
the counter updates while holding those locks, that avoids taking
a different lock just for the counters. The only reason why its done
in nf_ct_refresh is that it was already taking the conntrack lock,
but if thats no longer the case, no reason to keep it there.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
