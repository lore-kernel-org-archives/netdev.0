From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neigh use-after-free
Date: Fri, 03 Apr 2015 16:34:13 -0700
Message-ID: <1428104053.25985.192.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150403202753.GF32724@Sligo.logfs.org>
	 <35adab927f1bade6afd57e62a8720205@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joern Engel <joern@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Potashnik <alexei@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33415 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbbDCXeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 19:34:18 -0400
Received: by paboj16 with SMTP id oj16so48953359pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 16:34:17 -0700 (PDT)
In-Reply-To: <35adab927f1bade6afd57e62a8720205@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-03 at 13:52 -0700, Alexei Potashnik wrote:
> Would this be an appropriate solution:
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index b49e8ba..38265f2 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -168,7 +168,8 @@ static int neigh_forced_gc(struct neigh_table *tbl)
> 
>  static void neigh_add_timer(struct neighbour *n, unsigned long when)
>  {
> -       neigh_hold(n);
> +       if (!atomic_inc_not_zero(&n->refcnt))
> +               return;
>         if (unlikely(mod_timer(&n->timer, when))) {
>                 printk("NEIGH: BUG, double timer add, state is %x\n",
>                        n->nud_state);

This is a very ugly hack. Please find root cause.

The correct way to implement refcount on a timer is :

if (!mod_timer(&n->timer, when))
	neigh_hold(&n->refcnt);

And current code seems to do that (It dumps a printk() and stack trace
otherwise)


Look at sk_reset_timer() for a good example.

Caller of this function must own a reference.
(Or the socket lock in case of sk_reset_timer())

If refcnt is 0 at this point, it means there is another bug, and we
should fix it instead of trying to work around it.
