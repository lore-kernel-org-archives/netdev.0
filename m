From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 14/15] netpoll: re-enable irq in poll_napi()
Date: Fri, 24 Aug 2012 12:43:34 -0700
Message-ID: <20120824124334.10313575.akpm@linux-foundation.org>
References: <1344597891-32242-1-git-send-email-amwang@redhat.com>
	<1344597891-32242-15-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:54182 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760037Ab2HXTnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:43:35 -0400
In-Reply-To: <1344597891-32242-15-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Aug 2012 19:24:50 +0800
Cong Wang <amwang@redhat.com> wrote:

> napi->poll() needs IRQ enabled, so we have to re-enable IRQ before
> calling it.
> 
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/core/netpoll.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index e4ba3e7..346b1eb 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -168,16 +168,24 @@ static void poll_napi(struct net_device *dev)
>  	struct napi_struct *napi;
>  	int budget = 16;
>  
> +	WARN_ON_ONCE(!irqs_disabled());
> +
>  	list_for_each_entry(napi, &dev->napi_list, dev_list) {
> +		local_irq_enable();
>  		if (napi->poll_owner != smp_processor_id() &&
>  		    spin_trylock(&napi->poll_lock)) {
> +			rcu_read_lock_bh();
>  			budget = poll_one_napi(rcu_dereference_bh(dev->npinfo),
>  					       napi, budget);
> +			rcu_read_unlock_bh();
>  			spin_unlock(&napi->poll_lock);
>  
> -			if (!budget)
> +			if (!budget) {
> +				local_irq_disable();
>  				break;
> +			}
>  		}
> +		local_irq_disable();
>  	}
>  }

This commit (6bdb7fe3104 in mainline) makes my netconsole-using x86_64
box lock up during boot.  Dunno why, but I do have a cellphone:
http://ozlabs.org/~akpm/stuff/IMG_20120824_122054.jpg
