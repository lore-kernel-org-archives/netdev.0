From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH 3/5] net/mlx4: fix some error handling in
 mlx4_multi_func_init()
Date: Thu, 11 Feb 2016 12:20:39 +0200
Message-ID: <20160211122039.4959f6cb@jpm-OptiPlex-GX620>
References: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
	<1455048677-19882-4-git-send-email-linux@rasmusvillemoes.dk>
	<56BB0577.8000000@dev.mellanox.co.il>
	<87twlgtosn.fsf@rasmusvillemoes.dk>
	<20160211112943.20c0de19@jpm-OptiPlex-GX620>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yishai Hadas <yishaih@dev.mellanox.co.il>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Majd Dibbiny <majd@mellanox.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33222 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbcBKKUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 05:20:36 -0500
Received: by mail-wm0-f68.google.com with SMTP id c200so9725099wme.0
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 02:20:35 -0800 (PST)
In-Reply-To: <20160211112943.20c0de19@jpm-OptiPlex-GX620>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ouch! Egg on my face!  Sorry about that.
You are correct!  while (--i >= 0) IS exactly equivalent to
while (i--). (the while condition is fully evaluated before the loop is
entered; pre or post increment only influences which value is tested
for true in the while condition -- the pre-value (with post-increment) 
or the post-value (with pre-increment)).

In that case, my comment below regarding the double-free is also not
correct.  Setting the freed pointer to NULL is not needed.

My bad. We should go with your format:  while (i--)

-Jack

On Thu, 11 Feb 2016 11:29:43 +0200
Jack Morgenstein <jackm@dev.mellanox.co.il> wrote:

> On Wed, 10 Feb 2016 19:15:20 +0100
> Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:
> 
> > On Wed, Feb 10 2016, Yishai Hadas <yishaih@dev.mellanox.co.il>
> > wrote:
> > 
> > >> @@ -2429,7 +2429,7 @@ err_thread:
> > >>   	flush_workqueue(priv->mfunc.master.comm_wq);
> > >>   	destroy_workqueue(priv->mfunc.master.comm_wq);
> > >>   err_slaves:
> > >> -	while (--i) {
> > >> +	while (i--) {
> > >
> > > This fix is wrong as it hits the case that i arrived the last
> > > value then below code will access to a non valid entry in the
> > > array.
> > >
> > > The expected fix should be:
> > > while (--i >= 0)
> > >
> > 
> > Huh? They're completely equivalent (given that i is necessarily
> > non-negative before we evaluate the loop condition)
> 
> No, they are not equivalent.
> if i == the max value (dev->num_slaves) when entering your proposed
> while loop, the kfree call index (i) will be out of range!  This can
> happen, for example, if the failure occurs downstream from the "i"
> for-loop (e.g., if the call to mlx4_init_resource_tracker() fails).
> 
> Therefore, we DO require the pre-decrement format.  Therefore, the
> one-line fix proposed by Yishai is the correct fix.
> >. I don't really
> > care either way, but git grep says that 'while (i--)' is 5 times
> > more common than 'while (--i >= 0)'.
> Not relevant, while (i--) is simply not correct, because of the case
> where the for-loop involving i completes successfully and an error
> occurs later.
> 
> FYI, you also had another bug in your solution -- a double-free when
> kzalloc for port 2 fails.  For your code, you should also have reset
> s_state->vlan_filter[port] to NULL as shown below:
> 			for (port = 1; port <= MLX4_MAX_PORTS;
> port++) { struct mlx4_vport_state *admin_vport;
> 				struct mlx4_vport_state *oper_vport;
> 
> 				s_state->vlan_filter[port] =
> 					kzalloc(sizeof(struct
> 				mlx4_vlan_fltr), GFP_KERNEL);
> 				if (!s_state->vlan_filter[port]) {
> 					if (--port) {
>  						kfree(s_state->vlan_filter[port]);
> 	==> You should have added this
> s_state->vlan_filter[port] = NULL; }
> 					goto err_slaves;
> 				}
> 
> However, again, the correct solution is to do what Yishai suggests:
> 	while (--i >= 0)
> so that if i is already zero the while-loop will not be entered.
> 
> -Jack
> > 
> > Rasmus
> > --
> > To unsubscribe from this list: send the line "unsubscribe
> > linux-rdma" in the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
