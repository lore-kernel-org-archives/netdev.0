From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Wed, 30 May 2012 06:45:37 +0200
Message-ID: <1338353137.2760.7.camel@edumazet-glaptop>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <4FC3A465.4030203@uclouvain.be>  <1338322661.7747.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56243 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab2E3Epm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 00:45:42 -0400
Received: by wgbdr13 with SMTP id dr13so4601491wgb.1
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 21:45:41 -0700 (PDT)
In-Reply-To: <1338322661.7747.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-29 at 22:17 +0200, Jesper Dangaard Brouer wrote:
> On Mon, 2012-05-28 at 18:14 +0200, Christoph Paasch wrote:
> 

> > Concerning (1):
> > I think, there are places where you may have troube because you don't
> > hold the lock.
> > E.g., in tcp_make_synack (called by tcp_v4_send_synack from your
> > tcp_v4_syn_conn_limit) there is:
> > 
> > if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
> > 	(req->window_clamp > tcp_full_space(sk) ||
> > 	 req->window_clamp == 0))
> > 	req->window_clamp = tcp_full_space(sk);
> > 
> > Thus, tcp_full_space(sk) may have different values between the check and
> > setting req->window_clamp.
> 
> This should be simply solved by using a local stack variable, for
> storing the result from tcp_full_space(sk).  Its likely that GCC already
> does this behind our back.
> 

Thats not the proper way to handle that situation.

A local stack variable makes no such guarantee. You need ACCESS_ONCE().

This is exactly the kind of things that RCU takes care of.
