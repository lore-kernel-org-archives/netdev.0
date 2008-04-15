From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Discard tcp out-of-order queue if system limit is
 reached
Date: Tue, 15 Apr 2008 08:22:59 -0700
Message-ID: <20080415082259.7a911aaf@extreme>
References: <200804151854.45021.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38425 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbYDOPXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 11:23:07 -0400
In-Reply-To: <200804151854.45021.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Apr 2008 18:54:44 +0400
Vitaliy Gusev <vgusev@openvz.org> wrote:

> Hello!
> 
> tcp_prune_queue() doesn't prune an out-of-order queue if socket
> is under rcvbuf. However even if socket is under rcvbuf but system-wide limit is
> reached then skb cannot be queued. It can lead to deadlock situation as any skb that
> fills sequence hole is dropped.
> So discard out-of-order queue if system-wide limit is reached.
> 
> Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>
> 
> ---
>  net/ipv4/tcp_input.c |   78 +++++++++++++++++++++++++++++++++----------------
>  1 files changed, 52 insertions(+), 26 deletions(-)
> 
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 5119856..bbb7d88 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3841,8 +3841,28 @@ static void tcp_ofo_queue(struct sock *sk)
>  	}
>  }
>  
> +static int tcp_prune_ofo_queue(struct sock *sk);
>  static int tcp_prune_queue(struct sock *sk);
>  
> +static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)

minor nit, current preferred style is to not use inline for used once functions,
the compiler will do it anyway.
