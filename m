From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Sat, 05 Jul 2008 21:40:02 +0200
Message-ID: <486FCE12.8040903@trash.net>
References: <20080411135714.GA8137@tp64> <483B9EBE.5030703@trash.net>	 <b25c3fa70805262320h7edb4246wd017261fe7187b88@mail.gmail.com>	 <483BAA7F.6060408@trash.net> <b25c3fa70806011516q7ae6c913q9d6e431d664d176e@mail.gmail.com> <4843EC0F.8010300@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090103040301060905040009"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41783 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbYGETkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 15:40:06 -0400
In-Reply-To: <4843EC0F.8010300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090103040301060905040009
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Joonwoo Park wrote:
>> Patrick,
>> Do you mind inserting a new flag to indicate vlan_tag is just for
>> af_packet or not into sk_buff?
>> I think if flag exists, we can pass vlan_tag to af_packet with just
>> modifications of vlan_get_tag(), vlan_put_tag() and
>> vlan_tag_present(),
>> without patching for invalidation.
> 
> I've considered this, but that would mean that we report
> the vlan tag for all devices layered on top, which seems
> wrong.
> 
> For now I think I'm going to temporarily do something like
> that so I can continue integrating the remaining patches
> and fix it properly later.


The entire idea didn't work out too well. Your original patch
passed packets for unknown VLANs to netif_receive_skb again,
but since they don't have a VLAN header, they are treated like
a normal non-VLAN packet and might end up in a protocol handler
instead of getting dropped. It would also have left one
inconsistency, for locally configured VLANs the packet is still
not visible on the lower device.

This patch (on top of my local tree with other changes, I'll
post the entire series soon) takes a different approach.
__vlan_hwaccel_rx() is supposed to behave similar to
netif_receive_skb(), so the easiest fix is to make it behave
more like netif_receive_skb() and deliver packets to ptype_all
handlers manually.


--------------090103040301060905040009
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 5110748e684267ca3d381f47ab972d47ddf178c6
Author: Patrick McHardy <kaber@trash.net>
Date:   Sat Jul 5 21:32:29 2008 +0200

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
index 0e1e4c1..ef95e7f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1144,6 +1144,7 @@ extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
+extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 69a09df..77d2fa4 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -14,6 +14,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		return NET_RX_DROP;
 	}
 
+	skb->vlan_tag = vlan_tag;
+	netif_nit_deliver(skb);
+
 	skb->dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
 	if (skb->dev == NULL) {
 		dev_kfree_skb_any(skb);
@@ -23,6 +26,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		 */
 		return 0;
 	}
+	skb->vlan_tag = 0;
 
 	skb->dev->last_rx = jiffies;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index fca23a3..6d9bbf1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2030,6 +2030,38 @@ out:
 }
 #endif
 
+/*
+ * 	netif_tap_deliver - deliver received packets to network taps
+ * 	@skb: buffer
+ *
+ * 	This function is used to deliver incoming packets to network
+ * 	taps. It should be used when the normal netif_receive_skb path
+ * 	is bypassed, for example because of VLAN acceleration.
+ */
+void netif_nit_deliver(struct sk_buff *skb)
+{
+	struct packet_type *ptype, *pt_prev = NULL;
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
+		if (!ptype->dev || ptype->dev == skb->dev) {
+			if (pt_prev)
+				deliver_skb(skb, pt_prev, skb->dev);
+			pt_prev = ptype;
+		}
+	}
+	if (pt_prev)
+		pt_prev->func(skb, skb->dev, pt_prev, skb->dev);
+	rcu_read_unlock();
+}
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process

--------------090103040301060905040009--
