From: Florian Westphal <fw@strlen.de>
Subject: Re: net: GPF in eth_header
Date: Mon, 28 Nov 2016 22:34:44 +0100
Message-ID: <20161128213444.GA9858@breakpoint.cc>
References: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
 <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
 <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
 <1480359019.18162.79.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAeHK+wWVp46ej0tk5mDnOHpH5Ky0+HiH9_SUqGcT0iTppLaGw@mail.gmail.com>
 <CACT4Y+Yr6UJxXosjx2FO=KtxGr40X07_UBiscs1BP1s8cTaqAA@mail.gmail.com>
 <1480362459.18162.83.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480367152.18162.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480367886.18162.88.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Florian Westphal <fw@strlen.de>,
        syzkaller <syzkaller@googlegroups.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38352 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753423AbcK1Vhq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:37:46 -0500
Content-Disposition: inline
In-Reply-To: <1480367886.18162.88.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Might be a bug added in commit daaa7d647f81f3
> > ("netfilter: ipv6: avoid nf_iterate recursion")
> > 
> > Florian, what do you think of dropping a packet that presumably was
> > mangled badly by nf_ct_frag6_queue() ?

ipv4 definitely frees malformed packets.
In general, I think netfilter should avoid 'silent' drops if possible
and let skb continue, but of course such skbs should not be made worse
as what we ate to begin with...

> > (Like about 48 byte pulled :(, and/or skb->csum changed )

I think this warrants a review of ipv6 reassembly too, bug reported here
is because ipv6 nf defrag is also done on output.

> diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
> index f7aab5ab93a5..508739a3ca2a 100644
> --- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
> +++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
> @@ -65,9 +65,9 @@ static unsigned int ipv6_defrag(void *priv,
>  
>  	err = nf_ct_frag6_gather(state->net, skb,
>  				 nf_ct6_defrag_user(state->hook, skb));
> -	/* queued */
> -	if (err == -EINPROGRESS)
> -		return NF_STOLEN;
> +	/* queued or mangled ... */
> +	if (err)
> +		return (err == -EINPROGRESS) ? NF_STOLEN : NF_DROP;
>  
>  	return NF_ACCEPT;

Looks good, we'll need to change some of the errno return codes in
nf_ct_frag6_gather to 0 though for this to work, which should not be too
hard ;)
