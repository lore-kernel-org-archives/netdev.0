From: akpm@osdl.org
Subject: [patch 2/5] small sha512 cleanup
Date: Mon, 25 Oct 2004 12:38:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410251940.i9PJeN910832@mail.osdl.org>
Cc: jmorris@redhat.com, netdev@oss.sgi.com, akpm@osdl.org,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>

Looks like open-coded be_to_cpu.  GCC produces rather poor code for this. 
be_to_cpu produces asm()s which are ~4 times shorter.

Compile-tested only.

I am not sure whether input can be 64bit-unaligned.
If it indeed can be, replace:

((u64*)(input))[I]  ->  get_unaligned( ((u64*)(input))+I )

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/crypto/sha512.c |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

diff -puN crypto/sha512.c~small-sha512-cleanup crypto/sha512.c
--- 25/crypto/sha512.c~small-sha512-cleanup	2004-10-01 21:20:42.100900176 -0700
+++ 25-akpm/crypto/sha512.c	2004-10-01 21:20:42.104899568 -0700
@@ -104,27 +104,12 @@ const u64 sha512_K[80] = {
 
 static inline void LOAD_OP(int I, u64 *W, const u8 *input)
 {
-        u64 t1  = input[(8*I)  ] & 0xff;
-        t1 <<= 8;
-        t1 |= input[(8*I)+1] & 0xff;
-        t1 <<= 8;
-        t1 |= input[(8*I)+2] & 0xff;
-        t1 <<= 8;
-        t1 |= input[(8*I)+3] & 0xff;
-        t1 <<= 8;
-        t1 |= input[(8*I)+4] & 0xff;
-        t1 <<= 8;
-        t1 |= input[(8*I)+5] & 0xff;
-        t1 <<= 8;
-        t1 |= input[(8*I)+6] & 0xff;
-        t1 <<= 8;
-        t1 |= input[(8*I)+7] & 0xff;
-        W[I] = t1;
+	W[I] = __be64_to_cpu( ((u64*)(input))[I] );
 }
 
 static inline void BLEND_OP(int I, u64 *W)
 {
-        W[I] = s1(W[I-2]) + W[I-7] + s0(W[I-15]) + W[I-16];
+	W[I] = s1(W[I-2]) + W[I-7] + s0(W[I-15]) + W[I-16];
 }
 
 static void
_
