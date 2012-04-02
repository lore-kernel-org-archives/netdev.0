From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 21/51] ipvs: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:11 -0400
Message-ID: <1333335521-1348-22-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab2DBC7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:44 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/ipvs/ip_vs_ctl.c |  108 +++++++++++++++++++++------------------
 1 files changed, 58 insertions(+), 50 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b3afe18..964d426 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2816,17 +2816,17 @@ static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
 
 	ip_vs_copy_stats(&ustats, stats);
 
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CONNS, ustats.conns);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPKTS, ustats.inpkts);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPKTS, ustats.outpkts);
-	NLA_PUT_U64(skb, IPVS_STATS_ATTR_INBYTES, ustats.inbytes);
-	NLA_PUT_U64(skb, IPVS_STATS_ATTR_OUTBYTES, ustats.outbytes);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CPS, ustats.cps);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPPS, ustats.inpps);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPPS, ustats.outpps);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INBPS, ustats.inbps);
-	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTBPS, ustats.outbps);
-
+	if (nla_put_u32(skb, IPVS_STATS_ATTR_CONNS, ustats.conns) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_INPKTS, ustats.inpkts) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTPKTS, ustats.outpkts) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_INBYTES, ustats.inbytes) ||
+	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTBYTES, ustats.outbytes) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_CPS, ustats.cps) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_INPPS, ustats.inpps) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTPPS, ustats.outpps) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_INBPS, ustats.inbps) ||
+	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTBPS, ustats.outbps))
+		goto nla_put_failure;
 	nla_nest_end(skb, nl_stats);
 
 	return 0;
@@ -2847,23 +2847,25 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	if (!nl_service)
 		return -EMSGSIZE;
 
-	NLA_PUT_U16(skb, IPVS_SVC_ATTR_AF, svc->af);
-
+	if (nla_put_u16(skb, IPVS_SVC_ATTR_AF, svc->af))
+		goto nla_put_failure;
 	if (svc->fwmark) {
-		NLA_PUT_U32(skb, IPVS_SVC_ATTR_FWMARK, svc->fwmark);
+		if (nla_put_u32(skb, IPVS_SVC_ATTR_FWMARK, svc->fwmark))
+			goto nla_put_failure;
 	} else {
-		NLA_PUT_U16(skb, IPVS_SVC_ATTR_PROTOCOL, svc->protocol);
-		NLA_PUT(skb, IPVS_SVC_ATTR_ADDR, sizeof(svc->addr), &svc->addr);
-		NLA_PUT_U16(skb, IPVS_SVC_ATTR_PORT, svc->port);
+		if (nla_put_u16(skb, IPVS_SVC_ATTR_PROTOCOL, svc->protocol) ||
+		    nla_put(skb, IPVS_SVC_ATTR_ADDR, sizeof(svc->addr), &svc->addr) ||
+		    nla_put_u16(skb, IPVS_SVC_ATTR_PORT, svc->port))
+			goto nla_put_failure;
 	}
 
-	NLA_PUT_STRING(skb, IPVS_SVC_ATTR_SCHED_NAME, svc->scheduler->name);
-	if (svc->pe)
-		NLA_PUT_STRING(skb, IPVS_SVC_ATTR_PE_NAME, svc->pe->name);
-	NLA_PUT(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
-	NLA_PUT_U32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ);
-	NLA_PUT_U32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask);
-
+	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, svc->scheduler->name) ||
+	    (svc->pe &&
+	     nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, svc->pe->name)) ||
+	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
+	    nla_put_u32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ) ||
+	    nla_put_u32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask))
+		goto nla_put_failure;
 	if (ip_vs_genl_fill_stats(skb, IPVS_SVC_ATTR_STATS, &svc->stats))
 		goto nla_put_failure;
 
@@ -3038,21 +3040,22 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
 	if (!nl_dest)
 		return -EMSGSIZE;
 
-	NLA_PUT(skb, IPVS_DEST_ATTR_ADDR, sizeof(dest->addr), &dest->addr);
-	NLA_PUT_U16(skb, IPVS_DEST_ATTR_PORT, dest->port);
-
-	NLA_PUT_U32(skb, IPVS_DEST_ATTR_FWD_METHOD,
-		    atomic_read(&dest->conn_flags) & IP_VS_CONN_F_FWD_MASK);
-	NLA_PUT_U32(skb, IPVS_DEST_ATTR_WEIGHT, atomic_read(&dest->weight));
-	NLA_PUT_U32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold);
-	NLA_PUT_U32(skb, IPVS_DEST_ATTR_L_THRESH, dest->l_threshold);
-	NLA_PUT_U32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
-		    atomic_read(&dest->activeconns));
-	NLA_PUT_U32(skb, IPVS_DEST_ATTR_INACT_CONNS,
-		    atomic_read(&dest->inactconns));
-	NLA_PUT_U32(skb, IPVS_DEST_ATTR_PERSIST_CONNS,
-		    atomic_read(&dest->persistconns));
-
+	if (nla_put(skb, IPVS_DEST_ATTR_ADDR, sizeof(dest->addr), &dest->addr) ||
+	    nla_put_u16(skb, IPVS_DEST_ATTR_PORT, dest->port) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_FWD_METHOD,
+			(atomic_read(&dest->conn_flags) &
+			 IP_VS_CONN_F_FWD_MASK)) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_WEIGHT,
+			atomic_read(&dest->weight)) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH, dest->l_threshold) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
+			atomic_read(&dest->activeconns)) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_INACT_CONNS,
+			atomic_read(&dest->inactconns)) ||
+	    nla_put_u32(skb, IPVS_DEST_ATTR_PERSIST_CONNS,
+			atomic_read(&dest->persistconns)))
+		goto nla_put_failure;
 	if (ip_vs_genl_fill_stats(skb, IPVS_DEST_ATTR_STATS, &dest->stats))
 		goto nla_put_failure;
 
@@ -3181,10 +3184,10 @@ static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __be32 state,
 	if (!nl_daemon)
 		return -EMSGSIZE;
 
-	NLA_PUT_U32(skb, IPVS_DAEMON_ATTR_STATE, state);
-	NLA_PUT_STRING(skb, IPVS_DAEMON_ATTR_MCAST_IFN, mcast_ifn);
-	NLA_PUT_U32(skb, IPVS_DAEMON_ATTR_SYNC_ID, syncid);
-
+	if (nla_put_u32(skb, IPVS_DAEMON_ATTR_STATE, state) ||
+	    nla_put_string(skb, IPVS_DAEMON_ATTR_MCAST_IFN, mcast_ifn) ||
+	    nla_put_u32(skb, IPVS_DAEMON_ATTR_SYNC_ID, syncid))
+		goto nla_put_failure;
 	nla_nest_end(skb, nl_daemon);
 
 	return 0;
@@ -3473,21 +3476,26 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 
 		__ip_vs_get_timeouts(net, &t);
 #ifdef CONFIG_IP_VS_PROTO_TCP
-		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP, t.tcp_timeout);
-		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP_FIN,
-			    t.tcp_fin_timeout);
+		if (nla_put_u32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP,
+				t.tcp_timeout) ||
+		    nla_put_u32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP_FIN,
+				t.tcp_fin_timeout))
+			goto nla_put_failure;
 #endif
 #ifdef CONFIG_IP_VS_PROTO_UDP
-		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_UDP, t.udp_timeout);
+		if (nla_put_u32(msg, IPVS_CMD_ATTR_TIMEOUT_UDP, t.udp_timeout))
+			goto nla_put_failure;
 #endif
 
 		break;
 	}
 
 	case IPVS_CMD_GET_INFO:
-		NLA_PUT_U32(msg, IPVS_INFO_ATTR_VERSION, IP_VS_VERSION_CODE);
-		NLA_PUT_U32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
-			    ip_vs_conn_tab_size);
+		if (nla_put_u32(msg, IPVS_INFO_ATTR_VERSION,
+				IP_VS_VERSION_CODE) ||
+		    nla_put_u32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
+				ip_vs_conn_tab_size))
+			goto nla_put_failure;
 		break;
 	}
 
-- 
1.7.7.6
