From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Wed, 22 May 2013 17:55:21 +0400
Message-ID: <519CCE49.4050308@yandex-team.ru>
References: <519B38EC.90401@yandex-team.ru>  <20130521120906.GD3578@linux.vnet.ibm.com>  <1369143885.3301.221.camel@edumazet-glaptop>  <519B8908.9080007@yandex-team.ru>  <1369150693.3301.233.camel@edumazet-glaptop>  <519BB90B.6080706@yandex-team.ru>  <1369188080.3301.268.camel@edumazet-glaptop> <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru> <1369225837.3301.324.camel@edumazet-glaptop> <AE90C24D6B3A694183C094C60CF0A2F6026B7246@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, paulmck@linux.vnet.ibm.com,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7246@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.05.2013 17:27, David Laight wrote:
>> So yes, the patch appears to fix the bug, but it sounds not logical to
>> me.
>
> I was confused because the copy of the code I found was different
> (it has some checks for reusaddr - which force a function call in the
> loop).
>
> The code being compiled is:
>
> begin:
> 	result = NULL;
> 	badness = -1;
> 	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
> 		score = compute_score2(sk, net, saddr, sport,
> 				      daddr, hnum, dif);
> 		if (score > badness) {
> 			result = sk;
> 			badness = score;
> 			if (score == SCORE2_MAX)
> 				goto exact_match;
> 		}
> 	}
> 	/*
> 	 * if the nulls value we got at the end of this lookup is
> 	 * not the expected one, we must restart lookup.
> 	 * We probably met an item that was moved to another chain.
> 	 */
> 	if (get_nulls_value(node) != slot2)
> 		goto begin;
>
> Which is entirely inlined - so the compiler is allowed to assume
> that no other code modifies any of the data.
> Hence it is allowed to cache the list head value.
> Indeed it could convert the last line to "for (;;);".
>
> A asm volatile ("":::"memory") somewhere would fix it.
>

Yes, it does. It was my first attempt to fix the issue.
But putting such instructions into each such cycle isn't a good idea, IMHO.

Regards,
Roman
