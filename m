From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] ipvs: fix synchronization on connection close
Date: Thu, 10 Dec 2009 16:41:42 +0800
Message-ID: <1260434502-14166-1-git-send-email-dfeng@redhat.com>
Cc: linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255AbZLJIlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 03:41:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9d3a0de makes slaves expire as they would do on the master
with much shorter timeouts. But it introduces another problem:
When we close a connection, on master server the connection became
CLOSE_WAIT/TIME_WAIT, it was synced to slaves, but if master is
finished within it's timeouts (CLOSE), it will not be synced to
slaves. Then slaves will be kept on CLOSE_WAIT/TIME_WAIT until
timeout reaches. Thus we should also sync with CLOSE.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David S. Miller <davem@davemloft.net>
---
 net/netfilter/ipvs/ip_vs_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b95699f..847ffca 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1366,6 +1366,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	       == sysctl_ip_vs_sync_threshold[0])) ||
 	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
 	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
+	       (cp->state == IP_VS_TCP_S_CLOSE) ||
 	       (cp->state == IP_VS_TCP_S_CLOSE_WAIT) ||
 	       (cp->state == IP_VS_TCP_S_TIME_WAIT)))))
 		ip_vs_sync_conn(cp);
-- 
1.6.5.2

