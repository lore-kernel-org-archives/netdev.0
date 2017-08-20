From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/2] netfilter: ipvs: do not create conn for ABORT packet in sctp_conn_schedule
Date: Sun, 20 Aug 2017 13:38:08 +0800
Message-ID: <3f97d61377667c421b40f865f85d99541f693ae9.1503207076.git.lucien.xin@gmail.com>
References: <cover.1503207076.git.lucien.xin@gmail.com>
 <9475ae3e6d80f0c6547371f5a910edfbbd4a9b2a.1503207076.git.lucien.xin@gmail.com>
Cc: pablo@netfilter.org, Alex Gartrell <agartrell@fb.com>,
        lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38620 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752570AbdHTFid (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 01:38:33 -0400
In-Reply-To: <9475ae3e6d80f0c6547371f5a910edfbbd4a9b2a.1503207076.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1503207076.git.lucien.xin@gmail.com>
References: <cover.1503207076.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no reason for ipvs to create a conn for an ABORT packet
even if sysctl_sloppy_sctp is set.

This patch is to accept it without creating a conn, just as ipvs
does for tcp's RST packet.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index e9b18ac..d86773a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -25,7 +25,8 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			sch = skb_header_pointer(skb, iph->len + sizeof(_sctph),
 						 sizeof(_schunkh), &_schunkh);
 			if (sch) {
-				if (!(sysctl_sloppy_sctp(ipvs) ||
+				if (sch->type == SCTP_CID_ABORT ||
+				    !(sysctl_sloppy_sctp(ipvs) ||
 				      sch->type == SCTP_CID_INIT))
 					return 1;
 				ports = &sh->source;
-- 
2.1.0
