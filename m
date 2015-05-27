From: Ido Yariv <ido@wizery.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Wed, 27 May 2015 11:23:37 -0400
Message-ID: <20150527152337.GB558@WorkStation.home>
References: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
 <1432671437-19140-1-git-send-email-ido@wizery.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40A1A@AcuExch.aculab.com>
 <1432734077.4060.382.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527144029.GA558@WorkStation.home>
 <1432738585.4060.392.camel@edumazet-glaptop2.roam.corp.google.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432738585.4060.392.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Wed, May 27, 2015 at 07:56:25AM -0700, Eric Dumazet wrote:
> On Wed, 2015-05-27 at 10:40 -0400, Ido Yariv wrote:
> 
> > HZ=100 is used on some embedded platforms, so it's still something we
> > have to deal with unfortunately..
> > 
> > Since the '2' here is a lower bound, and msecs_to_jiffies(10) will
> > return values greater than 2 for HZ>100 anyway, always ensuring the
> > 2 jiffies lower bound shouldn't impact the behavior when HZ=1000.
> > 
> > However, as far as I can tell, comparing msecs_to_jiffies(10) to 2, or
> > comparing the whole timeout to 2 doesn't make much difference, since
> > msecs_to_jiffies isn't inlined.
> > 
> > In other words, keeping the #if shouldn't make much difference in behavior,
> > but will save the small comparison.
> 
> Yes, I guess David point is to have a macro in include/linux/tcp.h so
> that we can have a nice comment, and not having #if ... in a C file.
> 
> Maybe other timers in TCP need the same care (I am not asking you to
> find them, but having a macro would ease things perhaps)

Something along the lines of the patch below?

Thanks,
Ido.

>From 562019884d1b2c7619ce3f49ecb595147d28bbdd Mon Sep 17 00:00:00 2001
From: Ido Yariv <ido@wizery.com>
Date: Thu, 21 May 2015 08:23:13 +0200
Subject: [PATCH v3] net: tcp: Fix a PTO timing granularity issue

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
 include/net/tcp.h     | 9 +++++++++
 net/ipv4/tcp_output.c | 2 +-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2bb2bad..86090b6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1751,4 +1751,13 @@ static inline void skb_set_tcp_pure_ack(struct sk_buff *skb)
 	skb->truesize = 2;
 }
 
+/* Convert msecs to jiffies, ensuring that the return value is always at least
+ * 2. This can be used when setting tick-based timers to guarantee that they
+ * won't expire right away.
+ */
+static inline unsigned long tcp_safe_msecs_to_jiffies(const unsigned int m)
+{
+	return max_t(u32, 2, msecs_to_jiffies(m));
+}
+
 #endif	/* _TCP_H */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 534e5fd..83021c5 100644
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
