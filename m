From: Tom Herbert <therbert@google.com>
Subject: [PATCH next-next 2/6] net: Create net/core/checksum.c
Date: Fri, 4 Apr 2014 17:27:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404041714360.20534@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:37996 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbaDEA1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 20:27:02 -0400
Received: by mail-ie0-f202.google.com with SMTP id lx4so727574iec.5
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 17:27:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New file for skbuff checksum routines. Moved checksum complete
functions from datagram.c.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/Makefile   |  3 ++-
 net/core/checksum.c | 26 ++++++++++++++++++++++++++
 net/core/datagram.c | 20 --------------------
 3 files changed, 28 insertions(+), 21 deletions(-)
 create mode 100644 net/core/checksum.c

diff --git a/net/core/Makefile b/net/core/Makefile
index 826b925..5f7b9f0 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -3,7 +3,8 @@
 #
 
 obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
-	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o flow_dissector.o
+	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o flow_dissector.o \
+	 checksum.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
diff --git a/net/core/checksum.c b/net/core/checksum.c
new file mode 100644
index 0000000..2954f86
--- /dev/null
+++ b/net/core/checksum.c
@@ -0,0 +1,26 @@
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+
+#include <net/checksum.h>
+
+__sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len)
+{
+	__sum16 sum;
+
+	sum = csum_fold(skb_checksum(skb, 0, len, skb->csum));
+	if (likely(!sum)) {
+		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
+			netdev_rx_csum_fault(skb->dev);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+	return sum;
+}
+EXPORT_SYMBOL(__skb_checksum_complete_head);
+
+__sum16 __skb_checksum_complete(struct sk_buff *skb)
+{
+	return __skb_checksum_complete_head(skb, skb->len);
+}
+EXPORT_SYMBOL(__skb_checksum_complete);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index a16ed7b..e64c2af 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -734,26 +734,6 @@ fault:
 	return -EFAULT;
 }
 
-__sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len)
-{
-	__sum16 sum;
-
-	sum = csum_fold(skb_checksum(skb, 0, len, skb->csum));
-	if (likely(!sum)) {
-		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
-			netdev_rx_csum_fault(skb->dev);
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	}
-	return sum;
-}
-EXPORT_SYMBOL(__skb_checksum_complete_head);
-
-__sum16 __skb_checksum_complete(struct sk_buff *skb)
-{
-	return __skb_checksum_complete_head(skb, skb->len);
-}
-EXPORT_SYMBOL(__skb_checksum_complete);
-
 /**
  *	skb_copy_and_csum_datagram_iovec - Copy and checkum skb to user iovec.
  *	@skb: skbuff
-- 
1.9.1.423.g4596e3a
