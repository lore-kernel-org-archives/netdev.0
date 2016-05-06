From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: make sch_handle_ingress() drop monitor ready
Date: Fri, 06 May 2016 15:55:50 -0700
Message-ID: <1462575350.13075.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33680 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758503AbcEFWzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 18:55:52 -0400
Received: by mail-pf0-f173.google.com with SMTP id 206so54519104pfu.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 15:55:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TC_ACT_STOLEN is used when ingress traffic is mirred/redirected
to say ifb.

Packet is not dropped, but consumed.

Only TC_ACT_SHOT is a clear indication something went wrong.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/core/dev.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e98ba63fe2800c10d4d407f12d11ca8975dc1e8e..c7490339315cc0046a2da67c00a95f079e602588 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3956,9 +3956,11 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 		break;
 	case TC_ACT_SHOT:
 		qdisc_qstats_cpu_drop(cl->q);
+		kfree_skb(skb);
+		return NULL;
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
-		kfree_skb(skb);
+		consume_skb(skb);
 		return NULL;
 	case TC_ACT_REDIRECT:
 		/* skb_mac_header check was done by cls/act_bpf, so
