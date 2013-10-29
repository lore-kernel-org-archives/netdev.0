From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Tue, 29 Oct 2013 08:08:13 -0700
Message-ID: <1383059293.5464.31.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131028115552.GC4408@cpaasch-mac>
	 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029144100.GA28046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:61488 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab3J2PI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 11:08:29 -0400
Received: by mail-pa0-f48.google.com with SMTP id kq14so147534pab.7
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 08:08:28 -0700 (PDT)
In-Reply-To: <20131029144100.GA28046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 22:41 +0800, Herbert Xu wrote:
> On Mon, Oct 28, 2013 at 06:15:08PM -0700, Eric Dumazet wrote:
> > On Mon, 2013-10-28 at 06:21 -0700, Eric Dumazet wrote:
> > 
> > > But we also need to fix the skb_segment() bug anyway.
> > 
> > Hi Christoph
> > 
> > I cooked a minimal patch, could you please try it ?
> > 
> > I'll refactor skb_segment() to be smarter for the next release
> > (linux-3.14).
> 
> I think this patch is just papering over a deeper issue.
> 
> We should either be building skbs in pages, or using frag_list.
> In the latter case each frag_list must be exactly mss bytes,
> except for the last one.
> 
> So if we're crashing here it means that we got mixed up on the
> receive side, either because the driver was sending us bogus skbs
> or we're simply buggy.
> 
> So we need to figure out why the receive-side (i.e., GRO) is building
> these bogus packets, and not papering over them on the transmit-side.

It looks like you missed a lot of recent changes.

GRO layer was updated to be able to stack two or three sk_buff,
fully populated with page frags.

Thats quite mandatory to support line rate for 40Gb links.

We now have to make skb_segment() aware of this, I missed this part.
