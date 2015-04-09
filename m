From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3 net-next] net_device: Add minimal padding to allow for net_device pointer alignment
Date: Fri, 10 Apr 2015 01:43:28 +0200
Message-ID: <1676328eb3e9d02a4432783494d0c5a13f0d4656.1428622095.git.tgraf@suug.ch>
References: <cover.1428622095.git.tgraf@suug.ch>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56816 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256AbbDIXnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 19:43:41 -0400
In-Reply-To: <cover.1428622095.git.tgraf@suug.ch>
In-Reply-To: <cover.1428622095.git.tgraf@suug.ch>
References: <cover.1428622095.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes use of the __alignof__ GCC builtin to determine the minimal
amount of padding required to align the pointer afterwards.

Due to use of ____cacheline_aligned_in_smp inside net_device,
struct net_device is actually always a multiple of SMP_CACHE_BYTES
so typically no padding is needed but this logic is kept in place
in case that is no longer the case.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/kernel.h | 2 ++
 net/core/dev.c         | 3 +--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index d6d630d..4ec018f 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -50,6 +50,8 @@
 #define __ALIGN_MASK(x, mask)	__ALIGN_KERNEL_MASK((x), (mask))
 #define PTR_ALIGN(p, a)		((typeof(p))ALIGN((unsigned long)(p), (a)))
 #define IS_ALIGNED(x, a)		(((x) & ((typeof(x))(a) - 1)) == 0)
+#define PTR_ALIGN_PAD(type, a) \
+	({ (__alignof__(type) < (a)) ? (a) - __alignof__(type) : 0; })
 
 #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]) + __must_be_array(arr))
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b2775f0..2b43aba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6794,8 +6794,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 		alloc_size = ALIGN(alloc_size, NETDEV_ALIGN);
 		alloc_size += sizeof_priv;
 	}
-	/* ensure 32-byte alignment of whole construct */
-	alloc_size += NETDEV_ALIGN - 1;
+	alloc_size += PTR_ALIGN_PAD(struct net_device, NETDEV_ALIGN);
 
 	p = kzalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
 	if (!p)
-- 
1.9.3
