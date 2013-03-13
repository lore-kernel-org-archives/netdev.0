From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH] net/core: fixing dst_neigh_lookup/dst_neigh_lookup_skb caused
 kernel panic
Date: Wed, 13 Mar 2013 12:00:34 +0800
Message-ID: <CAABZP2yznP5jD6Og=-ZxgAh23VpfM1BGX4OJsOb00KDeyV-jyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stable@vger.kernel.org, trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 when neighbour table is full, dst_neigh_lookup/dst_neigh_lookup_skb
will return -ENOBUFS which
is absolutely non zero, while all the code in kernel which use above
functions  assume failure only
on zero return (I did a grep), which will cause kernel panic. (for
example: https://bugzilla.kernel.org/show_bug.cgi?id=54731)

  This patch corrects above error with smallest changes to kernel source code.
Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>

diff --git a/include/net/dst.h b/include/net/dst.h
index 853cda1..d594f8b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -413,13 +413,15 @@ static inline int dst_neigh_output(struct
dst_entry *dst, struct neighbour *n,

 static inline struct neighbour *dst_neigh_lookup(const struct
dst_entry *dst, const void *daddr)
 {
-       return dst->ops->neigh_lookup(dst, NULL, daddr);
+       struct neighbour *n = dst->ops->neigh_lookup(dst, NULL, daddr);
+       return IS_ERR(n) ? NULL : n;
 }

 static inline struct neighbour *dst_neigh_lookup_skb(const struct
dst_entry *dst,
                                                     struct sk_buff *skb)
 {
-       return dst->ops->neigh_lookup(dst, skb, NULL);
+       struct neighbour *n = dst->ops->neigh_lookup(dst, skb, NULL);
+       return IS_ERR(n) ? NULL : n;
 }

 static inline void dst_link_failure(struct sk_buff *skb)
