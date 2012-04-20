From: Basil Gor <basil.gor@gmail.com>
Subject: [PATCH v2] macvlan/macvtap: Fix vlan tagging on user read
Date: Sat, 21 Apr 2012 03:20:58 +0400
Message-ID: <1334964058-3338-1-git-send-email-basilgor@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Basil Gor <basilgor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34318 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192Ab2DTXVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 19:21:53 -0400
Received: by iagz16 with SMTP id z16so14037138iag.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 16:21:53 -0700 (PDT)
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

Changes from original version:
vlan header restoring code is moved from macvtap_forward to
macvtap_receive

Signed-off-by: Basil Gor <basilgor@gmail.com>
---
 drivers/net/macvtap.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0427c65..5e025d9 100644
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
@@ -271,6 +272,15 @@ drop:
 static int macvtap_receive(struct sk_buff *skb)
 {
 	skb_push(skb, ETH_HLEN);
+
+	if (vlan_tx_tag_present(skb)) {
+		skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
+		if (unlikely(!skb))
+			return NET_RX_DROP;
+
+		skb->vlan_tci = 0;
+	}
+
 	return macvtap_forward(skb->dev, skb);
 }
 
-- 
1.7.6.5
