From: Andrew Grover <andrew.grover@intel.com>
Subject: [PATCH 4/10] [IOAT] Setup the net subsystem as DMA client
Date: Thu, 20 Apr 2006 13:49:58 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0604201337180.22544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:30425 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751270AbWDTUt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 16:49:59 -0400
Received: from orsfmr100.jf.intel.com (orsfmr100.jf.intel.com [10.7.209.16])
	by orsfmr002.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k3KKnwgv022300
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:49:58 GMT
Received: from nwlxmail01.jf.intel.com (nwlxmail01.jf.intel.com [10.7.171.40])
	by orsfmr100.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k3KKnw2u015852
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:49:58 GMT
Received: from isotope.jf.intel.com (isotope.jf.intel.com [10.23.35.8])
	by nwlxmail01.jf.intel.com (8.12.10/8.12.9/MailSET/Hub) with ESMTP id k3KKnwhF021527
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 13:49:58 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Attempts to allocate per-CPU DMA channels

Signed-off-by: Chris Leech <christopher.leech@intel.com>

---

 drivers/dma/Kconfig       |   12 +++++
 include/linux/netdevice.h |    4 ++
 include/net/netdma.h      |   38 ++++++++++++++++
 net/core/dev.c            |  104 +++++++++++++++++++++++++++++++++++++++++++++

diff --git a/drivers/dma/Kconfig b/drivers/dma/Kconfig
index 0f15e76..30d021d 100644
--- a/drivers/dma/Kconfig
+++ b/drivers/dma/Kconfig
@@ -10,6 +10,18 @@ config DMA_ENGINE
 	  DMA engines offload copy operations from the CPU to dedicated
 	  hardware, allowing the copies to happen asynchronously.
 
+comment "DMA Clients"
+
+config NET_DMA
+	bool "Network: TCP receive copy offload"
+	depends on DMA_ENGINE && NET
+	default y
+	---help---
+	  This enables the use of DMA engines in the network stack to
+	  offload receive copy-to-user operations, freeing CPU cycles.
+	  Since this is the main user of the DMA engine, it should be enabled;
+	  say Y here.
+
 comment "DMA Devices"
 
 config INTEL_IOATDMA
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 950dc55..7fda35f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -37,6 +37,7 @@
 #include <linux/config.h>
 #include <linux/device.h>
 #include <linux/percpu.h>
+#include <linux/dmaengine.h>
 
 struct divert_blk;
 struct vlan_group;
@@ -592,6 +593,9 @@ struct softnet_data
 	struct sk_buff		*completion_queue;
 
 	struct net_device	backlog_dev;	/* Sorry. 8) */
+#ifdef CONFIG_NET_DMA
+	struct dma_chan		*net_dma;
+#endif
 };
 
 DECLARE_PER_CPU(struct softnet_data,softnet_data);
diff --git a/include/net/netdma.h b/include/net/netdma.h
new file mode 100644
index 0000000..cbfe89d
--- /dev/null
+++ b/include/net/netdma.h
@@ -0,0 +1,38 @@
+/*
+ * Copyright(c) 2004 - 2006 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ */
+#ifndef NETDMA_H
+#define NETDMA_H
+#include <linux/config.h>
+#ifdef CONFIG_NET_DMA
+#include <linux/dmaengine.h>
+
+static inline struct dma_chan *get_softnet_dma(void)
+{
+	struct dma_chan *chan;
+	rcu_read_lock();
+	chan = rcu_dereference(__get_cpu_var(softnet_data.net_dma));
+	if (chan)
+		dma_chan_get(chan);
+	rcu_read_unlock();
+	return chan;
+}
+#endif /* CONFIG_NET_DMA */
+#endif /* NETDMA_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index a3ab11f..ffd3d6d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -115,6 +115,7 @@
 #include <net/iw_handler.h>
 #include <asm/current.h>
 #include <linux/audit.h>
+#include <linux/dmaengine.h>
 
 /*
  *	The list of packet types we will receive (as opposed to discard)
@@ -148,6 +149,12 @@ static DEFINE_SPINLOCK(ptype_lock);
 static struct list_head ptype_base[16];	/* 16 way hashed list */
 static struct list_head ptype_all;		/* Taps */
 
+#ifdef CONFIG_NET_DMA
+static struct dma_client *net_dma_client;
+static unsigned int net_dma_count;
+static spinlock_t net_dma_event_lock;
+#endif
+
 /*
  * The @dev_base list is protected by @dev_base_lock and the rtln
  * semaphore.
@@ -1780,6 +1787,19 @@ static void net_rx_action(struct softirq
 		}
 	}
 out:
+#ifdef CONFIG_NET_DMA
+	/*
+	 * There may not be any more sk_buffs coming right now, so push
+	 * any pending DMA copies to hardware
+	 */
+	if (net_dma_client) {
+		struct dma_chan *chan;
+		rcu_read_lock();
+		list_for_each_entry_rcu(chan, &net_dma_client->channels, client_node)
+			dma_async_memcpy_issue_pending(chan);
+		rcu_read_unlock();
+	}
+#endif
 	local_irq_enable();
 	return;
 
@@ -3243,6 +3263,88 @@ static int dev_cpu_callback(struct notif
 }
 #endif /* CONFIG_HOTPLUG_CPU */
 
+#ifdef CONFIG_NET_DMA
+/**
+ * net_dma_rebalance -
+ * This is called when the number of channels allocated to the net_dma_client
+ * changes.  The net_dma_client tries to have one DMA channel per CPU.
+ */
+static void net_dma_rebalance(void)
+{
+	unsigned int cpu, i, n;
+	struct dma_chan *chan;
+
+	lock_cpu_hotplug();
+
+	if (net_dma_count == 0) {
+		for_each_online_cpu(cpu)
+			rcu_assign_pointer(per_cpu(softnet_data.net_dma, cpu), NULL);
+		unlock_cpu_hotplug();
+		return;
+	}
+
+	i = 0;
+	cpu = first_cpu(cpu_online_map);
+
+	rcu_read_lock();
+	list_for_each_entry(chan, &net_dma_client->channels, client_node) {
+		n = ((num_online_cpus() / net_dma_count)
+		   + (i < (num_online_cpus() % net_dma_count) ? 1 : 0));
+
+		while(n) {
+			per_cpu(softnet_data.net_dma, cpu) = chan;
+			cpu = next_cpu(cpu, cpu_online_map);
+			n--;
+		}
+		i++;
+	}
+	rcu_read_unlock();
+
+	unlock_cpu_hotplug();
+}
+
+/**
+ * netdev_dma_event - event callback for the net_dma_client
+ * @client: should always be net_dma_client
+ * @chan:
+ * @event:
+ */
+static void netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
+	enum dma_event event)
+{
+	spin_lock(&net_dma_event_lock);
+	switch (event) {
+	case DMA_RESOURCE_ADDED:
+		net_dma_count++;
+		net_dma_rebalance();
+		break;
+	case DMA_RESOURCE_REMOVED:
+		net_dma_count--;
+		net_dma_rebalance();
+		break;
+	default:
+		break;
+	}
+	spin_unlock(&net_dma_event_lock);
+}
+
+/**
+ * netdev_dma_regiser - register the networking subsystem as a DMA client
+ */
+static int __init netdev_dma_register(void)
+{
+	spin_lock_init(&net_dma_event_lock);
+	net_dma_client = dma_async_client_register(netdev_dma_event);
+	if (net_dma_client == NULL)
+		return -ENOMEM;
+
+	dma_async_client_chan_request(net_dma_client, num_online_cpus());
+	return 0;
+}
+
+#else
+static int __init netdev_dma_register(void) { return -ENODEV; }
+#endif /* CONFIG_NET_DMA */
 
 /*
  *	Initialize the DEV module. At boot time this walks the device list and
@@ -3296,6 +3398,8 @@ static int __init net_dev_init(void)
 		atomic_set(&queue->backlog_dev.refcnt, 1);
 	}
 
+	netdev_dma_register();
+
 	dev_boot_phase = 0;
 
 	open_softirq(NET_TX_SOFTIRQ, net_tx_action, NULL);
-- 
1.2.6



