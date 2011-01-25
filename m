From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: remove tests on 64bit platforms
Date: Tue, 25 Jan 2011 12:21:38 +0800
Message-ID: <1295929298-13163-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37830 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab1AYEWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 23:22:16 -0500
Received: by iwn9 with SMTP id 9so4708658iwn.19
        for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 20:22:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 64bit platforms, >31 bit shifting of a unsigned long variable is
valid, so we can remove the related boundary tests, which may slow
down the CPU if branch prediction fails.

The size of text becomes smaller:
before:
   text	   data	    bss	    dec	    hex	filename
  15721	     16	     16	  15753	   3d89	net/ipv4/fib_trie.o
after:
   text	   data	    bss	    dec	    hex	filename
  15656	     16	     16	  15688	   3d48	net/ipv4/fib_trie.o

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/fib_trie.c |    8 ++++++++
 1 file changed, 8 insertions(+)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 0f28034..95c8bb3 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -219,15 +219,23 @@ static inline int tnode_child_length(const struct tnode *tn)
 
 static inline t_key mask_pfx(t_key k, unsigned short l)
 {
+#if BITS_PER_LONG > 32
+	return ((u64)k) >> (KEYLENGTH-l) << (KEYLENGTH-l);
+#else
 	return (l == 0) ? 0 : k >> (KEYLENGTH-l) << (KEYLENGTH-l);
+#endif
 }
 
 static inline t_key tkey_extract_bits(t_key a, int offset, int bits)
 {
+#if BITS_PER_LONG > 32
+	return (t_key)((u64)a << offset) >> (KEYLENGTH - bits);
+#else
 	if (offset < KEYLENGTH)
 		return ((t_key)(a << offset)) >> (KEYLENGTH - bits);
 	else
 		return 0;
+#endif
 }
 
 static inline int tkey_equals(t_key a, t_key b)
