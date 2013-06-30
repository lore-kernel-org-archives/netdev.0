From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/12] ipvs: drop SCTP connections depending on state
Date: Mon,  1 Jul 2013 01:54:36 +0200
Message-ID: <1372636481-3705-8-git-send-email-pablo@netfilter.org>
References: <1372636481-3705-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59874 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab3F3Xy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jun 2013 19:54:58 -0400
In-Reply-To: <1372636481-3705-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

Drop SCTP connections under load (dropentry context) depending
on the protocol state, just like for TCP: INIT conns are
dropped immediately, established are dropped randomly while
connections in progress or shutdown are skipped.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index c8c52a9..4c8e5c0 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1231,6 +1231,18 @@ void ip_vs_random_dropentry(struct net *net)
 				default:
 					continue;
 				}
+			} else if (cp->protocol == IPPROTO_SCTP) {
+				switch (cp->state) {
+				case IP_VS_SCTP_S_INIT1:
+				case IP_VS_SCTP_S_INIT:
+					break;
+				case IP_VS_SCTP_S_ESTABLISHED:
+					if (todrop_entry(cp))
+						break;
+					continue;
+				default:
+					continue;
+				}
 			} else {
 				if (!todrop_entry(cp))
 					continue;
-- 
1.7.10.4
