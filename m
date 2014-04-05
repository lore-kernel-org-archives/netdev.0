From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/6] net: Allow csum_add to be provided in arch
Date: Fri, 4 Apr 2014 17:26:46 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404041714560.20552@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:35638 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbaDEA0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 20:26:48 -0400
Received: by mail-yh0-f74.google.com with SMTP id f10so595856yha.1
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 17:26:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

csum_add is really nothing more then add-with-carry which
can be implemented efficiently in some architectures.
Allow architecture to define this protected by HAVE_ARCH_CSUM_ADD.

Provide csum_add in for x86.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 arch/x86/include/asm/checksum_64.h | 7 +++++++
 include/net/checksum.h             | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index e6fd8a0..3581761 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -188,4 +188,11 @@ static inline unsigned add32_with_carry(unsigned a, unsigned b)
 	return a;
 }
 
+#define HAVE_ARCH_CSUM_ADD
+static inline __wsum csum_add(__wsum csum, __wsum addend)
+{
+	return (__force __wsum)add32_with_carry((__force unsigned)csum,
+						(__force unsigned)addend);
+}
+
 #endif /* _ASM_X86_CHECKSUM_64_H */
diff --git a/include/net/checksum.h b/include/net/checksum.h
index a28f4e0..87cb190 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -57,12 +57,14 @@ static __inline__ __wsum csum_and_copy_to_user
 }
 #endif
 
+#ifndef HAVE_ARCH_CSUM_ADD
 static inline __wsum csum_add(__wsum csum, __wsum addend)
 {
 	u32 res = (__force u32)csum;
 	res += (__force u32)addend;
 	return (__force __wsum)(res + (res < (__force u32)addend));
 }
+#endif
 
 static inline __wsum csum_sub(__wsum csum, __wsum addend)
 {
-- 
1.9.1.423.g4596e3a
