From: Alex Bergmann <alex@linlab.net>
Subject: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Wed, 22 Aug 2012 01:29:23 +0200
Message-ID: <503419D3.1080700@linlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I'm not 100% sure, but it looks like I found an RFC mismatch with the 
current default values of the TCP implementation.

Alex

>From 8b854a525eb45f64ad29dfab16f9d9f681e84495 Mon Sep 17 00:00:00 2001
From: Alexander Bergmann <alex@linlab.net>
Date: Wed, 22 Aug 2012 00:29:08 +0200
Subject: [PATCH 1/1] tcp: Wrong timeout for SYN segments

Commit 9ad7c049 changed the initRTO from 3secs to 1sec in accordance to
RFC6298 (former RFC2988bis). This introduced a gap with RFC1122 that
defines a minimum retransmission window for SYN segments of at least
180secs.

Prior to 9ad7c049 the timeout was defined with 189secs. Now we have only
a timeout of 63secs.

        ((2 << 5) - 1) * 3 secs = 189 secs
        ((2 << 5) - 1) * 1 secs = 63 secs

To fulfill the MUST constraint in RFC1122 section 4.2.3.5 about R2 for
SYN segments, the values of TCP_SYN_RETRIES and TCP_SYNACK_RETRIES must
be changed to 7 reties.

        ((2 << 7) - 1) * 1 secs = 255 secs

This would result in an ETIMEDOUT of 4 minutes 15 seconds.

Signed-off-by: Alexander Bergmann <alex@linlab.net>
---
 include/net/tcp.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1f000ff..7eaae19 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -98,10 +98,10 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
                                 * 15 is ~13-30min depending on RTO.
                                 */
 
-#define TCP_SYN_RETRIES         5      /* number of times to retry active opening a
+#define TCP_SYN_RETRIES         7      /* number of times to retry active opening a
                                 * connection: ~180sec is RFC minimum   */
 
-#define TCP_SYNACK_RETRIES 5   /* number of times to retry passive opening a
+#define TCP_SYNACK_RETRIES 7   /* number of times to retry passive opening a
                                 * connection: ~180sec is RFC minimum   */
 
 #define TCP_TIMEWAIT_LEN (60*HZ) /* how long to wait to destroy TIME-WAIT
-- 
1.7.8.6
