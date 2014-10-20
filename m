From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] xfrm6: fix a potential use after free in xfrm6_policy.c
Date: Mon, 20 Oct 2014 14:36:16 +0400
Message-ID: <5444E5A0.9040004@cogentembedded.com>
References: <1413794954-16967-1-git-send-email-roy.qing.li@gmail.com> <1413794954-16967-2-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:38801 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbaJTKgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 06:36:19 -0400
Received: by mail-lb0-f169.google.com with SMTP id 10so3589017lbg.14
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 03:36:17 -0700 (PDT)
In-Reply-To: <1413794954-16967-2-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/20/2014 12:49 PM, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>

> pskb_may_pull() maybe change skb->data and make nh and exthdr pointer
> oboslete, so recompute the nd and exthdr

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>   net/ipv6/xfrm6_policy.c |   11 ++++++++---
>   1 file changed, 8 insertions(+), 3 deletions(-)

> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> index ac49f84..115fd3b 100644
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -170,8 +170,10 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
>   		case IPPROTO_DCCP:
>   			if (!onlyproto && (nh + offset + 4 < skb->data ||
>   			     pskb_may_pull(skb, nh + offset + 4 - skb->data))) {
> -				__be16 *ports = (__be16 *)exthdr;
> +				__be16 *ports;
>
> +				nh = skb_network_header(skb);
> +				ports = (__be16*)(nh + offset);

    Please insert a space between '__be16' and * like it was done in the 
deleted assignment.

[...]
> @@ -180,8 +182,10 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
>
>   		case IPPROTO_ICMPV6:
>   			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
> -				u8 *icmp = (u8 *)exthdr;
> +				u8 *icmp;
>
> +				nh = skb_network_header(skb);
> +				icmp = (u8*)(nh + offset);

    Likewise.

[...]
> @@ -192,8 +196,9 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
>   		case IPPROTO_MH:
>   			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
>   				struct ip6_mh *mh;
> -				mh = (struct ip6_mh *)exthdr;
>
> +				nh = skb_network_header(skb);
> +				mh = (struct ip6_mh*)(nh + offset);

    Likewise.

[...]

WBR, Sergei
