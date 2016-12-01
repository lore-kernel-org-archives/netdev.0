From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] arp: avoid sending ucast probes to 00:00:00:00:00:00
Date: Thu,  1 Dec 2016 14:56:34 -0800
Message-ID: <1480632994-12128-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33038 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbcLAW4o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 17:56:44 -0500
Received: by mail-pf0-f193.google.com with SMTP id 144so12497145pfv.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 14:56:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

If initial broadcast probe(s) is/are lost, the neigh entry wont have
valid address of the neighbour. In a situation like this, the fall
back should be to send a broadcast probe, however the code logic
continues sending ucast probes to 00:00:00:00:00:00. The default value
of ucast probes is 3 so system usually recovers after three such probes
but if the value configured is larger it takes those many probes
(a probe is sent every second in default config) / seconds to recover
making machine not-available on the network.

This patch just ensures that the unicast address is not NULL otherwise
falls back to sending broadcast probe.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/ipv4/arp.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 89a8cac4726a..56fb33d5ed31 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -330,6 +330,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
 	__be32 saddr = 0;
 	u8 dst_ha[MAX_ADDR_LEN], *dst_hw = NULL;
+	u8 null_dev_hw_addr[MAX_ADDR_LEN];
 	struct net_device *dev = neigh->dev;
 	__be32 target = *(__be32 *)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
@@ -371,10 +372,12 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
 	if (probes < 0) {
+		memset(&null_dev_hw_addr, 0, dev->addr_len);
 		if (!(neigh->nud_state & NUD_VALID))
 			pr_debug("trying to ucast probe in NUD_INVALID\n");
 		neigh_ha_snapshot(dst_ha, neigh, dev);
-		dst_hw = dst_ha;
+		if (memcmp(&dst_ha, &null_dev_hw_addr, dev->addr_len) != 0)
+			dst_hw = dst_ha;
 	} else {
 		probes -= NEIGH_VAR(neigh->parms, APP_PROBES);
 		if (probes < 0) {
-- 
2.8.0.rc3.226.g39d4020
