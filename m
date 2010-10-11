From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Subject: Re: [PATCH 3/3] NET: wimax, fix use after free
Date: Mon, 11 Oct 2010 09:46:46 -0700
Message-ID: <1286815606.21592.11.camel@localhost.localdomain>
References: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
	 <1286789218-13976-3-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	linux-wimax <linux-wimax@intel.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62986 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388Ab0JKQwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 12:52:30 -0400
In-Reply-To: <1286789218-13976-3-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-11 at 02:26 -0700, Jiri Slaby wrote: 
> Stanse found that i2400m_rx frees skb, but still uses skb->len even
> though it has skb_len defined. So use skb_len properly in the code.
> 
> And also define it unsinged int rather than size_t to solve
> compilation warnings.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Ops, fail. Thanks for the catch. I assume you have compile tested it.

Acked-by: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

> Cc: linux-wimax@intel.com
> ---
>  drivers/net/wimax/i2400m/rx.c |   26 +++++++++++++-------------
>  1 files changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
> index c4876d0..844133b 100644
> --- a/drivers/net/wimax/i2400m/rx.c
> +++ b/drivers/net/wimax/i2400m/rx.c
> @@ -1244,16 +1244,16 @@ int i2400m_rx(struct i2400m *i2400m, struct sk_buff *skb)
>  	int i, result;
>  	struct device *dev = i2400m_dev(i2400m);
>  	const struct i2400m_msg_hdr *msg_hdr;
> -	size_t pl_itr, pl_size, skb_len;
> +	size_t pl_itr, pl_size;
>  	unsigned long flags;
> -	unsigned num_pls, single_last;
> +	unsigned num_pls, single_last, skb_len;
>  
>  	skb_len = skb->len;
> -	d_fnstart(4, dev, "(i2400m %p skb %p [size %zu])\n",
> +	d_fnstart(4, dev, "(i2400m %p skb %p [size %u])\n",
>  		  i2400m, skb, skb_len);
>  	result = -EIO;
>  	msg_hdr = (void *) skb->data;
> -	result = i2400m_rx_msg_hdr_check(i2400m, msg_hdr, skb->len);
> +	result = i2400m_rx_msg_hdr_check(i2400m, msg_hdr, skb_len);
>  	if (result < 0)
>  		goto error_msg_hdr_check;
>  	result = -EIO;
> @@ -1261,10 +1261,10 @@ int i2400m_rx(struct i2400m *i2400m, struct sk_buff *skb)
>  	pl_itr = sizeof(*msg_hdr) +	/* Check payload descriptor(s) */
>  		num_pls * sizeof(msg_hdr->pld[0]);
>  	pl_itr = ALIGN(pl_itr, I2400M_PL_ALIGN);
> -	if (pl_itr > skb->len) {	/* got all the payload descriptors? */
> +	if (pl_itr > skb_len) {	/* got all the payload descriptors? */
>  		dev_err(dev, "RX: HW BUG? message too short (%u bytes) for "
>  			"%u payload descriptors (%zu each, total %zu)\n",
> -			skb->len, num_pls, sizeof(msg_hdr->pld[0]), pl_itr);
> +			skb_len, num_pls, sizeof(msg_hdr->pld[0]), pl_itr);
>  		goto error_pl_descr_short;
>  	}
>  	/* Walk each payload payload--check we really got it */
> @@ -1272,7 +1272,7 @@ int i2400m_rx(struct i2400m *i2400m, struct sk_buff *skb)
>  		/* work around old gcc warnings */
>  		pl_size = i2400m_pld_size(&msg_hdr->pld[i]);
>  		result = i2400m_rx_pl_descr_check(i2400m, &msg_hdr->pld[i],
> -						  pl_itr, skb->len);
> +						  pl_itr, skb_len);
>  		if (result < 0)
>  			goto error_pl_descr_check;
>  		single_last = num_pls == 1 || i == num_pls - 1;
> @@ -1290,16 +1290,16 @@ int i2400m_rx(struct i2400m *i2400m, struct sk_buff *skb)
>  	if (i < i2400m->rx_pl_min)
>  		i2400m->rx_pl_min = i;
>  	i2400m->rx_num++;
> -	i2400m->rx_size_acc += skb->len;
> -	if (skb->len < i2400m->rx_size_min)
> -		i2400m->rx_size_min = skb->len;
> -	if (skb->len > i2400m->rx_size_max)
> -		i2400m->rx_size_max = skb->len;
> +	i2400m->rx_size_acc += skb_len;
> +	if (skb_len < i2400m->rx_size_min)
> +		i2400m->rx_size_min = skb_len;
> +	if (skb_len > i2400m->rx_size_max)
> +		i2400m->rx_size_max = skb_len;
>  	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
>  error_pl_descr_check:
>  error_pl_descr_short:
>  error_msg_hdr_check:
> -	d_fnend(4, dev, "(i2400m %p skb %p [size %zu]) = %d\n",
> +	d_fnend(4, dev, "(i2400m %p skb %p [size %u]) = %d\n",
>  		i2400m, skb, skb_len, result);
>  	return result;
>  }



