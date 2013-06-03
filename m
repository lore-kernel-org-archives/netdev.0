From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next] netlink: allow large data transfers from
 user-space
Date: Mon, 03 Jun 2013 11:00:37 -0700
Message-ID: <1370282437.24311.175.camel@edumazet-glaptop>
References: <1370277599-27072-1-git-send-email-pablo@netfilter.org>
	 <1370279559.24311.160.camel@edumazet-glaptop>
	 <20130603174138.GA28338@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:56765 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab3FCSAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 14:00:38 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so1013599pde.32
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 11:00:38 -0700 (PDT)
In-Reply-To: <20130603174138.GA28338@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 19:41 +0200, Pablo Neira Ayuso wrote:
> Hi Eric!
> 
> On Mon, Jun 03, 2013 at 10:12:39AM -0700, Eric Dumazet wrote:
> > On Mon, 2013-06-03 at 18:39 +0200, Pablo Neira Ayuso wrote:
> > 
> > > +	if (is_vmalloc_addr(skb->head)) {
> > > +		vfree(skb->head);
> > > +		skb->data = NULL;
> > > +	}
> > >  
> > 
> > You probably meant :
> > 
> > 	skb->head = NULL;
> > 
> > Now, cross our fingers we do not skb_orphan() these skb too early :)
> 
> skb_release_all checks for skb->data != NULL to release skb->head as
> it would have been allocated via kmalloc. This didn't look very
> intuitive to me when I hit a panic while testing my patch either.

Oh well, this is probably an old typo because of skb_release_data() name

So we indeed do :

	if (likely(skb->data))
		skb_release_data(skb);

But it really should be

	if (likely(skb->head))
		skb_release_head(skb);

as skb->data is not pointing to the beginning of the area to be freed.

BTW, __alloc_skb_head() inits skb->data to NULL, and leaves skb->head
uninitialized. Thats is really not nice...
