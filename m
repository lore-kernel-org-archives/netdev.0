From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Subject: [PATCH 1/2] atm: br2684: Make headroom and hard_header_len depend on the payload type
Date: Mon, 28 Nov 2011 13:40:15 -0500
Message-ID: <201111281840.pASIeFhI011675@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:36901 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab1K1SlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 13:41:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Pascal Hambourg <pascal@plouf.fr.eu.org>
Date: Wed, 17 Aug 2011 08:37:18 +0200
Subject: [PATCH 1/2] atm: br2684: Make headroom and hard_header_len depend on the payload type

Routed payload requires less headroom than bridged payload.
So do not reallocate headroom if not needed.
Also, add worst case AAL5 overhead to netdev->hard_header_len.

Signed-off-by: Pascal Hambourg <pascal@plouf.fr.eu.org>
Signed-off-by: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
---
 net/atm/br2684.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 53b0aa1..ed72263 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -202,7 +202,10 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct net_device *dev,
 {
 	struct br2684_dev *brdev = BRPRIV(dev);
 	struct atm_vcc *atmvcc;
-	int minheadroom = (brvcc->encaps == e_llc) ? 10 : 2;
+	int minheadroom = (brvcc->encaps == e_llc) ?
+		((brdev->payload == p_bridged) ?
+			sizeof(llc_oui_pid_pad) : sizeof(llc_oui_ipv4)) :
+		((brdev->payload == p_bridged) ? BR2684_PAD_LEN : 0);
 
 	if (skb_headroom(skb) < minheadroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, minheadroom);
@@ -583,6 +586,7 @@ static void br2684_setup(struct net_device *netdev)
 	struct br2684_dev *brdev = BRPRIV(netdev);
 
 	ether_setup(netdev);
+	netdev->hard_header_len += sizeof(llc_oui_pid_pad); /* worst case */
 	brdev->net_dev = netdev;
 
 	netdev->netdev_ops = &br2684_netdev_ops;
@@ -595,7 +599,7 @@ static void br2684_setup_routed(struct net_device *netdev)
 	struct br2684_dev *brdev = BRPRIV(netdev);
 
 	brdev->net_dev = netdev;
-	netdev->hard_header_len = 0;
+	netdev->hard_header_len = sizeof(llc_oui_ipv4); /* worst case */
 	netdev->netdev_ops = &br2684_netdev_ops_routed;
 	netdev->addr_len = 0;
 	netdev->mtu = 1500;
-- 
1.7.6
