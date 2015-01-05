From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC rocker-net-next 2/6] net: flow: Handle error when putting a field while putting a flow
Date: Mon,  5 Jan 2015 15:50:06 +0900
Message-ID: <1420440610-20621-3-git-send-email-simon.horman@netronome.com>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:45305 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbbAEGui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 01:50:38 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so27513100pde.15
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 22:50:37 -0800 (PST)
In-Reply-To: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/core/flow_table.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 2af831e..753ebe0 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -981,8 +981,9 @@ done:
 
 int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 {
-	struct nlattr *flows, *matches;
+	struct nlattr *flows;
 	struct nlattr *actions = NULL; /* must be null to unwind */
+	struct nlattr *matches = NULL; /* must be null to unwind */
 	int err, j, i = 0;
 
 	flows = nla_nest_start(skb, NET_FLOW_FLOW);
@@ -1005,7 +1006,11 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 			if (!f->header)
 				continue;
 
-			nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);
+			err = nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);
+			if (err) {
+				nla_nest_cancel(skb, matches);
+				goto flows_put_failure;
+			}
 		}
 		nla_nest_end(skb, matches);
 	}
-- 
2.1.3
