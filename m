From: akpm@osdl.org
Subject: [patch 3/5] reduce sha512_transform() stack usage, speedup
Date: Mon, 25 Oct 2004 12:38:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410251940.i9PJeP910837@mail.osdl.org>
Cc: jmorris@redhat.com, netdev@oss.sgi.com, akpm@osdl.org,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>

Patch moves large temporary u64 W[80] from stack to ctx struct:

* reduces stack usage by 640 bytes
* saves one 640-byte memset() per sha512_transform()
  (we still do it after *all* iterations are done)
* quite unexpectedly saves 1.6k of code on i386
  because stack offsets now fit into 8bits
  and many stack addressing insns got 3 bytes smaller:

# size sha512.o.org sha512.o
text       data     bss     dec     hex filename
8281        372       0    8653    21cd sha512.o.org
6649        372       0    7021    1b6d sha512.o

# objdump -d sha512.o.org | cut -b9- >sha512.d.org
# objdump -d sha512.o | cut -b9- >sha512.d
# diff -u sha512.d.org sha512.d
[snip]
 :      8b 4b 28                mov    0x28(%ebx),%ecx
 :      8b 5b 2c                mov    0x2c(%ebx),%ebx
-:      89 8d 44 fd ff ff       mov    %ecx,0xfffffd44(%ebp)
-:      89 9d 48 fd ff ff       mov    %ebx,0xfffffd48(%ebp)
-:      89 9d f4 fc ff ff       mov    %ebx,0xfffffcf4(%ebp)
+:      89 4d c4                mov    %ecx,0xffffffc4(%ebp)
+:      89 5d c8                mov    %ebx,0xffffffc8(%ebp)
+:      89 9d 64 ff ff ff       mov    %ebx,0xffffff64(%ebp)
 :      8b 5d 08                mov    0x8(%ebp),%ebx
-:      89 8d f0 fc ff ff       mov    %ecx,0xfffffcf0(%ebp)
+:      89 8d 60 ff ff ff       mov    %ecx,0xffffff60(%ebp)
 :      8b 42 30                mov    0x30(%edx),%eax
 :      8b 52 34                mov    0x34(%edx),%edx

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/crypto/sha512.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff -puN crypto/sha512.c~reduce-sha512_transform-stack-usage-speedup crypto/sha512.c
--- 25/crypto/sha512.c~reduce-sha512_transform-stack-usage-speedup	2004-10-01 21:20:45.102443872 -0700
+++ 25-akpm/crypto/sha512.c	2004-10-01 21:20:45.106443264 -0700
@@ -30,6 +30,7 @@ struct sha512_ctx {
 	u64 state[8];
 	u32 count[4];
 	u8 buf[128];
+	u64 W[80];
 };
 
 static inline u64 Ch(u64 x, u64 y, u64 z)
@@ -113,10 +114,9 @@ static inline void BLEND_OP(int I, u64 *
 }
 
 static void
-sha512_transform(u64 *state, const u8 *input)
+sha512_transform(u64 *state, u64 *W, const u8 *input)
 {
 	u64 a, b, c, d, e, f, g, h, t1, t2;
-	u64 W[80];
 
 	int i;
 
@@ -157,7 +157,6 @@ sha512_transform(u64 *state, const u8 *i
 
 	/* erase our data */
 	a = b = c = d = e = f = g = h = t1 = t2 = 0;
-	memset(W, 0, 80 * sizeof(u64));
 }
 
 static void
@@ -215,10 +214,10 @@ sha512_update(void *ctx, const u8 *data,
 	/* Transform as many times as possible. */
 	if (len >= part_len) {
 		memcpy(&sctx->buf[index], data, part_len);
-		sha512_transform(sctx->state, sctx->buf);
+		sha512_transform(sctx->state, sctx->W, sctx->buf);
 
 		for (i = part_len; i + 127 < len; i+=128)
-			sha512_transform(sctx->state, &data[i]);
+			sha512_transform(sctx->state, sctx->W, &data[i]);
 
 		index = 0;
 	} else {
@@ -227,6 +226,9 @@ sha512_update(void *ctx, const u8 *data,
 
 	/* Buffer remaining input */
 	memcpy(&sctx->buf[index], &data[i], len - i);
+
+	/* erase our data */
+	memset(sctx->W, 0, sizeof(sctx->W));
 }
 
 static void
_
