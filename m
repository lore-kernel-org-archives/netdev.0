From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [SCTP]: Add address type check while process paramaters
 of ASCONF chunk
Date: Tue, 13 May 2008 13:30:49 +0200
Message-ID: <48297BE9.9020204@trash.net>
References: <1210360195-16524-1-git-send-email-vladislav.yasevich@hp.com> <1210360195-16524-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070509050401090605050106"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39560 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbYEMLb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 07:31:27 -0400
In-Reply-To: <1210360195-16524-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070509050401090605050106
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Vlad Yasevich wrote:
> @@ -2827,6 +2827,19 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
>  	union sctp_addr	addr;
>  	union sctp_addr_param *addr_param;
>  
> +	switch (addr_param->v4.param_hdr.type) {

^^^ use of addr_param

> +	case SCTP_PARAM_IPV6_ADDRESS:
> +		if (!asoc->peer.ipv6_address)
> +			return SCTP_ERROR_INV_PARAM;
> +		break;
> +	case SCTP_PARAM_IPV4_ADDRESS:
> +		if (!asoc->peer.ipv4_address)
> +			return SCTP_ERROR_INV_PARAM;
> +		break;
> +	default:
> +		return SCTP_ERROR_INV_PARAM;
> +	}
> +
>  	addr_param = (union sctp_addr_param *)
>  			((void *)asconf_param + sizeof(sctp_addip_param_t));

^^^ initialization of addr_param

The patch is wrong and needs this fix on top.





--------------070509050401090605050106
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 1beb4530b5bf180d8989993d3050fabdf21522cc
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue May 13 13:27:22 2008 +0200

    [SCTP]: Fix use of uninitialized pointer
    
    Introduced by c4492586 (sctp: Add address type check while process
    paramaters of ASCONF chunk):
    
    net/sctp/sm_make_chunk.c: In function 'sctp_process_asconf':
    net/sctp/sm_make_chunk.c:2828: warning: 'addr_param' may be used uninitialized in this function
    net/sctp/sm_make_chunk.c:2828: note: 'addr_param' was declared here
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 6eeee53..bbc7107 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2827,6 +2827,9 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 	union sctp_addr	addr;
 	union sctp_addr_param *addr_param;
 
+	addr_param = (union sctp_addr_param *)
+			((void *)asconf_param + sizeof(sctp_addip_param_t));
+
 	switch (addr_param->v4.param_hdr.type) {
 	case SCTP_PARAM_IPV6_ADDRESS:
 		if (!asoc->peer.ipv6_address)
@@ -2840,9 +2843,6 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		return SCTP_ERROR_INV_PARAM;
 	}
 
-	addr_param = (union sctp_addr_param *)
-			((void *)asconf_param + sizeof(sctp_addip_param_t));
-
 	af = sctp_get_af_specific(param_type2af(addr_param->v4.param_hdr.type));
 	if (unlikely(!af))
 		return SCTP_ERROR_INV_PARAM;

--------------070509050401090605050106--
