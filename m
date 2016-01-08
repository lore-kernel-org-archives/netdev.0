From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 16/17] netfilter: nft_byteorder: provide 64bit le/be
 conversion
Date: Fri, 8 Jan 2016 16:41:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCC05A4@AcuExch.aculab.com>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
 <1452261737-7475-17-git-send-email-pablo@netfilter.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC043B@AcuExch.aculab.com>
 <20160108162351.GD26058@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Florian Westphal' <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160108162351.GD26058@breakpoint.cc>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal
> Sent: 08 January 2016 16:24
> To: David Laight
> David Laight <David.Laight@ACULAB.COM> wrote:
> > From: Pablo Neira Ayuso
> > > Sent: 08 January 2016 14:02
> > > From: Florian Westphal <fw@strlen.de>
> > >
> > > Needed to convert the (64bit) conntrack counters to BE ordering.
> > >
> > ...
> > >  	switch (priv->size) {
> > > +	case 8: {
> > > +		u64 src64;
> > > +
> > > +		switch (priv->op) {
> > > +		case NFT_BYTEORDER_NTOH:
> > > +			for (i = 0; i < priv->len / 8; i++) {
> > > +				src64 = get_unaligned_be64(&src[i]);
> > > +				src64 = be64_to_cpu((__force __be64)src64);
> > > +				put_unaligned_be64(src64, &dst[i]);
> > > +			}
> > > +			break;
> > > +		case NFT_BYTEORDER_HTON:
> > > +			for (i = 0; i < priv->len / 8; i++) {
> > > +				src64 = get_unaligned_be64(&src[i]);
> > > +				src64 = (__force u64)cpu_to_be64(src64);
> > > +				put_unaligned_be64(src64, &dst[i]);
> > > +			}
> > > +			break;
> > > +		}
> > > +		break;
> >
> > That is horrid.
> 
> Yes, sorry for this, however ...
> 
> > On a little-endian system you are byteswapping the data 3 times.
> > Image the code on a cpu that doesn't support misaligned transfers
> > and doesn't have a byteswap instruction.
> 
> diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
> --- a/net/netfilter/nft_byteorder.c
> +++ b/net/netfilter/nft_byteorder.c
> @@ -46,16 +46,16 @@ static void nft_byteorder_eval(const struct nft_expr *expr,
>  		switch (priv->op) {
>  		case NFT_BYTEORDER_NTOH:
>  			for (i = 0; i < priv->len / 8; i++) {
> -				src64 = get_unaligned_be64(&src[i]);
> +				src64 = get_unaligned((u64 *)&src[i]);
>  				src64 = be64_to_cpu((__force __be64)src64);
> -				put_unaligned_be64(src64, &dst[i]);
> +				put_unaligned(src64, (u64 *)&dst[i]);

Why not just:
				src64 = get_unaligned_be64(&src[i]);
				put_unaligned(src64, (u64 *)&dst[i]);

...
> Results in identical object code.

How many architectures have you looked at?
Try sparc64, ppc64 and arm64, especially le variants.
(le sparc would be bad - but doesn't exist).
Also older compilers that don't have builtin support for misaligned
memory accesses.

Actually there is (probably) a generic problem with:
		put_unaligned(src64, (u64 *)&dst[i]);
The C language rules for casts effectively forbid pointers to
misaligned structures (the compiler is allowed to assume they
are aligned however hard you try to persuade it otherwise).
I suspect that means that the (u64 *) cast is allowed to mask
off the bottom address bits.

	David

