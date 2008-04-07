From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/2] Do not allocate unneeded memory for dev->priv
 alignment.
Date: Mon, 07 Apr 2008 20:31:12 +0400
Message-ID: <47FA4C50.3080405@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42516 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759101AbYDGQHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 12:07:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The alloc_netdev_mq() tries to produce 32-bytes alignment for both
the net_device itself and its private data. The second alignment is
achieved by adding the NETDEV_ALIGN_CONST to the whole size of
the memory to be allocated.

However, for those devices that do not need the private area, this
addition just makes the net_device weight 1024 + 32 = 1068 bytes,
i.e. consume twice as much memory.

Since loopback device is such (sizeof_priv == 0 for it), and each
net namespace creates one, this can save a noticeable amount of
memory for kernel with net namespaces turned on.

After this set the lo device is actually allocated from a size-1024
kmem cache on i386 box even with NETPOLL and WIRELESS_EXT turned on.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7aa0112..80e103a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4000,7 +4000,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
 		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
 		     ~NETDEV_ALIGN_CONST;
-	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
+	if (sizeof_priv)
+		alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
 	if (!p) {
-- 
1.5.3.4

