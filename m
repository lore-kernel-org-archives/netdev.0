From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 5/8] llc: use limited socket backlog
Date: Wed,  3 Mar 2010 14:35:08 +0800
Message-ID: <1267598111-12503-5-git-send-email-yi.zhu@intel.com>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-3-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65441 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754518Ab0CCGdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 01:33:38 -0500
In-Reply-To: <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make llc adapt to the limited socket backlog change.

Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/llc/llc_c_ac.c |    2 +-
 net/llc/llc_conn.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
index 019c780..86d6985 100644
--- a/net/llc/llc_c_ac.c
+++ b/net/llc/llc_c_ac.c
@@ -1437,7 +1437,7 @@ static void llc_process_tmr_ev(struct sock *sk, struct sk_buff *skb)
 			llc_conn_state_process(sk, skb);
 		else {
 			llc_set_backlog_type(skb, LLC_EVENT);
-			sk_add_backlog(sk, skb);
+			__sk_add_backlog(sk, skb);
 		}
 	}
 }
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index a8dde9b..a12144d 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -827,7 +827,8 @@ void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb)
 	else {
 		dprintk("%s: adding to backlog...\n", __func__);
 		llc_set_backlog_type(skb, LLC_PACKET);
-		sk_add_backlog(sk, skb);
+		if (sk_add_backlog(sk, skb))
+			goto drop_unlock;
 	}
 out:
 	bh_unlock_sock(sk);
-- 
1.6.3.3

