From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V8 net-next 6/6] xen-net{back,
	front}: Document multi-queue feature in netif.h
Date: Wed, 14 May 2014 14:52:30 +0100
Message-ID: <1400075550-4580-7-git-send-email-andrew.bennieston@citrix.com>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	paul.durrant@citrix.com, david.vrabel@citrix.com, zoltan.kiss@citrix.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>

Document the multi-queue feature in terms of XenStore keys to be written
by the backend and by the frontend.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
Acked-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 include/xen/interface/io/netif.h |   53 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index c50061d..70054cc 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -51,6 +51,59 @@
  */
 
 /*
+ * Multiple transmit and receive queues:
+ * If supported, the backend will write the key "multi-queue-max-queues" to
+ * the directory for that vif, and set its value to the maximum supported
+ * number of queues.
+ * Frontends that are aware of this feature and wish to use it can write the
+ * key "multi-queue-num-queues", set to the number they wish to use, which
+ * must be greater than zero, and no more than the value reported by the backend
+ * in "multi-queue-max-queues".
+ *
+ * Queues replicate the shared rings and event channels.
+ * "feature-split-event-channels" may optionally be used when using
+ * multiple queues, but is not mandatory.
+ *
+ * Each queue consists of one shared ring pair, i.e. there must be the same
+ * number of tx and rx rings.
+ *
+ * For frontends requesting just one queue, the usual event-channel and
+ * ring-ref keys are written as before, simplifying the backend processing
+ * to avoid distinguishing between a frontend that doesn't understand the
+ * multi-queue feature, and one that does, but requested only one queue.
+ *
+ * Frontends requesting two or more queues must not write the toplevel
+ * event-channel (or event-channel-{tx,rx}) and {tx,rx}-ring-ref keys,
+ * instead writing those keys under sub-keys having the name "queue-N" where
+ * N is the integer ID of the queue for which those keys belong. Queues
+ * are indexed from zero. For example, a frontend with two queues and split
+ * event channels must write the following set of queue-related keys:
+ *
+ * /local/domain/1/device/vif/0/multi-queue-num-queues = "2"
+ * /local/domain/1/device/vif/0/queue-0 = ""
+ * /local/domain/1/device/vif/0/queue-0/tx-ring-ref = "<ring-ref-tx0>"
+ * /local/domain/1/device/vif/0/queue-0/rx-ring-ref = "<ring-ref-rx0>"
+ * /local/domain/1/device/vif/0/queue-0/event-channel-tx = "<evtchn-tx0>"
+ * /local/domain/1/device/vif/0/queue-0/event-channel-rx = "<evtchn-rx0>"
+ * /local/domain/1/device/vif/0/queue-1 = ""
+ * /local/domain/1/device/vif/0/queue-1/tx-ring-ref = "<ring-ref-tx1>"
+ * /local/domain/1/device/vif/0/queue-1/rx-ring-ref = "<ring-ref-rx1"
+ * /local/domain/1/device/vif/0/queue-1/event-channel-tx = "<evtchn-tx1>"
+ * /local/domain/1/device/vif/0/queue-1/event-channel-rx = "<evtchn-rx1>"
+ *
+ * If there is any inconsistency in the XenStore data, the backend may
+ * choose not to connect any queues, instead treating the request as an
+ * error. This includes scenarios where more (or fewer) queues were
+ * requested than the frontend provided details for.
+ *
+ * Mapping of packets to queues is considered to be a function of the
+ * transmitting system (backend or frontend) and is not negotiated
+ * between the two. Guests are free to transmit packets on any queue
+ * they choose, provided it has been set up correctly. Guests must be
+ * prepared to receive packets on any queue they have requested be set up.
+ */
+
+/*
  * "feature-no-csum-offload" should be used to turn IPv4 TCP/UDP checksum
  * offload off or on. If it is missing then the feature is assumed to be on.
  * "feature-ipv6-csum-offload" should be used to turn IPv6 TCP/UDP checksum
-- 
1.7.10.4
