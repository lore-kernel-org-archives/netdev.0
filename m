From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 1/3] NET: [DOC] Multiqueue hardware support documentation
Date: Mon, 18 Jun 2007 11:42:18 -0700
Message-ID: <20070618184218.12274.446.stgit@localhost.localdomain>
References: <20070618184208.12274.13017.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	hadi@cyberus.ca, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1901 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763857AbXFRSm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 14:42:26 -0400
In-Reply-To: <20070618184208.12274.13017.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a brief howto to Documentation/networking for multiqueue.  It
explains how to use the multiqueue API in a driver to support
multiqueue paths from the stack, as well as the qdiscs to use for
feeding a multiqueue device.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 Documentation/networking/multiqueue.txt |   98 +++++++++++++++++++++++++++++++
 1 files changed, 98 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/multiqueue.txt b/Documentation/networking/multiqueue.txt
new file mode 100644
index 0000000..8201767
--- /dev/null
+++ b/Documentation/networking/multiqueue.txt
@@ -0,0 +1,98 @@
+
+		HOWTO for multiqueue network device support
+		===========================================
+
+Section 1: Base driver requirements for implementing multiqueue support
+Section 2: Qdisc support for multiqueue devices
+Section 3: Brief howto using PRIO for multiqueue devices
+
+
+Intro: Kernel support for multiqueue devices
+---------------------------------------------------------
+
+Kernel support for multiqueue devices is only an API that is presented to the
+netdevice layer for base drivers to implement.  This feature is part of the
+core networking stack, and all network devices will be running on the
+multiqueue-aware stack.  If a base driver only has one queue, then these
+changes are transparent to that driver.
+
+
+Section 2: Base driver requirements for implementing multiqueue support
+-----------------------------------------------------------------------
+
+Base drivers are required to use the new alloc_etherdev_mq() or
+alloc_netdev_mq() functions to allocate the subqueues for the device.  The
+underlying kernel API will take care of the allocation and deallocation of
+the subqueue memory, as well as netdev configuration of where the queues
+exist in memory.
+
+The base driver will also need to manage the queues as it does the global
+netdev->queue_lock today.  Therefore base drivers should use the
+netif_{start|stop|wake}_subqueue() functions to manage each queue while the
+device is still operational.  netdev->queue_lock is still used when the device
+comes online or when it's completely shut down (unregister_netdev(), etc.).
+
+Finally, the base driver should indicate that it is a multiqueue device.  The
+feature flag NETIF_F_MULTI_QUEUE should be added to the netdev->features
+bitmap on device initialization.  Below is an example from e1000:
+
+#ifdef CONFIG_E1000_MQ
+	if ( (adapter->hw.mac.type == e1000_82571) ||
+	     (adapter->hw.mac.type == e1000_82572) ||
+	     (adapter->hw.mac.type == e1000_80003es2lan))
+		netdev->features |= NETIF_F_MULTI_QUEUE;
+#endif
+
+
+Section 3: Qdisc support for multiqueue devices
+-----------------------------------------------
+
+Currently two qdiscs support multiqueue devices.  A new round-robin qdisc,
+sch_rr, and sch_prio. The qdisc is responsible for classifying the skb's to
+bands and queues, and will store the queue mapping into skb->queue_mapping.
+Use this field in the base driver to determine which queue to send the skb
+to.
+
+sch_rr has been added for hardware that doesn't want scheduling policies from
+software, so it's a straight round-robin qdisc.  It uses the same syntax and
+classification priomap that sch_prio uses, so it should be intuitive to
+configure for people who've used sch_prio.
+
+The PRIO qdisc naturally plugs into a multiqueue device.  Upon load of the
+qdisc, PRIO will make a best-effort assignment of queue to PRIO band to evenly
+distribute traffic flows.  The algorithm can be found in prio_tune() in
+net/sched/sch_prio.c.  Once the association is made, any skb that is
+classified will have skb->queue_mapping set, which will allow the driver to
+properly queue skb's to multiple queues.  sch_prio can have these features
+compiled in or out of the module.
+
+
+Section 4: Brief howto using PRIO for multiqueue devices
+--------------------------------------------------------
+
+The userspace command 'tc,' part of the iproute2 package, is used to configure
+qdiscs.  To add the PRIO qdisc to your network device, assuming the device is
+called eth0, run the following command:
+
+# tc qdisc add dev eth0 root handle 1: prio
+
+This will create 3 bands, 0 being highest priority, and associate those bands
+to the queues on your NIC.  Assuming eth0 has 2 Tx queues, the band mapping
+would look like:
+
+band 0 => queue 0
+band 1 => queue 1
+band 2 => queue 1
+
+Traffic will begin flowing through each queue if your TOS values are assigning
+traffic across the various bands.  For example, ssh traffic will always try to
+go out band 0 based on TOS -> Linux priority conversion (realtime traffic),
+so it will be sent out queue 0.  ICMP traffic (pings) fall into the "normal"
+traffic classification, which is band 1.  Therefore pings will be send out
+queue 1 on the NIC.
+
+The behavior of tc filters remains the same, where it will override TOS priority
+classification.
+
+
+Author: Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
