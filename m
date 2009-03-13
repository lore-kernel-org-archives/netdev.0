From: Dave Jones <davej@redhat.com>
Subject: r8169 skb leak
Date: Fri, 13 Mar 2009 17:10:08 -0400
Message-ID: <20090313211008.GA14796@redhat.com>
References: <49B89385.4090005@cosmosbay.com> <20090312045657.GB7132@redhat.com> <49B89A33.2030207@cosmosbay.com> <20090313.133640.130060599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:32867 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbZCMVKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 17:10:13 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n2DLA9AR029706
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 17:10:09 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n2DLA9mq022214
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 17:10:10 -0400
Received: from gelk.kernelslacker.org (vpn-12-86.rdu.redhat.com [10.11.12.86])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n2DLA9TT026032
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 17:10:09 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n2DLA8lC014807
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 17:10:08 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.3/8.14.3/Submit) id n2DLA8Vk014803
	for netdev@vger.kernel.org; Fri, 13 Mar 2009 17:10:08 -0400
Content-Disposition: inline
In-Reply-To: <20090313.133640.130060599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

r8169 seems to have the same problem that the via-velocity did with skb padding.
Found by code-inspection only, no hardware to test.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b347340..07b1de1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3145,7 +3145,9 @@ err_out:
 static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
 				 struct TxDesc *desc)
 {
-	unsigned int len = tx_skb->len;
+	unsigned int len;
+
+	len = max_t(unsigned, tx_skb->len, ETH_ZLEN);
 
 	pci_unmap_single(pdev, le64_to_cpu(desc->addr), len, PCI_DMA_TODEVICE);
 	desc->opts1 = 0x00;
@@ -3364,11 +3366,9 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else {
 		len = skb->len;
 
-		if (unlikely(len < ETH_ZLEN)) {
-			if (skb_padto(skb, ETH_ZLEN))
-				goto err_update_stats;
-			len = ETH_ZLEN;
-		}
+		if (skb_padto(skb, ETH_ZLEN))
+			goto err_update_stats;
+		len = max_t(unsigned, skb->len, ETH_ZLEN);
 
 		opts1 |= FirstFrag | LastFrag;
 		tp->tx_skb[entry].skb = skb;
-- 
http://www.codemonkey.org.uk
