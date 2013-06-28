From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: Check the argument for listen(2)
Date: Fri, 28 Jun 2013 09:30:17 -0700
Message-ID: <20130628093017.36bc60b1@nehalam.linuxnetplumber.net>
References: <1372436076-61436-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:54092 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544Ab3F1QaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:30:22 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so1123157pdj.31
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 09:30:21 -0700 (PDT)
In-Reply-To: <1372436076-61436-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Jun 2013 00:14:36 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> As we use u16 to save the value of the argument for listen(2),
> we'd better check if the value is larger than SINT_MAX other
> than cut it down silently on error.
> ---
>  net/ipv4/af_inet.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index b4d0be2..35aaf00 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -198,6 +198,9 @@ int inet_listen(struct socket *sock, int backlog)
>  	unsigned char old_state;
>  	int err;
>  
> +	if (backlog >= (1 << 16))
> +		return EINVAL;
> +
>  	lock_sock(sk);
>  
>  	err = -EINVAL;

Is this just a theoretical problem or is there an example?
Since this is a user API, you should check related standards, it maybe
that the kernel should just silently truncate. Returning errors
to legacy applications makes people really angry.

If you decide that returning an error is the correct behaviour
then the return value should be negative in order to follow kernel practice
and other parts of same code.

Rather than open coding >= (1<<16) might be better to > USHRT_MAX.

Lastly, a test like this deserves a comment like:
       /* since sk_max_ack_backlog is ushort */
