From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH v3 6/7] Documentation: networking: add RSS information
Date: Thu, 24 Aug 2017 10:28:27 +0300
Message-ID: <1503559708-13405-7-git-send-email-madalin.bucur@nxp.com>
References: <1503559708-13405-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503559708-13405-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 Documentation/networking/dpaa.txt | 68 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 67 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/dpaa.txt b/Documentation/networking/dpaa.txt
index 76e016d..f88194f 100644
--- a/Documentation/networking/dpaa.txt
+++ b/Documentation/networking/dpaa.txt
@@ -13,6 +13,7 @@ Contents
 	- Configuring DPAA Ethernet in your kernel
 	- DPAA Ethernet Frame Processing
 	- DPAA Ethernet Features
+	- DPAA IRQ Affinity and Receive Side Scaling
 	- Debugging
 
 DPAA Ethernet Overview
@@ -147,7 +148,10 @@ gradually.
 
 The driver has Rx and Tx checksum offloading for UDP and TCP. Currently the Rx
 checksum offload feature is enabled by default and cannot be controlled through
-ethtool.
+ethtool. Also, rx-flow-hash and rx-hashing was added. The addition of RSS
+provides a big performance boost for the forwarding scenarios, allowing
+different traffic flows received by one interface to be processed by different
+CPUs in parallel.
 
 The driver has support for multiple prioritized Tx traffic classes. Priorities
 range from 0 (lowest) to 3 (highest). These are mapped to HW workqueues with
@@ -166,6 +170,68 @@ classes as follows:
 tc qdisc add dev <int> root handle 1: \
 	 mqprio num_tc 4 map 0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 hw 1
 
+DPAA IRQ Affinity and Receive Side Scaling
+==========================================
+
+Traffic coming on the DPAA Rx queues or on the DPAA Tx confirmation
+queues is seen by the CPU as ingress traffic on a certain portal.
+The DPAA QMan portal interrupts are affined each to a certain CPU.
+The same portal interrupt services all the QMan portal consumers.
+
+By default the DPAA Ethernet driver enables RSS, making use of the
+DPAA FMan Parser and Keygen blocks to distribute traffic on 128
+hardware frame queues using a hash on IP v4/v6 source and destination
+and L4 source and destination ports, in present in the received frame.
+When RSS is disabled, all traffic received by a certain interface is
+received on the default Rx frame queue. The default DPAA Rx frame
+queues are configured to put the received traffic into a pool channel
+that allows any available CPU portal to dequeue the ingress traffic.
+The default frame queues have the HOLDACTIVE option set, ensuring that
+traffic bursts from a certain queue are serviced by the same CPU.
+This ensures a very low rate of frame reordering. A drawback of this
+is that only one CPU at a time can service the traffic received by a
+certain interface when RSS is not enabled.
+
+To implement RSS, the DPAA Ethernet driver allocates an extra set of
+128 Rx frame queues that are configured to dedicated channels, in a
+round-robin manner. The mapping of the frame queues to CPUs is now
+hardcoded, there is no indirection table to move traffic for a certain
+FQ (hash result) to another CPU. The ingress traffic arriving on one
+of these frame queues will arrive at the same portal and will always
+be processed by the same CPU. This ensures intra-flow order preservation
+and workload distribution for multiple traffic flows.
+
+RSS can be turned off for a certain interface using ethtool, i.e.
+
+	# ethtool -N fm1-mac9 rx-flow-hash tcp4 ""
+
+To turn it back on, one needs to set rx-flow-hash for tcp4/6 or udp4/6:
+
+	# ethtool -N fm1-mac9 rx-flow-hash udp4 sfdn
+
+There is no independent control for individual protocols, any command
+run for one of tcp4|udp4|ah4|esp4|sctp4|tcp6|udp6|ah6|esp6|sctp6 is
+going to control the rx-flow-hashing for all protocols on that interface.
+
+Besides using the FMan Keygen computed hash for spreading traffic on the
+128 Rx FQs, the DPAA Ethernet driver also sets the skb hash value when
+the NETIF_F_RXHASH feature is on (active by default). This can be turned
+on or off through ethtool, i.e.:
+
+	# ethtool -K fm1-mac9 rx-hashing off
+	# ethtool -k fm1-mac9 | grep hash
+	receive-hashing: off
+	# ethtool -K fm1-mac9 rx-hashing on
+	Actual changes:
+	receive-hashing: on
+	# ethtool -k fm1-mac9 | grep hash
+	receive-hashing: on
+
+Please note that Rx hashing depends upon the rx-flow-hashing being on
+for that interface - turning off rx-flow-hashing will also disable the
+rx-hashing (without ethtool reporting it as off as that depends on the
+NETIF_F_RXHASH feature flag).
+
 Debugging
 =========
 
-- 
2.1.0
