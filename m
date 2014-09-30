From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 net 1/2] tg3: Allow for recieve of full-size 8021AD frames
Date: Tue, 30 Sep 2014 19:39:36 -0400
Message-ID: <1412120377-11125-2-git-send-email-vyasevic@redhat.com>
References: <1412120377-11125-1-git-send-email-vyasevic@redhat.com>
Cc: prashant@broadcom.com, mchan@broadcom.com, sony.chacko@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:63282 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaI3Xjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 19:39:47 -0400
Received: by mail-qa0-f47.google.com with SMTP id cm18so10185qab.20
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 16:39:47 -0700 (PDT)
In-Reply-To: <1412120377-11125-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving a vlan-tagged frame that still contains
a vlan header, the length of the packet will be greater
then MTU+ETH_HLEN since it will account of the extra
vlan header.  TG3 checks this for the case for 802.1Q,
but not for 802.1ad.  As a result, full sized 802.1ad
frames get dropped by the card.

Add a check for 802.1ad protocol when receving full
sized frames.

Suggested-by: Prashant Sreedharan <prashant@broadcom.com>
CC: Prashant Sreedharan <prashant@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e7d3a62..ba49948 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6918,7 +6918,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		skb->protocol = eth_type_trans(skb, tp->dev);
 
 		if (len > (tp->dev->mtu + ETH_HLEN) &&
-		    skb->protocol != htons(ETH_P_8021Q)) {
+		    skb->protocol != htons(ETH_P_8021Q) &&
+		    skb->protocol != htons(ETH_P_8021AD)) {
 			dev_kfree_skb_any(skb);
 			goto drop_it_no_recycle;
 		}
-- 
1.9.3
