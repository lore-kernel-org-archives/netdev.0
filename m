From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6: release dst in ping_v6_sendmsg
Date: Tue, 06 Sep 2016 10:52:43 -0700
Message-ID: <1473184363.10725.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160902183950.p3iv25jnuwmq74sg@codemonkey.org.uk>
         <20160906173621.GA33747@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36594 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755314AbcIFRwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 13:52:46 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so11243589pab.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 10:52:46 -0700 (PDT)
In-Reply-To: <20160906173621.GA33747@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-06 at 10:36 -0700, Martin KaFai Lau wrote:
> On Fri, Sep 02, 2016 at 02:39:50PM -0400, Dave Jones wrote:
> > Neither the failure or success paths of ping_v6_sendmsg release
> > the dst it acquires.  This leads to a flood of warnings from
> > "net/core/dst.c:288 dst_release" on older kernels that
> > don't have 8bf4ada2e21378816b28205427ee6b0e1ca4c5f1 backported.
> >
> > That patch optimistically hoped this had been fixed post 3.10, but
> > it seems at least one case wasn't, where I've seen this triggered
> > a lot from machines doing unprivileged icmp sockets.
> >
> > Cc: Martin Lau <kafai@fb.com>
> > Signed-off-by: Dave Jones <davej@codemonkey.org.uk>
> >
> > diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
> > index 0900352c924c..0e983b694ee8 100644
> > --- a/net/ipv6/ping.c
> > +++ b/net/ipv6/ping.c
> > @@ -126,8 +126,10 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
> >  	rt = (struct rt6_info *) dst;
> >
> >  	np = inet6_sk(sk);
> > -	if (!np)
> > -		return -EBADF;
> > +	if (!np) {
> > +		err = -EBADF;
> > +		goto dst_err_out;
> > +	}
> >
> >  	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
> >  		fl6.flowi6_oif = np->mcast_oif;
> > @@ -163,6 +165,9 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
> >  	}
> >  	release_sock(sk);
> >
> > +dst_err_out:
> > +	dst_release(dst);
> > +
> >  	if (err)
> >  		return err;
> >
> 
> Acked-by: Martin KaFai Lau <kafai@fb.com>

This really does not make sense to me.

If np was NULL, we should have a crash before.

So we should remove this test, since it is absolutely useless.
