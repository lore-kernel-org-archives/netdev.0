From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 07:15:36 +0200
Message-ID: <1319001336.4424.8.camel@jlt3.sipsolutions.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:59637 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab1JSFPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 01:15:40 -0400
In-Reply-To: <20111019.001610.312990203017422173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 00:16 -0400, David Miller wrote:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Thu, 13 Oct 2011 11:46:26 +0200
> 
> > The first patch fixes a bug in the time stamping code introduced in
> > v2.6.36 of the kernel.
> > 
> > The other two patches depend on the first patch and fix two bugs in a
> > PTP Hardware Clock driver. This driver was first introduced in Linux
> > version 3.0.
> > 
> > Richard Cochran (3):
> >   net: hold sock reference while processing tx timestamps
> >   dp83640: use proper function to free transmit time stamping packets
> >   dp83640: free packet queues on remove
> 
> Johannes and Eric, please help review Richard's fixes here.

The only thing I'm not completely sure about is whether or not it is
permissible to sock_hold() at that point. I'm probably just missing
something, but: if sk_free() was called before hard_start_xmit() which
will call skb_clone_tx_timestamp(), can we really call sock_hold()?

The reason I ask is that sock_wfree() doesn't check sk_refcnt, so if it
is possible for sk_free() to have been called before hard_start_xmit(),
maybe because the packet was stuck on the qdisc for a while, the socket
won't be released (sk_free checks sk_wmem_alloc) but the sk_wfree() when
the original skb is freed will actually free the socket, invalidating
the clone's sk pointer *even though* we called sock_hold() right after
making the clone.

So what guarantees that sk_refcnt is still non-zero when we make the
clone? Alternatively, should sock_wfree() check sk_refcnt?

johannes
