From: kaber@trash.net
Subject: [PATCH 1/3] netfilter: nf_ct_sip: handle non-linear skbs
Date: Thu, 20 May 2010 18:00:44 +0200
Message-ID: <1274371246-26760-2-git-send-email-kaber@trash.net>
References: <1274371246-26760-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1274371246-26760-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Handle non-linear skbs by linearizing them instead of silently failing.
Long term the helper should be fixed to either work with non-linear skbs
directly by using the string search API or work on a copy of the data.

Based on patch by Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_sip.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index b20f427..53d8922 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1393,10 +1393,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 
 	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (skb_is_nonlinear(skb)) {
-		pr_debug("Copy of skbuff not supported yet.\n");
-		return NF_ACCEPT;
-	}
+	if (unlikely(skb_linearize(skb)))
+		return NF_DROP;
 
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
@@ -1455,10 +1453,8 @@ static int sip_help_udp(struct sk_buff *skb, unsigned int protoff,
 
 	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (skb_is_nonlinear(skb)) {
-		pr_debug("Copy of skbuff not supported yet.\n");
-		return NF_ACCEPT;
-	}
+	if (unlikely(skb_linearize(skb)))
+		return NF_DROP;
 
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
-- 
1.7.0.4

