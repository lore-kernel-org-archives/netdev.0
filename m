From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] bnx2: Correctly receive full sized 802.1ad fragmes
Date: Tue, 30 Sep 2014 16:35:20 -0400
Message-ID: <1412109320-5183-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-HSGLinuxNICDev@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:33853 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaI3Uff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 16:35:35 -0400
Received: by mail-qa0-f43.google.com with SMTP id cm18so968472qab.30
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 13:35:31 -0700 (PDT)
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
