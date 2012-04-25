From: Basil Gor <basil.gor@gmail.com>
Subject: [PATCH v3 2/2] macvtap: restore vlan header on user read
Date: Wed, 25 Apr 2012 21:01:56 +0400
Message-ID: <1335373316-612-1-git-send-email-basil.gor@gmail.com>
References: <m1ipgtzwew.fsf@fess.ebiederm.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:44641 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299Ab2DYRCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 13:02:34 -0400
Received: by mail-lb0-f174.google.com with SMTP id gf7so270700lbb.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 10:02:33 -0700 (PDT)
In-Reply-To: <m1ipgtzwew.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlan tag is restored during buffer transmit to a network device (bridge
port) in bridging code in case of tun/tap driver. In case of macvtap it
has to be done explicitly. Otherwise vlan_tci is ignored and user always
gets untagged packets.

Signed-off-by: Basil Gor <basil.gor@gmail.com>
---
 drivers/net/macvtap.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0427c65..28d2678 100644
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
@@ -753,13 +754,21 @@ static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
 
 /* Put packet to the user space buffer */
 static ssize_t macvtap_put_user(struct macvtap_queue *q,
-				const struct sk_buff *skb,
+				struct sk_buff *skb,
 				const struct iovec *iv, int len)
 {
 	struct macvlan_dev *vlan;
 	int ret;
 	int vnet_hdr_len = 0;
 
+	if (vlan_tx_tag_present(skb)) {
+		skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
+		if (unlikely(!skb))
+			return -ENOMEM;
+
+		skb->vlan_tci = 0;
+	}
+
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
 		vnet_hdr_len = q->vnet_hdr_sz;
-- 
1.7.6.5
