From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: skb_linearize
Date: Wed, 31 Oct 2012 21:15:30 +0200
Message-ID: <20121031191530.GA3674@redhat.com>
References: <20120916091747.GA23775@redhat.com>
 <1347808032.13258.275.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759805Ab2JaTNO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 15:13:14 -0400
Content-Disposition: inline
In-Reply-To: <1347808032.13258.275.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 16, 2012 at 04:07:12PM +0100, Ben Hutchings wrote:
> On Sun, 2012-09-16 at 12:17 +0300, Michael S. Tsirkin wrote:
> > I notice that dev_hard_start_xmit might invoke
> > __skb_linearize e.g. if device does not support NETIF_F_SG.
> > 
> > This in turn onvokes __pskb_pull_tail, and
> > documentation of __pskb_pull_tail says:
> >   &sk_buff MUST have reference count of 1.
> > 
> > I am guessing 'reference count' means users in this context, right?
> > IIUC this is because it modifies skb in a way that
> > isn't safe if anyone else is looking at the skb.
> > 
> > 
> > However, I don't see what guarantees that reference
> > count is 1 when dev_hard_start_xmit invokes
> > linearize. In particular it calls dev_queue_xmit_nit
> > which could queue packets on a network tap.
> > 
> > Could someone help me understand please?
> 
> Reference count here means references to struct sk_buff itself.  The
> header area and data fragments are allowed to be shared.
> 
> dev_queue_xmit_nit() clones the skb for each tap, so the reference count
> on the original skb remains 1.
> 
> Ben.

Interesting. But don't skb clones share the fragment list?
Maybe I misunderstand? If they do it looks like the following race
would be possible:

- skb is cloned and queued e.g. at socket receive queue.
  dataref becomes 2.
- On CPU 1, skb_copy_datagram_iovec is called on clone 1, is reads nr_frags and sees
  value > 1.
- On CPU 2, __skb_linearize is now called on clone 2, it modified the
  skb so nr_frags is now 0, and does put_page for all frags > 1.
- On CPU 1, skb_copy_datagram_iovec will now use the previously read
  nr_frags > 1 and access a fragment page that was already freed.

What did I miss?

> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
