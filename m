From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] act_nat: fix the wrong checksum when addr isn't in old_addr/mask
Date: Sun, 30 May 2010 08:26:59 +0800
Message-ID: <1275179219-10424-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:50969 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757008Ab0E3A1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 20:27:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix the wrong checksum when addr isn't in old_addr/mask

For TCP and UDP packets, when addr isn't in old_addr/mask we don't do SNAT or
DNAT, and we should not update layer 4 checksum.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_nat.c |    4 ++++
 1 file changed, 4 insertions(+)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index d885ba3..5709494 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -159,6 +159,9 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 			iph->daddr = new_addr;
 
 		csum_replace4(&iph->check, addr, new_addr);
+	} else if ((iph->frag_off & htons(IP_OFFSET)) ||
+		   iph->protocol != IPPROTO_ICMP) {
+		goto out;
 	}
 
 	ihl = iph->ihl * 4;
@@ -247,6 +250,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 		break;
 	}
 
+out:
 	return action;
 
 drop:
