From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 3/8] sctp: use common head of addr parameter
 to access member in addr-unrelated code
Date: Tue, 19 Apr 2011 13:11:47 +0800
Message-ID: <4DAD1993.5070801@cn.fujitsu.com>
References: <4DAD18AB.3040401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52220 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752007Ab1DSFLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 01:11:44 -0400
In-Reply-To: <4DAD18AB.3040401@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

The 'p' member of struct sctp_paramhdr is common part for
IPv4 addr parameter and IPv6 addr parameter in union sctp_addr_param.

For addr-related code, use specified addr parameter.
Otherwise, use common header to access type/length member.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/input.c         |    2 +-
 net/sctp/sm_make_chunk.c |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 5436c69..30cec77 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -1017,7 +1017,7 @@ static struct sctp_association *__sctp_rcv_asconf_lookup(
 	/* Skip over the ADDIP header and find the Address parameter */
 	param = (union sctp_addr_param *)(asconf + 1);
 
-	af = sctp_get_af_specific(param_type2af(param->v4.param_hdr.type));
+	af = sctp_get_af_specific(param_type2af(param->p.type));
 	if (unlikely(!af))
 		return NULL;
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index b3434cc..844adfd 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2923,7 +2923,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 	    asconf_param->param_hdr.type != SCTP_PARAM_SET_PRIMARY)
 		return SCTP_ERROR_UNKNOWN_PARAM;
 
-	switch (addr_param->v4.param_hdr.type) {
+	switch (addr_param->p.type) {
 	case SCTP_PARAM_IPV6_ADDRESS:
 		if (!asoc->peer.ipv6_address)
 			return SCTP_ERROR_DNS_FAILED;
@@ -2936,7 +2936,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		return SCTP_ERROR_DNS_FAILED;
 	}
 
-	af = sctp_get_af_specific(param_type2af(addr_param->v4.param_hdr.type));
+	af = sctp_get_af_specific(param_type2af(addr_param->p.type));
 	if (unlikely(!af))
 		return SCTP_ERROR_DNS_FAILED;
 
@@ -3100,7 +3100,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	/* Skip the address parameter and store a pointer to the first
 	 * asconf parameter.
 	 */
-	length = ntohs(addr_param->v4.param_hdr.length);
+	length = ntohs(addr_param->p.length);
 	asconf_param = (sctp_addip_param_t *)((void *)addr_param + length);
 	chunk_len -= length;
 
@@ -3177,7 +3177,7 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 			((void *)asconf_param + sizeof(sctp_addip_param_t));
 
 	/* We have checked the packet before, so we do not check again.	*/
-	af = sctp_get_af_specific(param_type2af(addr_param->v4.param_hdr.type));
+	af = sctp_get_af_specific(param_type2af(addr_param->p.type));
 	af->from_addr_param(&addr, addr_param, htons(bp->port), 0);
 
 	switch (asconf_param->param_hdr.type) {
@@ -3304,7 +3304,7 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 	/* Skip the address parameter in the last asconf sent and store a
 	 * pointer to the first asconf parameter.
 	 */
-	length = ntohs(addr_param->v4.param_hdr.length);
+	length = ntohs(addr_param->p.length);
 	asconf_param = (sctp_addip_param_t *)((void *)addr_param + length);
 	asconf_len -= length;
 
-- 
1.6.5.2


