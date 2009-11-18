From: Ed Cashin <ecashin@coraid.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Wed, 18 Nov 2009 11:49:03 -0500
Message-ID: <ca0871f61dfa85d98f218db8e3dd5178@coraid.com>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
	<8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
	<20091110150617.0e6920f0@nehalam>
	<20091110155316.2c3d7b6e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: shemminger@vyatta.com, karaluh@karaluh.pl, ecashin@coraid.com,
	roel.kluin@gmail.com, harvey.harrison@gmail.com,
	bzolnier@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baron.coraid.com ([12.51.113.4]:49192 "EHLO coraid.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757838AbZKRQuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 11:50:03 -0500
In-Reply-To: <20091110155316.2c3d7b6e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue Nov 10 18:53:43 EST 2009, shemminger@vyatta.com wrote:

...
> --- a/drivers/block/aoe/aoecmd.c	2009-11-10 15:13:25.673859220 -0800
> +++ b/drivers/block/aoe/aoecmd.c	2009-11-10 15:49:20.009047132 -0800
...
> @@ -424,12 +426,29 @@ static void
>  ejectif(struct aoetgt *t, struct aoeif *ifp)
>  {
>  	struct aoeif *e;
> +	struct net_device *nd;
>  	ulong n;
>  
>  	e = t->ifs + NAOEIFS - 1;
> +	nd = e->nd;
>  	n = (e - ifp) * sizeof *ifp;
>  	memmove(ifp, ifp+1, n);
>  	e->nd = NULL;
> +	dev_put(nd);
> +}

I didn't notice this before, but e->nd will be the net_device pointer
from the last ifp in the allocated array, whether it's NULL or not,
and usually won't be ifp->nd, the one we need to give to dev_put.  I
think that's why I see an oops when testing the version of the patch
that I sent last.  The test is doing rmmod on the interface that's
being used to create an ext2 fs on an AoE target.

I'll use ifp->nd instead of e->nd and test again tomorrow.  I have to
step away from the computer today.

-- 
  Ed
