From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Ipoverib] [PATCH] IPv6: Add correct padding
 to IPoIB link addr option
Date: Wed, 19 Jan 2005 09:20:18 +0900 (JST)
Message-ID: <20050119.092018.07351674.yoshfuji@linux-ipv6.org>
References: <528y6qej5w.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, openib-general@openib.org, ipoverib@ietf.org
Return-path: <openib-general-bounces@openib.org>
To: roland@topspin.com, davem@davemloft.net
In-Reply-To: <528y6qej5w.fsf@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

David, let me tkink about this.
Thanks.

In article <528y6qej5w.fsf@topspin.com> (at Tue, 18 Jan 2005 09:33:47 -0800), Roland Dreier <roland@topspin.com> says:

> +++ linux-bk/net/ipv6/ndisc.c	2005-01-14 21:20:55.736745091 -0800
> @@ -169,12 +169,33 @@
>  
>  #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
>  
> -static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int data_len)
> +/*
> + * Return the padding between the option length and the start of the
> + * link addr.  Currently only IP-over-InfiniBand needs this, although
> + * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may
> + * also need a pad of 2.
> + */
> +static int ndisc_addr_option_pad(unsigned short type)
> +{
> +	switch (type) {
> +	case ARPHRD_INFINIBAND: return 2;
> +	default:                return 0;
> +	}
> +}
> +
> +static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int data_len,
> +				  unsigned short addr_type)
>  {
>  	int space = NDISC_OPT_SPACE(data_len);
> +	int pad   = ndisc_addr_option_pad(addr_type);
>  
>  	opt[0] = type;
>  	opt[1] = space>>3;
> +
> +	memset(opt + 2, 0, pad);
> +	opt   += pad;
> +	space -= pad;
> +
>  	memcpy(opt+2, data, data_len);
>  	data_len += 2;
>  	opt += data_len;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
