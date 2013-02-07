From: Szymon Janc <szymon.janc-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch] NFC: llcp: integer underflow in nfc_llcp_set_remote_gb()
Date: Thu, 7 Feb 2013 11:16:01 +0100
Message-ID: <2148581.S8tzak9aE2@uw000953>
References: <20130131081645.GA14812@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Thierry Escande <thierry.escande-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfc-y27Ovi1pjclAfugRpC6u6w@public.gmane.org" <linux-nfc-y27Ovi1pjclAfugRpC6u6w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130131081645.GA14812-mgFCXtclrQlZLf2FXnZxJA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dan,

On Thursday 31 of January 2013 10:16:46 Dan Carpenter wrote:
> If gb_len is less than 3 it would cause an integer underflow and
> possibly memory corruption in nfc_llcp_parse_gb_tlv().
> 
> I removed the old test for gb_len == 0.  I also removed the test for
> ->remote_gb == NULL.  It's not possible for ->remote_gb to be NULL and
> we have already dereferenced ->remote_gb_len so it's too late to test.
> 
> The old test return -ENODEV but my test returns -EINVAL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> 
> diff --git a/net/nfc/llcp/llcp.c b/net/nfc/llcp/llcp.c
> index 85bc75c..746f5a2 100644
> --- a/net/nfc/llcp/llcp.c
> +++ b/net/nfc/llcp/llcp.c
> @@ -549,14 +549,13 @@ int nfc_llcp_set_remote_gb(struct nfc_dev *dev, u8 *gb, u8 gb_len)
>  		pr_err("No LLCP device\n");
>  		return -ENODEV;
>  	}
> +	if (gb_len < 3)
> +		return -EINVAL;

Maybe define NFC_MIN_GT_LEN and test it together with NFC_MAX_GT_LEN in
nfc_set_remote_general_bytes() ?

>  
>  	memset(local->remote_gb, 0, NFC_MAX_GT_LEN);
>  	memcpy(local->remote_gb, gb, gb_len);
>  	local->remote_gb_len = gb_len;
>  
> -	if (local->remote_gb == NULL || local->remote_gb_len == 0)
> -		return -ENODEV;
> -
>  	if (memcmp(local->remote_gb, llcp_magic, 3)) {
>  		pr_err("MAC does not support LLCP\n");
>  		return -EINVAL;

-- 
BR
Szymon Janc
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
