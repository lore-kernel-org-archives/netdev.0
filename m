From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/7] ipvs: add missing ip_vs_pe_put in sync code
Date: Thu,  5 Mar 2015 21:48:45 +0100
Message-ID: <1425588529-4573-4-git-send-email-pablo@netfilter.org>
References: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34452 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758663AbbCEUpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 15:45:20 -0500
In-Reply-To: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

ip_vs_conn_fill_param_sync() gets in param.pe a module
reference for persistence engine from __ip_vs_pe_getbyname()
but forgets to put it. Problem occurs in backup for
sync protocol v1 (2.6.39).

Also, pe_data usually comes in sync messages for
connection templates and ip_vs_conn_new() copies
the pointer only in this case. Make sure pe_data
is not leaked if it comes unexpectedly for normal
connections. Leak can happen only if bogus messages
are sent to backup server.

Fixes: fe5e7a1efb66 ("IPVS: Backup, Adding Version 1 receive capability")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index c47ffd7..d93ceeb 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -896,6 +896,8 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 			IP_VS_DBG(2, "BACKUP, add new conn. failed\n");
 			return;
 		}
+		if (!(flags & IP_VS_CONN_F_TEMPLATE))
+			kfree(param->pe_data);
 	}
 
 	if (opt)
@@ -1169,6 +1171,7 @@ static inline int ip_vs_proc_sync_conn(struct net *net, __u8 *p, __u8 *msg_end)
 				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL)
 				);
 #endif
+	ip_vs_pe_put(param.pe);
 	return 0;
 	/* Error exit */
 out:
-- 
1.7.10.4
