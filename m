From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 02/13] SCTP : Fix to process bundled ASCONF chunk correctly
Date: Wed,  7 Nov 2007 12:46:20 -0500
Message-ID: <11944575911325-git-send-email-vladislav.yasevich@hp.com>
References: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:39385 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754412AbXKGSEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 13:04:54 -0500
In-Reply-To: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If ASCONF chunk is bundled with other chunks as the first chunk, when
process the ASCONF parameters, full packet data will be process as the
parameters of the ASCONF chunk, not only the real parameters. So if you
send a ASCONF chunk bundled with other chunks, you will get an unexpected
result.
This problem also exists when ASCONF-ACK chunk is bundled with other chunks.

This patch fix this problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index c377e4e..5de4729 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2848,10 +2848,11 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 
 	__be16	err_code;
 	int	length = 0;
-	int	chunk_len = asconf->skb->len;
+	int	chunk_len;
 	__u32	serial;
 	int	all_param_pass = 1;
 
+	chunk_len = ntohs(asconf->chunk_hdr->length) - sizeof(sctp_chunkhdr_t);
 	hdr = (sctp_addiphdr_t *)asconf->skb->data;
 	serial = ntohl(hdr->serial);
 
@@ -2990,7 +2991,7 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 	sctp_addip_param_t	*asconf_ack_param;
 	sctp_errhdr_t		*err_param;
 	int			length;
-	int			asconf_ack_len = asconf_ack->skb->len;
+	int			asconf_ack_len;
 	__be16			err_code;
 
 	if (no_err)
@@ -2998,6 +2999,9 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 	else
 		err_code = SCTP_ERROR_REQ_REFUSED;
 
+	asconf_ack_len = ntohs(asconf_ack->chunk_hdr->length) -
+			     sizeof(sctp_chunkhdr_t);
+
 	/* Skip the addiphdr from the asconf_ack chunk and store a pointer to
 	 * the first asconf_ack parameter.
 	 */
-- 
1.5.2.4

