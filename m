From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ipv6: release dst in ping_v6_sendmsg
Date: Tue, 6 Sep 2016 14:50:09 -0400
Message-ID: <20160906185009.6cpnwrytcsogz6r5@codemonkey.org.uk>
References: <20160902183950.p3iv25jnuwmq74sg@codemonkey.org.uk>
 <20160906173621.GA33747@kafai-mba.local>
 <1473184363.10725.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:43836 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756679AbcIFSuP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 14:50:15 -0400
Content-Disposition: inline
In-Reply-To: <1473184363.10725.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 10:52:43AM -0700, Eric Dumazet wrote:
 
 > > > @@ -126,8 +126,10 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 > > >  	rt = (struct rt6_info *) dst;
 > > >
 > > >  	np = inet6_sk(sk);
 > > > -	if (!np)
 > > > -		return -EBADF;
 > > > +	if (!np) {
 > > > +		err = -EBADF;
 > > > +		goto dst_err_out;
 > > > +	}
 > > >
 > > >  	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
 > > >  		fl6.flowi6_oif = np->mcast_oif;
 > > > @@ -163,6 +165,9 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 > > >  	}
 > > >  	release_sock(sk);
 > > >
 > > > +dst_err_out:
 > > > +	dst_release(dst);
 > > > +
 > > >  	if (err)
 > > >  		return err;
 > > >
 > > 
 > > Acked-by: Martin KaFai Lau <kafai@fb.com>
 > 
 > This really does not make sense to me.
 > 
 > If np was NULL, we should have a crash before.

In the case where I was seeing the traces, we were taking the 'success'
path through the function, so sk was non-null.

 > So we should remove this test, since it is absolutely useless.

Looking closer, it seems the assignment of np is duplicated also,
so that can also go.   This is orthogonal to the dst leak though.
I'll submit a follow-up cleaning that up.

	Dave
