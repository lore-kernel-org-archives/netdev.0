From: Ido Yariv <ido@wizery.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Thu, 28 May 2015 00:37:29 -0400
Message-ID: <20150528043729.GA32339@WorkStation.home>
References: <1432671437-19140-1-git-send-email-ido@wizery.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40A1A@AcuExch.aculab.com>
 <1432734077.4060.382.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527144029.GA558@WorkStation.home>
 <1432738585.4060.392.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527152337.GB558@WorkStation.home>
 <1432743816.4060.404.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527165403.GC558@WorkStation.home>
 <1432747456.4060.409.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527191526.GA17823@WorkStation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ido Yariv <idox.yariv@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36443 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbbE1Ehc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 00:37:32 -0400
Received: by qkx62 with SMTP id 62so18396969qkx.3
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 21:37:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150527191526.GA17823@WorkStation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Wed, May 27, 2015 at 03:15:26PM -0400, Ido Yariv wrote:
> Hi Eric,
> 
> On Wed, May 27, 2015 at 10:24:16AM -0700, Eric Dumazet wrote:
> > On Wed, 2015-05-27 at 12:54 -0400, Ido Yariv wrote:
> > > Hi Eric,
> > 
> > > That's a nice optimization ;)
> > > 
> > > However, I think that with Nicholas Mc Guire's recent changes to
> > > msecs_to_jiffies (http://marc.info/?l=linux-kernel&m=143195210010666),
> > > we should get this for free, no?
> > 
> > Well, on net and net-next tree we currently have :
> > 
> > $ grep msecs_to_jiffies include/linux/jiffies.h
> > extern unsigned long msecs_to_jiffies(const unsigned int m);
> > 
> > Given your patch is for stable, I would not mind having this done
> > anyway.
> 
> I believe these changes are in tip, but not in net/net-next just yet.
> 
> I actually didn't think this patch is for stable, but we can certainly
> do that.
> 
> Would you be fine with the patch below? Please note that I modified your
> optimization a bit.

We'd probably like to avoid any potential integer overflows as well, so
I modified the if statement accordingly.

Not sure this optimization is really beneficial (and only on stable
kernels), but here's the updated patch.

Cheers,
Ido.

>From 8d78f75cde8ef523a312e6cfab8e1b7a89f97c9f Mon Sep 17 00:00:00 2001
From: Ido Yariv <ido@wizery.com>
Date: Thu, 21 May 2015 08:23:13 +0200
Subject: [PATCH v5] net: tcp: Fix a PTO timing granularity issue

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
index 2bb2bad..19ed4c0 100644
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
+static inline unsigned long tcp_safe_msecs_to_jiffies(const unsigned int m)
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
index 190538a..26cc5a6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2207,7 +2207,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	if (tp->packets_out == 1)
 		timeout = max_t(u32, timeout,
 				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
-	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
+	timeout = max_t(u32, timeout, tcp_safe_msecs_to_jiffies(10));
 
 	/* If RTO is shorter, just schedule TLP in its place. */
 	tlp_time_stamp = tcp_time_stamp + timeout;
-- 
2.1.0
