From: Roberto Nibali <ratz@drugphish.ch>
Subject: Re: [Patch] 2.4.32 - Neighbour Cache (ARP) State machine bug Fixed
Date: Mon, 28 Nov 2005 22:40:05 +0100
Message-ID: <438B7935.8050604@drugphish.ch>
References: <9fda5f510511281257o364acb3gd634f8e412cd7301@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@osdl.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751319AbVK1VkN@vger.kernel.org>
To: Pradeep Vincent <pradeep.vincent@gmail.com>
In-Reply-To: <9fda5f510511281257o364acb3gd634f8e412cd7301@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In 2.4.21, arp code uses gc_timer to check for stale arp cache
> entries. In 2.6, each entry has its own timer to check for stale arp
> cache. 2.4.29 to 2.4.32 kernels (atleast) use neither of these timers.

Regarding NUD_REACHABLE <-> NUD_STALE transition it has a timer check.
Due to the fast path it's not enabled per default. Use neigh_sync() to
check, although I believe the installed tasklet does this for you already.

The knowledgeable netdev people will know better.

> This causes problems in environments where IPs or MACs are reassigned
> - saw this problem on load balancing router based networks that use
> VMACs. Tested this code on load balancing router based networks as
> well as peer-linux systems.

How do you use VMACs in 2.4.x?

> diff -Naur old/net/core/neighbour.c new/net/core/neighbour.c
> --- old/net/core/neighbour.c    Wed Nov 23 17:15:30 2005
> +++ new/net/core/neighbour.c    Wed Nov 23 17:26:01 2005
> @@ -14,6 +14,7 @@
> *     Vitaly E. Lavrov        releasing NULL neighbor in neigh_add.
> *     Harald Welte            Add neighbour cache statistics like rtstat
> *     Harald Welte            port neighbour cache rework from 2.6.9-rcX
> + *      Pradeep Vincent         Move neighbour cache entry to stale state
> */
> 
> #include <linux/config.h>
> @@ -705,6 +706,14 @@
>                        neigh_release(n);
>                        continue;
>                }
> +
> +               /* Mark it stale - To be reconfirmed later when used */
> +               if (n->nud_state&NUD_REACHABLE &&
> +                   now - n->confirmed > n->parms->reachable_time) {
> +                       n->nud_state = NUD_STALE;
> +                       neigh_suspect(n);
> +               }
> +

If this is really a problem, why not simply call neigh_sync()? Your
patch also seems to be whitespace damaged.

>                write_unlock(&n->lock);
> 
> next_elt:

I've cc'd netdev since this is where such patches should go for
discussion; left Linus in the loop (netiquette) although he's nothing to
do with this ;).

Cheers,
Roberto Nibali, ratz
-- 
echo
'[q]sa[ln0=aln256%Pln256/snlbx]sb3135071790101768542287578439snlbxq' | dc
