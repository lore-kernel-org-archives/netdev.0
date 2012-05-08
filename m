From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 1/2] vhost-net: fix handle_rx buffer size
Date: Tue, 8 May 2012 22:27:33 +0300
Message-ID: <20120508192732.GA28536@redhat.com>
References: <1336121724-31902-1-git-send-email-basil.gor@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Basil Gor <basil.gor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755396Ab2EHT1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 15:27:32 -0400
Content-Disposition: inline
In-Reply-To: <1336121724-31902-1-git-send-email-basil.gor@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 04, 2012 at 12:55:23PM +0400, Basil Gor wrote:
> Take vlan header length into account, when vlan id is stored as
> vlan_tci. Otherwise tagged packets comming from macvtap will be
> truncated.
> 
> Signed-off-by: Basil Gor <basil.gor@gmail.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

This doesn't fix packet socket backends but that can be
handled separately later.

Eric, ack?

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
