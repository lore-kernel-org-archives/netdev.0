From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 00/14] shrink skb cb to 44 bytes
Date: Mon, 02 Mar 2015 20:02:05 -0800
Message-ID: <1425355325.5130.157.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
	 <1425325763.5130.123.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150302.171747.1423128180512348489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33399 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879AbbCCECI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 23:02:08 -0500
In-Reply-To: <20150302.171747.1423128180512348489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-02 at 17:17 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 02 Mar 2015 11:49:23 -0800
> 
> > Size of skb->cb[] is not the major factor. Trying to gain 4 or 8 bytes
> > is not going to improve performance a lot.
> > 
> > The real problem is that we clear it in skb_alloc()/build_skb(), instead
> > of each layer doing so at demand, and only the part that matters for
> > this layer.
> > 
> > Basically, skb->cb[] could be 80 or 160 bytes instead of 48, and we
> > should not care, as long as no layer does a stupid/lazy 
> > 
> > memset(skb->cb, 0, sizeof(skb->cb))
> > 
> > Presumably skb_clone() could be extended to receive the length of
> > skb->cb[] that current layer cares about.
> 
> Regardless, I think Florian's work has value.

Of course. I hope my answer was not implying the contrary !

48 -> 44 cb change, with the 8 bytes alignment and various __packed
tricks that might confuse compilers on some arches, will be hard to
quantify in term of performances on all arches.

About the GRO layout change, reason why 'struct sk_buff *last;' is at
the end of struct napi_gro_cb is that this field is not used in fast
path.

Note : We could try to use one bit in skb to advertise zero shinfo(skb).

Many skbs have a zeroed shinfo() (but shinfo->dataref == 1) , and
dereferencing skb_shinfo adds a cache line miss. 

-> We could avoid memset(shinfo, 0, offsetof(struct skb_shared_info,
dataref)) & atomic_set(&shinfo->dataref, 1); 

 in alloc_skb() and friends completely.

Unfortunately this kind of change would be quite invasive...
