From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Fix possible memory leak while process INIT chunk
 with AUTH paramters
Date: Thu, 20 Mar 2008 08:24:52 -0400
Message-ID: <47E25794.6050001@hp.com>
References: <47E20DA8.1080805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:10217 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbYCTMYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 08:24:54 -0400
In-Reply-To: <47E20DA8.1080805@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei

Wei Yongjun wrote:
> While endpoint received INIT/INIT-ACK chunk with AUTH parameters, such 
> as RANDOM, HMAC_ALGO, CHUNKS parameter, if those parameters appear more 
> then once, memory for store those parameters will be malloc more then 
> once and not free.
> 

All these parameters must be included only once in the packet.

If these things are included more then once, we should either ABORT or
completely ignore the packet.  I haven't decided which one makes more
sense yet.

If someone when to the trouble of violating the protocol, we should not
establish the association with them.

-vlad

> This patch change to used the first parameter and ignore the others.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> --- a/net/sctp/sm_make_chunk.c    2008-02-11 17:14:05.000000000 -0500
> +++ b/net/sctp/sm_make_chunk.c    2008-02-14 03:57:58.000000000 -0500
> @@ -2458,6 +2458,9 @@ static int sctp_process_param(struct sct
>         if (!sctp_auth_enable)
>             goto fall_through;
> 
> +        if (asoc->peer.peer_random)
> +            break;
> +
>         /* Save peer's random parameter */
>         asoc->peer.peer_random = kmemdup(param.p,
>                         ntohs(param.p->length), gfp);
> @@ -2471,6 +2474,9 @@ static int sctp_process_param(struct sct
>         if (!sctp_auth_enable)
>             goto fall_through;
> 
> +        if (asoc->peer.peer_hmacs) +            break;
> +
>         /* Save peer's HMAC list */
>         asoc->peer.peer_hmacs = kmemdup(param.p,
>                         ntohs(param.p->length), gfp);
> @@ -2487,6 +2493,9 @@ static int sctp_process_param(struct sct
>         if (!sctp_auth_enable)
>             goto fall_through;
> 
> +        if (asoc->peer.peer_chunks)
> +            break;
> +
>         asoc->peer.peer_chunks = kmemdup(param.p,
>                         ntohs(param.p->length), gfp);
>         if (!asoc->peer.peer_chunks)
> 
> 
> 

