From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: tso: add support for IPv6
Date: Mon, 26 Oct 2015 01:34:26 +0300
Message-ID: <562D58F2.40407@cogentembedded.com>
References: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, egrumbach@gmail.com
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33344 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbbJYWea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 18:34:30 -0400
Received: by lffv3 with SMTP id v3so129385876lff.0
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 15:34:28 -0700 (PDT)
In-Reply-To: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/25/2015 10:58 PM, Emmanuel Grumbach wrote:

> Adding IPv6 for the TSO helper API is trivial:
> * Don't play with the id (which doesn't exist in IPv6)
> * Correctly update the payload_len (don't include the
>    length of the IP header itself)
>
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> ---
>   net/core/tso.c | 17 ++++++++++++-----
>   1 file changed, 12 insertions(+), 5 deletions(-)
>
> diff --git a/net/core/tso.c b/net/core/tso.c
> index 630b30b..ece4605 100644
> --- a/net/core/tso.c
> +++ b/net/core/tso.c
> @@ -14,18 +14,25 @@ EXPORT_SYMBOL(tso_count_descs);
>   void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
>   		   int size, bool is_last)
>   {
> -	struct iphdr *iph;
>   	struct tcphdr *tcph;
>   	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
>   	int mac_hdr_len = skb_network_offset(skb);
>
>   	memcpy(hdr, skb->data, hdr_len);
> -	iph = (struct iphdr *)(hdr + mac_hdr_len);
> -	iph->id = htons(tso->ip_id);
> -	iph->tot_len = htons(size + hdr_len - mac_hdr_len);
> +	if (skb->protocol == htons(ETH_P_IP)) {
> +		struct iphdr *iph = (void *)(hdr + mac_hdr_len);
> +
> +		iph->id = htons(tso->ip_id);
> +		iph->tot_len = htons(size + hdr_len - mac_hdr_len);
> +		tso->ip_id++;
> +	}
> +	if (skb->protocol == htons(ETH_P_IPV6)) {

    *else* needed.

> +		struct ipv6hdr *iph = (void *)(hdr + mac_hdr_len);
> +
> +		iph->payload_len = htons(size + tcp_hdrlen(skb));
> +	}

    The above asks to be a *switch* statement.

[...]

MBR, Sergei
