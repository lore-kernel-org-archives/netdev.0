From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: asconf's process should verify address parameter is in the beginning
Date: Mon, 24 Aug 2015 18:07:58 +0800
Message-ID: <87d339ea910a3665c9376b6ba69b003af967c6d1.1440410878.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34835 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbbHXKIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 06:08:02 -0400
Received: by pacdd16 with SMTP id dd16so93862761pac.2
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 03:08:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in sctp_process_asconf(), we get address parameter from the beginning of the
addip params. but we never check if it's really there. if the addr param is not
there, it still can pass sctp_verify_asconf(), then to be handled by
sctp_process_asconf(), it will not be safe.

so add a code in sctp_verify_asconf() to check the address parameter is in the
beginning, or return false to send abort.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_make_chunk.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 0ee5ca7..a2a72d5 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3122,6 +3122,14 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
 	union sctp_params param;
 	bool addr_param_seen = false;
 
+	if(addr_param_needed){
+		/* Ensure the address parameter is in the beginning */
+		param.v = chunk->skb->data + sizeof(sctp_addiphdr_t);
+		if (param.p->type != SCTP_PARAM_IPV4_ADDRESS &&
+		    param.p->type != SCTP_PARAM_IPV6_ADDRESS)
+			return false;
+	}
+
 	sctp_walk_params(param, addip, addip_hdr.params) {
 		size_t length = ntohs(param.p->length);
 
-- 
2.1.0
