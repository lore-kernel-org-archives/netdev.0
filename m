From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net-next panic in ovs call to arch_fast_hash2 since e5a2c899
Date: Fri, 14 Nov 2014 12:10:15 +0100
Message-ID: <1415963415.15154.6.camel@localhost>
References: <12086.1415931332@famine>
	 <20141113.214549.1520205472319716774.davem@davemloft.net>
	 <12872.1415941444@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	discuss@openvswitch.org, pshelar@nicira.com, ogerlitz@mellanox.com
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:59868 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934378AbaKNLKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 06:10:18 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 8405B209B1
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 06:10:17 -0500 (EST)
In-Reply-To: <12872.1415941444@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

On Do, 2014-11-13 at 21:04 -0800, Jay Vosburgh wrote:
> 	[ adding Hannes to Cc, which I should've done initially ]
> 
> David Miller <davem@davemloft.net> wrote:
> 
> >From: Jay Vosburgh <jay.vosburgh@canonical.com>
> >Date: Thu, 13 Nov 2014 18:15:32 -0800
> >
> >> 	The "have feature" function, __intel_crc4_2_hash2, does not
> >> clobber %r8, and so the call does not panic on a system with
> >> X86_FEATURE_XMM4_2, although I'm not sure if that's a deliberate
> >> compiler action or just happenstance because __intel_crc4_2_hash2 uses
> >> fewer registers than __jhash2.
> >
> >Perhaps alternative calls can only be used with assembler routines
> >that use specific calling conventions, and they therefore generally
> >don't work with C functions?
> 
> 	I don't know the answer to that, but a quick search suggests
> that arch_fast_hash and arch_fast_hash2 (both added by commit e5a2c899)
> may be the only cases of alternative calls that aren't supplying either
> single instructions or assembly language functions.
> 
> 	From looking at how the alternative calls are implemented (code
> patching at boot or module load time from a table stored in a special
> section of the object file), I'm skeptical that the compiler could know
> what's the right thing to do.
> 
> 	Hannes, can you shed any light on this?

Unfortunately I only tested this code with rhashtable, which itself
takes a function pointer to arch_fast_hash and thus doesn't need to care
about clobbering so much. As a first step, I am currently testing this
patch as a first step and check thoroughly. Thanks for the report:

diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
index a881d78..1b32c82 100644
--- a/arch/x86/include/asm/hash.h
+++ b/arch/x86/include/asm/hash.h
@@ -4,45 +4,12 @@
 #include <linux/cpufeature.h>
 #include <asm/alternative.h>
 
-u32 __intel_crc4_2_hash(const void *data, u32 len, u32 seed);
-u32 __intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed);
-
-/*
- * non-inline versions of jhash so gcc does not need to generate
- * duplicate code in every object file
- */
-u32 __jhash(const void *data, u32 len, u32 seed);
-u32 __jhash2(const u32 *data, u32 len, u32 seed);
-
 /*
  * for documentation of these functions please look into
  * <include/asm-generic/hash.h>
  */
 
-static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
-{
-       u32 hash;
-
-       alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
-#ifdef CONFIG_X86_64
-                        "=a" (hash), "D" (data), "S" (len), "d" (seed));
-#else
-                        "=a" (hash), "a" (data), "d" (len), "c" (seed));
-#endif
-       return hash;
-}
-
-static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
-{
-       u32 hash;
-
-       alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
-#ifdef CONFIG_X86_64
-                        "=a" (hash), "D" (data), "S" (len), "d" (seed));
-#else
-                        "=a" (hash), "a" (data), "d" (len), "c" (seed));
-#endif
-       return hash;
-}
+u32 arch_fast_hash(const void *data, u32 len, u32 seed);
+u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed);
 
 #endif /* __ASM_X86_HASH_H */
diff --git a/arch/x86/lib/hash.c b/arch/x86/lib/hash.c
index e143271..a0a7a7e 100644
--- a/arch/x86/lib/hash.c
+++ b/arch/x86/lib/hash.c
@@ -38,7 +38,7 @@
 #include <linux/hash.h>
 #include <linux/jhash.h>
 
-static inline u32 crc32_u32(u32 crc, u32 val)
+static u32 crc32_u32(u32 crc, u32 val)
 {
 #ifdef CONFIG_AS_CRC32
        asm ("crc32l %1,%0\n" : "+r" (crc) : "rm" (val));
@@ -71,7 +71,6 @@ u32 __intel_crc4_2_hash(const void *data, u32 len, u32 seed)
 
        return seed;
 }
-EXPORT_SYMBOL(__intel_crc4_2_hash);
 
 u32 __intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed)
 {
@@ -82,16 +81,45 @@ u32 __intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed)
 
        return seed;
 }
-EXPORT_SYMBOL(__intel_crc4_2_hash2);
 
 u32 __jhash(const void *data, u32 len, u32 seed)
 {
        return jhash(data, len, seed);
 }
-EXPORT_SYMBOL(__jhash);
 
 u32 __jhash2(const u32 *data, u32 len, u32 seed)
 {
        return jhash2(data, len, seed);
 }
-EXPORT_SYMBOL(__jhash2);
+
+noinline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
+{
+       u32 hash;
+
+
+#ifdef CONFIG_X86_64
+       alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
+                        "=a" (hash), "D" (data), "S" (len), "d" (seed));
+#else
+       alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
+                        "=a" (hash), "a" (data), "d" (len), "c" (seed));
+#endif
+       return hash;
+}
+EXPORT_SYMBOL(arch_fast_hash);
+
+noinline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
+{
+       u32 hash;
+
+
+#ifdef CONFIG_X86_64
+       alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
+                        "=a" (hash), "D" (data), "S" (len), "d" (seed));
+#else
+       alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
+                        "=a" (hash), "a" (data), "d" (len), "c" (seed));
+#endif
+       return hash;
+}
+EXPORT_SYMBOL(arch_fast_hash2);
