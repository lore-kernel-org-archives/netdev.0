From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: add skb_cow_head
Date: Mon, 10 Mar 2014 16:31:59 -0400 (EDT)
Message-ID: <20140310.163159.2226500192198218961.davem@davemloft.net>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	<1394432551-4856-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394432551-4856-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 10 Mar 2014 14:22:31 +0800

> Call skb_cow_head() before editing the tx packet header. The header
> would be reallocated if it is shared.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index c7ef30d..faad39b 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -1376,6 +1376,11 @@ static int msdn_giant_send_check(struct sk_buff *skb)
>  {
>  	const struct ipv6hdr *ipv6h;
>  	struct tcphdr *th;
> +	int ret;
> +
> +	ret = skb_cow_head(skb, 0);
> +	if (ret)
> +		goto out1;
>  
>  	ipv6h = ipv6_hdr(skb);
>  	th = tcp_hdr(skb);
> @@ -1383,7 +1388,8 @@ static int msdn_giant_send_check(struct sk_buff *skb)
>  	th->check = 0;
>  	th->check = ~tcp_v6_check(0, &ipv6h->saddr, &ipv6h->daddr, 0);
>  
> -	return 0;
> +out1:
> +	return ret;
>  }
>  
>  static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,

Please just return directly instead of "goto out1".  There are no other
operations or pieces of state to undo if you fail at the beginning of
the function, and the label furthermore will have only one user, so
it seems completely unnecessary.  A simple "return ret" will work just
fine.

Thanks.
