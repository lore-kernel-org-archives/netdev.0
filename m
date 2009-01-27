From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] tcp: splice as many packets as possible at once
Date: Tue, 27 Jan 2009 12:16:42 +0000
Message-ID: <20090127121642.GA5866@ff.dom.local>
References: <20090125.212203.15909648.davem@davemloft.net> <20090127071130.GA29125@gondor.apana.org.au> <20090127075418.GB4197@ff.dom.local> <20090127100958.GA30239@gondor.apana.org.au> <20090127103511.GE4197@ff.dom.local> <20090127114805.GA30982@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f11.google.com ([209.85.221.11]:37186 "EHLO
	mail-qy0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175AbZA0MQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 07:16:56 -0500
Content-Disposition: inline
In-Reply-To: <20090127114805.GA30982@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 10:48:05PM +1100, Herbert Xu wrote:
> On Tue, Jan 27, 2009 at 10:35:11AM +0000, Jarek Poplawski wrote:
> >
> > > > Yes, but ip_append_data() (and skb_append_datato_frags() for
> > > > NETIF_F_UFO only, so currently not a problem), uses this differently,
> > > > and these pages in sk->sk_sndmsg_page could leak or be used after
> > > > kfree. (I didn't track locking in these other places).
> > > 
> > > It'll be freed when the socket is freed so that should be fine.
> > 
> > I don't think so: these places can overwrite sk->sk_sndmsg_page left
> > after tcp_sendmsg(), or skb_splice_bits() now, with NULL or a new
> > pointer without put_page() (they only reference copied chunks and
> > expect auto freeing). On the other hand, if tcp_sendmsg() reads after
> > them it could use a pointer after the page is freed, I guess.
> 
> I wasn't referring to the first part of your sentence.  That can't
> happen because they're only used for UDP sockets, this is a TCP
> socket.

Do you mean this part from ip_append_data() isn't used for TCP?:

1007
1008                         if (page && (left = PAGE_SIZE - off) > 0) {
1009                                 if (copy >= left)
1010                                         copy = left;
1011                                 if (page != frag->page) {
1012                                         if (i == MAX_SKB_FRAGS) {
1013                                                 err = -EMSGSIZE;
1014                                                 goto error;
1015                                         }
1016                                         get_page(page);
1017                                         skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
1018                                         frag = &skb_shinfo(skb)->frags[i];
1019                                 }
1020                         } else if (i < MAX_SKB_FRAGS) {
1021                                 if (copy > PAGE_SIZE)
1022                                         copy = PAGE_SIZE;
1023                                 page = alloc_pages(sk->sk_allocation, 0);
1024                                 if (page == NULL)  {
1025                                         err = -ENOMEM;
1026                                         goto error;
1027                                 }
1028                                 sk->sk_sndmsg_page = page;
1029                                 sk->sk_sndmsg_off = 0;
1030
1031                                 skb_fill_page_desc(skb, i, page, 0, 0);
1032                                 frag = &skb_shinfo(skb)->frags[i];
1033                         } else {

Jarek P.
