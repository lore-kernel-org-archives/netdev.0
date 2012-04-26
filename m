From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v3 1/2] vhost-net: fix handle_rx buffer size
Date: Wed, 25 Apr 2012 22:30:10 -0700
Message-ID: <m1bomfgivx.fsf@fess.ebiederm.org>
References: <m1ipgtzwew.fsf@fess.ebiederm.org>
	<1335373275-336-1-git-send-email-basil.gor@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Basil Gor <basil.gor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53735 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462Ab2DZF0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 01:26:04 -0400
In-Reply-To: <1335373275-336-1-git-send-email-basil.gor@gmail.com> (Basil
	Gor's message of "Wed, 25 Apr 2012 21:01:15 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basil Gor <basil.gor@gmail.com> writes:

> Take vlan header length into account, when vlan id is stored as
> vlan_tci. Otherwise tagged packets comming from macvtap will be
> truncated.

Better.

In recvmsg you are still missing handling of PACKET_AUXDATA
that includes aux.tp_vlan_tci === vlan_id and
aux.tp_status === TP_STATUS_VLAN_VALID.

That is the way pf_packet sockets report the vlan.  Not
in the actual packet itself.

Eric

> Signed-off-by: Basil Gor <basil.gor@gmail.com>
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
