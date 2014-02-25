From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v6 net-next 1/2] net: add skb_mstamp infrastructure
Date: Mon, 24 Feb 2014 22:22:04 -0800
Message-ID: <1393309324.2316.119.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
	 <1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg>
	 <1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140224155130.4c286cca@samsung-9>
	 <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:55623 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaBYGWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 01:22:07 -0500
Received: by mail-pb0-f54.google.com with SMTP id uo5so7645183pbc.13
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 22:22:06 -0800 (PST)
In-Reply-To: <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ktime_get() is too expensive on some cases, and we'd like to get
usec resolution timestamps in TCP stack.

This patch adds a light weight facility using a combination of
local_clock() and jiffies samples.

Instead of :

	u64 t0, t1;

	t0 = ktime_get();
	// stuff
	t1 = ktime_get();
	delta_us = ktime_us_delta(t1, t0);

use :
	struct skb_mstamp t0, t1;

	skb_mstamp_get(&t0);
	// stuff
	skb_mstamp_get(&t1);
	delta_us = skb_mstamp_us_delta(&t1, &t0);

Note : local_clock() might have a (bounded) drift between cpus.

Do not use this infra in place of ktime_get() without understanding the
issues.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Larry Brakmo <brakmo@google.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/linux/skbuff.h |   59 +++++++++++++++++++++++++++++++++++++--
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 11b6925f0e96..7f24f50f307e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -32,6 +32,7 @@
 #include <linux/hrtimer.h>
 #include <linux/dma-mapping.h>
 #include <linux/netdev_features.h>
+#include <linux/sched.h>
 #include <net/flow_keys.h>
 
 /* A. Checksumming of received packets by device.
@@ -356,11 +357,62 @@ typedef unsigned int sk_buff_data_t;
 typedef unsigned char *sk_buff_data_t;
 #endif
 
+/**
+ * struct skb_mstamp - multi resolution time stamps
+ * @stamp_us: timestamp in us resolution
+ * @stamp_jiffies: timestamp in jiffies
+ */
+struct skb_mstamp {
+	union {
+		u64		v64;
+		struct {
+			u32	stamp_us;
+			u32	stamp_jiffies;
+		};
+	};
+};
+
+/**
+ * skb_mstamp_get - get sample current time
+ * @cl: place to store timestamps
+ */
+static inline void skb_mstamp_get(struct skb_mstamp *cl)
+{
+	u64 val = local_clock();
+
+	do_div(val, NSEC_PER_USEC);
+	cl->stamp_us = (u32)val;
+	cl->stamp_jiffies = (u32)jiffies;
+}
+
+/**
+ * skb_mstamp_delta - compute the difference in usec between two skb_mstamp
+ * @t1: pointer to oldest sample
+ * @t0: pointer to newest sample
+ */
+static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
+				      const struct skb_mstamp *t0)
+{
+	s32 delta_us = t1->stamp_us - t0->stamp_us;
+	u32 delta_jiffies = t1->stamp_jiffies - t0->stamp_jiffies;
+
+	/* If delta_us is negative, this might be because interval is too big,
+	 * or local_clock() drift is too big : fallback using jiffies.
+	 */
+	if (delta_us <= 0 ||
+	    delta_jiffies >= (INT_MAX / (USEC_PER_SEC / HZ)))
+
+		delta_us = jiffies_to_usecs(delta_jiffies);
+
+	return delta_us;
+}
+
+
 /** 
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
  *	@prev: Previous buffer in list
- *	@tstamp: Time we arrived
+ *	@tstamp: Time we arrived/left
  *	@sk: Socket we are owned by
  *	@dev: Device we arrived on/are leaving by
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
@@ -429,7 +481,10 @@ struct sk_buff {
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
 
-	ktime_t			tstamp;
+	union {
+		ktime_t		tstamp;
+		struct skb_mstamp skb_mstamp;
+	};
 
 	struct sock		*sk;
 	struct net_device	*dev;
