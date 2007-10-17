From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with napi
	poll
Date: Wed, 17 Oct 2007 12:52:02 +1000
Message-ID: <1192589522.11899.130.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41211 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762368AbXJQCwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 22:52:42 -0400
In-Reply-To: <20071016115318.0fc36af3@freepuppy.rosehill>
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

Switched to do a cpu_relax() spin instead and only on SMP. Not that
we have an smp_mb() in there which synchronize_irq() lacks. I believe
this is a bug in synchronize_irq() which I'll handle separately.

Note: unfortunately, Jeff already picked up the EMAC patch without
waiting for this to be sorted out (oops...). So if you agree with
this patch, it would be nice to have it go in quickly or maybe via
Jeff's tree to avoid breakage ? Not terribly important tho.

Index: linux-work/include/linux/netdevice.h
===================================================================
--- linux-work.orig/include/linux/netdevice.h	2007-10-17 12:39:40.000000000 +1000
+++ linux-work/include/linux/netdevice.h	2007-10-17 12:40:59.000000000 +1000
@@ -394,6 +394,23 @@ static inline void napi_disable(struct n
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
+#ifdef CONFIG_SMP
+	smp_mb();
+	while (test_bit(NAPI_STATE_SCHED, &n->state))
+		cpu_relax();
+#endif /* CONFIG_SMP */
+}
+
+/**
  *	napi_enable - enable NAPI scheduling
  *	@n: napi context
  *


