From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v4 iproute2 -next 2/2] ipxfrm: allow to setup filter when dumping SA
Date: Fri, 21 Mar 2014 11:02:43 +0100
Message-ID: <1395396163-11692-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20140320103901.6e57049a@nehalam.linuxnetplumber.net>
 <1395396163-11692-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:60057 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965139AbaCUKCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 06:02:48 -0400
In-Reply-To: <1395396163-11692-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's now possible to filter SA directly into the kernel by specifying
XFRMA_PROTO and/or XFRMA_ADDRESS_FILTER.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
Note that this patch is intended to work with net-next.

v4: use C99 initializers for all structure

v3: use C99 initializers

 ip/xfrm_state.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 140a4503b799..fe7708e533f3 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -1136,7 +1136,30 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 		}
 
 	} else {
-		if (rtnl_wilddump_request(&rth, preferred_family, XFRM_MSG_GETSA) < 0) {
+		struct xfrm_address_filter addrfilter = {
+			.saddr = filter.xsinfo.saddr,
+			.daddr = filter.xsinfo.id.daddr,
+			.family = filter.xsinfo.family,
+			.splen = filter.id_src_mask,
+			.dplen = filter.id_dst_mask,
+		};
+		struct {
+			struct nlmsghdr n;
+			char buf[NLMSG_BUF_SIZE];
+		} req = {
+			.n.nlmsg_len = NLMSG_HDRLEN,
+			.n.nlmsg_flags = NLM_F_DUMP | NLM_F_REQUEST,
+			.n.nlmsg_type = XFRM_MSG_GETSA,
+			.n.nlmsg_seq = rth.dump = ++rth.seq,
+		};
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
