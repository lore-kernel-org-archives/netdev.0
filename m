From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 1/2] vhost-net: fix handle_rx buffer size
Date: Thu, 3 May 2012 16:16:24 +0300
Message-ID: <20120503131623.GA26705@redhat.com>
References: <m1ipgtzwew.fsf@fess.ebiederm.org>
 <1335373275-336-1-git-send-email-basil.gor@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Basil Gor <basil.gor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754623Ab2ECNQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 09:16:19 -0400
Content-Disposition: inline
In-Reply-To: <1335373275-336-1-git-send-email-basil.gor@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 25, 2012 at 09:01:15PM +0400, Basil Gor wrote:
> Take vlan header length into account, when vlan id is stored as
> vlan_tci. Otherwise tagged packets comming from macvtap will be
> truncated.
> 
> Signed-off-by: Basil Gor <basil.gor@gmail.com>

So I'm inclined to apply these two patches, we
this doesn't fix packet socket backend
but could be fixed by a follow-up patch.

> ---
>  drivers/vhost/net.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 1f21d2a..5c17010 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -24,6 +24,7 @@
>  #include <linux/if_arp.h>
>  #include <linux/if_tun.h>
>  #include <linux/if_macvlan.h>
> +#include <linux/if_vlan.h>
>  
>  #include <net/sock.h>
>  
> @@ -283,8 +284,12 @@ static int peek_head_len(struct sock *sk)
>  
>  	spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
>  	head = skb_peek(&sk->sk_receive_queue);
> -	if (likely(head))
> +	if (likely(head)) {
>  		len = head->len;
> +		if (vlan_tx_tag_present(head))
> +			len += VLAN_HLEN;
> +	}
> +
>  	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
>  	return len;
>  }
> -- 
> 1.7.6.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
