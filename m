From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 5/6] x25: Allow 32 bit socket ioctl in 64 bit kernel
Date: Thu, 16 Feb 2006 15:18:24 +0100
Message-ID: <200602161518.25157.netdev@axxeo.de>
References: <1140068774.4941.26.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kenel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932470AbWBPOSh@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1140068774.4941.26.camel@spereira05.tusc.com.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shaun Pereira wrote:
> removed magic number 33 as suggested by Arnaldo 

But are you sure, you use the right substitute for it?
 
>  struct x25_calluserdata {
> diff -uprN -X dontdiff linux-2.6.16-rc3-vanilla/include/net/x25.h linux-2.6.16-rc3/include/net/x25.h
> --- linux-2.6.16-rc3-vanilla/include/net/x25.h	2006-02-16 15:26:19.000000000 +1100
> +++ linux-2.6.16-rc3/include/net/x25.h	2006-02-16 15:31:50.000000000 +1100
> @@ -101,9 +101,17 @@ enum {
>  #define	X25_FAC_PACKET_SIZE	0x42
>  #define	X25_FAC_WINDOW_SIZE	0x43
>  
> -#define	X25_MAX_FAC_LEN		20		/* Plenty to spare */
> +#define X25_MAX_FAC_LEN 	60
>  #define	X25_MAX_CUD_LEN		128
>  
> +#define X25_FAC_CALLING_AE 	0xCB
> +#define X25_FAC_CALLED_AE 	0xC9
> +
> +#define X25_MARKER 		0x00
> +#define X25_DTE_SERVICES 	0x0F
> +#define X25_MAX_AE_LEN 		40			/* Max num of semi-octets in AE - OSI Nw */
> +#define X25_MAX_DTE_FACIL_LEN	21			/* Max length of DTE facility params */

Are you sure that you don't mean 0x21 (== 33) here?

> diff -uprN -X dontdiff linux-2.6.16-rc3-vanilla/net/x25/x25_facilities.c linux-2.6.16-rc3/net/x25/x25_facilities.c
> --- linux-2.6.16-rc3-vanilla/net/x25/x25_facilities.c	2006-02-16 15:26:25.000000000 +1100
> +++ linux-2.6.16-rc3/net/x25/x25_facilities.c	2006-02-16 15:31:50.000000000 +1100
> @@ -112,9 +127,30 @@ int x25_parse_facilities(struct sk_buff 
>  			len -= 4;
>  			break;
>  		case X25_FAC_CLASS_D:
> -			printk(KERN_DEBUG "X.25: unknown facility %02X, "
> -			       "length %d, values %02X, %02X, %02X, %02X\n",
> -			       p[0], p[1], p[2], p[3], p[4], p[5]);
> +		switch (*p) {
> +	 		case X25_FAC_CALLING_AE:
> +	 			if (p[1] > X25_MAX_DTE_FACIL_LEN)

Because the magic number 33 was here before ...

> +				break;
> +				dte_facs->calling_len = p[2];
> +				memcpy(dte_facs->calling_ae, &p[3], p[1] - 1);
> +				*vc_fac_mask |= X25_MASK_CALLING_AE;
> +				break;
> +
> +			case X25_FAC_CALLED_AE:
> +				if (p[1] > X25_MAX_DTE_FACIL_LEN)

...and here

> +				break;
> +				dte_facs->called_len = p[2];
> +				memcpy(dte_facs->called_ae, &p[3], p[1] - 1);
> +				*vc_fac_mask |= X25_MASK_CALLED_AE;
> +				break;
> +
> +			default:
> +				printk(KERN_DEBUG "X.25: unknown facility %02X,"
> +				"length %d, values %02X, %02X, %02X, %02X\n",
> +				p[0], p[1], p[2], p[3], p[4], p[5]);
> +				break;
> +			}
> +
>  			len -= p[1] + 2;
>  			p   += p[1] + 2;
>  			break;

Regards

Ingo Oeser
