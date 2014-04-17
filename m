From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: add support for busy polling to sctp protocol
Date: Thu, 17 Apr 2014 17:37:29 -0400
Message-ID: <53504999.4080709@gmail.com>
References: <1397762811-2989-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36496 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbaDQVhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 17:37:33 -0400
In-Reply-To: <1397762811-2989-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2014 03:26 PM, Neil Horman wrote:
> The busy polling socket option adds support for sockets to busy wait on data
> arriving on the napi queue from which they have most recently received a frame.
> Currently only tcp and udp support this feature, but theres no reason sctp can't
> do so as well.  Add it in so appliations can take advantage of it
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Daniel Borkmann <dborkman@redhat.com>
> CC: netdev@vger.kernel.org

Hi Neil

Do we gain anything by polling?
This is probably more appropriate for net-next...

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Thanks
-vlad

> ---
>  net/sctp/socket.c   | 5 +++++
>  net/sctp/ulpqueue.c | 4 ++++
>  2 files changed, 9 insertions(+)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 981aaf8..9788e07 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -71,6 +71,7 @@
>  #include <net/route.h>
>  #include <net/ipv6.h>
>  #include <net/inet_common.h>
> +#include <net/busy_poll.h>
>  
>  #include <linux/socket.h> /* for sa_family_t */
>  #include <linux/export.h>
> @@ -6553,6 +6554,10 @@ static struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
>  		if (sk->sk_shutdown & RCV_SHUTDOWN)
>  			break;
>  
> +		if (sk_can_busy_loop(sk) &&
> +		    sk_busy_loop(sk, noblock))
> +			continue;
> +
>  		/* User doesn't want to wait.  */
>  		error = -EAGAIN;
>  		if (!timeo)
> diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
> index 5dc9411..a4df012 100644
> --- a/net/sctp/ulpqueue.c
> +++ b/net/sctp/ulpqueue.c
> @@ -38,6 +38,7 @@
>  #include <linux/types.h>
>  #include <linux/skbuff.h>
>  #include <net/sock.h>
> +#include <net/busy_poll.h>
>  #include <net/sctp/structs.h>
>  #include <net/sctp/sctp.h>
>  #include <net/sctp/sm.h>
> @@ -204,6 +205,9 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
>  	if (sock_flag(sk, SOCK_DEAD) || (sk->sk_shutdown & RCV_SHUTDOWN))
>  		goto out_free;
>  
> +	if (!sctp_ulpevent_is_notification(event))
> +		sk_mark_napi_id(sk, skb);
> +
>  	/* Check if the user wishes to receive this event.  */
>  	if (!sctp_ulpevent_is_enabled(event, &sctp_sk(sk)->subscribe))
>  		goto out_free;
> 
