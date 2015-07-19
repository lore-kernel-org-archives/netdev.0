From: sfeldma@gmail.com
Subject: [PATCH net-next v3 1/5] net: don't reforward packets already forwarded by offload device
Date: Sat, 18 Jul 2015 18:24:48 -0700
Message-ID: <1437269092-17669-2-git-send-email-sfeldma@gmail.com>
References: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com, nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35582 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102AbbGSBWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 21:22:36 -0400
Received: by pdrg1 with SMTP id g1so82003294pdr.2
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 18:22:35 -0700 (PDT)
In-Reply-To: <1437269092-17669-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Just before queuing skb for xmit on port, check if skb has been marked by
switchdev port driver as already fordwarded by device.  If so, drop skb.  A
non-zero skb->offload_fwd_mark field is set by the switchdev port
driver/device on ingress to indicate the skb has already been forwarded by
the device to egress ports with matching dev->skb_mark.  The switchdev port
driver would assign a non-zero dev->offload_skb_mark for each device port
netdev during registration, for example.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/netdevice.h |    6 ++++++
 include/linux/skbuff.h    |    9 ++++++++-
 net/core/dev.c            |   10 ++++++++++
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 45cfd79..8364f29 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1456,6 +1456,8 @@ enum netdev_priv_flags {
  *
  *	@xps_maps:	XXX: need comments on this one
  *
+ *	@offload_fwd_mark:	Offload device fwding mark
+ *
  *	@trans_start:		Time (in jiffies) of last Tx
  *	@watchdog_timeo:	Represents the timeout that is used by
  *				the watchdog ( see dev_watchdog() )
@@ -1697,6 +1699,10 @@ struct net_device {
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
 
+#ifdef CONFIG_NET_SWITCHDEV
+	u32			offload_fwd_mark;
+#endif
+
 	/* These may be needed for future network-power-down code. */
 
 	/*
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d6cdd6e..af7a096 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -506,6 +506,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
   *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
+ *	@offload_fwd_mark: fwding offload mark
  *	@mark: Generic packet mark
  *	@vlan_proto: vlan encapsulation protocol
  *	@vlan_tci: vlan tag control information
@@ -650,9 +651,15 @@ struct sk_buff {
 		unsigned int	sender_cpu;
 	};
 #endif
+	union {
 #ifdef CONFIG_NETWORK_SECMARK
-	__u32			secmark;
+		__u32		secmark;
+#endif
+#ifdef CONFIG_NET_SWITCHDEV
+		__u32		offload_fwd_mark;
 #endif
+	};
+
 	union {
 		__u32		mark;
 		__u32		reserved_tailroom;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8810b6b..2ee15af 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3061,6 +3061,16 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	else
 		skb_dst_force(skb);
 
+#ifdef CONFIG_NET_SWITCHDEV
+	/* Don't forward if offload device already forwarded */
+	if (skb->offload_fwd_mark &&
+	    skb->offload_fwd_mark == dev->offload_fwd_mark) {
+		consume_skb(skb);
+		rc = NET_XMIT_SUCCESS;
+		goto out;
+	}
+#endif
+
 	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 
-- 
1.7.10.4
