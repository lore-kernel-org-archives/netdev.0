From: Patrick McHardy <kaber@trash.net>
Subject: ipvs 02/05: fix synchronization on connection close
Date: Tue, 15 Dec 2009 17:14:29 +0100 (MET)
Message-ID: <20091215161428.4146.67084.sendpatchset@x2.localnet>
References: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59644 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759624AbZLOQOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:14:30 -0500
In-Reply-To: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9abfe315de96aa5c9878b2f627542bc54901c6e9
Author: Xiaotian Feng <dfeng@redhat.com>
Date:   Mon Dec 14 16:38:21 2009 +0100

    ipvs: fix synchronization on connection close
    
    commit 9d3a0de makes slaves expire as they would do on the master
    with much shorter timeouts. But it introduces another problem:
    When we close a connection, on master server the connection became
    CLOSE_WAIT/TIME_WAIT, it was synced to slaves, but if master is
    finished within it's timeouts (CLOSE), it will not be synced to
    slaves. Then slaves will be kept on CLOSE_WAIT/TIME_WAIT until
    timeout reaches. Thus we should also sync with CLOSE.
    
    Cc: Wensong Zhang <wensong@linux-vs.org>
    Cc: Simon Horman <horms@verge.net.au>
    Cc: Julian Anastasov <ja@ssi.bg>
    Cc: David S. Miller <davem@davemloft.net>
    Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
    Acked-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

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
