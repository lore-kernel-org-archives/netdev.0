From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2 -next 2/2] ipxfrm: allow to setup filter when dumping SA
Date: Wed, 19 Mar 2014 17:52:08 +0100
Message-ID: <1395247928-9954-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1395247928-9954-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56169 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932602AbaCSQwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 12:52:14 -0400
In-Reply-To: <1395247928-9954-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's now possible to filter SA directly into the kernel by specifying
XFRMA_PROTO and/or XFRMA_ADDRESS_FILTER.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Note that this patch is intended to work with net-next.

 ip/xfrm_state.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 140a4503b799..8295223f8118 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -1136,7 +1136,35 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 		}
 
 	} else {
-		if (rtnl_wilddump_request(&rth, preferred_family, XFRM_MSG_GETSA) < 0) {
+		struct xfrm_address_filter addrfilter;
+		struct {
+			struct nlmsghdr n;
+			char buf[NLMSG_BUF_SIZE];
+		} req;
+
+		memset(&addrfilter, 0, sizeof(addrfilter));
+		addrfilter.family = filter.xsinfo.family;
+		memcpy(&addrfilter.saddr, &filter.xsinfo.saddr,
+		       sizeof(xfrm_address_t));
+		addrfilter.splen = filter.id_src_mask;
+		memcpy(&addrfilter.daddr, &filter.xsinfo.id.daddr,
+		       sizeof(xfrm_address_t));
+		addrfilter.dplen = filter.id_dst_mask;
+
+		memset(&req, 0, sizeof(req));
+		req.n.nlmsg_len = NLMSG_HDRLEN;
+		req.n.nlmsg_flags = NLM_F_DUMP | NLM_F_REQUEST;
+		req.n.nlmsg_type = XFRM_MSG_GETSA;
+		req.n.nlmsg_pid = 0;
+		req.n.nlmsg_seq = rth.dump = ++rth.seq;
+
+		if (filter.xsinfo.id.proto)
+			addattr8(&req.n, sizeof(req), XFRMA_PROTO,
+				 filter.xsinfo.id.proto);
+		addattr_l(&req.n, sizeof(req), XFRMA_ADDRESS_FILTER,
+			  &addrfilter, sizeof(addrfilter));
+
+		if (rtnl_send(&rth, (void *)&req, req.n.nlmsg_len) < 0) {
 			perror("Cannot send dump request");
 			exit(1);
 		}
-- 
1.8.5.4
