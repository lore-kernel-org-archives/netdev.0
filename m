From: sfeldma@gmail.com
Subject: [RFC PATCH net-next 1/4] net: don't reforward packets already forwarded by offload device
Date: Sat, 13 Jun 2015 11:04:27 -0700
Message-ID: <1434218670-43821-2-git-send-email-sfeldma@gmail.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33263 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbbFMSCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 14:02:37 -0400
Received: by igbpi8 with SMTP id pi8so30286992igb.0
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2015 11:02:37 -0700 (PDT)
In-Reply-To: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Just before queuing skb for xmit on port, check if skb has been marked by
switchdev port driver as already fordwarded by device.  If so, drop skb.  A
non-zero skb->fwd_mark field is set by the switchdev port driver/device on
ingress to indicate the skb has already been forwarded by the device to
egress ports with matching dev->skb_mark.  The switchdev port driver would
assign a non-zero dev->skb_mark for each device port netdev during
registration, for example.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/linux/netdevice.h |    6 ++++++
 include/linux/skbuff.h    |    4 ++++
 net/core/dev.c            |    9 +++++++++
 3 files changed, 19 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6f5f71f..181b08f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1444,6 +1444,8 @@ enum netdev_priv_flags {
  *
  *	@xps_maps:	XXX: need comments on this one
  *
+ *	@fwd_mark:		Offload device fwding mark
+ *
  *	@trans_start:		Time (in jiffies) of last Tx
  *	@watchdog_timeo:	Represents the timeout that is used by
  *				the watchdog ( see dev_watchdog() )
@@ -1681,6 +1683,10 @@ struct net_device {
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
 
+#ifdef CONFIG_NET_SWITCHDEV
+	u32			fwd_mark;
+#endif
+
 	/* These may be needed for future network-power-down code. */
 
 	/*
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cc612fc..ba98c05 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -501,6 +501,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
   *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
+ *	@fwd_mark: fwding offload mark
  *	@mark: Generic packet mark
  *	@vlan_proto: vlan encapsulation protocol
  *	@vlan_tci: vlan tag control information
@@ -648,6 +649,9 @@ struct sk_buff {
 #ifdef CONFIG_NETWORK_SECMARK
 	__u32			secmark;
 #endif
+#ifdef CONFIG_NET_SWITCHDEV
+	__u32			fwd_mark;
+#endif
 	union {
 		__u32		mark;
 		__u32		reserved_tailroom;
diff --git a/net/core/dev.c b/net/core/dev.c
index 6778a99..558bf33 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3065,6 +3065,15 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	else
 		skb_dst_force(skb);
 
+#ifdef CONFIG_NET_SWITCHDEV
+	/* Don't forward if offload device already forwarded */
+	if (skb->fwd_mark && skb->fwd_mark == dev->fwd_mark) {
+		kfree_skb(skb);
+		rc = NET_XMIT_SUCCESS;
+		goto out;
+	}
+#endif
+
 	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 
-- 
1.7.10.4
