From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [SECURITY] memory corruption in X.25 facilities parsing
Date: Wed, 03 Nov 2010 19:44:31 -0400
Message-ID: <1288827871.22123.0.camel@dan>
References: <1288710168.2504.6.camel@dan>
	 <AANLkTi=fAMDP-rGZfOcHS0j_J=KSBgxqqbLaQsXxooJn@mail.gmail.com>
	 <1288824893.1858.5.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:51351 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab0KCXoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 19:44:34 -0400
In-Reply-To: <1288824893.1858.5.camel@jaunty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good to me.  Thanks for the quick turnaround.

-Dan

On Thu, 2010-11-04 at 09:54 +1100, Andrew Hendry wrote:
> On Wed, 2010-11-03 at 12:12 +1100, Andrew Hendry wrote:
> > There is an issue here, under select scenarios I can crash systems.
> > However the patch doesn't resolve it fully, I think after breaking at
> > that point the len and p pointers are messed up before it tries to
> > parse the next facility.
> > 
> > Maybe it should return not break? It should reject/clear such calls.
> > I'll start checking if the callers properly handle errors.
> > Also should it be if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] <= 1),
> > because it does the memcpy with p[1] -1
> > 
> > 
> > On Wed, Nov 3, 2010 at 2:02 AM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> > > I put this together after a quick glance, so if someone knows this code
> > > better than I do (i.e. at all), feel free to comment or drop this patch
> > > if it's unnecessary.
> > >
> > > A value of 0 will cause a memcpy() of ULONG_MAX size, destroying the
> > > kernel heap.
> > >
> > > Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> > >
> > > --- linux-2.6.36-rc6.orig/net/x25/x25_facilities.c      2010-09-28 21:01:22.000000000 -0400
> > > +++ linux-2.6.36-rc6/net/x25/x25_facilities.c   2010-11-02 10:36:02.827291324 -0400
> > > @@ -134,14 +134,14 @@ int x25_parse_facilities(struct sk_buff
> > >                case X25_FAC_CLASS_D:
> > >                        switch (*p) {
> > >                        case X25_FAC_CALLING_AE:
> > > -                               if (p[1] > X25_MAX_DTE_FACIL_LEN)
> > > +                               if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] == 0)
> > >                                        break;
> > >                                dte_facs->calling_len = p[2];
> > >                                memcpy(dte_facs->calling_ae, &p[3], p[1] - 1);
> > >                                *vc_fac_mask |= X25_MASK_CALLING_AE;
> > >                                break;
> > >                        case X25_FAC_CALLED_AE:
> > > -                               if (p[1] > X25_MAX_DTE_FACIL_LEN)
> > > +                               if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] == 0)
> > >                                        break;
> > >                                dte_facs->called_len = p[2];
> > >                                memcpy(dte_facs->called_ae, &p[3], p[1] - 1);
> > >
> > >
> > >
> 
> How does this look? It appears to fix it for the cases I could test.
> 
> Signed-of-by: Andrew Hendry <andrew.hendry@gmail.com>
> 
> diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
> index 771bab0..3a8c4c4 100644
> --- a/net/x25/x25_facilities.c
> +++ b/net/x25/x25_facilities.c
> @@ -134,15 +134,15 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
>  		case X25_FAC_CLASS_D:
>  			switch (*p) {
>  			case X25_FAC_CALLING_AE:
> -				if (p[1] > X25_MAX_DTE_FACIL_LEN)
> -					break;
> +				if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] <= 1)
> +					return 0;
>  				dte_facs->calling_len = p[2];
>  				memcpy(dte_facs->calling_ae, &p[3], p[1] - 1);
>  				*vc_fac_mask |= X25_MASK_CALLING_AE;
>  				break;
>  			case X25_FAC_CALLED_AE:
> -				if (p[1] > X25_MAX_DTE_FACIL_LEN)
> -					break;
> +				if (p[1] > X25_MAX_DTE_FACIL_LEN || p[1] <= 1)
> +					return 0;
>  				dte_facs->called_len = p[2];
>  				memcpy(dte_facs->called_ae, &p[3], p[1] - 1);
>  				*vc_fac_mask |= X25_MASK_CALLED_AE;
> diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
> index 6317896..1d80e10 100644
> --- a/net/x25/x25_in.c
> +++ b/net/x25/x25_in.c
> @@ -119,6 +119,8 @@ static int x25_state1_machine(struct sock *sk, struct sk_buff *skb, int frametyp
>  						&x25->vc_facil_mask);
>  			if (len > 0)
>  				skb_pull(skb, len);
> +			else 
> +				return -1;
>  			/*
>  			 *	Copy any Call User Data.
>  			 */


