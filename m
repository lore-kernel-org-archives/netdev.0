From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V3 net 2/3] be2net: Fix offload features for Q-in-Q packets
Date: Tue, 23 May 2017 13:38:42 -0400
Message-ID: <1495561123-1819-3-git-send-email-vyasevic@redhat.com>
References: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
Cc: alexander.duyck@gmail.com, makita.toshiaki@lab.ntt.co.jp,
        Vladislav Yasevich <vyasevic@redhat.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:32981 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933876AbdEWRiy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 13:38:54 -0400
Received: by mail-qt0-f194.google.com with SMTP id a46so23135340qte.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 10:38:54 -0700 (PDT)
In-Reply-To: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least some of the be2net cards do not seem to be capabled
of performing checksum offload computions on Q-in-Q packets.
In these case, the recevied checksum on the remote is invalid
and TCP syn packets are dropped.

This patch adds a call to check disbled acceleration features
on Q-in-Q tagged traffic.

CC: Sathya Perla <sathya.perla@broadcom.com>
CC: Ajit Khaparde <ajit.khaparde@broadcom.com>
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
