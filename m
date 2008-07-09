From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/08]: vlan: deliver packets received with VLAN acceleration
 to network taps
Date: Wed, 09 Jul 2008 14:37:59 +0200
Message-ID: <4874B127.4080305@trash.net>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain> <20080709120948.11669.98935.sendpatchset@localhost.localdomain> <20080709123520.GK28029@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030003080103020306040102"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59317 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbYGIMiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:38:03 -0400
In-Reply-To: <20080709123520.GK28029@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030003080103020306040102
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Ben Hutchings wrote:
> Patrick McHardy wrote:
>> vlan: deliver packets received with VLAN acceleration to network taps
>>
>> When VLAN header stripping is used, packets currently bypass packet
>> sockets (and other network taps) completely. For locally existing
>> VLANs, they appear directly on the VLAN device, for unknown VLANs
>> they are silently dropped.
>>
>> Add a new function netif_nit_deliver() to deliver incoming packets
>> to all network interface taps and use it in __vlan_hwaccel_rx() to
>> make VLAN packets visible on the underlying device.
> [...]
>> +/*
>> + * 	netif_tap_deliver - deliver received packets to network taps
>> + * 	@skb: buffer
>> + *
>> + * 	This function is used to deliver incoming packets to network
>> + * 	taps. It should be used when the normal netif_receive_skb path
>> + * 	is bypassed, for example because of VLAN acceleration.
>> + */
>> +void netif_nit_deliver(struct sk_buff *skb)
> [...]
> 
> Is it supposed to be called netif_nit_deliver() or netif_tap_deliver()?

Thanks, seems I only renamed it half way :)

Fixed patch attached.

--------------030003080103020306040102
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit d5c10a9dd25c8c9333e12d92cd81191a37376097
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jul 9 14:37:44 2008 +0200

    vlan: deliver packets received with VLAN acceleration to network taps
    
    When VLAN header stripping is used, packets currently bypass packet
    sockets (and other network taps) completely. For locally existing
    VLANs, they appear directly on the VLAN device, for unknown VLANs
    they are silently dropped.
    
    Add a new function netif_nit_deliver() to deliver incoming packets
    to all network interface taps and use it in __vlan_hwaccel_rx() to
    make VLAN packets visible on the underlying device.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 203c550..85c5db8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1152,6 +1152,7 @@ extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
+extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 68df12d..916061f 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -14,6 +14,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		return NET_RX_DROP;
 	}
 
+	skb->vlan_tci = vlan_tci;
+	netif_nit_deliver(skb);
+
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 	if (skb->dev == NULL) {
 		dev_kfree_skb_any(skb);
@@ -22,6 +25,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		return NET_RX_SUCCESS;
 	}
 	skb->dev->last_rx = jiffies;
+	skb->vlan_tci = 0;
 
 	stats = &skb->dev->stats;
 	stats->rx_packets++;
diff --git a/net/core/dev.c b/net/core/dev.c
index a29a359..feaab48 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2068,6 +2068,33 @@ out:
 }
 #endif
 
+/*
+ * 	netif_nit_deliver - deliver received packets to network taps
+ * 	@skb: buffer
+ *
+ * 	This function is used to deliver incoming packets to network
+ * 	taps. It should be used when the normal netif_receive_skb path
+ * 	is bypassed, for example because of VLAN acceleration.
+ */
+void netif_nit_deliver(struct sk_buff *skb)
+{
+	struct packet_type *ptype;
+
+	if (list_empty(&ptype_all))
+		return;
+
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb->mac_len = skb->network_header - skb->mac_header;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ptype, &ptype_all, list) {
+		if (!ptype->dev || ptype->dev == skb->dev)
+			deliver_skb(skb, ptype, skb->dev);
+	}
+	rcu_read_unlock();
+}
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process

--------------030003080103020306040102--
