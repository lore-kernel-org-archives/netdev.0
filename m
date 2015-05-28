From: Ido Yariv <ido@wizery.com>
Subject: [PATCH v6] net: tcp: Fix a PTO timing granularity issue
Date: Thu, 28 May 2015 08:33:13 -0400
Message-ID: <1432816393-6941-1-git-send-email-ido@wizery.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CB4175B@AcuExch.aculab.com>
Cc: Ido Yariv <ido@wizery.com>, Ido Yariv <idox.yariv@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36032 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbbE1Mdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 08:33:44 -0400
Received: by qgf2 with SMTP id 2so15336553qgf.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 05:33:43 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB4175B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Tail Loss Probe RFC specifies that the PTO value should be set to
max(2 * SRTT, 10ms), where SRTT is the smoothed round-trip time.

The PTO value is converted to jiffies, so the timer may expire
prematurely.

This is especially problematic on systems in which HZ <= 100, so work
around this by setting the timeout to at least 2 jiffies on such
systems.

The 10ms figure was originally selected based on tests performed with
the current implementation and HZ = 1000. Thus, leave the behavior on
systems with HZ > 100 unchanged.

Signed-off-by: Ido Yariv <idox.yariv@intel.com>
---
 include/net/tcp.h     | 20 ++++++++++++++++++++
 net/ipv4/tcp_output.c |  2 +-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2bb2bad..2ff0181 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1751,4 +1751,24 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
 	skb->truesize = 2;
 }
 
+/* Convert msecs to jiffies, ensuring that the return value is at least 2
+ * jiffies.
+ * This can be used when setting tick-based timers to guarantee that they won't
+ * expire right away.
+ */
+static inline unsigned long tcp_msecs_to_jiffies_min_2(const unsigned int m)
+{
+	if (__builtin_constant_p(m)) {
+		/* The theoretical upper bound of m for 2 jiffies is 2 seconds,
+		 * so compare m with that to avoid potential integer overflows.
+		 */
+		if ((m > 2 * MSEC_PER_SEC) || (m * HZ > 2 * MSEC_PER_SEC))
+			return msecs_to_jiffies(m);
+
+		return 2;
+	}
+
+	return max_t(u32, 2, msecs_to_jiffies(m));
+}
+
 #endif	/* _TCP_H */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 190538a..37694d2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2207,7 +2207,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	if (tp->packets_out == 1)
 		timeout = max_t(u32, timeout,
 				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
-	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
+	timeout = max_t(u32, timeout, tcp_msecs_to_jiffies_min_2(10));
 
 	/* If RTO is shorter, just schedule TLP in its place. */
 	tlp_time_stamp = tcp_time_stamp + timeout;
-- 
2.1.0
