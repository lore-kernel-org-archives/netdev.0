From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 1/3] NET: Multiqueue network device support documentation.
Date: Thu, 12 Apr 2007 17:19:52 -0700
Message-ID: <20070413001952.18763.80465.stgit@gitlost.site>
References: <20070413001630.18763.41107.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1809 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752306AbXDMADq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 20:03:46 -0400
In-Reply-To: <20070413001630.18763.41107.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Adding documentation for the new multiqueue API.

Signed-off-by: Peter P. Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 Documentation/networking/multiqueue.txt |   97 +++++++++++++++++++++++++++++++
 1 files changed, 97 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/multiqueue.txt b/Documentation/networking/multiqueue.txt
new file mode 100644
index 0000000..c32ed83
--- /dev/null
+++ b/Documentation/networking/multiqueue.txt
@@ -0,0 +1,97 @@
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
+Currently two qdiscs support multiqueue devices.  The default qdisc, pfifo_fast,
+and the PRIO qdisc.  The qdisc is responsible for classifying the skb's to
+bands and queues, and will store the queue mapping into skb->queue_mapping.
+Use this field in the base driver to determine which queue to send the skb
+to.
+
+pfifo_fast, being the default qdisc when a device is brought online, will not
+assign a queue mapping, therefore the skb will have a value of zero.  We
+cannot assume anything about the device itself, how many queues it really has,
+etc.  Therefore sending all traffic to queue 0 is the safest thing to do here.
+
+The PRIO qdisc naturally plugs into a multiqueue device.  Upon load of the
+qdisc, PRIO will make a best-effort assignment of queue to PRIO band to evenly
+distribute traffic flows.  The algorithm can be found in prio_tune() in
+net/sched/sch_prio.c.  Once the association is made, any skb that is
+classified will have skb->queue_mapping set, which will allow the driver to
+properly queue skb's to multiple queues.
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

