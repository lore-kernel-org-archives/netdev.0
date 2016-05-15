From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] net: also make sch_handle_egress() drop monitor ready
Date: Sun, 15 May 2016 23:28:29 +0200
Message-ID: <94bae5636d86c039a0cfee3aa4876fc7bcde2eef.1463347152.git.daniel@iogearbox.net>
Cc: eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44756 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbcEOV2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 17:28:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up for 8a3a4c6e7b34 ("net: make sch_handle_ingress() drop
monitor ready") to also make the egress side drop monitor ready.

Also here only TC_ACT_SHOT is a clear indication that something
went wrong. Hence don't provide false positives to drop monitors
such as 'perf record -e skb:kfree_skb ...'.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/dev.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 12436d1..904ff43 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3186,12 +3186,12 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 	case TC_ACT_SHOT:
 		qdisc_qstats_cpu_drop(cl->q);
 		*ret = NET_XMIT_DROP;
-		goto drop;
+		kfree_skb(skb);
+		return NULL;
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
 		*ret = NET_XMIT_SUCCESS;
-drop:
-		kfree_skb(skb);
+		consume_skb(skb);
 		return NULL;
 	case TC_ACT_REDIRECT:
 		/* No need to push/pop skb's mac_header here on egress! */
-- 
1.9.3
