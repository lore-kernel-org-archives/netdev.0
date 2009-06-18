From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Thu, 18 Jun 2009 18:09:48 +0200
Message-ID: <4A3A66CC.4090205@trash.net>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <20090617110803.GA10175@elte.hu> <20090618052356.GA18722@elte.hu> <4A39D778.9020607@cosmosbay.com> <4A3A0D45.8090806@trash.net> <4A3A5599.4080906@trash.net> <4A3A6143.3040607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34759 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbZFRQJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 12:09:49 -0400
In-Reply-To: <4A3A6143.3040607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> In my own analysis, I found death_by_timeout() might be problematic,
> with RCU and lockless lookups.
> 
> static void death_by_timeout(unsigned long ul_conntrack)
> {
>         struct nf_conn *ct = (void *)ul_conntrack;
> 
>         if (!test_bit(IPS_DYING_BIT, &ct->status) &&
>             unlikely(nf_conntrack_event(IPCT_DESTROY, ct) < 0)) {
>                 /* destroy event was not delivered */
>                 nf_ct_delete_from_lists(ct);
> << HERE >>
> 
>                 nf_ct_insert_dying_list(ct);
>                 return;
>         }
>         set_bit(IPS_DYING_BIT, &ct->status);
>         nf_ct_delete_from_lists(ct);
>         nf_ct_put(ct);
> }
> 
> 
> We delete ct from a list and insert it in a new list.
> 
> I believe a reader could "*catch*" ct while doing a lookup and miss the end
> of its chain. (nulls algo check the null value at the end of lookup and can
> decide to restart the lookup if the null value is not the expected one)
> 
> We need to change nf_conntrack_init_net() and use a different "null" value,
> guaranteed not being used in regular lists

Good catch. This is a new bug, but it shouldn't matter in this case
since nf_conntrack_event() can't fail unless you have a userspace
listener that makes use of reliable delivery, which I think hasn't
even been released yet.

> Patch follows :

Looks good. If you send me a Signed-off-by: I'll already apply it.
