From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Tue, 01 May 2012 19:04:52 +0200
Message-ID: <1335891892.22133.23.camel@edumazet-glaptop>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	 <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>
	 <1335835677.11396.5.camel@edumazet-glaptop>
	 <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
	 <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47987 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab2EARE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:04:58 -0400
Received: by bkcji2 with SMTP id ji2so1062724bkc.19
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 10:04:57 -0700 (PDT)
In-Reply-To: <4FA00C9F.8080409@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 09:17 -0700, Alexander Duyck wrote:
> On 04/30/2012 11:39 PM, Eric Dumazet wrote:
> > On Mon, 2012-04-30 at 22:33 -0700, Alexander Duyck wrote:
> >
> >> The question I had was more specific to GRO.  As long as we have
> >> skb->users == 1 and the skb isn't cloned we should be fine.   It just
> >> hadn't occurred to me before that napi_gro_receive had the extra
> >> requirement that the skb couldn't be cloned.
> >>
> > OK
> >
> > By the way, even if skb was cloned, we would be allowed to steal
> > skb->head.
> >
> > When we clone an oskb we :
> >
> > 1) allocate a struct nskb sk_buff (or use the shadow in case of TCP)
> > 2) increment dataref
> The problem I have is with this piece right here.  So you increment
> dataref.  Now you have an skb that is still pointing to the shared info
> on this page and dataref is 2.  What about the side that is stealing the
> head?  Is it going to be tracking the dataref as well and decrementing
> it before put_page or does it just assume that dataref is 1 and call
> put_page directly?  I am guessing the latter since I didn't see anything
> that allowed for tracking the dataref of stolen heads.

The only changed thing is the kfree() replaced by put_page()

This kfree() was done when last reference to dataref was released.

If we had a problem before, we have same problem after my patch.

Truth is : In TCP (coalesce and splice()) and GRO, we owns skbs.

(See the various __kfree_skb(skb) calls in net/ipv4/tcp_input.c
There is one exception in ipv6 / treq->pktopts ) but its for SYN packet
and this wont be merged with a previous packet.
