From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v3 2/3] sctp: Add ASCONF operation on the
 single-homed host
Date: Wed, 13 Apr 2011 09:14:33 +0800
Message-ID: <4DA4F8F9.2030302@cn.fujitsu.com>
References: <02627A77-8793-4EEC-9540-F2DECBB8E23A@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61748 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757447Ab1DMBOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 21:14:16 -0400
In-Reply-To: <02627A77-8793-4EEC-9540-F2DECBB8E23A@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Michio Honda

> SCTP can change the IP address on the single-homed host.  
> In this case, the SCTP association transmits an ASCONF packet including addition of the new IP address and deletion of the old address.  
> This patch implements this functionality.  
>
>

...snip...

>  
> @@ -1277,7 +1284,7 @@ void sctp_assoc_update(struct sctp_association *asoc,
>   */
>  void sctp_assoc_update_retran_path(struct sctp_association *asoc)
>  {
> -	struct sctp_transport *t, *next;
> +	struct sctp_transport *t, *next, *unconfirmed;
>  	struct list_head *head = &asoc->peer.transport_addr_list;
>  	struct list_head *pos;
>  
> @@ -1287,7 +1294,7 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
>  	/* Find the next transport in a round-robin fashion. */
>  	t = asoc->peer.retran_path;
>  	pos = &t->transports;
> -	next = NULL;
> +	next = unconfirmed = NULL;
>  
>  	while (1) {
>  		/* Skip the head. */
> @@ -1318,11 +1325,15 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
>  			 */
>  			if (t->state != SCTP_UNCONFIRMED && !next)
>  				next = t;
> +			else if (t->state == SCTP_UNCONFIRMED)
> +				unconfirmed = t;
>  		}
>  	}
>  
>  	if (t)
>  		asoc->peer.retran_path = t;
> +	else if (unconfirmed)
> +		asoc->peer.retran_path = t = unconfirmed;
>  
>  	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_update_retran_path:association"
>  				 " %p addr: "

since we can not select unconfirmed transports for retransmission,
this part is not correct. the specification forbids this due to security
issues.
Not sure whether you hit this bug: remove transport and left only
one unconfirmed transport, it may cause oops while retransmit.
I will send other patch to fix it first.


...snip...

