From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 1/4] uapi: define DIV_ROUND_UP for userland
Date: Fri,  4 Mar 2016 11:52:16 +0100
Message-ID: <1457088739-1065-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20160303.170804.2300821465150459193.davem@davemloft.net>
 <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:49055 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcCDKwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 05:52:49 -0500
In-Reply-To: <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DIV_ROUND_UP is defined in linux/kernel.h only for the kernel.
When ethtool.h is included by a userland app, we got the following error:

include/linux/ethtool.h:1218:8: error: variably modified 'queue_mask' at file scope
  __u32 queue_mask[DIV_ROUND_UP(MAX_NUM_QUEUE, 32)];
        ^

Let's add a common definition in uapi and use it everywhere.

Fixes: ac2c7ad0e5d6 ("net/ethtool: introduce a new ioctl for per queue setting")
CC: Kan Liang <kan.liang@intel.com>
Suggested-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/kernel.h       | 2 +-
 include/uapi/linux/ethtool.h | 3 ++-
 include/uapi/linux/kernel.h  | 1 +
 include/uapi/linux/mroute6.h | 9 ++-------
 4 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index f31638c6e873..ac1923957236 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -64,7 +64,7 @@
 #define round_down(x, y) ((x) & ~__round_mask(x, y))
 
 #define FIELD_SIZEOF(t, f) (sizeof(((t*)0)->f))
-#define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
+#define DIV_ROUND_UP __KERNEL_DIV_ROUND_UP
 #define DIV_ROUND_UP_ULL(ll,d) \
 	({ unsigned long long _tmp = (ll)+(d)-1; do_div(_tmp, d); _tmp; })
 
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 37fd6dc33de4..9c22249ebf35 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -13,6 +13,7 @@
 #ifndef _UAPI_LINUX_ETHTOOL_H
 #define _UAPI_LINUX_ETHTOOL_H
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
@@ -1215,7 +1216,7 @@ enum ethtool_sfeatures_retval_bits {
 struct ethtool_per_queue_op {
 	__u32	cmd;
 	__u32	sub_command;
-	__u32	queue_mask[DIV_ROUND_UP(MAX_NUM_QUEUE, 32)];
+	__u32	queue_mask[__KERNEL_DIV_ROUND_UP(MAX_NUM_QUEUE, 32)];
 	char	data[];
 };
 
diff --git a/include/uapi/linux/kernel.h b/include/uapi/linux/kernel.h
index 321e399457f5..466073f0ce46 100644
--- a/include/uapi/linux/kernel.h
+++ b/include/uapi/linux/kernel.h
@@ -9,5 +9,6 @@
 #define __ALIGN_KERNEL(x, a)		__ALIGN_KERNEL_MASK(x, (typeof(x))(a) - 1)
 #define __ALIGN_KERNEL_MASK(x, mask)	(((x) + (mask)) & ~(mask))
 
+#define __KERNEL_DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
 
 #endif /* _UAPI_LINUX_KERNEL_H */
diff --git a/include/uapi/linux/mroute6.h b/include/uapi/linux/mroute6.h
index ce91215cf7e6..5062fb5751e1 100644
--- a/include/uapi/linux/mroute6.h
+++ b/include/uapi/linux/mroute6.h
@@ -1,6 +1,7 @@
 #ifndef _UAPI__LINUX_MROUTE6_H
 #define _UAPI__LINUX_MROUTE6_H
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/sockios.h>
 
@@ -46,14 +47,8 @@ typedef unsigned short mifi_t;
 typedef	__u32		if_mask;
 #define NIFBITS (sizeof(if_mask) * 8)        /* bits per mask */
 
-#if !defined(__KERNEL__)
-#if !defined(DIV_ROUND_UP)
-#define	DIV_ROUND_UP(x,y)	(((x) + ((y) - 1)) / (y))
-#endif
-#endif
-
 typedef struct if_set {
-	if_mask ifs_bits[DIV_ROUND_UP(IF_SETSIZE, NIFBITS)];
+	if_mask ifs_bits[__KERNEL_DIV_ROUND_UP(IF_SETSIZE, NIFBITS)];
 } if_set;
 
 #define IF_SET(n, p)    ((p)->ifs_bits[(n)/NIFBITS] |= (1 << ((n) % NIFBITS)))
-- 
2.4.2
