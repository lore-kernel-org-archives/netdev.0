From: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Subject: Re: [Fwd: [patch 02/15] ppp_mppe: add PPP MPPE encryption module]
Date: Fri, 8 Jul 2005 21:42:21 +1000
Message-ID: <17102.26269.264419.345257@cargo.ozlabs.ibm.com>
References: <42B747C9.7060901@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matt_Domsch-8PEkshWhKlo@public.gmane.org, Brice.Goglin-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org,
	james.cameron-VXdhtT5mjnY@public.gmane.org, pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org
In-Reply-To: <42B747C9.7060901-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=pptpclient-devel>
List-Id: netdev.vger.kernel.org

Some comments on the MPPE kernel patch (sorry it's taken me so long):

> +static inline struct sk_buff *
> +pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
> +{
> +	struct sk_buff *new_skb;
> +	int len;
> +	int new_skb_size = ppp->dev->mtu + ppp->xcomp->comp_skb_extra_space + ppp->dev->hard_header_len;
> +	int compressor_skb_size = ppp->dev->mtu + ppp->xcomp->comp_skb_extra_space + PPP_HDRLEN;

This would be nicer if you broke these lines each into two lines.  It
would help if you chose shorter names for comp_skb_extra_space and
decomp_skb_extra_space (just comp_extra, for instance).  And why do we
need decomp_skb_extra_space anyway?  We expect the decompressor to
expand things; if they shrink (as they will with MPPE) we don't have
to do anything special.

> +	} else {
> +		/*
> +		 * (len < 0)
> +		 * MPPE requires that we do not send unencrypted
> +		 * frames.  The compressor will return -1 if we
> +		 * should drop the frame.  We cannot simply test
> +		 * the compress_proto because MPPE and MPPC share
> +		 * the same number.
> +		 */
> +		if (net_ratelimit())
> +			printk(KERN_ERR "ppp: compressor dropped pkt\n");
> +		kfree_skb(new_skb);
> +		new_skb = NULL;

I think we just leaked the original skb in this case.

> @@ -1683,7 +1716,7 @@ ppp_decompress_frame(struct ppp *ppp, st
>  		goto err;
>  
>  	if (proto == PPP_COMP) {
> -		ns = dev_alloc_skb(ppp->mru + PPP_HDRLEN);
> +		ns = dev_alloc_skb(ppp->mru + ppp->rcomp->decomp_skb_extra_space + PPP_HDRLEN);
>  		if (ns == 0) {
>  			printk(KERN_ERR "ppp_decompress_frame: no memory\n");
>  			goto err;

I don't see where you make sure that you drop any unencrypted received
frames.

> diff -puN /dev/null drivers/net/ppp_mppe.c

I haven't looked at this in detail, presumably it works OK.

Paul.


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
