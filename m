From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: sctp use-uninitialized warning in net-2.6.25
Date: Fri, 18 Jan 2008 11:03:20 -0500
Message-ID: <4790CDC8.6060000@hp.com>
References: <20080116135957.4eb54958.akpm@linux-foundation.org> <20080118.044911.64979691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:11720 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757439AbYARQDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 11:03:22 -0500
In-Reply-To: <20080118.044911.64979691.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 16 Jan 2008 13:59:57 -0800
> 
>> net/sctp/sm_statefuns.c: In function 'sctp_sf_do_5_1C_ack':
>> net/sctp/sm_statefuns.c:484: warning: 'error' may be used uninitialized in this function
>>
>> It is not obvious that this is a false positive.
> 
> I'll check in the following for now.
> 
> Vlad, please take a look.
> 
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index b126751..6e12757 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -481,7 +481,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
>  	sctp_init_chunk_t *initchunk;
>  	struct sctp_chunk *err_chunk;
>  	struct sctp_packet *packet;
> -	sctp_error_t error;
> +	sctp_error_t error = SCTP_ERROR_NO_ERROR;
>  
>  	if (!sctp_vtag_verify(chunk, asoc))
>  		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
> 

Hi David

We can do that, or move the declaration to the only block that uses it.
Like this:

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f02ce3d..193c0c2 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -442,7 +442,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 	sctp_init_chunk_t *initchunk;
 	struct sctp_chunk *err_chunk;
 	struct sctp_packet *packet;
-	sctp_error_t error;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -466,6 +465,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
+		sctp_error_t error;
 
 		SCTP_INC_STATS(SCTP_MIB_ABORTEDS);

-vlad
