From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: Reducing rwnd by sizeof(struct sk_buff) for each
 CHUNK is too aggressive
Date: Fri, 24 Jun 2011 09:48:51 -0400
Message-ID: <4E0495C3.30102@hp.com>
References: <20110624101535.GB9222@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:17605 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174Ab1FXNs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 09:48:56 -0400
In-Reply-To: <20110624101535.GB9222@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2011 06:15 AM, Thomas Graf wrote:
> Currently we subtract sizeof(struct sk_buff) of our view of the
> receiver's rwnd for each DATA chunk appended to a sctp packet.
> Reducing the rwnd by >200 bytes for each DATA chunk quickly
> consumes the available window and prevents max MTU sized packets
> (for large MTU values) from being generated in combination with
> small DATA chunks. The sender has to wait for the next SACK to
> be processed for the rwnd to be corrected.
> 
> Accounting for data structures required for rx is the responsibility
> of the stack which is why we announce a rwnd of sk_rcvbuf/2.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index b4f3cf0..ceb55b2 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -700,13 +700,7 @@ static void sctp_packet_append_data(struct sctp_packet *packet,
>  	/* Keep track of how many bytes are in flight to the receiver. */
>  	asoc->outqueue.outstanding_bytes += datasize;
>  
> -	/* Update our view of the receiver's rwnd. Include sk_buff overhead
> -	 * while updating peer.rwnd so that it reduces the chances of a
> -	 * receiver running out of receive buffer space even when receive
> -	 * window is still open. This can happen when a sender is sending
> -	 * sending small messages.
> -	 */
> -	datasize += sizeof(struct sk_buff);
> +	/* Update our view of the receiver's rwnd. */
>  	if (datasize < rwnd)
>  		rwnd -= datasize;
>  	else
> 

Hi Thomas

I believe there was work in progress to change how window is computed.  The issue with
your current patch is that it is possible to consume all of the receive buffer space while
still having an open receive window.  We've seen it in real life which is why the above band-aid
was applied.

The correct patch should really something similar to TCP, where receive window is computed as
a percentage of the available receive buffer space at every adjustment.  This should also take into
account SWS on the sender side.

Someone started implementing that code, but I am not sure where it currently is.

Thanks
-vlad
