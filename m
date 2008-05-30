From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows with MD5SIG enabled
Date: Fri, 30 May 2008 20:02:20 +0100
Message-ID: <20080530190218.GD1743@solarflare.com>
References: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Adam Langley <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:35309 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752545AbYE3TDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 15:03:35 -0400
Content-Disposition: inline
In-Reply-To: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adam Langley wrote:
> When MD5 signatures are turned on we can end up with syntactically invalid
> packets with a header length < 20 bytes. This is because tcp_header_size
> overflows with 12 bytes of timestamp, 20 bytes of signature and > 8 bytes of
> SACK option.
[...]
> @@ -519,12 +529,23 @@ static int tcp_transmit_skb(struct sock *sk,
> struct sk_buff *skb, int clone_it,
>                         tcp_header_size += TCPOLEN_WSCALE_ALIGNED;
>                         sysctl_flags |= SYSCTL_FLAG_WSCALE;
>                 }
> -               if (sysctl_tcp_sack) {
> +               if (sysctl_tcp_sack
> +#ifdef CONFIG_TCP_MD5SIG
> +                   /* We don't include SACK options if we are going to
> +                    * include an MD5 signature because they can't fit
> +                    * in the options space */
> +                   && !md5
> +#endif

Putting an #ifdef..#endif in the middle of an if () is a bit nasty.  Why not
define md5 and set it to 0 if CONFIG_TCP_MD5SIG is not set?  The compiler
should be able to optimise it away if it's always initialised to 0.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
