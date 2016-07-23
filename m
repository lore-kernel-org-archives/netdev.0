From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/25] ipvs: count pre-established TCP states as active
Date: Sat, 23 Jul 2016 13:08:15 +0200
Message-ID: <1469272119-29942-2-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35876 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222AbcGWLJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:11 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5C55BE7DAA
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:10 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4EBD9DA8F3
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:10 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BD20BFAB53
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:07 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>

Some users observed that "least connection" distribution algorithm doesn't
handle well bursts of TCP connections from reconnecting clients after
a node or network failure.

This is because the algorithm counts active connection as worth 256
inactive ones where for TCP, "active" only means TCP connections in
ESTABLISHED state. In case of a connection burst, new connections are
handled before previous ones have finished the three way handshaking so
that all are still counted as "inactive", i.e. cheap ones. The become
"active" quickly but at that time, all of them are already assigned to one
real server (or few), resulting in highly unbalanced distribution.

Address this by counting the "pre-established" states as "active".

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index d7024b2..5117bcb 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -395,6 +395,20 @@ static const char *const tcp_state_name_table[IP_VS_TCP_S_LAST+1] = {
 	[IP_VS_TCP_S_LAST]		=	"BUG!",
 };
 
+static const bool tcp_state_active_table[IP_VS_TCP_S_LAST] = {
+	[IP_VS_TCP_S_NONE]		=	false,
+	[IP_VS_TCP_S_ESTABLISHED]	=	true,
+	[IP_VS_TCP_S_SYN_SENT]		=	true,
+	[IP_VS_TCP_S_SYN_RECV]		=	true,
+	[IP_VS_TCP_S_FIN_WAIT]		=	false,
+	[IP_VS_TCP_S_TIME_WAIT]		=	false,
+	[IP_VS_TCP_S_CLOSE]		=	false,
+	[IP_VS_TCP_S_CLOSE_WAIT]	=	false,
+	[IP_VS_TCP_S_LAST_ACK]		=	false,
+	[IP_VS_TCP_S_LISTEN]		=	false,
+	[IP_VS_TCP_S_SYNACK]		=	true,
+};
+
 #define sNO IP_VS_TCP_S_NONE
 #define sES IP_VS_TCP_S_ESTABLISHED
 #define sSS IP_VS_TCP_S_SYN_SENT
@@ -418,6 +432,13 @@ static const char * tcp_state_name(int state)
 	return tcp_state_name_table[state] ? tcp_state_name_table[state] : "?";
 }
 
+static bool tcp_state_active(int state)
+{
+	if (state >= IP_VS_TCP_S_LAST)
+		return false;
+	return tcp_state_active_table[state];
+}
+
 static struct tcp_states_t tcp_states [] = {
 /*	INPUT */
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
@@ -540,12 +561,12 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 
 		if (dest) {
 			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
-			    (new_state != IP_VS_TCP_S_ESTABLISHED)) {
+			    !tcp_state_active(new_state)) {
 				atomic_dec(&dest->activeconns);
 				atomic_inc(&dest->inactconns);
 				cp->flags |= IP_VS_CONN_F_INACTIVE;
 			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
-				   (new_state == IP_VS_TCP_S_ESTABLISHED)) {
+				   tcp_state_active(new_state)) {
 				atomic_inc(&dest->activeconns);
 				atomic_dec(&dest->inactconns);
 				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
-- 
2.1.4
