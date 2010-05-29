From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_nat: fix the wrong checksum when addr isn't in old_addr/mask
Date: Sat, 29 May 2010 18:41:51 +0800
Message-ID: <1275129711-21486-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fix the wrong checksum when addr isn't in old_addr/mask

When addr isn't in old_addr/mask we don't do SNAT or DNAT, and we should not
update the checksum too.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_nat.c |   32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index d885ba3..f9b12a9 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -142,24 +142,25 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	else
 		addr = iph->daddr;
 
-	if (!((old_addr ^ addr) & mask)) {
-		if (skb_cloned(skb) &&
-		    !skb_clone_writable(skb, sizeof(*iph)) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
-			goto drop;
+	if ((old_addr ^ addr) & mask)
+		goto out;
 
-		new_addr &= mask;
-		new_addr |= addr & ~mask;
+	if (skb_cloned(skb) &&
+	    !skb_clone_writable(skb, sizeof(*iph)) &&
+	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		goto drop;
 
-		/* Rewrite IP header */
-		iph = ip_hdr(skb);
-		if (egress)
-			iph->saddr = new_addr;
-		else
-			iph->daddr = new_addr;
+	new_addr &= mask;
+	new_addr |= addr & ~mask;
 
-		csum_replace4(&iph->check, addr, new_addr);
-	}
+	/* Rewrite IP header */
+	iph = ip_hdr(skb);
+	if (egress)
+		iph->saddr = new_addr;
+	else
+		iph->daddr = new_addr;
+
+	csum_replace4(&iph->check, addr, new_addr);
 
 	ihl = iph->ihl * 4;
 
@@ -247,6 +248,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 		break;
 	}
 
+out:
 	return action;
 
 drop:
