From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Tue, 17 Jul 2007 17:30:21 +0300
Message-ID: <200707171730.21655.joakim.koskela@hiit.fi>
References: <200707161506.47915.joakim.koskela@hiit.fi> <469BBD4C.5040503@trash.net>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:54021 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934910AbXGQPof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 11:44:35 -0400
In-Reply-To: <469BBD4C.5040503@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 16 July 2007 21:47:40 Patrick McHardy wrote:
>
> I lost interest here, but the reintroduced bugs make me think that
> some old version was simply rediffed without even checking the
> output and the state initialization also seems to need a bit more work.
>

Thanks for reviewing the code, really appreciate it (whoa, would have been a 
lot of problems [re-]introduced)! And yes, you're right - it seemed at the 
time easier to just convert the old code to run in the new kernel as it's 
been working fine for us. Quickly scanned the existing (non-interfamily) beet 
implementation, but I guess not thoroughly enough. Anyway, merged back the 
latest non-interfamily versions and rolling with those now. Should have a 
fixed version ready soon..

Some other comments:

> Joakim Koskela wrote:
> > diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
> > index fa1902d..7a39f4c 100644
> > --- a/net/ipv4/xfrm4_input.c
> > +++ b/net/ipv4/xfrm4_input.c
> > @@ -108,7 +108,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb, __u16
> > encap_type) if (x->mode->input(x, skb))
> >  			goto drop;
> >
> > -		if (x->props.mode == XFRM_MODE_TUNNEL) {
> > +		if (x->props.mode == XFRM_MODE_TUNNEL ||
> > +		    x->props.mode == XFRM_MODE_BEET) {
> >  			decaps = 1;
> >  			break;
> >  		}
>
> I was under the impression that one of the main points of BEET is that
> it offers tunnel semantics but does only transport mode processing.
> Its necessary for inter-family tunnels, but shouldn't this be avoided
> for normal use?
>

Yes, this is actually quite a nice improvement to the interfamily processing I 
(at least) haven't thought of before. Tested it & works fine (ipv4-ipv4).

>
> > diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
> > index 44ef208..8db7910 100644
> > --- a/net/ipv4/xfrm4_output.c
> > +++ b/net/ipv4/xfrm4_output.c
> > @@ -53,7 +53,8 @@ static int xfrm4_output_one(struct sk_buff *skb)
> >  			goto error_nolock;
> >  	}
> >
> > -	if (x->props.mode == XFRM_MODE_TUNNEL) {
> > +	if (x->props.mode == XFRM_MODE_TUNNEL ||
> > +	    x->props.mode == XFRM_MODE_BEET) {
> >  		err = xfrm4_tunnel_check_size(skb);
>
> Its not a real tunnel and all packets are generated locally, why
> does it need to send ICMPs?

Guess not. I'll have to still trace through, but can probably be removed.

> > +		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
> > +			encap_family = xfrm[i]->props.family;
> > +			if (encap_family == AF_INET) {
> > +				remote.in = (struct in_addr *)
> > +					&xfrm[i]->id.daddr.a4;
> > +				local.in  = (struct in_addr *)
> > +					&xfrm[i]->props.saddr.a4;
> > +			} else if (encap_family == AF_INET6) {
> > +				remote.in6 = (struct in6_addr *)
> > +					xfrm[i]->id.daddr.a6;
> > +				local.in6 = (struct in6_addr *)
> > +					xfrm[i]->props.saddr.a6;
> > +			}
>
> No ifdefs here?

Thanks for noticing!

> >  static int ipip_init_state(struct xfrm_state *x)
> >  {
> > -	if (x->props.mode != XFRM_MODE_TUNNEL)
> > +	if (x->props.mode != XFRM_MODE_TUNNEL ||
> > +	    x->props.mode != XFRM_MODE_BEET)
> >  		return -EINVAL;
>
> Looks like a bug fix that should be seperated.
>

Probably. This has been there for a while, don't know what's the story behind 
it, have to check..

br, j
