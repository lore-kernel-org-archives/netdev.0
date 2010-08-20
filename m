From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] netfilter: save the hash of the tuple in the original
 direction for latter use
Date: Fri, 20 Aug 2010 23:22:23 +0800
Message-ID: <AANLkTimj=6HBdZK0WiPBxhm9YPG_8zRXEZyP--E7Shj8@mail.gmail.com>
References: <1282316003-2966-1-git-send-email-xiaosuo@gmail.com> <1282317016.2484.173.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49932 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab0HTPWp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 11:22:45 -0400
In-Reply-To: <1282317016.2484.173.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 20, 2010 at 11:10 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 20 ao=FBt 2010 =E0 22:53 +0800, Changli Gao a =E9crit :
>> Since we don't change the tuple in the original direction, we can sa=
ve it
>> in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_con=
firm()
>> use.
>>
>> __hash_conntrack() is split into two steps: ____hash_conntrack() is =
used
>> to get the raw hash, and __hash_bucket() is used to get the bucket i=
d.
>>
>> In SYN-flood case, early_drop() doesn't need to recompute the hash a=
gain.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>
> Hmm... so to accept a few more SYN packets per second in SYNFLOOD
> attack, we slow a bit normal operations ?

SYN-flood case is just a side effect. What I want to do is eliminating
the second call to hash_conntrack() of the original tuple in
__nf_conntrack_confirm().

> (adding one test on each
> packet going through conntrack)

Do you mean the rnd test?

>
> If yes (I dont think we should, hackers are stronger than you anyway,
> just face it)
>
> v4:
> =A0 =A0 =A0 =A0__read_mostly on nf_conntrack_rnd
>
>
> What would happen if we let the initialization of nf_conntrack_rnd
> only in the insertion case (like currently done) ?
> Only the first packet received on the machine/conntrack might be hash=
ed
> on a wrong slot. Is it a big deal ? If yes, maybe find a way to
> recompute the hash in this case, instead of reusing 'wrong' one ?
>

I should keep the old way, but fix a race.

        if (unlikely(!nf_conntrack_hash_rnd_initted)) {
                get_random_bytes(&nf_conntrack_hash_rnd,
                                sizeof(nf_conntrack_hash_rnd));
                nf_conntrack_hash_rnd_initted =3D 1;
        }

nf_conntrack_alloc() isn't called with in the nf_conntrack_lock. So
the above code maybe executed more than once on different CPUs. It is
easy to fix with the cmpxchg() trick.

Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
