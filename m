From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3] fast_hash: clobber registers correctly for inline function use
Date: Fri, 14 Nov 2014 16:17:31 +0100
Message-ID: <6751d6af4301f283134a419385f65dfcf92a44ab.1415978153.git.hannes@stressinduktion.org>
References: <1415976656.17262.41.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: ogerlitz@mellanox.com, pshelar@nicira.com, jesse@nicira.com,
	jay.vosburgh@canonical.com, discuss@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:39889 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965485AbaKNPRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 10:17:38 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 9921220C65
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 10:17:37 -0500 (EST)
In-Reply-To: <1415976656.17262.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the arch_fast_hash call gets inlined we need to tell gcc which
registers are clobbered with. rhashtable was fine, because it used
arch_fast_hash via function pointer and thus the compiler took care of
that. In case of openvswitch the call got inlined and arch_fast_hash
touched registeres which gcc didn't know about.

Also don't use conditional compilation inside arguments, as this confuses
sparse.

Fixes: e5a2c899957659c ("fast_hash: avoid indirect function calls")
Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
Cc: Pravin Shelar <pshelar@nicira.com>
Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---


v2)
After studying gcc documentation again, it occured to me that I need to
specificy all input operands in the clobber section, too. Otherwise gcc
can expect that the inline assembler section won't modify the inputs,
which is not true.

v3)
added Fixes tag

Bye,
Hannes

 arch/x86/include/asm/hash.h | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
index a881d78..a25c45a 100644
--- a/arch/x86/include/asm/hash.h
+++ b/arch/x86/include/asm/hash.h
@@ -23,11 +23,15 @@ static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
 {
 	u32 hash;
 
-	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
 #ifdef CONFIG_X86_64
-			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
+	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
+			 "=a" (hash), "D" (data), "S" (len), "d" (seed)
+			 : "rdi", "rsi", "rdx", "rcx", "r8", "r9", "r10", "r11",
+			   "cc", "memory");
 #else
-			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
+	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
+			 "=a" (hash), "a" (data), "d" (len), "c" (seed)
+			 : "edx", "ecx", "cc", "memory");
 #endif
 	return hash;
 }
@@ -36,11 +40,15 @@ static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
 {
 	u32 hash;
 
-	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
 #ifdef CONFIG_X86_64
-			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
+	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
+			 "=a" (hash), "D" (data), "S" (len), "d" (seed)
+			 : "rdi", "rsi", "rdx", "rcx", "r8", "r9", "r10", "r11",
+			   "cc", "memory");
 #else
-			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
+	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
+			 "=a" (hash), "a" (data), "d" (len), "c" (seed)
+			 : "edx", "ecx", "cc", "memory");
 #endif
 	return hash;
 }
-- 
1.9.3
