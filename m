From: Vasily Averin <vvs@parallels.com>
Subject: Re: [PATCH] bridge: Reset IPCB on forward non-local packets in br_handle_frame_finish()
Date: Wed, 02 Nov 2011 23:11:38 +0400
Message-ID: <4EB195EA.4050100@parallels.com>
References: <4EB19549.4010601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>, devel@openvz.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1914 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932164Ab1KBTLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 15:11:54 -0400
In-Reply-To: <4EB19549.4010601@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2011 11:08 PM, Vasily Averin wrote:
> if dst is not local br_handle_frame_finish() does not clone original skb and
> forgets to reset IPCB before return to IP stack. it can lead to stack corruption
> in icmp_send()

example of stack corruption
http://bugzilla.openvz.org/show_bug.cgi?id=2016

> Signed-off-by: Vasily Averin <vvs@sw.ru>
> ---
>  net/bridge/br_input.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index f06ee39..6be8d00 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -93,10 +93,11 @@ int br_handle_frame_finish(struct sk_buff *skb)
>  			skb2 = skb;
> 
>  		br->dev->stats.multicast++;
> -	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
> +	} else if ((dst = __br_fdb_get(br, dest)) != NULL) {
>  		skb2 = skb;
>  		/* Do not forward the packet since it's local. */
> -		skb = NULL;
> +		if (dst->is_local) {
> +			skb = NULL;
>  	}
> 
>  	if (skb) {
> -- 1.7.5.4
