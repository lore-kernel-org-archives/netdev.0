From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Fix locking bug in lltx path
Date: 13 Sep 2004 21:43:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095126203.1056.7.camel@jzny.localdomain>
References: <m3vfei9gzv.fsf@averell.firstfloor.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        arjanv@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m3vfei9gzv.fsf@averell.firstfloor.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Finaly got around to testing today and got bitten by this (was planning
to send patch);->

In any case, some good news: one of the NICs tested was e1000 with and
without LLTX pure forwarding (eth0->eth1 and eth1->eth0, 64 byte packets
beating up the interfaces at 1/48Mpps): did not see
much difference between the two. There did seem to be some latency
improvements (in the range of 50 microsecs or so for the LLTX but could
be experimental error, needs more validation). 
I think perhaps a case where multi processors fanning into one NIC would
be a better test to see the value of LLTX.
The good news (for me) is it doesnt seem to affect things negatively.

[We saw some corrupt netpoll packets but that could be something else
broken].

cheers,
jamal

On Mon, 2004-09-13 at 14:11, Andi Kleen wrote:
> Thanks to Arjan's spinlock debug kernel for finding it.
> 
> This fixes a silly missing spin lock in the relock path. For some 
> reason it seems to still work when you don't have spinlock debugging
> enabled.
> 
> Please apply.
> 
> -Andi
> 
> --------------------------------------------------------------------
> 
> Fix missing spin lock in lltx path.
> 
> Thanks to Arjan's spinlock debug kernel for finding it.
> 
> Signed-off-by: Andi Kleen <ak@muc.de>
> 
> diff -u linux-2.6.9rc1-bk19/net/sched/sch_generic.c-X linux-2.6.9rc1-bk19/net/sched/sch_generic.c
> --- linux-2.6.9rc1-bk19/net/sched/sch_generic.c-X	2004-09-13 08:51:46.000000000 +0200
> +++ linux-2.6.9rc1-bk19/net/sched/sch_generic.c	2004-09-13 19:22:50.000000000 +0200
> @@ -153,8 +153,10 @@
>  					spin_lock(&dev->queue_lock);
>  					return -1;
>  				}
> -				if (ret == -1 && nolock)
> +				if (ret == -1 && nolock) {
> +					spin_lock(&dev->queue_lock);
>  					goto collision; 
> +				}
>  			}
>  
>  			/* Release the driver */
> 
> 
> 
