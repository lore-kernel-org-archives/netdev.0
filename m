From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [mac802154][question] MAC layer RX datapath design
Date: Fri, 4 May 2012 11:34:59 +0400
Message-ID: <CAJmB2rCnUQ9nS+jJt2E6oHW_QmEX2tA4g+yQs0vCJeFNpNxS2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:49937 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751535Ab2EDHfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 03:35:01 -0400
Received: by lahj13 with SMTP id j13so1812930lah.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 00:34:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Two months ago I sent a patch-set for the basic mac802154 support. The problem
was in the design of RX datapath. The doubtful patch is listed in the end.

Your comments were:

> If packets are properly pushed into the stack via the core receive
> packet processing of the networking, you should always be in softirq
> context and therefore have no need to a workqueue to get out of hardirq
> context.
> Please redo this code so that it processes RX packets properly and
> consistently with how other protocol layers do things, which is taking
> packets from the netif_receive_skb() et al. paths via core protocol
> demux and therefore running always in softirq context.

Please see below my thoughts, and Dmitry Eremin-Solenikov, please
correct me if I'm wrong and you see this mail:

The IEEE 802.15.4 stack contains 3 main levels:
 - ieee802154 - 802.15.4 address family/netlink interface
 - mac802154 - 802.15.4 MAC layer
 - physical - device drivers

The IEEE 802.15.4 standard defines 4 MAC packet types:
 - beacon frame
 - MAC command frame
 - acknowledgement frame
 - data frame

and only the data frame should be pushed to the upper layer. Others must be
managed by MAC layer only. And only if the frame represents a data burst, MAC
layer calls netif_rx and sends packet to the network queue (which is handled
by the ieee802154 layer).

So that's the reason why workqueue was designed as a middle "medium" between
drivers and MAC layer - to communicate MAC-specific information. And the overall
conception is based on mac80211 code in mainline.


If this conception is still undesirable, could you, or anybody else, please
give me any hint how to improve it?


With best regards,
Alexander


8<--

diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
new file mode 100644
index 0000000..3446379
--- /dev/null
+++ b/net/mac802154/rx.c
@@ -0,0 +1,109 @@
...
...
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/workqueue.h>
+#include <linux/netdevice.h>
+#include <linux/crc-ccitt.h>
+
+#include <net/mac802154.h>
+#include <net/ieee802154_netdev.h>
+
+#include "mac802154.h"
+
+static void
+mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
+{
+       struct mac802154_priv *priv = mac802154_to_priv(hw);
+
+       mac_cb(skb)->lqi = lqi;
+       skb->protocol = htons(ETH_P_IEEE802154);
+       skb_reset_mac_header(skb);
+
+       BUILD_BUG_ON(sizeof(struct ieee802154_mac_cb) > sizeof(skb->cb));
+
+       if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
+               u16 crc;
+
+               if (skb->len < 2) {
+                       pr_debug("(%s): got invalid frame\n", __func__);
+                       goto out;
+               }
+               crc = crc_ccitt(0, skb->data, skb->len);
+               if (crc) {
+                       pr_debug("(%s): CRC mismatch\n", __func__);
+                       goto out;
+               }
+               skb_trim(skb, skb->len - 2); /* CRC */
+       }
+
+out:
+       dev_kfree_skb(skb);
+       return;
+}
+
+struct rx_work {
+       struct sk_buff *skb;
+       struct work_struct work;
+       struct ieee802154_dev *dev;
+       u8 lqi;
+};
+
+static void mac802154_rx_worker(struct work_struct *work)
+{
+       struct rx_work *rw = container_of(work, struct rx_work, work);
+       struct sk_buff *skb = rw->skb;
+
+       mac802154_subif_rx(rw->dev, skb, rw->lqi);
+       kfree(rw);
+}
+
+void
+ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
+       struct mac802154_priv *priv = mac802154_to_priv(dev);
+       struct rx_work *work;
+
+       if (!skb)
+               return;
+
+       work = kzalloc(sizeof(struct rx_work), GFP_ATOMIC);
+       if (!work)
+               return;
+
+       INIT_WORK(&work->work, mac802154_rx_worker);
+       work->skb = skb;
+       work->dev = dev;
+       work->lqi = lqi;
+
+       queue_work(priv->dev_workqueue, &work->work);
+}
+EXPORT_SYMBOL(ieee802154_rx_irqsafe);
+
+void mac802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
+{
+       if (skb)
+               mac802154_subif_rx(dev, skb, lqi);
+}
+EXPORT_SYMBOL(mac802154_rx);
