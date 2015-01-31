From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 5/6] udpv6: Add lockless sendmsg() support
Date: Sat, 31 Jan 2015 23:49:56 +0300
Message-ID: <54CD3FF4.1030007@cogentembedded.com>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com> <1422718818-21093-6-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:44837 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547AbbAaUt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 15:49:59 -0500
Received: by mail-la0-f51.google.com with SMTP id ge10so30680993lab.10
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 12:49:57 -0800 (PST)
In-Reply-To: <1422718818-21093-6-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/31/2015 6:40 PM, Vladislav Yasevich wrote:

> This commit adds the same functionaliy to IPv6 that
> commit 903ab86d195cca295379699299c5fc10beba31c7
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Tue Mar 1 02:36:48 2011 +0000

>      udp: Add lockless transmit path

> added to IPv4.

> UDP transmit path can now run without a socket lock,
> thus allowing multiple threads to send to a single socket
> more efficiently.
> This is only used when corking/MSG_MORE is not used.

> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>   net/ipv6/udp.c | 24 ++++++++++++++++++++----
>   1 file changed, 20 insertions(+), 4 deletions(-)

> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 67a3d70..d048d46 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
[...]
> @@ -1307,6 +1308,20 @@ do_udp_sendmsg:
>   		goto do_confirm;
>   back_from_confirm:
>
> +	/* Lockless fast path for the non-corking case */
> +	if (!corkreq) {
> +		struct sk_buff *skb;
> +
> +		skb = ip6_make_skb(sk, getfrag, msg, ulen,
> +				   sizeof(struct udphdr), hlimit, tclass, opt,
> +				   &fl6, (struct rt6_info *)dst,
> +				   msg->msg_flags, dontfrag);
> +		err = PTR_ERR(skb);

    You should use PTR_ERR_OR_ZERO() here, I think.

[...]

WBR, Sergei
