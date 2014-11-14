From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] fast_hash: clobber registers correctly for inline function use
Date: Fri, 14 Nov 2014 15:06:55 +0100
Message-ID: <4086c7bc9f7f9e8e2de9656c9e27ef1e71bb6423.1415973706.git.hannes@stressinduktion.org>
Cc: ogerlitz@mellanox.com, pshelar@nicira.com, jesse@nicira.com,
	jay.vosburgh@canonical.com, discuss@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38587 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755086AbaKNOHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 09:07:03 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 7C8A6209B8
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 09:07:02 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the arch_fast_hash call gets inlined we need to tell gcc which
registers are clobbered with. Most callers where fine, as rhashtable
used arch_fast_hash via function pointer and thus the compiler took care
of that. In case of openvswitch the call got inlined and arch_fast_hash
touched registeres which gcc didn't know about.

Also don't use conditional compilation inside arguments, as this confuses
sparse.

Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
Cc: Pravin Shelar <pshelar@nicira.com>
Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 arch/x86/include/asm/hash.h | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
index a881d78..771cee0 100644
--- a/arch/x86/include/asm/hash.h
+++ b/arch/x86/include/asm/hash.h
@@ -23,11 +23,14 @@ static inline u32 arch_fast_hash(const void *data, u32 len, u32 seed)
 {
 	u32 hash;
 
-	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
 #ifdef CONFIG_X86_64
-			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
+	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
+			 "=a" (hash), "D" (data), "S" (len), "d" (seed)
+			 : "rcx", "r8", "r9", "r10", "r11", "cc", "memory");
 #else
-			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
+	alternative_call(__jhash, __intel_crc4_2_hash, X86_FEATURE_XMM4_2,
+			 "=a" (hash), "a" (data), "d" (len), "c" (seed)
+			 : "cc", "memory");
 #endif
 	return hash;
 }
@@ -36,11 +39,14 @@ static inline u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
 {
 	u32 hash;
 
-	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
 #ifdef CONFIG_X86_64
-			 "=a" (hash), "D" (data), "S" (len), "d" (seed));
+	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
+			 "=a" (hash), "D" (data), "S" (len), "d" (seed)
+			 : "rcx", "r8", "r9", "r10", "r11", "cc", "memory");
 #else
-			 "=a" (hash), "a" (data), "d" (len), "c" (seed));
+	alternative_call(__jhash2, __intel_crc4_2_hash2, X86_FEATURE_XMM4_2,
+			 "=a" (hash), "a" (data), "d" (len), "c" (seed)
+			 : "cc", "memory");
 #endif
 	return hash;
 }
-- 
1.9.3
