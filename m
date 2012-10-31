From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: skb_linearize
Date: Wed, 31 Oct 2012 21:03:32 +0000
Message-ID: <1351717412.2706.28.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120916091747.GA23775@redhat.com>
	 <1347808032.13258.275.camel@deadeye.wl.decadent.org.uk>
	 <20121031191530.GA3674@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.hengli.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32377 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933501Ab2JaVDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 17:03:35 -0400
In-Reply-To: <20121031191530.GA3674@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-31 at 21:15 +0200, Michael S. Tsirkin wrote:
> On Sun, Sep 16, 2012 at 04:07:12PM +0100, Ben Hutchings wrote:
> > On Sun, 2012-09-16 at 12:17 +0300, Michael S. Tsirkin wrote:
> > > I notice that dev_hard_start_xmit might invoke
> > > __skb_linearize e.g. if device does not support NETIF_F_SG.
> > > 
> > > This in turn onvokes __pskb_pull_tail, and
> > > documentation of __pskb_pull_tail says:
> > >   &sk_buff MUST have reference count of 1.
> > > 
> > > I am guessing 'reference count' means users in this context, right?
> > > IIUC this is because it modifies skb in a way that
> > > isn't safe if anyone else is looking at the skb.
> > > 
> > > 
> > > However, I don't see what guarantees that reference
> > > count is 1 when dev_hard_start_xmit invokes
> > > linearize. In particular it calls dev_queue_xmit_nit
> > > which could queue packets on a network tap.
> > > 
> > > Could someone help me understand please?
> > 
> > Reference count here means references to struct sk_buff itself.  The
> > header area and data fragments are allowed to be shared.
> > 
> > dev_queue_xmit_nit() clones the skb for each tap, so the reference count
> > on the original skb remains 1.
> > 
> > Ben.
> 
> Interesting. But don't skb clones share the fragment list?

Yes.

> Maybe I misunderstand? If they do it looks like the following race
> would be possible:
> 
> - skb is cloned and queued e.g. at socket receive queue.
>   dataref becomes 2.
> - On CPU 1, skb_copy_datagram_iovec is called on clone 1, is reads nr_frags and sees
>   value > 1.
> - On CPU 2, __skb_linearize is now called on clone 2, it modified the
>   skb so nr_frags is now 0, and does put_page for all frags > 1.
> - On CPU 1, skb_copy_datagram_iovec will now use the previously read
>   nr_frags > 1 and access a fragment page that was already freed.
> 
> What did I miss?

__skb_linearize() calls __pskb_pull_tail(), which starts with:

	if (eat > 0 || skb_cloned(skb)) {
		if (pskb_expand_head(skb, 0, eat > 0 ? eat + 128 : 0,
				     GFP_ATOMIC))
			return NULL;
	}

pskb_expand_head() will then create a new unshared head area for the skb
being linearised, and will add a reference to each fragment page
(skb_frag_ref()).  __pskb_pull_tail() unreferences the pages later, as
you say, but this all cancels out.

(pskb_expand_head() will also cancel zero-copy (skb_orphan_frags() ->
skb_copy_ubufs()), which seems like it should be done only after the
head area has been unshared.  But skb_clone() will also do that, so I
don't know how the zero-copy flag would still be set on a cloned skb.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
