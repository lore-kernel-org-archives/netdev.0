From: Vlad Yasevich <vyasevich@verizon.net>
Subject: Re: sctp use-uninitialized warning in net-2.6.25
Date: Sun, 20 Jan 2008 05:47:13 -0500
Message-ID: <479326B1.3090009@verizon.net>
References: <4790CDC8.6060000@hp.com>
	<20080118.153715.167557482.davem@davemloft.net>	<47915DD4.7090109@hp.com>
 <20080118.203723.184002414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=------------000201010102060504020801
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173003pub.verizon.net ([206.46.173.3]:58343 "EHLO
	vms173003pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbYATKrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 05:47:37 -0500
Received: from [192.168.98.101] ([70.20.36.56]) by vms173003.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JUX00M0IV65D4P6@vms173003.mailsrvcs.net> for
 netdev@vger.kernel.org; Sun, 20 Jan 2008 04:44:39 -0600 (CST)
In-reply-to: <20080118.203723.184002414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000201010102060504020801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri, 18 Jan 2008 21:17:56 -0500
> 
>> Hmm... in the code I am looking at, it's set in both zero and
>> non-zero cases so it does solve the issue.
>>
>> So does initializing it to NO_ERROR like you did.
> 
> Here is the code block in question in net-2.6.25:
> 
> 	/* Verify the INIT chunk before processing it. */
> 	err_chunk = NULL;
> 	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
> 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
> 			      &err_chunk)) {
>  ...
> 		if (err_chunk) {
>  ...
> 			if (packet) {
> 				sctp_add_cmd_sf(commands, SCTP_CMD_SEND_PKT,
> 						SCTP_PACKET(packet));
> 				SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
> 				error = SCTP_ERROR_INV_PARAM;
> 			} else {
> 				error = SCTP_ERROR_NO_RESOURCE;
> 			}
> 		}
>  ...
> 		return sctp_stop_t1_and_abort(commands, error, ECONNREFUSED,
> 						asoc, chunk->transport);
> 
> If err_chunk == NULL at the "if (err_chunk)" test, error
> will be left uninitialized, even after being moved as you
> have suggested (right after the sctp_verify_init() call).
> 
> Thanks.
> 

Hi David

Thanks for beating into my thick scull that this is in 2.6.25.  I missed that
initially.

Anyway, here is a patch that sets the correct value.

-vlad

--------------000201010102060504020801
Content-Type: text/x-patch;
 name="0001-SCTP-Correctly-initialize-error-when-parameter-val.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-SCTP-Correctly-initialize-error-when-parameter-val.patc";
 filename*1="h"

>From 4788563632fae22023fc0d75b525d2d5f8e0735b Mon Sep 17 00:00:00 2001
From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Sun, 20 Jan 2008 00:22:06 -0500
Subject: [PATCH] [SCTP] Correctly initialize error when parameter validation failed.

When parameter validation fails, there should be error causes
that specify what type of failure we've encountered.  If the
causes are not there, we lacked memory to allocated them.  Thus
make that the default value for the error.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 6e12757..da5497e 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -481,7 +481,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 	sctp_init_chunk_t *initchunk;
 	struct sctp_chunk *err_chunk;
 	struct sctp_packet *packet;
-	sctp_error_t error = SCTP_ERROR_NO_ERROR;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -506,6 +505,8 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 
+		sctp_error_t error = SCTP_ERROR_NO_RESOURCE;
+
 		/* This chunk contains fatal error. It is to be discarded.
 		 * Send an ABORT, with causes.  If there are no causes,
 		 * then there wasn't enough memory.  Just terminate
@@ -525,9 +526,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 						SCTP_PACKET(packet));
 				SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
 				error = SCTP_ERROR_INV_PARAM;
-			} else {
-				error = SCTP_ERROR_NO_RESOURCE;
-			}
+			} 
 		}
 
 		/* SCTP-AUTH, Section 6.3:
-- 
1.5.2.5


--------------000201010102060504020801--
