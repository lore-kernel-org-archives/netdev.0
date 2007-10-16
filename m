From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with napi poll
Date: Tue, 16 Oct 2007 15:40:49 +1000
Message-ID: <1192513249.19073.9.camel@pasglop>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: shemminger@linux.foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37294 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755020AbXJPFlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 01:41:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net: Add __napi_sycnhronize() to sync with napi poll

The EMAC driver which needs to handle multiple devices with one
NAPI instance implements its own per-channel disable bit. However,
when setting such a bit, it needs to synchronize with the poller
(that is make sure that any pending poller instance has completed,
or is started late enough to see that disable bit).

This implements a low level __napi_synchronize() function to acheive
that. The underscores are to emphasis the low level aspect of it and
to discourage driver writers who don't know what they are doing to
use it (to please DaveM :-)

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

If the approach is accepted, I would like to have this merged now
so the EMAC patch to make it work again can follow :-)

Note: I use msleep_interruptible(1); just like napi_disable(). However
I'm not too happy that the "hot" loop that results of a pending signal
here will spin without even a cpu_relax ... what do you guys think would
be the best way to handle this ?



Index: linux-work/include/linux/netdevice.h
===================================================================
--- linux-work.orig/include/linux/netdevice.h	2007-10-16 15:27:27.000000000 +1000
+++ linux-work/include/linux/netdevice.h	2007-10-16 15:27:38.000000000 +1000
@@ -394,6 +394,21 @@ static inline void napi_disable(struct n
 }
 
 /**
+ *	__napi_synchronize - synchronize with a concurrent poll
+ *	@n: napi context
+ *
+ * Synchronizes with a concurrent poll. Not to be used in normal
+ * drivers, mostly useful if you end up with multiple interfaces
+ * on one NAPI instance.
+ */
+static inline void __napi_synchronize(struct napi_struct *n)
+{
+	smp_mb();
+	while (test_bit(NAPI_STATE_SCHED, &n->state))
+		msleep_interruptible(1);
+}
+
+/**
  *	napi_enable - enable NAPI scheduling
  *	@n: napi context
  *


