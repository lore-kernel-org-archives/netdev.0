From: David Miller <davem@davemloft.net>
Subject: Re: XTP for 2.6.25
Date: Fri, 25 Apr 2008 01:55:08 -0700 (PDT)
Message-ID: <20080425.015508.254917794.davem@davemloft.net>
References: <18b669d80804250059m793f3f56xc4fdb8bad949fa3@mail.gmail.com>
	<Pine.LNX.4.64.0804251115470.2363@wrl-59.cs.helsinki.fi>
	<18b669d80804250151h516788cdqc7931a7ab5a195de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shigeonx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50529
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757105AbYDYIzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 04:55:08 -0400
In-Reply-To: <18b669d80804250151h516788cdqc7931a7ab5a195de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shigeo N" <shigeonx@gmail.com>
Date: Fri, 25 Apr 2008 17:51:49 +0900

> One host(sender) is 2.6.25, but the other(receiver) is 2.6.18.
> I will evaluate again after I upgrade it to 2.6.25.

The bug fix isn't in 2.6.25 either.

Here is the patch in question, please add it to the kernel
during your tests.

>From 3c0390e1a6d8a5d0cdae57959f0be37a236b474d Mon Sep 17 00:00:00 2001
From: John Heffner <jheffner@napa.(none)>
Date: Fri, 25 Apr 2008 01:43:57 -0700
Subject: [PATCH] [TCP]: Increase the max_burst threshold from 3 to tp->reordering.

[ Upstream commit: dd9e0dda66ba38a2ddd1405ac279894260dc5c36 ]

This change is necessary to allow cwnd to grow during persistent
reordering.  Cwnd moderation is applied when in the disorder state
and an ack that fills the hole comes in.  If the hole was greater
than 3 packets, but less than tp->reordering, cwnd will shrink when
it should not have.

Signed-off-by: John Heffner <jheffner@napa.(none)>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4fd3eb2..d69d12e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -776,11 +776,14 @@ extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
 
 /* Slow start with delack produces 3 packets of burst, so that
- * it is safe "de facto".
+ * it is safe "de facto".  This will be the default - same as
+ * the default reordering threshold - but if reordering increases,
+ * we must be able to allow cwnd to burst at least this much in order
+ * to not pull it back when holes are filled.
  */
 static __inline__ __u32 tcp_max_burst(const struct tcp_sock *tp)
 {
-	return 3;
+	return tp->reordering;
 }
 
 /* Returns end sequence number of the receiver's advertised window */
-- 
1.5.5.1.57.g5909c

