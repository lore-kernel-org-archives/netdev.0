From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 3/5] NET: ARP: allow to invalidate specific ARP entries
Date: Sun, 28 Nov 2010 03:15:34 +0200
Message-ID: <1290906936-14472-4-git-send-email-maximlevitsky@gmail.com>
References: <1290906936-14472-1-git-send-email-maximlevitsky@gmail.com>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35883 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403Ab0K1BPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 20:15:54 -0500
Received: by bwz15 with SMTP id 15so2883359bwz.19
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 17:15:53 -0800 (PST)
In-Reply-To: <1290906936-14472-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 over firewire needs to be able to remove ARP entries
from cache that belong to nodes that are removed, because
IPv4 over firewire uses ARP packets for private information
about nodes.

This information becames invalid on node removal, thus
as soon as it is connected again, ARP packet should be sent
to it which is not done due to valid cache entry.

CC: netdev@vger.kernel.org
Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 include/net/arp.h |    1 +
 net/ipv4/arp.c    |   29 ++++++++++++++++++-----------
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index f4cf6ce..91f0568 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -25,5 +25,6 @@ extern struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 				  const unsigned char *src_hw,
 				  const unsigned char *target_hw);
 extern void arp_xmit(struct sk_buff *skb);
+int arp_invalidate(struct net_device *dev, __be32 ip);
 
 #endif	/* _ARP_H */
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d8e540c..35b1272 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1142,6 +1142,23 @@ static int arp_req_get(struct arpreq *r, struct net_device *dev)
 	return err;
 }
 
+int arp_invalidate(struct net_device *dev, __be32 ip)
+{
+	int err = -ENXIO;
+	struct neighbour *neigh = neigh_lookup(&arp_tbl, &ip, dev);
+
+	if (neigh) {
+		if (neigh->nud_state & ~NUD_NOARP)
+			err = neigh_update(neigh, NULL, NUD_FAILED,
+					   NEIGH_UPDATE_F_OVERRIDE|
+					   NEIGH_UPDATE_F_ADMIN);
+		neigh_release(neigh);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(arp_invalidate);
+
 static int arp_req_delete_public(struct net *net, struct arpreq *r,
 		struct net_device *dev)
 {
@@ -1162,7 +1179,6 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 {
 	int err;
 	__be32 ip;
-	struct neighbour *neigh;
 
 	if (r->arp_flags & ATF_PUBL)
 		return arp_req_delete_public(net, r, dev);
@@ -1180,16 +1196,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 		if (!dev)
 			return -EINVAL;
 	}
-	err = -ENXIO;
-	neigh = neigh_lookup(&arp_tbl, &ip, dev);
-	if (neigh) {
-		if (neigh->nud_state & ~NUD_NOARP)
-			err = neigh_update(neigh, NULL, NUD_FAILED,
-					   NEIGH_UPDATE_F_OVERRIDE|
-					   NEIGH_UPDATE_F_ADMIN);
-		neigh_release(neigh);
-	}
-	return err;
+	return arp_invalidate(dev, ip);
 }
 
 /*
-- 
1.7.1

