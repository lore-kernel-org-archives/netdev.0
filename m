From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] net: Add napi_sycnhronize() to sync with napi poll
Date: Thu, 18 Oct 2007 08:04:14 +1000
Message-ID: <1192658654.6783.43.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
	 <1192589522.11899.130.camel@pasglop> <47157EA4.1000500@garzik.org>
	 <1192591481.11899.134.camel@pasglop>
	 <20071017083107.6a1b1bd3@freepuppy.rosehill>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:44015 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756015AbXJQWEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 18:04:32 -0400
In-Reply-To: <20071017083107.6a1b1bd3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net: Add __napi_synchronize() to sync with napi poll

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

Back to msleep() since it fits my need well and that's what
you used as well. Note that the smp_mb() will turn into barrier()
on non-SMP.

I'll send a separate patch to fix EMAC to use the non __ version.

Index: linux-work/include/linux/netdevice.h
===================================================================
--- linux-work.orig/include/linux/netdevice.h	2007-10-17 13:31:32.000000000 +1000
+++ linux-work/include/linux/netdevice.h	2007-10-18 08:01:05.000000000 +1000
@@ -394,6 +394,23 @@ static inline void napi_disable(struct n
 }
 
 /**
+ *	napi_synchronize - synchronize with a concurrent poll
+ *	@n: napi context
+ *
+ * Synchronizes with a concurrent poll. Not to be used in normal
+ * drivers, mostly useful if you end up with multiple interfaces
+ * on one NAPI instance. This must be called from task context.
+ */
+static inline void napi_synchronize(struct napi_struct *n)
+{
+	smp_mb();
+#ifdef CONFIG_SMP
+	while (test_bit(NAPI_STATE_SCHED, &n->state))
+		msleep(1);
+#endif /* CONFIG_SMP */
+}
+
+/**
  *	napi_enable - enable NAPI scheduling
  *	@n: napi context
  *


