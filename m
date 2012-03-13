From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Mon, 12 Mar 2012 22:12:21 -0700
Message-ID: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47186 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917Ab2CMFMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 01:12:37 -0400
Received: by iagz16 with SMTP id z16so275544iag.19
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 22:12:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

See ffs(x) definition in arch/x86/include/asm/bitops.h

  ffs - find first set bit in word

  ffs(value) returns 0 if value is 0 or the position of the first
  set bit if value is nonzero. The first (least significant) bit
  is at position 1.

On x86_64 ffs(x) is effectively:
  Z :=3D -1
  BSFL X, Z
  return Z + 1

Since we subtract one, we effectively end up with:
  Z :=3D -1
  BSFL X, Z
  return Z

This is certainly more readable than the open coded array that
was there before, supports an easier change in the number of bands,
and is probably faster to boot (no memory lookup).

However, on other architectures ffs() might not be so pretty,
hence use a clever arithmetic hack on other archs.
Unfortunately it only support 3 bands.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/sched/sch_generic.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 67fc573e013a..935492d6a0b6 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -436,9 +436,19 @@ struct pfifo_fast_priv {
  * Convert a bitmap to the first band number where an skb is queued, w=
here:
  * 	bitmap=3D0 means there are no skbs on any band.
  * 	bitmap=3D1 means there is an skb on band 0.
- *	bitmap=3D7 means there are skbs on all 3 bands, etc.
+ * 	bitmap=3D7 means there are skbs on all 3 bands, etc.
+ *
+ * This is equivalent to ffs(i) - 1
  */
-static const int bitmap2band[] =3D {-1, 0, 1, 0, 2, 0, 1, 0};
+static inline int bitmap2band(int i)
+{
+#if defined(CONFIG_X86_64)
+	return ffs(i) - 1; /* Known to be efficient. */
+#else
+	/* For i in 0..7 returns {-1, 0, 1, 0, 2, 0, 1, 0}[i] */
+	return ((26468 >> (i+i)) & 3) - 1;
+#endif
+}
=20
 static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *p=
riv,
 					     int band)
@@ -464,7 +474,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, =
struct Qdisc *qdisc)
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 {
 	struct pfifo_fast_priv *priv =3D qdisc_priv(qdisc);
-	int band =3D bitmap2band[priv->bitmap];
+	int band =3D bitmap2band(priv->bitmap);
=20
 	if (likely(band >=3D 0)) {
 		struct sk_buff_head *list =3D band2list(priv, band);
@@ -483,7 +493,7 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qd=
isc *qdisc)
 static struct sk_buff *pfifo_fast_peek(struct Qdisc *qdisc)
 {
 	struct pfifo_fast_priv *priv =3D qdisc_priv(qdisc);
-	int band =3D bitmap2band[priv->bitmap];
+	int band =3D bitmap2band(priv->bitmap);
=20
 	if (band >=3D 0) {
 		struct sk_buff_head *list =3D band2list(priv, band);
--=20
1.7.9.4
