From: Eric Leblond <eric@regit.org>
Subject: Re: [PATCH] ipv4: ip_check_defrag must not modify skb before
 unsharing
Date: Mon, 10 Dec 2012 12:02:58 +0100
Message-ID: <1355137378.5391.2.camel@tiger2>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
	 <20121207.153134.25835204617509469.davem@davemloft.net>
	 <1354915824.9124.11.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_223020_561049_DB965D43) <1354916502.9124.18.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_224129_500056_6617D80D) <1354918363.9124.29.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_231231_221604_E7B34625) <1354919017.9124.33.camel@jlt4.sipsolutions.net>
	 (sfid-20121207_232321_820322_B0AAB1D2) <1355131788.9857.1.camel@jlt4.sipsolutions.net>
	 (sfid-20121210_102940_332564_5C53F8B8) <1355132466.9857.6.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:44494 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441Ab2LJLDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 06:03:42 -0500
In-Reply-To: <1355132466.9857.6.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, 2012-12-10 at 10:41 +0100, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> ip_check_defrag() might be called from af_packet within the
> RX path where shared SKBs are used, so it must not modify
> the input SKB before it has unshared it for defragmentation.
> Use skb_copy_bits() to get the IP header and only pull in
> everything later.
> 
> The same is true for the other caller in macvlan as it is
> called from dev->rx_handler which can also get a shared SKB.

I've applied the patch and built a new kernel. I did not manage to get
it crashed when using the two techniques (suspend to ram and down/up
interface) that were working well to crash kernel without the patch.

BR,

> Reported-by: Eric Leblond <eric@regit.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
> For some versions of the kernel, this code goes into af_packet.c
> 
>  net/ipv4/ip_fragment.c | 19 +++++++++----------
>  1 file changed, 9 insertions(+), 10 deletions(-)
> 
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index 448e685..8d5cc75 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -707,28 +707,27 @@ EXPORT_SYMBOL(ip_defrag);
>  
>  struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
>  {
> -	const struct iphdr *iph;
> +	struct iphdr iph;
>  	u32 len;
>  
>  	if (skb->protocol != htons(ETH_P_IP))
>  		return skb;
>  
> -	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> +	if (!skb_copy_bits(skb, 0, &iph, sizeof(iph)))
>  		return skb;
>  
> -	iph = ip_hdr(skb);
> -	if (iph->ihl < 5 || iph->version != 4)
> +	if (iph.ihl < 5 || iph.version != 4)
>  		return skb;
> -	if (!pskb_may_pull(skb, iph->ihl*4))
> -		return skb;
> -	iph = ip_hdr(skb);
> -	len = ntohs(iph->tot_len);
> -	if (skb->len < len || len < (iph->ihl * 4))
> +
> +	len = ntohs(iph.tot_len);
> +	if (skb->len < len || len < (iph.ihl * 4))
>  		return skb;
>  
> -	if (ip_is_fragment(ip_hdr(skb))) {
> +	if (ip_is_fragment(&iph)) {
>  		skb = skb_share_check(skb, GFP_ATOMIC);
>  		if (skb) {
> +			if (!pskb_may_pull(skb, iph.ihl*4))
> +				return skb;
>  			if (pskb_trim_rcsum(skb, len))
>  				return skb;
>  			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));

-- 
Eric Leblond <eric@regit.org>
Blog: https://home.regit.org/
