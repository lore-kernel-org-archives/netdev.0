From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] sctp: fix append error cause to ERROR chunk correctly
Date: Fri, 14 May 2010 08:37:36 +0800
Message-ID: <4BEC9B50.60502@cn.fujitsu.com>
References: <4BEB8BE1.2080901@cn.fujitsu.com> <20100513133100.GC21535@shamino.rdu.redhat.com> <4BEC00B2.6000705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, Eugene Teo <eteo@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61728 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753025Ab0ENAjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 20:39:37 -0400
In-Reply-To: <4BEC00B2.6000705@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 5fa782c2f5ef6c2e4f04d3e228412c9b4a4c8809
  sctp: Fix skb_over_panic resulting from multiple invalid \
    parameter errors (CVE-2010-1173) (v4)

cause 'error cause' never be add the the ERROR chunk due to
some typo when check valid length in sctp_init_cause_fixed().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Reviewed-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_make_chunk.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 30c1767..70d6c10 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -141,7 +141,7 @@ int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16 cause_code,
 	len = sizeof(sctp_errhdr_t) + paylen;
 	err.length  = htons(len);
 
-	if (skb_tailroom(chunk->skb) >  len)
+	if (skb_tailroom(chunk->skb) < len)
 		return -ENOSPC;
 	chunk->subh.err_hdr = sctp_addto_chunk_fixed(chunk,
 						     sizeof(sctp_errhdr_t),
@@ -1421,7 +1421,7 @@ void *sctp_addto_chunk(struct sctp_chunk *chunk, int len, const void *data)
 void *sctp_addto_chunk_fixed(struct sctp_chunk *chunk,
 			     int len, const void *data)
 {
-	if (skb_tailroom(chunk->skb) > len)
+	if (skb_tailroom(chunk->skb) >= len)
 		return sctp_addto_chunk(chunk, len, data);
 	else
 		return NULL;
-- 
1.6.5.2

