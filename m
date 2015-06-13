From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] flow_dissector: add support for dst,
 hop-by-hop and routing ext hdrs
Date: Fri, 12 Jun 2015 18:50:04 -0700
Message-ID: <20150613015004.GA9918@Alexeis-MacBook-Pro.local>
References: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
 <1434124866-3881537-3-git-send-email-tom@herbertland.com>
 <20150613012752.GA9895@Alexeis-MacBook-Pro.local>
 <1434159454.27504.101.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Tom Herbert <tom@herbertland.com>,
	edumazet@google.com, netdev@vger.kernel.org,
	dan.carpenter@oracle.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33102 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbbFMBuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 21:50:07 -0400
Received: by padev16 with SMTP id ev16so31383310pad.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 18:50:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434159454.27504.101.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2015 at 06:37:34PM -0700, Eric Dumazet wrote:
> On Fri, 2015-06-12 at 18:27 -0700, Alexei Starovoitov wrote:
> > On Fri, Jun 12, 2015 at 09:01:06AM -0700, Tom Herbert wrote:
> > > If dst, hop-by-hop or routing extension headers are present determine
> > > length of the options and skip over them in flow dissection.
> > > 
> > > Signed-off-by: Tom Herbert <tom@herbertland.com>
> > > ---
> > >  net/core/flow_dissector.c | 17 +++++++++++++++++
> > >  1 file changed, 17 insertions(+)
> > > 
> > > diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> > > index 1818cdc..22e4dff 100644
> > > --- a/net/core/flow_dissector.c
> > > +++ b/net/core/flow_dissector.c
> > > @@ -327,6 +327,7 @@ mpls:
> > >  		return false;
> > >  	}
> > >  
> > > +ip_proto_again:
> > >  	switch (ip_proto) {
> > >  	case IPPROTO_GRE: {
> > >  		struct gre_hdr {
> > > @@ -383,6 +384,22 @@ mpls:
> > >  		}
> > >  		goto again;
> > >  	}
> > > +	case NEXTHDR_HOP:
> > > +	case NEXTHDR_ROUTING:
> > > +	case NEXTHDR_DEST: {
> > > +		u8 _opthdr[2], *opthdr;
> > > +
> > > +		if (proto != htons(ETH_P_IPV6))
> > > +			break;
> > > +
> > > +		opthdr = __skb_header_pointer(skb, nhoff, sizeof(_opthdr),
> > > +					      data, hlen, &_opthdr);
> > > +
> > > +		ip_proto = _opthdr[0];
> > > +		nhoff += (_opthdr[1] + 1) << 3;
> > > +
> > > +		goto ip_proto_again;
> > > +	}
> > 
> > Dave,
> > 
> > please revert it. My server locks up during boot with:
> 
> Seems easy to fix instead ?
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 22e4dffa0c8b3b9a20a7324eae1627313e14ce30..476e5dda59e19822dba98a931369ff2666c59c0d 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -394,9 +394,11 @@ ip_proto_again:
>  
>  		opthdr = __skb_header_pointer(skb, nhoff, sizeof(_opthdr),
>  					      data, hlen, &_opthdr);
> +		if (!opthdr)
> +			return false;
>  
> -		ip_proto = _opthdr[0];
> -		nhoff += (_opthdr[1] + 1) << 3;
> +		ip_proto = opthdr[0];
> +		nhoff += (opthdr[1] + 1) << 3;
>  
>  		goto ip_proto_again;
>  	}
> 

sure, that's better.
If you're going to submit it officialy, please add my Tested-by.
My server is happy now :)
