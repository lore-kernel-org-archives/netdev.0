From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] vxlan: fix sparse warnings
Date: Mon, 21 Mar 2016 17:39:18 +0100
Message-ID: <c100b5ed75967714ab32287f37d250b729753282.1458578309.git.jbenc@redhat.com>
Cc: kbuild test robot <fengguang.wu@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755825AbcCUQjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 12:39:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse reports false positives for the header manipulation inlines. Annotate
them correctly.

Tested by sparse on a little endian and big endian machine.

Fixes: 54bfd872bf16d ("vxlan: keep flags and vni in network byte order")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
As a side note, I tried to simplify all of these functions by using nested
be32_to_cpu(cpu_to_be32()) calls but GCC seems not to be clever enough to
optimize the byteswaps out.
---
 include/net/vxlan.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index a763c96ecde4..73ed2e951c02 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -271,36 +271,36 @@ static inline struct vxlanhdr *vxlan_hdr(struct sk_buff *skb)
 static inline __be32 vxlan_vni(__be32 vni_field)
 {
 #if defined(__BIG_ENDIAN)
-	return vni_field >> 8;
+	return (__force __be32)((__force u32)vni_field >> 8);
 #else
-	return (vni_field & VXLAN_VNI_MASK) << 8;
+	return (__force __be32)((__force u32)(vni_field & VXLAN_VNI_MASK) << 8);
 #endif
 }
 
 static inline __be32 vxlan_vni_field(__be32 vni)
 {
 #if defined(__BIG_ENDIAN)
-	return vni << 8;
+	return (__force __be32)((__force u32)vni << 8);
 #else
-	return vni >> 8;
+	return (__force __be32)((__force u32)vni >> 8);
 #endif
 }
 
 static inline __be32 vxlan_tun_id_to_vni(__be64 tun_id)
 {
 #if defined(__BIG_ENDIAN)
-	return tun_id;
+	return (__force __be32)tun_id;
 #else
-	return tun_id >> 32;
+	return (__force __be32)((__force u64)tun_id >> 32);
 #endif
 }
 
 static inline __be64 vxlan_vni_to_tun_id(__be32 vni)
 {
 #if defined(__BIG_ENDIAN)
-	return (__be64)vni;
+	return (__force __be64)vni;
 #else
-	return (__be64)vni << 32;
+	return (__force __be64)((u64)(__force u32)vni << 32);
 #endif
 }
 
-- 
1.8.3.1
