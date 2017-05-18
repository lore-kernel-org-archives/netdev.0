From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net 2/3] be2net: Fix offload features for Q-in-Q packets
Date: Thu, 18 May 2017 09:31:04 -0400
Message-ID: <1495114265-23368-3-git-send-email-vyasevic@redhat.com>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35854 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754741AbdERNbX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 09:31:23 -0400
Received: by mail-qk0-f194.google.com with SMTP id y128so6000393qka.3
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 06:31:23 -0700 (PDT)
In-Reply-To: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least some of the be2net cards do not seem to be capabled
of performing checksum offload computions on Q-in-Q packets.
In these case, the recevied checksum on the remote is invalid
and TCP syn packets are dropped.

This patch adds a call to check disbled acceleration features
on Q-in-Q tagged traffic.

CC: Sathya Perla <sathya.perla@broadcom.com>
CC: Ajit Khaparde <ajit.khaparde@broadcom.com
CC: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
CC: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f3a09ab..4eee18c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5078,9 +5078,11 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
 	struct be_adapter *adapter = netdev_priv(dev);
 	u8 l4_hdr = 0;
 
-	/* The code below restricts offload features for some tunneled packets.
+	/* The code below restricts offload features for some tunneled and
+	 * Q-in-Q packets.
 	 * Offload features for normal (non tunnel) packets are unchanged.
 	 */
+	features = vlan_features_check(skb, features);
 	if (!skb->encapsulation ||
 	    !(adapter->flags & BE_FLAGS_VXLAN_OFFLOADS))
 		return features;
-- 
2.7.4
