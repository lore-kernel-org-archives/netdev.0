From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: [1/2] PPP MPPE module
Date: Fri, 18 Jun 2004 17:15:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618161558.GA22913@infradead.org>
References: <20040618161001.GE19269@lists.us.dell.com> <20040618161242.GG19269@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, pptpclient-devel@lists.sourceforge.net,
        paulus@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Content-Disposition: inline
In-Reply-To: <20040618161242.GG19269@lists.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Last time I talked to Paul on MPPE he didn't like those hacks in
the ppp core.

> --- 1.45/drivers/net/ppp_generic.c	2004-04-09 18:21:06 -05:00
> +++ edited/drivers/net/ppp_generic.c	2004-06-18 09:47:10 -05:00
> @@ -1066,8 +1066,15 @@
>  	/* try to do packet compression */
>  	if ((ppp->xstate & SC_COMP_RUN) && ppp->xc_state != 0
>  	    && proto != PPP_LCP && proto != PPP_CCP) {
> -		new_skb = alloc_skb(ppp->dev->mtu + ppp->dev->hard_header_len,
> -				    GFP_ATOMIC);
> +                int new_skb_size = ppp->dev->mtu + ppp->dev->hard_header_len;
> +                int compressor_skb_size = ppp->dev->mtu + PPP_HDRLEN;
> +
> +                if (ppp->xcomp->compress_proto == CI_MPPE) {
> +                        /* CCP [must have] reduced MTU by MPPE_PAD. */
> +                        new_skb_size += MPPE_PAD;
> +                        compressor_skb_size += MPPE_PAD;
> +                }
> +                new_skb = alloc_skb(new_skb_size, GFP_ATOMIC);
>  		if (new_skb == 0) {
>  			printk(KERN_ERR "PPP: no memory (comp pkt)\n");
>  			goto drop;
> @@ -1079,15 +1086,27 @@
>  		/* compressor still expects A/C bytes in hdr */
>  		len = ppp->xcomp->compress(ppp->xc_state, skb->data - 2,
>  					   new_skb->data, skb->len + 2,
> -					   ppp->dev->mtu + PPP_HDRLEN);
> +                                           compressor_skb_size);
>  		if (len > 0 && (ppp->flags & SC_CCP_UP)) {
>  			kfree_skb(skb);
>  			skb = new_skb;
>  			skb_put(skb, len);
>  			skb_pull(skb, 2);	/* pull off A/C bytes */
> -		} else {
> +                } else if (len == 0) {
>  			/* didn't compress, or CCP not up yet */
>  			kfree_skb(new_skb);
> +                } else {
> +                        /*
> +                         * (len < 0)
> +                         * MPPE requires that we do not send unencrypted
> +                         * frames.  The compressor will return -1 if we
> +                         * should drop the frame.  We cannot simply test
> +                         * the compress_proto because MPPE and MPPC share
> +                         * the same number.
> +                         */
> +                        printk(KERN_ERR "ppp: compressor dropped pkt\n");
> +                        kfree_skb(new_skb);
> +                        goto drop;
>  		}
>  	}
>  
> @@ -1596,7 +1615,7 @@
>  		goto err;
>  
>  	if (proto == PPP_COMP) {
> -		ns = dev_alloc_skb(ppp->mru + PPP_HDRLEN);
> +		ns = dev_alloc_skb(ppp->mru + 128 + PPP_HDRLEN);
>  		if (ns == 0) {
>  			printk(KERN_ERR "ppp_decompress_frame: no memory\n");
>  			goto err;
> ===== include/linux/ppp-comp.h 1.4 vs edited =====
> --- 1.4/include/linux/ppp-comp.h	2003-08-07 18:57:19 -05:00
> +++ edited/include/linux/ppp-comp.h	2004-06-18 09:46:32 -05:00
> @@ -191,6 +191,100 @@
>  #define DEFLATE_CHK_SEQUENCE	0
>  
>  /*
> + * Definitions for MPPE.
> + */
> +
> +#define CI_MPPE                        18      /* config option for MPPE */
> +#define CILEN_MPPE             6       /* length of config option */
> +
> +#define MPPE_PAD               8       /* MPPE growth per frame */
> +#define MPPE_MAX_KEY_LEN       16      /* largest key length (128-bit) */
> +
> +/* option bits for ccp_options.mppe */
> +#define MPPE_OPT_40            0x01    /* 40 bit */
> +#define MPPE_OPT_128           0x02    /* 128 bit */
> +#define MPPE_OPT_STATEFUL      0x04    /* stateful mode */
> +/* unsupported opts */
> +#define MPPE_OPT_56            0x08    /* 56 bit */
> +#define MPPE_OPT_MPPC          0x10    /* MPPC compression */
> +#define MPPE_OPT_D             0x20    /* Unknown */
> +#define MPPE_OPT_UNSUPPORTED (MPPE_OPT_56|MPPE_OPT_MPPC|MPPE_OPT_D)
> +#define MPPE_OPT_UNKNOWN       0x40    /* Bits !defined in RFC 3078 were set */
> +
> +/*
> + * This is not nice ... the alternative is a bitfield struct though.
> + * And unfortunately, we cannot share the same bits for the option
> + * names above since C and H are the same bit.  We could do a u_int32
> + * but then we have to do a htonl() all the time and/or we still need
> + * to know which octet is which.
> + */
> +#define MPPE_C_BIT             0x01    /* MPPC */
> +#define MPPE_D_BIT             0x10    /* Obsolete, usage unknown */
> +#define MPPE_L_BIT             0x20    /* 40-bit */
> +#define MPPE_S_BIT             0x40    /* 128-bit */
> +#define MPPE_M_BIT             0x80    /* 56-bit, not supported */
> +#define MPPE_H_BIT             0x01    /* Stateless (in a different byte) */
> +
> +/* Does not include H bit; used for least significant octet only. */
> +#define MPPE_ALL_BITS (MPPE_D_BIT|MPPE_L_BIT|MPPE_S_BIT|MPPE_M_BIT|MPPE_H_BIT)
> +
> +/* Build a CI from mppe opts (see RFC 3078) */
> +#define MPPE_OPTS_TO_CI(opts, ci)              \
> +    do {                                       \
> +       u_char *ptr = ci; /* u_char[4] */       \
> +                                               \
> +       /* H bit */                             \
> +       if (opts & MPPE_OPT_STATEFUL)           \
> +           *ptr++ = 0x0;                       \
> +       else                                    \
> +           *ptr++ = MPPE_H_BIT;                \
> +       *ptr++ = 0;                             \
> +       *ptr++ = 0;                             \
> +                                               \
> +       /* S,L bits */                          \
> +       *ptr = 0;                               \
> +       if (opts & MPPE_OPT_128)                \
> +           *ptr |= MPPE_S_BIT;                 \
> +       if (opts & MPPE_OPT_40)                 \
> +           *ptr |= MPPE_L_BIT;                 \
> +       /* M,D,C bits not supported */          \
> +    } while (/* CONSTCOND */ 0)
> +
> +/* The reverse of the above */
> +#define MPPE_CI_TO_OPTS(ci, opts)              \
> +    do {                                       \
> +       u_char *ptr = ci; /* u_char[4] */       \
> +                                               \
> +       opts = 0;                               \
> +                                               \
> +       /* H bit */                             \
> +       if (!(ptr[0] & MPPE_H_BIT))             \
> +           opts |= MPPE_OPT_STATEFUL;          \
> +                                               \
> +       /* S,L bits */                          \
> +       if (ptr[3] & MPPE_S_BIT)                \
> +           opts |= MPPE_OPT_128;               \
> +       if (ptr[3] & MPPE_L_BIT)                \
> +           opts |= MPPE_OPT_40;                \
> +                                               \
> +       /* M,D,C bits */                        \
> +       if (ptr[3] & MPPE_M_BIT)                \
> +           opts |= MPPE_OPT_56;                \
> +       if (ptr[3] & MPPE_D_BIT)                \
> +           opts |= MPPE_OPT_D;                 \
> +       if (ptr[3] & MPPE_C_BIT)                \
> +           opts |= MPPE_OPT_MPPC;              \
> +                                               \
> +       /* Other bits */                        \
> +       if (ptr[0] & ~MPPE_H_BIT)               \
> +           opts |= MPPE_OPT_UNKNOWN;           \
> +       if (ptr[1] || ptr[2])                   \
> +           opts |= MPPE_OPT_UNKNOWN;           \
> +       if (ptr[3] & ~MPPE_ALL_BITS)            \
> +           opts |= MPPE_OPT_UNKNOWN;           \
> +    } while (/* CONSTCOND */ 0)
> +
> +/*
>   * Definitions for other, as yet unsupported, compression methods.
>   */
>  

---end quoted text---
