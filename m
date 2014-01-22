From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v5 2/3] net: introduce reciprocal_scale helper and convert users
Date: Wed, 22 Jan 2014 02:29:40 +0100
Message-ID: <1390354181-5080-3-git-send-email-hannes@stressinduktion.org>
References: <1390354181-5080-1-git-send-email-hannes@stressinduktion.org>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56766 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbaAVB3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 20:29:44 -0500
In-Reply-To: <1390354181-5080-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

As David Laight suggests, we shouldn't necessarily call this
reciprocal_divide() when users didn't requested a reciprocal_value();
lets keep the basic idea and call it reciprocal_scale(). More
background information on this topic can be found in [1].

Joint work with Hannes Frederic Sowa.

  [1] http://homepage.cs.uiowa.edu/~jones/bcd/divide.html

Suggested-by: David Laight <david.laight@aculab.com>
Cc: Jakub Zawadzki <darkjames-ws@darkjames.pl>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/kernel.h | 19 +++++++++++++++++++
 include/net/codel.h    |  4 +---
 net/packet/af_packet.c |  3 +--
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index ecb8754..03d8a6b 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -193,6 +193,25 @@ extern int _cond_resched(void);
 		(__x < 0) ? -__x : __x;		\
 	})
 
+/**
+ * reciprocal_scale - "scale" a value into range [0, ep_ro)
+ * @val: value
+ * @ep_ro: right open interval endpoint
+ *
+ * Perform a "reciprocal multiplication" in order to "scale" a value into
+ * range [0, ep_ro), where the upper interval endpoint is right-open.
+ * This is useful, e.g. for accessing a index of an array containing
+ * ep_ro elements, for example. Think of it as sort of modulus, only that
+ * the result isn't that of modulo. ;) Note that if initial input is a
+ * small value, then result will return 0.
+ *
+ * Return: a result based on val in interval [0, ep_ro).
+ */
+static inline u32 reciprocal_scale(u32 val, u32 ep_ro)
+{
+	return (u32)(((u64) val * ep_ro) >> 32);
+}
+
 #if defined(CONFIG_MMU) && \
 	(defined(CONFIG_PROVE_LOCKING) || defined(CONFIG_DEBUG_ATOMIC_SLEEP))
 void might_fault(void);
diff --git a/include/net/codel.h b/include/net/codel.h
index 3b04ff5..fe0eab3 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -46,7 +46,6 @@
 #include <linux/skbuff.h>
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
-#include <linux/reciprocal_div.h>
 
 /* Controlling Queue Delay (CoDel) algorithm
  * =========================================
@@ -211,10 +210,9 @@ static codel_time_t codel_control_law(codel_time_t t,
 				      codel_time_t interval,
 				      u32 rec_inv_sqrt)
 {
-	return t + reciprocal_divide(interval, rec_inv_sqrt << REC_INV_SQRT_SHIFT);
+	return t + reciprocal_scale(interval, rec_inv_sqrt << REC_INV_SQRT_SHIFT);
 }
 
-
 static bool codel_should_drop(const struct sk_buff *skb,
 			      struct Qdisc *sch,
 			      struct codel_vars *vars,
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index df3cbdd..9734616 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -88,7 +88,6 @@
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
-#include <linux/reciprocal_div.h>
 #include <linux/percpu.h>
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -1262,7 +1261,7 @@ static unsigned int fanout_demux_hash(struct packet_fanout *f,
 				      struct sk_buff *skb,
 				      unsigned int num)
 {
-	return reciprocal_divide(skb->rxhash, num);
+	return reciprocal_scale(skb->rxhash, num);
 }
 
 static unsigned int fanout_demux_lb(struct packet_fanout *f,
-- 
1.8.4.2
