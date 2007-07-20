From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 01/10] HOWTO documentation for Batching SKB.
Date: Fri, 20 Jul 2007 12:02:01 +0530
Message-ID: <20070720063201.26341.79273.sendpatchset@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	netdev@vger.kernel.org, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, hadi@cyberus.ca, kaber@trash.net, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Add HOWTO documentation on what batching is, how to implement drivers to use
it, and how users can enable/disable batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 Batching_skb_API.txt |   91 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 91 insertions(+)

diff -ruNp org/Documentation/networking/Batching_skb_API.txt new/Documentation/networking/Batching_skb_API.txt
--- org/Documentation/networking/Batching_skb_API.txt	1970-01-01 05:30:00.000000000 +0530
+++ new/Documentation/networking/Batching_skb_API.txt	2007-07-20 08:30:22.000000000 +0530
@@ -0,0 +1,91 @@
+		 HOWTO for batching skb API support
+		 -----------------------------------
+
+Section 1: What is batching skb API ?
+Section 2: How batching API works vs the original API ?
+Section 3: How drivers can support this API ?
+Section 4: How users can work with this API ?
+
+
+Introduction: Kernel support for batching skb
+-----------------------------------------------
+
+An extended API is supported in the netdevice layer, which is very similar
+to the existing hard_start_xmit() API. Drivers which wish to take advantage
+of this new API should implement this routine similar to how the
+hard_start_xmit handler is written. The difference between these API's is
+that while the existing hard_start_xmit processes one skb, the new API can
+process multiple skbs (or even one) in a single call. It is also possible
+for the driver writer to re-use most of the code from the existing API in
+the new API without having code duplication.
+
+
+Section 1: What is batching skb API ?
+-------------------------------------
+
+	This is a new API that is optionally exported by a driver. The pre-
+	requisite for a driver to use this API is that it should have a
+	reasonably sized hardware queue that can process multiple skbs.
+
+
+Section 2: How batching API works vs the original API ?
+-------------------------------------------------------
+
+	The networking stack normally gets called from upper layer protocols
+	with a single skb to xmit. This skb is first enqueue'd and an
+	attempt is next made to transmit it immediately (via qdisc_run).
+	However, events like driver lock contention, queue stopped, etc, can
+	result in the skb not getting sent out, and it remains in the queue.
+	When a new xmit is called or when the queue is re-enabled, qdisc_run
+	could potentially find multiple packets in the queue, and have to
+	send them all out one by one iteratively.
+
+	The batching skb API case was added to exploit this situation where
+	if there are multiple skbs, all of them can be sent to the device in
+	one shot. This reduces driver processing, locking at the driver (or
+	in stack for ~LLTX drivers) gets amortized over multiple skbs, and
+	in case of specific drivers where every xmit results in a completion
+	processing (like IPoIB), optimizations could be made in the driver
+	to get a completion for only the last skb that was sent which will
+	result in saving interrupts for every (but the last) skb that was
+	sent in the same batch.
+
+	This batching can result in significant performance gains for
+	systems that have multiple data stream paths over the same network
+	interface card.
+
+
+Section 3: How drivers can support this API ?
+---------------------------------------------
+
+	The new API - dev->hard_start_xmit_batch(struct net_device *dev),
+	simplistically, can be written almost identically to the regular
+	xmit API (hard_start_xmit), except that all skbs on dev->skb_blist
+	should be processed by the driver instead of just one skb. The new
+	API doesn't get any skb as argument to process, instead it picks up
+	all the skbs from dev->skb_blist, where it was added by the stack,
+	and tries to send them out.
+
+	Batching requires the driver to set the NETIF_F_BATCH_SKBS bit in
+	dev->features, and dev->hard_start_xmit_batch should point to the
+	new API implemented for that driver.
+
+
+Section 4: How users can work with this API ?
+---------------------------------------------
+
+	Batching could be disabled for a particular device, e.g. on desktop
+	systems if only one stream of network activity for that device is
+	taking place, since performance could be slightly affected due to
+	extra processing that batching adds. Batching can be enabled if
+	more than one stream of network activity per device is being done,
+	e.g. on servers, or even desktop usage with multiple browser, chat,
+	file transfer sessions, etc.
+
+	Per device batching can be enabled/disabled using:
+
+	echo 1 > /sys/class/net/<device-name>/tx_batch_skbs (enable)
+	echo 0 > /sys/class/net/<device-name>/tx_batch_skbs (disable)
+
+	E.g. to enable batching on eth0, run:
+		echo 1 > /sys/class/net/eth0/tx_batch_skbs
