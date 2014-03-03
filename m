From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 -next 3/3] ipxfrm: allow to setup filter when dumping SA
Date: Mon,  3 Mar 2014 15:36:07 +0100
Message-ID: <1393857367-15016-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1393857367-15016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:55423 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982AbaCCOgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 09:36:19 -0500
In-Reply-To: <1393857367-15016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's now possible to filter SA directly into the kernel by specifying
XFRMA_PROTO and/or XFRMA_FILTER.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Note that this patch is intended to work with net-next.

 ip/xfrm_state.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 140a4503b799..61f6d930b2d2 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -1136,7 +1136,35 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 		}
 
 	} else {
-		if (rtnl_wilddump_request(&rth, preferred_family, XFRM_MSG_GETSA) < 0) {
+		struct xfrm_filter safilter;
+		struct {
+			struct nlmsghdr n;
+			char buf[NLMSG_BUF_SIZE];
+		} req;
+
+		memset(&safilter, 0, sizeof(safilter));
+		safilter.family = filter.xsinfo.family;
+		memcpy(&safilter.saddr, &filter.xsinfo.saddr,
+		       sizeof(xfrm_address_t));
+		safilter.splen = filter.id_src_mask;
+		memcpy(&safilter.daddr, &filter.xsinfo.id.daddr,
+		       sizeof(xfrm_address_t));
+		safilter.dplen = filter.id_dst_mask;
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
+		addattr_l(&req.n, sizeof(req), XFRMA_FILTER, &safilter,
+			  sizeof(safilter));
+
+		if (rtnl_send(&rth, (void *)&req, req.n.nlmsg_len) < 0) {
 			perror("Cannot send dump request");
 			exit(1);
 		}
-- 
1.8.5.4
