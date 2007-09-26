From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Zero-length write() does not generate a datagram on connected socket
Date: Wed, 26 Sep 2007 11:18:39 +0800
Message-ID: <E1IaNQ7-0004DX-00@gondolin.me.apana.org.au>
References: <20070924153435.14249225@freepuppy.rosehill>
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org (Stephen Hemminger)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4387 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751830AbXIZDSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 23:18:44 -0400
In-Reply-To: <20070924153435.14249225@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> The bug http://bugzilla.kernel.org/show_bug.cgi?id=5731
> describes an issue where write() can't be used to generate a zero-length
> datagram (but send, and sendto do work).
> 
> I think the following is needed:
> 
> --- a/net/socket.c      2007-08-20 09:54:28.000000000 -0700
> +++ b/net/socket.c      2007-09-24 15:31:25.000000000 -0700
> @@ -777,8 +777,11 @@ static ssize_t sock_aio_write(struct kio
>        if (pos != 0)
>                return -ESPIPE;
> 
> -       if (iocb->ki_left == 0) /* Match SYS5 behaviour */
> -               return 0;
> +       if (unlikely(iocb->ki_left == 0)) {
> +               struct socket *sock = iocb->ki_filp->private_data;
> +               if (sock->type == SOCK_STREAM)
> +                       return 0;
> +       }

I'm not sure whether all STREAM protocols treat zero-length
sends as no-ops.  What about SCTP?

Put it another way, do we really need to keep the short-circuit
for SOCK_STREAM?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
