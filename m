From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: [PATCH] net/neighbour: fix crash at dumping device-agnostic proxy
 entries
Date: Tue, 01 Dec 2015 01:14:48 +0300
Message-ID: <144892168886.1956.12514575216454077256.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35323 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214AbbK3WOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 17:14:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Proxy entries could have null pointer to net-device.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Fixes: 84920c1420e2 ("net: Allow ipv6 proxies and arp proxies be shown with iproute2")
Cc: <stable@vger.kernel.org> # v3.4
---
 net/core/neighbour.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e6af42da28d9..f18ae91b652e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2215,7 +2215,7 @@ static int pneigh_fill_info(struct sk_buff *skb, struct pneigh_entry *pn,
 	ndm->ndm_pad2    = 0;
 	ndm->ndm_flags	 = pn->flags | NTF_PROXY;
 	ndm->ndm_type	 = RTN_UNICAST;
-	ndm->ndm_ifindex = pn->dev->ifindex;
+	ndm->ndm_ifindex = pn->dev ? pn->dev->ifindex : 0;
 	ndm->ndm_state	 = NUD_NONE;
 
 	if (nla_put(skb, NDA_DST, tbl->key_len, pn->key))
@@ -2333,7 +2333,7 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		if (h > s_h)
 			s_idx = 0;
 		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next) {
-			if (dev_net(n->dev) != net)
+			if (pneigh_net(n) != net)
 				continue;
 			if (idx < s_idx)
 				goto next;
