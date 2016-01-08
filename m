From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 16/17] netfilter: nft_byteorder: provide 64bit le/be
 conversion
Date: Fri, 8 Jan 2016 17:55:36 +0100
Message-ID: <20160108165536.GE26058@breakpoint.cc>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
 <1452261737-7475-17-git-send-email-pablo@netfilter.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC043B@AcuExch.aculab.com>
 <20160108162351.GD26058@breakpoint.cc>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC05A4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Florian Westphal' <fw@strlen.de>,
	'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49149 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755203AbcAHQzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 11:55:42 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCC05A4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> wrote:
> From: Florian Westphal
> > Sent: 08 January 2016 16:24
> > To: David Laight
> > David Laight <David.Laight@ACULAB.COM> wrote:
> > > From: Pablo Neira Ayuso
> > > > Sent: 08 January 2016 14:02
> > > > From: Florian Westphal <fw@strlen.de>
> > > >
> > > > Needed to convert the (64bit) conntrack counters to BE ordering.
> > > >
> > > ...
> > > >  	switch (priv->size) {
> > > > +	case 8: {
> > > > +		u64 src64;
> > > > +
> > > > +		switch (priv->op) {
> > > > +		case NFT_BYTEORDER_NTOH:
> > > > +			for (i = 0; i < priv->len / 8; i++) {
> > > > +				src64 = get_unaligned_be64(&src[i]);
> > > > +				src64 = be64_to_cpu((__force __be64)src64);
> > > > +				put_unaligned_be64(src64, &dst[i]);
> > > > +			}
> > > > +			break;
> > > > +		case NFT_BYTEORDER_HTON:
> > > > +			for (i = 0; i < priv->len / 8; i++) {
> > > > +				src64 = get_unaligned_be64(&src[i]);
> > > > +				src64 = (__force u64)cpu_to_be64(src64);
> > > > +				put_unaligned_be64(src64, &dst[i]);
> > > > +			}
> > > > +			break;
> > > > +		}
> > > > +		break;
> > >
> > > That is horrid.
> > 
> > Yes, sorry for this, however ...
> > 
> > > On a little-endian system you are byteswapping the data 3 times.
> > > Image the code on a cpu that doesn't support misaligned transfers
> > > and doesn't have a byteswap instruction.
> > 
> > diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
> > --- a/net/netfilter/nft_byteorder.c
> > +++ b/net/netfilter/nft_byteorder.c
> > @@ -46,16 +46,16 @@ static void nft_byteorder_eval(const struct nft_expr *expr,
> >  		switch (priv->op) {
> >  		case NFT_BYTEORDER_NTOH:
> >  			for (i = 0; i < priv->len / 8; i++) {
> > -				src64 = get_unaligned_be64(&src[i]);
> > +				src64 = get_unaligned((u64 *)&src[i]);
> >  				src64 = be64_to_cpu((__force __be64)src64);
> > -				put_unaligned_be64(src64, &dst[i]);
> > +				put_unaligned(src64, (u64 *)&dst[i]);
> 
> Why not just:
> 				src64 = get_unaligned_be64(&src[i]);
> 				put_unaligned(src64, (u64 *)&dst[i]);

Sure.
