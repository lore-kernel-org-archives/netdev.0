From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: oopses since "net: Optimize memory usage when splicing from sockets"
Date: Thu, 30 Apr 2009 14:40:36 +0200
Message-ID: <20090430124036.GN14729@mail.wantstofly.org>
References: <20090430031626.GM14729@mail.wantstofly.org> <20090430084321.GA2753@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:45382 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761722AbZD3Mgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 08:36:52 -0400
Content-Disposition: inline
In-Reply-To: <20090430084321.GA2753@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 10:43:21AM +0200, Jarek Poplawski wrote:

> > Since 4fb669948116d928ae44262ab7743732c574630d ("net: Optimize memory
> > usage when splicing from sockets.") I'm seeing this oops (e.g. in
> > 2.6.30-rc3) when splicing from a TCP socket to /dev/null on a driver
> > (mv643xx_eth) that uses LRO in the skb mode (lro_receive_skb) rather
> > than the frag mode:
> ...
> > addr2line suggests skb->sk is NULL in linear_to_page():
> > 
> > 
> > 	static inline struct page *linear_to_page(struct page *page, unsigned int *len,
> > 						  unsigned int *offset,
> > 						  struct sk_buff *skb)
> > 	{
> > 		struct sock *sk = skb->sk;
> > 		struct page *p = sk->sk_sndmsg_page;		<========
> > 		unsigned int off;
> > 
> > 		if (!p) {
> > 
> > 
> > When we get here, skb->sk has apparently already been dropped, leading
> > to a NULL pointer deref.  Backing out the offending commit makes the
> > oops go away (as does converting the driver to lro frag rx, but that
> > destroys routing performance).
> > 
> > Thoughts?  Should we just fall back to plain alloc_pages() if skb->sk
> > is NULL, or should have still have the socket reference when we get here?
> 
> Hmm... I definitely need more time for this, but the first and maybe
> wrong impression is this is an skb from the frag_list. There are
> probably better ways of fixing it properly, but here is a quick hack
> for the beginning (alas not even compile-tested at the moment).

With your patch, at least the oops is gone, and I guess it makes
sense and looks correct, so:

	Tested-by: Lennert Buytenhek <buytenh@wantstofly.org>

Thanks!
