From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch v2] arp: fix a regression in arp_solicit()
Date: Mon, 24 Dec 2012 09:23:16 +0800
Message-ID: <1356312196-23185-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Sedat Dilek <sedat.dilek@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:46518 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab2LXBXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 20:23:35 -0500
Received: by mail-pb0-f50.google.com with SMTP id wz7so3710357pbc.23
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2012 17:23:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

Sedat reported the following commit caused a regression:

commit 9650388b5c56578fdccc79c57a8c82fb92b8e7f1
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Dec 21 07:32:10 2012 +0000

    ipv4: arp: fix a lockdep splat in arp_solicit

This is due to the 6th parameter of arp_send() needs to be NULL
for the broadcast case, the above commit changed it to an all-zero
array by mistake.

Reported-by: Sedat Dilek <sedat.dilek@gmail.com>
Tested-by: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1169ed4..9547a273 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -321,7 +321,7 @@ static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb)
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
 	__be32 saddr = 0;
-	u8 dst_ha[MAX_ADDR_LEN];
+	u8 dst_ha[MAX_ADDR_LEN], *dst_hw = NULL;
 	struct net_device *dev = neigh->dev;
 	__be32 target = *(__be32 *)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
@@ -364,8 +364,8 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		if (!(neigh->nud_state & NUD_VALID))
 			pr_debug("trying to ucast probe in NUD_INVALID\n");
 		neigh_ha_snapshot(dst_ha, neigh, dev);
+		dst_hw = dst_ha;
 	} else {
-		memset(dst_ha, 0, dev->addr_len);
 		probes -= neigh->parms->app_probes;
 		if (probes < 0) {
 #ifdef CONFIG_ARPD
@@ -376,7 +376,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	}
 
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
-		 dst_ha, dev->dev_addr, NULL);
+		 dst_hw, dev->dev_addr, NULL);
 }
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
