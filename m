From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 23:11:07 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1603282256120.25443@blackhole.kfki.hu>
References: <56F8987B.5030501@gmail.com> <56F92E21.30509@gmail.com>  <alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu>  <20160328.152959.1109841569654352040.davem@davemloft.net>  <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
 <1459197963.6473.125.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jan Engelhardt <jengelh@inai.de>,
	David Miller <davem@davemloft.net>, sploving1@gmail.com,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1459197963.6473.125.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2016, Eric Dumazet wrote:

> On Mon, 2016-03-28 at 22:20 +0200, Jan Engelhardt wrote:
> > On Monday 2016-03-28 21:29, David Miller wrote:
> > >>> > > @@ -3716,6 +3716,8 @@ void tcp_parse_options(const struct sk_buff *skb,
> > >>> > >               length--;
> > >>> > >               continue;
> > >>> > >           default:
> > >>> > > +            if (length < 2)
> > >>> > > +                return;
> > >>> > >               opsize = *ptr++;
> > >>> > >               if (opsize < 2) /* "silly options" */
> > >>> > >                   return;
> > >
> > >I'm trying to figure out how this can even matter.
> > >If we are in the loop, length is at least one.
> > >That means it is legal to read the opsize byte.
> > 
> > Is that because the skbuff is always padded to a multiple of (at
> > least) two? Maybe such padding is explicitly foregone when ASAN is in
> > place. After all, glibc, in userspace, is likely to do padding as
> > well for malloc, and yet, ASAN catches these cases.

There might be a TCP option combination, which is "properly" padded but 
broken, like (wscale, wscale-value, mss) where the mss-value is missing.

> We have at least 384 bytes of padding in skb->head (this is struct
> skb_shared_info).
> 
> Whatever garbage we might read, current code is fine.
> 
> We have to deal with a false positive here.

In net/netfilter/nf_conntrack_proto_tcp.c we copy the options into a 
buffer with skb_header_pointer(), so it's not a false positive there and 
the KASAN report referred to that part.

I thought it's valid for tcp_parse_options() too, but then I'm wrong so 
at least the part from the patch for tcp_input.c can be dropped.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
