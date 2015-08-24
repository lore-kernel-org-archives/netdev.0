From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: asconf process should treat multiple address parameter as unrecognized parameter
Date: Mon, 24 Aug 2015 18:07:30 +0800
Message-ID: <13ab95079875febb3985b32d0fdaf587c6de1973.1440410850.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35481 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbbHXKHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 06:07:36 -0400
Received: by pacdd16 with SMTP id dd16so93854571pac.2
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 03:07:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

currently, we sctp_walk_params(), if we encounter the address parameter, we will
skip them, we do not care about how many addr params are there.

but the params of ASCONF chunk should consist of one *Address Parameter* and one
or more *ASCONF Parameters*.

so we will process multiple address parameters as unrecognized parameter and
send error cause to peer.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_make_chunk.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 06320c8..0ee5ca7 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3217,10 +3217,18 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 
 	/* Process the TLVs contained within the ASCONF chunk. */
 	sctp_walk_params(param, addip, addip_hdr.params) {
-		/* Skip preceeding address parameters. */
+		/* Skip preceeding address parameters.
+		 * process multi-addrparam as unrecognized parameters
+		 */
 		if (param.p->type == SCTP_PARAM_IPV4_ADDRESS ||
-		    param.p->type == SCTP_PARAM_IPV6_ADDRESS)
+		    param.p->type == SCTP_PARAM_IPV6_ADDRESS) {
+			if(param.addr != addr_param) {
+				all_param_pass = false;
+				sctp_add_asconf_response(asconf_ack, 0,
+					SCTP_ERROR_UNKNOWN_PARAM, param.v);
+			}
 			continue;
+		}
 
 		err_code = sctp_process_asconf_param(asoc, asconf,
 						     param.addip);
-- 
2.1.0
