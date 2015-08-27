From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net v4] sctp: asconf's process should verify address parameter is in the beginning
Date: Thu, 27 Aug 2015 16:26:34 +0800
Message-ID: <842bb5735d0ea0e632695f49dc85021faa176784.1440663994.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, davem@davemloft.net, vyasevic@redhat.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34270 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbbH0I0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 04:26:41 -0400
Received: by pabzx8 with SMTP id zx8so18056849pab.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 01:26:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in sctp_process_asconf(), we get address parameter from the beginning of
the addip params. but we never check if it's really there. if the addr
param is not there, it still can pass sctp_verify_asconf(), then to be
handled by sctp_process_asconf(), it will not be safe.

so add a code in sctp_verify_asconf() to check the address parameter is in
the beginning, or return false to send abort.

note that this can also detect multiple address parameters, and reject it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---
 net/sctp/sm_make_chunk.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 06320c8..a655ddc 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3132,11 +3132,18 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
 		case SCTP_PARAM_IPV4_ADDRESS:
 			if (length != sizeof(sctp_ipv4addr_param_t))
 				return false;
+			/* ensure there is only one addr param and it's in the
+			 * beginning of addip_hdr params, or we reject it.
+			 */
+			if (param.v != addip->addip_hdr.params)
+				return false;
 			addr_param_seen = true;
 			break;
 		case SCTP_PARAM_IPV6_ADDRESS:
 			if (length != sizeof(sctp_ipv6addr_param_t))
 				return false;
+			if (param.v != addip->addip_hdr.params)
+				return false;
 			addr_param_seen = true;
 			break;
 		case SCTP_PARAM_ADD_IP:
-- 
2.1.0
