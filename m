From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] pppoe: Use workqueue to die properly when a PADT is
 received
Date: Fri, 20 Feb 2015 11:05:08 -0600
Message-ID: <1424451908.20313.19.camel@redhat.com>
References: <1424381068-22252-1-git-send-email-simon@farnz.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michal Ostrowski <mostrows@earthlink.net>
To: Simon Farnsworth <simon@farnz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47625 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725AbbBTRFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2015 12:05:22 -0500
In-Reply-To: <1424381068-22252-1-git-send-email-simon@farnz.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-19 at 21:24 +0000, Simon Farnsworth wrote:
> When a PADT frame is received, the socket may not be in a good state to
> close down the PPP interface. The current implementation handles this by
> simply blocking all further PPP traffic, and hoping that the lack of traffic
> will trigger the user to investigate.
> 
> Use schedule_work to get to a process context from which we clear down the
> PPP interface, in a fashion analogous to hangup on a TTY-based PPP
> interface. This causes pppd to disconnect immediately, and allows tools to
> take immediate corrective action.
> 
> Signed-off-by: Simon Farnsworth <simon@farnz.org.uk>

Adding my tested-by since I tested the patch and confirmed it fixes the
issue before Simon posted to netdev.

Tested-by: Dan Williams <dcbw@redhat.com>

> ---
> Note that I'm not subscribed to netdev; please cc me on any replies.
> 
> The patch falls out of https://bugzilla.gnome.org/show_bug.cgi?id=742939
> I'm trying to get NetworkManager back to using kernel PPPoE partly because
> it performs a little better, and mostly because kernel PPPoE copes with
> larger MTUs than userspace PPPoE.
> 
> Dan Williams (cc'd) has tested a previous version of this patch; the
> differences to this version are only cosmetic.
> 
>  drivers/net/ppp/pppoe.c  | 17 ++++++++++++++++-
>  include/linux/if_pppox.h |  2 ++
>  2 files changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
> index d2408a5..9c97e9b 100644
> --- a/drivers/net/ppp/pppoe.c
> +++ b/drivers/net/ppp/pppoe.c
> @@ -455,6 +455,18 @@ out:
>  	return NET_RX_DROP;
>  }
>  
> +static void pppoe_unbind_sock_work(struct work_struct *work)
> +{
> +	struct pppox_sock *po = container_of(work, struct pppox_sock,
> +					     proto.pppoe.padt_work);
> +	struct sock *sk = sk_pppox(po);
> +
> +	lock_sock(sk);
> +	pppox_unbind_sock(sk);
> +	release_sock(sk);
> +	sock_put(sk);
> +}
> +
>  /************************************************************************
>   *
>   * Receive a PPPoE Discovery frame.
> @@ -500,7 +512,8 @@ static int pppoe_disc_rcv(struct sk_buff *skb, struct net_device *dev,
>  		}
>  
>  		bh_unlock_sock(sk);
> -		sock_put(sk);
> +		if (!schedule_work(&po->proto.pppoe.padt_work))
> +			sock_put(sk);
>  	}
>  
>  abort:
> @@ -613,6 +626,8 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
>  
>  	lock_sock(sk);
>  
> +	INIT_WORK(&po->proto.pppoe.padt_work, pppoe_unbind_sock_work);
> +
>  	error = -EINVAL;
>  	if (sp->sa_protocol != PX_PROTO_OE)
>  		goto end;
> diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
> index aff7ad8..66a7d76 100644
> --- a/include/linux/if_pppox.h
> +++ b/include/linux/if_pppox.h
> @@ -19,6 +19,7 @@
>  #include <linux/netdevice.h>
>  #include <linux/ppp_channel.h>
>  #include <linux/skbuff.h>
> +#include <linux/workqueue.h>
>  #include <uapi/linux/if_pppox.h>
>  
>  static inline struct pppoe_hdr *pppoe_hdr(const struct sk_buff *skb)
> @@ -32,6 +33,7 @@ struct pppoe_opt {
>  	struct pppoe_addr	pa;	  /* what this socket is bound to*/
>  	struct sockaddr_pppox	relay;	  /* what socket data will be
>  					     relayed to (PPPoE relaying) */
> +	struct work_struct      padt_work;/* Work item for handling PADT */
>  };
>  
>  struct pptp_opt {
