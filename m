From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: [PATCH] sky2: Fix crash on receiving VLAN frames
Date: Fri,  3 May 2013 18:22:04 +0400
Message-ID: <1367590924-8594-1-git-send-email-kirr@mns.spb.ru>
Cc: netdev@vger.kernel.org, Kirill Smelkov <kirr@mns.spb.ru>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Mirko Lindner <mlindner@marvell.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:40514 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933859Ab3ECOgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 10:36:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After recent 86a9bad3 (net: vlan: add protocol argument to packet
tagging functions) my sky2 started to crash on receive of tagged
frames, with backtrace similar to

    #CRASH!!!
    vlan_do_receive
    __netif_receive_skb_core
    __netif_receive_skb
    netif_receive_skb
    sky2_poll
    ...
    __net_rx_action
    __do_softirq

The problem turned out to be:

    1) sky2 copies small packets from ring on RX, and in its
       receive_copy() skb header is copied manually field, by field, and
       only for some fields;

    2) 86a9bad3  added skb->vlan_proto, which vlan_untag() or
       __vlan_hwaccel_put_tag() set, and which is later used in
       vlan_do_receive().

       That patch updated copy_skb_header() for newly introduced
       skb->vlan_proto, but overlooked the need to also copy it in sky2's
       receive_copy().

Because of 2, we have the following scenario:

    - frame is received and tagged in a ring, by sky2_rx_tag(). Both
      skb->vlan_proto and skb->vlan_tci are set;

    - later skb is decided to be copied, but skb->vlan_proto is
      forgotten and becomes 0.

    - in the beginning of vlan_do_receive() we call

        __be16 vlan_proto = skb->vlan_proto;
        vlan_dev = vlan_find_dev(skb->dev, vlan_proto, vlan_id);

      which eventually invokes

        vlan_proto_idx(vlan_proto)

      and that routine BUGs for everything except ETH_P_8021Q and
      ETH_P_8021AD.

      Oops.

Fix it.

P.S.

Stephen, I wonder, why copy_skb_header() is not used in
sky2.c::receive_copy() ? Problems, where receive_copy was updated field
by field showed several times already, e.g.

    3f42941b    (sky2: propogate rx hash when packet is copied)
    e072b3fa    (sky2: fix receive length error in mixed non-VLAN/VLAN traffic)

Cc: Patrick McHardy <kaber@trash.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Mirko Lindner <mlindner@marvell.com>
Signed-off-by: Kirill Smelkov <kirr@mns.spb.ru>
---
 drivers/net/ethernet/marvell/sky2.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 256ae78..d175bbd 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2496,10 +2496,12 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
 		skb->rxhash = re->skb->rxhash;
+		skb->vlan_proto = re->skb->vlan_proto;
 		skb->vlan_tci = re->skb->vlan_tci;
 
 		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
 					       length, PCI_DMA_FROMDEVICE);
+		re->skb->vlan_proto = 0;
 		re->skb->vlan_tci = 0;
 		re->skb->rxhash = 0;
 		re->skb->ip_summed = CHECKSUM_NONE;
-- 
1.8.3.rc0.361.g39d8700
