From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 08/13] SCTP: Use hashed lookup when looking for an association.
Date: Fri, 09 Nov 2007 11:48:12 -0500
Message-ID: <47348F4C.8030504@hp.com>
References: <11944575911538-git-send-email-vladislav.yasevich@hp.com> <11944575913296-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:60694 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754251AbXKIQsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 11:48:14 -0500
In-Reply-To: <11944575913296-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote:
> A SCTP endpoint may have a lot of associations on them and walking
> the list is fairly inefficient.  Instead, use a hashed lookup,
> and filter out the hash list based on the endopoint we already have.

This one is missing an unlock.  Will send an update shortly.

-vlad

> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> ---
>  net/sctp/endpointola.c |   33 +++++++++++++++++++++------------
>  1 files changed, 21 insertions(+), 12 deletions(-)
> 
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 2d2d81e..f38fa0f 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -328,24 +328,33 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
>  	const union sctp_addr *paddr,
>  	struct sctp_transport **transport)
>  {
> +	struct sctp_association *asoc = NULL;
> +	struct sctp_transport *t = NULL;
> +	struct sctp_hashbucket *head;
> +	struct sctp_ep_common *epb;
> +	int hash;
>  	int rport;
> -	struct sctp_association *asoc;
> -	struct list_head *pos;
>  
> +	*transport = NULL;
>  	rport = ntohs(paddr->v4.sin_port);
>  
> -	list_for_each(pos, &ep->asocs) {
> -		asoc = list_entry(pos, struct sctp_association, asocs);
> -		if (rport == asoc->peer.port) {
> -			*transport = sctp_assoc_lookup_paddr(asoc, paddr);
> -
> -			if (*transport)
> -				return asoc;
> +	hash = sctp_assoc_hashfn(ep->base.bind_addr.port, rport);
> +	head = &sctp_assoc_hashtable[hash];
> +	read_lock(&head->lock);
> +	for (epb = head->chain; epb; epb = epb->next) {
> +		asoc = sctp_assoc(epb);
> +		if (asoc->ep != ep || rport != asoc->peer.port)
> +			goto next;
> +
> +		t = sctp_assoc_lookup_paddr(asoc, paddr);
> +		if (t) {
> +			*transport = t;
> +			break;
>  		}
> +next:
> +		asoc = NULL;
>  	}
> -
> -	*transport = NULL;
> -	return NULL;
> +	return asoc;
>  }
>  
>  /* Lookup association on an endpoint based on a peer address.  BH-safe.  */

