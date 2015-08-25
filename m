From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net v2] sctp: asconf's process should verify address parameter is in the beginning
Date: Tue, 25 Aug 2015 20:29:24 +0800
Message-ID: <3ffe8f6b86e33c016dddec672fab23a206c21acf.1440505764.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, davem@davemloft.net, vyasevic@redhat.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36233 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002AbbHYM32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 08:29:28 -0400
Received: by padfo6 with SMTP id fo6so6290410pad.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 05:29:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in sctp_process_asconf(), we get address parameter from the beginning of
the addip params. but we never check if it's really there. if the addr
param is not there, it still can pass sctp_verify_asconf(), then to be
handled by sctp_process_asconf(), it will not be safe.

so add a code in sctp_verify_asconf() to check the address parameter is in
the beginning, or return false to send abort.

v1->v2:
 * put the check behind the params' length verify.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_make_chunk.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 06320c8..89a4d1c 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3166,6 +3166,13 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
 		return false;
 	if (!addr_param_needed && addr_param_seen)
 		return false;
+	if (addr_param_needed && addr_param_seen) {
+		/* Ensure the address parameter is in the beginning */
+		param.v = chunk->skb->data + sizeof(sctp_addiphdr_t);
+		if (param.p->type != SCTP_PARAM_IPV4_ADDRESS &&
+		    param.p->type != SCTP_PARAM_IPV6_ADDRESS)
+			return false;
+	}
 	if (param.v != chunk->chunk_end)
 		return false;
 
-- 
2.1.0
