From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: adjust skb->truesize in pskb_expand_head()
Date: Thu, 26 Jan 2017 16:21:20 -0800
Message-ID: <1485476480.5145.194.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Slava Shwartsman <slavash@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36768 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbdA0AV2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 19:21:28 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so23522052pgf.3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:21:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Slava Shwartsman reported a warning in skb_try_coalesce(), when we
detect skb->truesize is completely wrong.

In his case, issue came from IPv6 reassembly coping with malicious
datagrams, that forced various pskb_may_pull() to reallocate a bigger
skb->head than the one allocated by NIC driver before entering GRO
layer.

Current code does not change skb->truesize, leaving this burden to
callers if they care enough.

Blindly changing skb->truesize in pskb_expand_head() is not
easy, as some producers might track skb->truesize, for example
in xmit path for back pressure feedback (sk->sk_wmem_alloc)

We can detect the cases where it should be safe to change
skb->truesize :

1) skb is not attached to a socket.
2) If it is attached to a socket, destructor is sock_edemux()

My audit gave only two callers doing their own skb->truesize
manipulation.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Slava Shwartsman <slavash@mellanox.com>
---
 net/core/skbuff.c        |   14 +++++++++++---
 net/netlink/af_netlink.c |    8 +++-----
 net/wireless/util.c      |    2 --
 3 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f8dbe4a7ab46a9196c6683ce5c9c14d3d99d..6cd59da7ec583260748b9c45b99a824bcc61 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1192,10 +1192,10 @@ EXPORT_SYMBOL(__pskb_copy_fclone);
 int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		     gfp_t gfp_mask)
 {
-	int i;
-	u8 *data;
-	int size = nhead + skb_end_offset(skb) + ntail;
+	int i, osize = skb_end_offset(skb);
+	int size = osize + nhead + ntail;
 	long off;
+	u8 *data;
 
 	BUG_ON(nhead < 0);
 
@@ -1257,6 +1257,14 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
+
+	/* It is not generally safe to change skb->truesize.
+	 * For the moment, we really care of rx path, or
+	 * when skb is orphaned (not attached to a socket)
+	 */
+	if (!skb->sk || skb->destructor == sock_edemux)
+		skb->truesize += size - osize;
+
 	return 0;
 
 nofrags:
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index edcc1e19ad532641f51f6809b8c90d1e3770..7b73c7c161a9680b8691a712c31073b77896 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1210,11 +1210,9 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 		skb = nskb;
 	}
 
-	if (!pskb_expand_head(skb, 0, -delta,
-			      (allocation & ~__GFP_DIRECT_RECLAIM) |
-			      __GFP_NOWARN | __GFP_NORETRY))
-		skb->truesize -= delta;
-
+	pskb_expand_head(skb, 0, -delta,
+			 (allocation & ~__GFP_DIRECT_RECLAIM) |
+			 __GFP_NOWARN | __GFP_NORETRY);
 	return skb;
 }
 
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 1b9296882dcd6a0b585dfd604a30807e7f26..68e5f2ecee1aa22f17ab9a55eb566124e585 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -618,8 +618,6 @@ int ieee80211_data_from_8023(struct sk_buff *skb, const u8 *addr,
 
 		if (pskb_expand_head(skb, head_need, 0, GFP_ATOMIC))
 			return -ENOMEM;
-
-		skb->truesize += head_need;
 	}
 
 	if (encaps_data) {
