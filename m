From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: list pmtudisc initizlisation for ipv4 sctp socket
Date: Thu, 24 Jul 2008 12:30:48 -0400
Message-ID: <4888AE38.7020208@hp.com>
References: <4888A3C9.3010203@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:44868 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbYGXQau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 12:30:50 -0400
In-Reply-To: <4888A3C9.3010203@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> I'm not sure whether this was done deliberately, but the
> sctp_v4_create_accept_sk doesn't set the newinet->pmtudisc
> like it is done in both cases (ipv4 and v6) for tcp sockets
> and for sctp over ipv6 socket.
> 
> This loss is painless, I suppose, since the whole socket is
> zeroed by default and thus this field is automatically set
> to IP_PMTUDISC_DONT.
> 
> Restore this setting logic for sctp over ipv4 socket.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index a6e0818..b05c739 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -626,6 +626,11 @@ static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
>  	newinet->mc_index = 0;
>  	newinet->mc_list = NULL;
>  
> +	if (ipv4_config.no_pmtu_disc)
> +		newinet->pmtudisc = IP_PMTUDISC_DONT;
> +	else
> +		newinet->pmtudisc = IP_PMTUDISC_WANT;
> +
>  	sk_refcnt_debug_inc(newsk);
>  
>  	if (newsk->sk_prot->init(newsk)) {

Hi Pavel

We already inherit the settings from the parent socket here:

        newinet->daddr = asoc->peer.primary_addr.v4.sin_addr.s_addr;
        newinet->pmtudisc = inet->pmtudisc;
        newinet->id = asoc->next_tsn ^ jiffies;

So NACK.

-vlad
