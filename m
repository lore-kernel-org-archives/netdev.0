From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 14:03:19 -0800
Message-ID: <1358892199.12374.139.camel@edumazet-glaptop>
References: <1358889648-1684-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:63588 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab3AVWDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 17:03:21 -0500
Received: by mail-pa0-f47.google.com with SMTP id fa10so4319392pad.34
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 14:03:21 -0800 (PST)
In-Reply-To: <1358889648-1684-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 13:20 -0800, Pravin B Shelar wrote:
> Make copy of skb sharable data by linearizing skb. so that
> csum remain consistent when skb is actually transmitted.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/ipv4/ip_gre.c |   22 ++++++++++++++++++----
>  1 file changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 7cdf1fe..20d3d37 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -738,7 +738,7 @@ drop:
>  static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct ip_tunnel *tunnel = netdev_priv(dev);
> -	const struct iphdr  *old_iph = ip_hdr(skb);
> +	const struct iphdr  *old_iph;
>  	const struct iphdr  *tiph;
>  	struct flowi4 fl4;
>  	u8     tos;
> @@ -752,9 +752,23 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  	int    mtu;
>  	u8     ttl;
>  
> -	if (skb->ip_summed == CHECKSUM_PARTIAL &&
> -	    skb_checksum_help(skb))
> -		goto tx_error;
> +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		int err;
> +
> +		/* Pages aren't locked and could change at any time.
> +		 * If this happens after we compute the checksum, the
> +		 * checksum will be wrong.  We linearize now to avoid
> +		 * this problem.
> +		 */
> +		err = __skb_linearize(skb);
> +		if (unlikely(err))
> +			goto tx_error;
> +
> +		err = skb_checksum_help(skb);
> +		if (unlikely(err))
> +			goto tx_error;
> +	}
> +	old_iph = ip_hdr(skb);
>  
>  	if (dev->type == ARPHRD_ETHER)
>  		IPCB(skb)->flags = 0;

This sounds bogus to me.

If user cant cope with changes on sent data, just disable GSO on GRE
device.

An application changing data provided on a sendfile() or vmsplice() cant
really expect data integrity being respected, even if checksum are done
by the NIC (TSO)

So if data integrity is not respected, just send a bogus TX checksum.
