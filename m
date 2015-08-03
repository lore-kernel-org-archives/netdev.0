From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 1/2] lwtunnel: set skb protocol and dev
Date: Mon, 3 Aug 2015 17:39:20 +0100
Message-ID: <1438619961-15919-2-git-send-email-rshearma@brocade.com>
References: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:22612 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751947AbbHCQk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 12:40:29 -0400
In-Reply-To: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the locally-generated packet path skb->protocol may not be set and
this is required for the lwtunnel encap in order to get the lwtstate.

This would otherwise have been set by ip_output or ip6_output so set
skb->protocol prior to calling the lwtunnel encap
function. Additionally set skb->dev in case it is needed further down
the transmit path.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/core/lwtunnel.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index c240c895b319..5d6d8e3d450a 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -215,8 +215,12 @@ int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
 	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
 	struct lwtunnel_state *lwtstate = NULL;
 
-	if (rt)
+	if (rt) {
 		lwtstate = rt->rt6i_lwtstate;
+		skb->dev = rt->dst.dev;
+	}
+
+	skb->protocol = htons(ETH_P_IPV6);
 
 	return __lwtunnel_output(sk, skb, lwtstate);
 }
@@ -227,8 +231,12 @@ int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
 	struct rtable *rt = (struct rtable *)skb_dst(skb);
 	struct lwtunnel_state *lwtstate = NULL;
 
-	if (rt)
+	if (rt) {
 		lwtstate = rt->rt_lwtstate;
+		skb->dev = rt->dst.dev;
+	}
+
+	skb->protocol = htons(ETH_P_IP);
 
 	return __lwtunnel_output(sk, skb, lwtstate);
 }
-- 
2.1.4
