From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 10 Feb 2014 05:08:41 -0800
Message-ID: <1392037721.6615.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
	 <1390810971-23959-2-git-send-email-fw@strlen.de>
	 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140128085706.GB30123@breakpoint.cc>
	 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140209025504.GB17395@gondor.apana.org.au>
	 <20140210122331.GA25153@breakpoint.cc>
	 <20140210123124.GA28752@gondor.apana.org.au>
	 <20140210124346.GA6329@breakpoint.cc>
	 <20140210125049.GB28752@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:61293 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbaBJNIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 08:08:42 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so6174252pab.29
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 05:08:42 -0800 (PST)
In-Reply-To: <20140210125049.GB28752@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 20:50 +0800, Herbert Xu wrote:
> On Mon, Feb 10, 2014 at 01:43:46PM +0100, Florian Westphal wrote:
> >
> > Eric suggested to shrink gso_size instead to avoid segmentation+fragments.
> > I think its nice idea, but skb_gso_segment makes certain assumptions about
> > nr_frags and gso_size (it can't handle frag size > desired mss).
> 
> This breaks the most important assumption behind GRO which is
> to preserve end-to-end connectivity.  Resegmenting packets as
> suggested on a router/bridge is just wrong.

Yeah, this is the old mantra.

Sending TCP packets without DF means the sender do not care by
definition.

If you disable GRO for such packets, it slows down receivers and
increase packet drops.

I've added the segmentation for these packets for a reason, that you are
free to not understand, but there is absolutely no need reason to not
aggregate TCP packets without DF. This is what you suggested to ignore
the problem on skb_segment() being so limited.

Instead of a router being forced to segment all incoming fragments into

X+Y
X+Y
X+Y
X+Y

Its reasonable to send X+X+X+X+X

And we should be reasonable, not trying to enforce a particular view of
what _should_ the traffic looks like on the Internet.
