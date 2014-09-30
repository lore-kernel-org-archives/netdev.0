From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 net 2/2] bnx2: Correctly receive full sized 802.1ad fragmes
Date: Tue, 30 Sep 2014 19:39:37 -0400
Message-ID: <1412120377-11125-3-git-send-email-vyasevic@redhat.com>
References: <1412120377-11125-1-git-send-email-vyasevic@redhat.com>
Cc: prashant@broadcom.com, mchan@broadcom.com, sony.chacko@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:33950 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbaI3Xju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 19:39:50 -0400
Received: by mail-qg0-f42.google.com with SMTP id z60so37055qgd.15
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 16:39:48 -0700 (PDT)
In-Reply-To: <1412120377-11125-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver, similar to tg3, has a check that will
cause full sized 802.1ad frames to be dropped.  The
frame will be larger then the standard mtu due to the
presense of vlan header that has not been stripped.
The driver should not drop this frame and should process
it just like it does for 802.1q.

CC: Sony Chacko <sony.chacko@qlogic.com>
CC: Dept-HSGLinuxNICDev@qlogic.com
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2fee73b..823d01c 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3236,8 +3236,9 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
-		if ((len > (bp->dev->mtu + ETH_HLEN)) &&
-			(ntohs(skb->protocol) != 0x8100)) {
+		if (len > (bp->dev->mtu + ETH_HLEN) &&
+		    skb->protocol != htons(0x8100) &&
+		    skb->protocol != htons(ETH_P_8021AD)) {
 
 			dev_kfree_skb(skb);
 			goto next_rx;
-- 
1.9.3
