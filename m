From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 3/8] openvswitch: Unify vport error stats handling.
Date: Fri, 14 Jun 2013 15:28:52 -0700
Message-ID: <1371248937-35614-4-git-send-email-jesse@nicira.com>
References: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Cc: netdev <netdev@vger.kernel.org>, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:59311 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753386Ab3FNW3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 18:29:08 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so1059207pad.9
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 15:29:07 -0700 (PDT)
In-Reply-To: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Following patch changes vport->send return type so that vport
layer can do error accounting.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-netdev.c | 5 ++---
 net/openvswitch/vport.c        | 9 +++++++--
 net/openvswitch/vport.h        | 3 ++-
 3 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4f01c6d..4371221 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -170,7 +170,7 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
 				     netdev_vport->dev->name,
 				     packet_length(skb), mtu);
-		goto error;
+		goto drop;
 	}
 
 	skb->dev = netdev_vport->dev;
@@ -179,9 +179,8 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 
 	return len;
 
-error:
+drop:
 	kfree_skb(skb);
-	ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);
 	return 0;
 }
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 7206231..7f20f6d 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -351,7 +351,7 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 {
 	int sent = vport->ops->send(vport, skb);
 
-	if (likely(sent)) {
+	if (likely(sent > 0)) {
 		struct pcpu_tstats *stats;
 
 		stats = this_cpu_ptr(vport->percpu_stats);
@@ -360,7 +360,12 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 		stats->tx_packets++;
 		stats->tx_bytes += sent;
 		u64_stats_update_end(&stats->syncp);
-	}
+	} else if (sent < 0) {
+		ovs_vport_record_error(vport, VPORT_E_TX_ERROR);
+		kfree_skb(skb);
+	} else
+		ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);
+
 	return sent;
 }
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 26c594b..1cef5cd 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -123,7 +123,8 @@ struct vport_parms {
  * existing vport to a &struct sk_buff.  May be %NULL for a vport that does not
  * have any configuration.
  * @get_name: Get the device's name.
- * @send: Send a packet on the device.  Returns the length of the packet sent.
+ * @send: Send a packet on the device.  Returns the length of the packet sent,
+ * zero for dropped packets or negative for error.
  */
 struct vport_ops {
 	enum ovs_vport_type type;
-- 
1.8.1.2
