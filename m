From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 2/9] sctp: check invalid value of length parameter
 in error cause
Date: Wed, 20 Apr 2011 15:26:26 +0800
Message-ID: <4DAE8AA2.10504@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60819 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753780Ab1DTH0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:26:24 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

RFC4960, section 3.3.7 said:
 If an endpoint receives an ABORT with a format error or no TCB is
 found, it MUST silently discard it.

When an endpoint receives ABORT that parameter value is invalid,
drop it.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/sm_statefuns.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index fe2036d..194d5ec 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2412,8 +2412,15 @@ static sctp_disposition_t __sctp_sf_do_9_1_abort(const struct sctp_endpoint *ep,
 
 	/* See if we have an error cause code in the chunk.  */
 	len = ntohs(chunk->chunk_hdr->length);
-	if (len >= sizeof(struct sctp_chunkhdr) + sizeof(struct sctp_errhdr))
+	if (len >= sizeof(struct sctp_chunkhdr) + sizeof(struct sctp_errhdr)) {
+
+		sctp_errhdr_t *err;
+		sctp_walk_errors(err, chunk->chunk_hdr);
+		if ((void *)err != (void *)chunk->chunk_end)
+			return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
 		error = ((sctp_errhdr_t *)chunk->skb->data)->cause;
+	}
 
 	sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR, SCTP_ERROR(ECONNRESET));
 	/* ASSOC_FAILED will DELETE_TCB. */
-- 
1.6.5.2


