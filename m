From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/4] openvswitch: Unify vport error stats handling.
Date: Wed, 12 Jun 2013 15:56:59 -0700
Message-ID: <1371077819-19679-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:34738 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758161Ab3FLW5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:57:03 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so10610027pdi.11
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 15:57:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch changes vport->send return type so that vport
layer can do error accounting.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport-netdev.c |    1 -
 net/openvswitch/vport.c        |    9 +++++++--
 net/openvswitch/vport.h        |    3 ++-
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4f01c6d..c3ee7de 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -181,7 +181,6 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 
 error:
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
index 68a377b..75d3ccb 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -125,7 +125,8 @@ struct vport_parms {
  * @get_name: Get the device's name.
  * @get_config: Get the device's configuration.
  * May be null if the device does not have an ifindex.
- * @send: Send a packet on the device.  Returns the length of the packet sent.
+ * @send: Send a packet on the device.  Returns the length of the packet sent,
+ * zero for dropped packets or negative for error.
  */
 struct vport_ops {
 	enum ovs_vport_type type;
-- 
1.7.1
