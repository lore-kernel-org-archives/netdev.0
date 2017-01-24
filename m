From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] net: reset ct before calling ndo_start_xmit
Date: Tue, 24 Jan 2017 10:40:13 +0100
Message-ID: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45422 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750733AbdAXJlk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 04:41:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices (e.g. ipoib and most wifi drivers) can retain the
to-be-xmitted packets on some internal queue for a possibly
unlimited time.

Removing conntrack modules after some skbs are queued on any of
those devices may cause rmmod to hang waiting for ct refcount going
away.

Since clearing skb nfct early can also improve the performance,
we now clear skb nfct before calling ndo_start_xmit() for all
the devices not strictly requiring such information, that is,
all virtual devices.

Currently we use the NETIF_F_LLTX feature bit to identify such devices,
since all the [legacy] phys drivers setting such bit are not prone
the hangup issue. The plan is adding a specific 'this is a
virtual device' priv flag and use it instead, in a later net-next
patch.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/netdevice.h | 7 +++++++
 net/core/dev.c            | 3 +++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9bde955..6e6b2ea 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4200,6 +4200,13 @@ static inline bool netif_reduces_vlan_mtu(struct net_device *dev)
 	return dev->priv_flags & IFF_MACSEC;
 }
 
+/* return true if we should preserve skb nfct before calling ndo_start_xmit() */
+static inline bool netif_needs_ct(struct net_device *dev)
+{
+	/* any kind of virtual device needs to preserve the ct entry */
+	return dev->features & NETIF_F_LLTX;
+}
+
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
diff --git a/net/core/dev.c b/net/core/dev.c
index 7f218e0..85fcae0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2886,6 +2886,9 @@ static int xmit_one(struct sk_buff *skb, struct net_device *dev,
 	unsigned int len;
 	int rc;
 
+	if (!netif_needs_ct(dev))
+		nf_reset(skb);
+
 	if (!list_empty(&ptype_all) || !list_empty(&dev->ptype_all))
 		dev_queue_xmit_nit(skb, dev);
 
-- 
2.9.3
