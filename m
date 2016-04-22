From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] gro: Partly revert "net: gro: allow to build full
 sized skb"
Date: Fri, 22 Apr 2016 10:51:07 +0200
Message-ID: <20160422085107.GJ3347@gauss.secunet.com>
References: <20160421074042.GF3347@gauss.secunet.com>
 <CAKgT0Uc-MfZseKauJMW+xh+5LTEww6hcWmuXeCATsDA+Z-POsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37990 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbcDVIvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 04:51:12 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0Uc-MfZseKauJMW+xh+5LTEww6hcWmuXeCATsDA+Z-POsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 09:02:48AM -0700, Alexander Duyck wrote:
> On Thu, Apr 21, 2016 at 12:40 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > This partly reverts the below mentioned patch because on
> > forwarding, such skbs can't be offloaded to a NIC.
> >
> > We need this to get IPsec GRO for forwarding to work properly,
> > otherwise the GRO aggregated packets get segmented again by
> > the GSO layer. Although discovered when implementing IPsec GRO,
> > this is a general problem in the forwarding path.
> 
> I'm confused as to why you would need this to get IPsec GRO forwarding
> to work. 

It works without this, but the performance numbers are not that good
if we have to do GSO in software.

> Are you having to go through a device that doesn't have
> NETIF_F_FRAGLIST defined?

I don't know of any NIC that can do TSO on a skbuff with fraglist,
that's why I try to avoid to have a buffer with fraglist.

> Also what is the issue with having to go
> through the GSO layer on segmentation?  It seems like we might be able
> to do something like what we did with GSO partial to split frames so
> that they are in chunks that wouldn't require NETIF_F_FRAGLIST.  Then
> you could get the best of both worlds in that the stack would only
> process one super-frame, and the transmitter could TSO a series of
> frames that are some fixed MSS in size.

This could be interesting. Then we could have a buffer with
fraglist, GSO layer splits in skbuffs without fraglist that
can be TSO offloaded. Something like this might solve my
performance problems.
