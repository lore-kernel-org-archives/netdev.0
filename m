From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] net: filter: add vlan tag access
Date: Sat, 27 Oct 2012 14:26:17 +0200
Message-ID: <1351340777.30380.273.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@aristanetworks.com>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <danborkmann@iogearbox.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56412 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab2J0M0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 08:26:22 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1424323eek.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 05:26:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

BPF filters lack ability to access skb->vlan_tci

This patch adds two new ancillary accessors :

SKF_AD_VLAN_TAG         (44) mapped to vlan_tx_tag_get(skb)

SKF_AD_VLAN_TAG_PRESENT (48) mapped to vlan_tx_tag_present(skb)

This allows libpcap/tcpdump to use a kernel filter instead of
having to fallback to accept all packets, then filter them in
user space.
 
Signed-off-by: Eric Dumazet <edumazet@google.com>
Suggested-by: Ani Sinha <ani@aristanetworks.com>
Suggested-by: Daniel Borkmann <danborkmann@iogearbox.net>
---
 include/linux/filter.h      |    2 ++
 include/uapi/linux/filter.h |    4 +++-
 net/core/filter.c           |    9 +++++++++
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 24d251f..c9f0005 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -123,6 +123,8 @@ enum {
 	BPF_S_ANC_CPU,
 	BPF_S_ANC_ALU_XOR_X,
 	BPF_S_ANC_SECCOMP_LD_W,
+	BPF_S_ANC_VLAN_TAG,
+	BPF_S_ANC_VLAN_TAG_PRESENT,
 };
 
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 3d79224..9cfde69 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -127,7 +127,9 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_RXHASH	32
 #define SKF_AD_CPU	36
 #define SKF_AD_ALU_XOR_X	40
-#define SKF_AD_MAX	44
+#define SKF_AD_VLAN_TAG	44
+#define SKF_AD_VLAN_TAG_PRESENT 48
+#define SKF_AD_MAX	52
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 3d92ebb..5a114d4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -39,6 +39,7 @@
 #include <linux/reciprocal_div.h>
 #include <linux/ratelimit.h>
 #include <linux/seccomp.h>
+#include <linux/if_vlan.h>
 
 /* No hurry in this branch
  *
@@ -341,6 +342,12 @@ load_b:
 		case BPF_S_ANC_CPU:
 			A = raw_smp_processor_id();
 			continue;
+		case BPF_S_ANC_VLAN_TAG:
+			A = vlan_tx_tag_get(skb);
+			continue;
+		case BPF_S_ANC_VLAN_TAG_PRESENT:
+			A = !!vlan_tx_tag_present(skb);
+			continue;
 		case BPF_S_ANC_NLATTR: {
 			struct nlattr *nla;
 
@@ -600,6 +607,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			ANCILLARY(RXHASH);
 			ANCILLARY(CPU);
 			ANCILLARY(ALU_XOR_X);
+			ANCILLARY(VLAN_TAG);
+			ANCILLARY(VLAN_TAG_PRESENT);
 			}
 		}
 		ftest->code = code;
