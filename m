From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] napi_synchronize: waiting for NAPI
Date: Wed, 17 Oct 2007 13:26:41 -0700
Message-ID: <20071017202653.266566036@linux-foundation.org>
References: <20071017202640.171902388@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47535 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935180AbXJQU2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 16:28:49 -0400
Content-Disposition: inline; filename=napi-synchronize.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some drivers with shared NAPI need a synchronization barrier.
Also suggested by Benjamin Herrenschmidt for EMAC.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/linux/netdevice.h	2007-10-17 08:45:32.000000000 -0700
+++ b/include/linux/netdevice.h	2007-10-17 08:47:54.000000000 -0700
@@ -407,6 +407,24 @@ static inline void napi_enable(struct na
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }
 
+#ifdef CONFIG_SMP
+/**
+ *	napi_synchronize - wait until NAPI is not running
+ *	@n: napi context
+ *
+ * Wait until NAPI is done being scheduled on this context.
+ * Waits till any outstanding processing completes but
+ * does not disable future activations.
+ */
+static inline void napi_synchronize(const struct napi_struct *n)
+{
+	while (test_bit(NAPI_STATE_SCHED, &n->state))
+		msleep(1);
+}
+#else
+# define napi_synchronize(n)	barrier()
+#endif
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

