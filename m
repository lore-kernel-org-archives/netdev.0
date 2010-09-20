From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 1/3] IRQ: Add irq_get_numa_node()
Date: Mon, 20 Sep 2010 13:44:31 +0100
Message-ID: <1284986671.2282.41.camel@achroite.uk.solarflarecom.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
	 <1283356463.2556.351.camel@edumazet-laptop>
	 <AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
	 <20100901.183251.106803238.davem@davemloft.net>
	 <1284673961.2283.57.camel@achroite.uk.solarflarecom.com>
	 <20100919172451.GA12878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38676 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab0ITMoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 08:44:34 -0400
In-Reply-To: <20100919172451.GA12878@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be used to support NUMA-aware memory allocation of
structures used in interrupt handlers, starting with network drivers.
---
irq_get_numa_node() probably needs to grab desc->lock.  Other than that,
this should work.

Ben.

 include/linux/interrupt.h |    9 +++++++++
 kernel/irq/manage.c       |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index a0384a4..82e9a08 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -260,6 +260,15 @@ static inline int irq_set_affinity_hint(unsigned int irq,
 }
 #endif /* CONFIG_SMP && CONFIG_GENERIC_HARDIRQS */
 
+#if defined(CONFIG_NUMA) && defined(CONFIG_GENERIC_HARDIRQS)
+extern int irq_get_numa_node(unsigned int irq);
+#else
+static inline int irq_get_numa_node(unsigned int irq)
+{
+	return -1;
+}
+#endif
+
 #ifdef CONFIG_GENERIC_HARDIRQS
 /*
  * Special lockdep variants of irq disabling/enabling.
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index c3003e9..03e683e 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -154,6 +154,41 @@ int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m)
 }
 EXPORT_SYMBOL_GPL(irq_set_affinity_hint);
 
+#ifdef CONFIG_NUMA
+/**
+ *	irq_get_numa_node - get the NUMA node of a given IRQ
+ *	@irq:		Interrupt to get NUMA node for
+ *
+ *	If the current SMP affinity mask of the IRQ corresponds to a
+ *	single NUMA node, return the node number.  Otherwise return
+ *	%NUMA_NO_NODE.
+ */
+int irq_get_numa_node(unsigned int irq)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+	const struct cpumask *mask;
+	int cpu, node = NUMA_NO_NODE;
+
+	if (!desc)
+		return node;
+
+	mask = desc->affinity;
+#ifdef CONFIG_GENERIC_PENDING_IRQ
+	if (desc->status & IRQ_MOVE_PENDING)
+		mask = desc->pending_mask;
+#endif
+
+	for_each_cpu(cpu, mask) {
+		if (node < 0)
+			node = cpu_to_node(cpu);
+		else if (node != cpu_to_node(cpu))
+			return NUMA_NO_NODE;
+	}
+
+	return node;
+}
+#endif
+
 #ifndef CONFIG_AUTO_IRQ_AFFINITY
 /*
  * Generic version of the affinity autoselector.
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

