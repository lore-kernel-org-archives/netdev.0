From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Do not use this_cpu_ptr() in preemptible
 context
Date: Sun, 08 Oct 2017 11:25:15 -0700
Message-ID: <1507487115.14419.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171008151839.24519-1-idosch@mellanox.com>
         <1507478633.14419.30.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171008165407.GA26635@shredder.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
        davem@davemloft.net, weiwan@google.com, mlxsw@mellanox.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:54699 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdJHSZS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 14:25:18 -0400
Received: by mail-pf0-f172.google.com with SMTP id m28so6762209pfi.11
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 11:25:17 -0700 (PDT)
In-Reply-To: <20171008165407.GA26635@shredder.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-08 at 19:54 +0300, Ido Schimmel wrote:
> Hi Eric,

> >  	prev = cmpxchg(p, NULL, pcpu_rt);
> > -	if (prev) {
> > -		/* If someone did it before us, return prev instead */
> > -		/* release refcnt taken by ip6_rt_pcpu_alloc() */
> > -		dst_release_immediate(&pcpu_rt->dst);
> > -		/* release refcnt taken by above dst_hold() */
> > -		dst_release_immediate(&pcpu_rt->dst);
> > -		dst_hold(&prev->dst);
> > -		pcpu_rt = prev;
> > -	}
> > +	BUG_ON(prev);
> 
> Is this BUG_ON() now valid because of the local_bh_disable() in
> ip6_pol_route()?

Yes, this bug to trigger would need this code be re-entered from a hard
IRQ, and that would be wrong of course.
