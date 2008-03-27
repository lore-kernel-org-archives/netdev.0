From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/7] [NET]: uninline skb_put, de-bloats a lot
Date: Thu, 27 Mar 2008 14:38:00 +0200
Message-ID: <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36880 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757077AbYC0MiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:38:09 -0400
In-Reply-To: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allyesconfig (v2.6.24-mm1):

~500 files changed
=2E..
 869 funcs, 198 +, 111003 -, diff: -110805 --- skb_put
  skb_put                       | +104

Without number of debug related CONFIGs (v2.6.25-rc2-mm1):

-60744  855 funcs, 861 +, 61605 -, diff: -60744 --- skb_put
  skb_put                       |  +57

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h |   21 +--------------------
 net/core/skbuff.c      |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7beb239..f085955 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -892,6 +892,7 @@ static inline void skb_set_tail_pointer(struct sk_b=
uff *skb, const int offset)
 /*
  *	Add data to an sk_buff
  */
+extern unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned i=
nt len)
 {
 	unsigned char *tmp =3D skb_tail_pointer(skb);
@@ -901,26 +902,6 @@ static inline unsigned char *__skb_put(struct sk_b=
uff *skb, unsigned int len)
 	return tmp;
 }
=20
-/**
- *	skb_put - add data to a buffer
- *	@skb: buffer to use
- *	@len: amount of data to add
- *
- *	This function extends the used data area of the buffer. If this wou=
ld
- *	exceed the total buffer size the kernel will panic. A pointer to th=
e
- *	first byte of the extra data is returned.
- */
-static inline unsigned char *skb_put(struct sk_buff *skb, unsigned int=
 len)
-{
-	unsigned char *tmp =3D skb_tail_pointer(skb);
-	SKB_LINEAR_ASSERT(skb);
-	skb->tail +=3D len;
-	skb->len  +=3D len;
-	if (unlikely(skb->tail > skb->end))
-		skb_over_panic(skb, len, current_text_addr());
-	return tmp;
-}
-
 static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned =
int len)
 {
 	skb->data -=3D len;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0d0fd28..3402eca 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -857,6 +857,27 @@ free_skb:
 	return err;
 }
=20
+/**
+ *	skb_put - add data to a buffer
+ *	@skb: buffer to use
+ *	@len: amount of data to add
+ *
+ *	This function extends the used data area of the buffer. If this wou=
ld
+ *	exceed the total buffer size the kernel will panic. A pointer to th=
e
+ *	first byte of the extra data is returned.
+ */
+unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
+{
+	unsigned char *tmp =3D skb_tail_pointer(skb);
+	SKB_LINEAR_ASSERT(skb);
+	skb->tail +=3D len;
+	skb->len  +=3D len;
+	if (unlikely(skb->tail > skb->end))
+		skb_over_panic(skb, len, __builtin_return_address(0));
+	return tmp;
+}
+EXPORT_SYMBOL(skb_put);
+
 /* Trims skb to length len. It can change skb pointers.
  */
=20
--=20
1.5.2.2

