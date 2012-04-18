From: Basil Gor <basil.gor@gmail.com>
Subject: [PATCH] macvlan/macvtap: Fix vlan tagging on user read
Date: Wed, 18 Apr 2012 22:34:58 +0400
Message-ID: <1334774098-22886-1-git-send-email-basilgor@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Basil Gor <basilgor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:61223 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab2DRSiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 14:38:18 -0400
Received: by lbom4 with SMTP id m4so2464930lbo.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 11:38:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlan tag is restored during buffer transmit to a network device (bridge
port) in bridging code in case of tun/tap driver. In case of macvtap it
has to be done explicitly. Otherwise vlan_tci is ignored and user always
gets untagged packets.

Scenario tested:
kvm guests (that use vlans) migration from bridged network to macvtap
revealed that packets delivered to guests are always untagged. Dumping
and comparing sk_buff in case of tap and macvtap driver showed that
macvtap does not restore vlan_tci.

With current patch applied I was able to get working network, kvm guests
get correctly tagged packets and can reach each other when macvtap in
bridge mode (both with no vlans and through vlan interfaces).

Signed-off-by: Basil Gor <basilgor@gmail.com>
---
 drivers/net/macvtap.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0427c65..a6802b9 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1,6 +1,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_macvlan.h>
 #include <linux/interrupt.h>
+#include <linux/if_vlan.h>
 #include <linux/nsproxy.h>
 #include <linux/compat.h>
 #include <linux/if_tun.h>
@@ -254,6 +255,14 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
 		goto drop;
 
+	if (vlan_tx_tag_present(skb)) {
+		skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
+		if (unlikely(!skb))
+			return NET_RX_DROP;
+
+		skb->vlan_tci = 0;
+	}
+
 	skb_queue_tail(&q->sk.sk_receive_queue, skb);
 	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
 	return NET_RX_SUCCESS;
-- 
1.7.6.5
