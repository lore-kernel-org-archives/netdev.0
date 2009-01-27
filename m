From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] tcp: splice as many packets as possible at once
Date: Tue, 27 Jan 2009 10:57:39 +0000
Message-ID: <20090127105739.GA5778@ff.dom.local>
References: <20090125.212203.15909648.davem@davemloft.net> <20090127071130.GA29125@gondor.apana.org.au> <20090127075418.GB4197@ff.dom.local> <20090127100958.GA30239@gondor.apana.org.au> <20090127103511.GE4197@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:25392 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbZA0K5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:57:49 -0500
Content-Disposition: inline
In-Reply-To: <20090127103511.GE4197@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 10:35:11AM +0000, Jarek Poplawski wrote:
> On Tue, Jan 27, 2009 at 09:09:58PM +1100, Herbert Xu wrote:
> > On Tue, Jan 27, 2009 at 07:54:18AM +0000, Jarek Poplawski wrote:
> > > 
> > > Yes, but ip_append_data() (and skb_append_datato_frags() for
> > > NETIF_F_UFO only, so currently not a problem), uses this differently,
> > > and these pages in sk->sk_sndmsg_page could leak or be used after
> > > kfree. (I didn't track locking in these other places).
> > 
> > It'll be freed when the socket is freed so that should be fine.
> > 
> 
> I don't think so: these places can overwrite sk->sk_sndmsg_page left
> after tcp_sendmsg(), or skb_splice_bits() now, with NULL or a new
> pointer without put_page() (they only reference copied chunks and
> expect auto freeing). On the other hand, if tcp_sendmsg() reads after
> them it could use a pointer after the page is freed, I guess.

tcp_v4_destroy_sock() looks like vulnerable too.

BTW, skb_append_datato_frags() currently doesn't need to use this
sk->sk_sndmsg_page at all - it doesn't use caching between calls.

Jarek P.
