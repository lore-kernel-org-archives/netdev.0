From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 4/4] sfc/RFS/irq_group debug output
Date: Mon, 20 Sep 2010 20:12:12 +0100
Message-ID: <1285009932.2282.133.camel@achroite.uk.solarflarecom.com>
References: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9651 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338Ab0ITTMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 15:12:15 -0400
In-Reply-To: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just some logging I found useful.

Ben.
---
 drivers/net/sfc/filter.c |   11 ++++++++++-
 kernel/irq/manage.c      |   21 +++++++++++++++++++++
 2 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 349b5d1..db7fa46 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -506,6 +506,11 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	rc = efx_filter_insert_filter(efx, &spec, true);
 	if (rc >= 0)
 		state->rps_flow_id[rc] = flow_id;
+	netif_info(efx, rx_status, efx->net_dev,
+		   "steering %s %pI4:%u:%pI4:%u to queue %u [flow %u filter %d]\n",
+		   (ip->protocol == IPPROTO_TCP) ? "TCP" : "UDP",
+		   &ip->saddr, ntohs(ports[0]), &ip->daddr, ntohs(ports[1]),
+		   rxq_index, flow_id, rc);
 
 	return rc;
 }
@@ -529,8 +534,12 @@ void efx_filter_rfs_expire(struct efx_nic *efx)
 		    table->spec[index].priority == EFX_FILTER_PRI_HINT &&
 		    rps_may_expire_flow(efx->net_dev,
 					table->spec[index].dmaq_id,
-					state->rps_flow_id[index], index))
+					state->rps_flow_id[index], index)) {
+			netif_info(efx, rx_status, efx->net_dev,
+				   "expiring filter %d [flow %u]\n",
+				   index, state->rps_flow_id[index]);
 			efx_filter_table_clear_entry(efx, table, index);
+		}
 		index = (index + 1) & mask;
 	}
 
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 3f2b1a9..7199dde 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -129,6 +129,21 @@ static bool irq_group_copy_neigh(struct irq_group *group, int cpu,
 	return false;
 }
 
+static void print_irq_group(const struct irq_group *group, const char *prefix)
+{
+	unsigned index;
+	int cpu;
+
+	pr_info("irq_group %p, %s:\n", group, prefix);
+
+	for_each_possible_cpu(cpu) {
+		index = group->closest[cpu].index;
+		pr_info("cpu %d -> index %u (IRQ %u; distance %u)\n",
+			cpu, index, group->irq[index]->irq,
+			group->closest[cpu].dist);
+	}
+}
+
 /* Update the per-CPU closest IRQs following a change of affinity */
 static void
 irq_update_group(struct irq_desc *desc, const struct cpumask *affinity)
@@ -145,6 +160,8 @@ irq_update_group(struct irq_desc *desc, const struct cpumask *affinity)
 		if (group->closest[cpu].index == index)
 			group->closest[cpu].dist = IRQ_CPU_DIST_INF;
 
+	print_irq_group(group, "after invalidating old distances");
+
 	/*
 	 * Set this as the closest IRQ for all CPUs in the affinity mask,
 	 * plus the following CPUs if they don't have a closer IRQ:
@@ -163,6 +180,8 @@ irq_update_group(struct irq_desc *desc, const struct cpumask *affinity)
 				       index, 3);
 	}
 
+	print_irq_group(group, "after updating neighbours");
+
 	/* Find new closest IRQ for any CPUs left with invalid distances */
 	for_each_online_cpu(cpu) {
 		if (!(group->closest[cpu].index == index &&
@@ -180,6 +199,8 @@ irq_update_group(struct irq_desc *desc, const struct cpumask *affinity)
 		/* We could continue into NUMA node distances, but for now
 		 * we give up. */
 	}
+
+	print_irq_group(group, "after copying neighbours");
 }
 
 /**
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

