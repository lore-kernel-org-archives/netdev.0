From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Re: netconsole still hangs
Date: Mon, 17 Mar 2008 16:12:22 -0700
Message-ID: <20080317161222.0fb9dfc9.akpm@linux-foundation.org>
References: <20080312235205.dcec2d35.akpm@linux-foundation.org>
	<20080314234749.GA10606@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59490 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751684AbYCQXNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 19:13:04 -0400
In-Reply-To: <20080314234749.GA10606@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 15 Mar 2008 00:47:49 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> [NETPOLL] zap_completion_queue: adjust skb->users counter
> 
> zap_completion_queue() retrieves skbs from completion_queue where they
> have zero skb->users counter. Before dev_kfree_skb_any() it should be
> non-zero yet, so it's increased now.
> 
> 
> Reported-and-tested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> (not tested)
> ---
> 
>  net/core/netpoll.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index d0c8bf5..b04d643 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -215,10 +215,12 @@ static void zap_completion_queue(void)
>  		while (clist != NULL) {
>  			struct sk_buff *skb = clist;
>  			clist = clist->next;
> -			if (skb->destructor)
> +			if (skb->destructor) {
> +				atomic_inc(&skb->users);
>  				dev_kfree_skb_any(skb); /* put this one back */
> -			else
> +			} else {
>  				__kfree_skb(skb);
> +			}
>  		}
>  	}

I retested.  This patch doesn't appear to make anything worse, but the hang
is still there.  
