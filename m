From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
	non-drops and modifying end-of-line points for skbs
Date: Thu, 5 Mar 2009 16:01:05 -0500
Message-ID: <20090305210105.GC12835@hmsreliant.think-freely.org>
References: <20090303170307.GD1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33647 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504AbZCEVBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:11 -0500
Content-Disposition: inline
In-Reply-To: <20090303170307.GD1480@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, as requested, new version of this patch to add in bifurcation of kfree_skb
into two versions, one for legitimate kfree's, and one for drops

Modification Notes:
1) Renamed kfree_skb_clean to consume_skb, to better identify points where we
are finished with an skb

2) checkpatch cleanups

Thanks!

Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/skbuff.h |    4 +++-
 net/core/datagram.c    |    2 +-
 net/core/skbuff.c      |   22 ++++++++++++++++++++++
 net/ipv4/arp.c         |    2 +-
 net/ipv4/udp.c         |    2 +-
 net/packet/af_packet.c |    2 +-
 6 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1f659e8..1fbab2a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -421,6 +421,7 @@ extern void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
 #endif
 
 extern void kfree_skb(struct sk_buff *skb);
+extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
 				   gfp_t priority, int fclone, int node);
@@ -459,7 +460,8 @@ extern int	       skb_to_sgvec(struct sk_buff *skb,
 extern int	       skb_cow_data(struct sk_buff *skb, int tailbits,
 				    struct sk_buff **trailer);
 extern int	       skb_pad(struct sk_buff *skb, int pad);
-#define dev_kfree_skb(a)	kfree_skb(a)
+#define dev_kfree_skb(a)	consume_skb(a)
+#define dev_consume_skb(a)	kfree_skb_clean(a)
 extern void	      skb_over_panic(struct sk_buff *skb, int len,
 				     void *here);
 extern void	      skb_under_panic(struct sk_buff *skb, int len,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 5e2ac0c..d0de644 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -208,7 +208,7 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
 
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
 {
-	kfree_skb(skb);
+	consume_skb(skb);
 	sk_mem_reclaim_partial(sk);
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e5e2111..6acbf9e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -65,6 +65,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
+#include <trace/skb.h>
 
 #include "kmap_skb.h"
 
@@ -442,11 +443,32 @@ void kfree_skb(struct sk_buff *skb)
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))
 		return;
+	trace_kfree_skb(skb, __builtin_return_address(0));
 	__kfree_skb(skb);
 }
 EXPORT_SYMBOL(kfree_skb);
 
 /**
+ *	consume_skb - free an skbuff
+ *	@skb: buffer to free
+ *
+ *	Drop a ref to the buffer and free it if the usage count has hit zero
+ *	Functions identically to kfree_skb, but kfree_skb assumes that the frame
+ *	is being dropped after a failure and notes that
+ */
+void consume_skb(struct sk_buff *skb)
+{
+	if (unlikely(!skb))
+		return;
+	if (likely(atomic_read(&skb->users) == 1))
+		smp_rmb();
+	else if (likely(!atomic_dec_and_test(&skb->users)))
+		return;
+	__kfree_skb(skb);
+}
+EXPORT_SYMBOL(consume_skb);
+
+/**
  *	skb_recycle_check - check if skb can be reused for receive
  *	@skb: buffer
  *	@skb_size: minimum receive buffer size
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 3f6b735..e89f7b7 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -892,7 +892,7 @@ static int arp_process(struct sk_buff *skb)
 out:
 	if (in_dev)
 		in_dev_put(in_dev);
-	kfree_skb(skb);
+	consume_skb(skb);
 	return 0;
 }
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4bd178a..05b7abb 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1184,7 +1184,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			sk = sknext;
 		} while (sknext);
 	} else
-		kfree_skb(skb);
+		consume_skb(skb);
 	spin_unlock(&hslot->lock);
 	return 0;
 }
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d8cc006..74776de 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -584,7 +584,7 @@ drop_n_restore:
 		skb->len = skb_len;
 	}
 drop:
-	kfree_skb(skb);
+	consume_skb(skb);
 	return 0;
 }
 
