From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v2 1/1] ppp: Fix one deadlock issue of PPP when send frame
Date: Wed, 17 Aug 2016 19:42:19 +0200
Message-ID: <20160817174219.y4opmhj4u77m3ufq@alphalink.fr>
References: <1471347218-24472-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulus@samba.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471347218-24472-1-git-send-email-fgao@ikuai8.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 16, 2016 at 07:33:38PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> PPP channel holds one spinlock before send frame. But the skb may
> select the same PPP channel with wrong route policy. As a result,
> the skb reaches the same channel path. It tries to get the same
> spinlock which is held before. Bang, the deadlock comes out.
> 
Unless I misunderstood the problem you're trying to solve, this patch
doesn't really help: deadlock still occurs if the same IP is used for
L2TP and PPP's peer address.

> Now add one lock owner to avoid it like xmit_lock_owner of
> netdev_queue. Check the lock owner before try to get the spinlock.
> If the current cpu is already the owner, needn't lock again. When
> PPP channel holds the spinlock at the first time, it sets owner
> with current CPU ID.
>
I think you should forbid lock recursion entirely, and drop the packet
if the owner tries to re-acquire the channel lock. Otherwise you just
move the deadlock down the stack (l2tp_xmit_skb() can't be called
recursively).

> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index 70cfa06..6909ab1 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -162,6 +162,37 @@ struct ppp {
>  			 |SC_MULTILINK|SC_MP_SHORTSEQ|SC_MP_XSHORTSEQ \
>  			 |SC_COMP_TCP|SC_REJ_COMP_TCP|SC_MUST_COMP)
>  
> +struct chennel_lock {
            ^
I guess you meant 'channel_lock'.

> +	spinlock_t lock;
> +	u32 owner;
This field's default value is -1. So why not declaring it as 'int'?
