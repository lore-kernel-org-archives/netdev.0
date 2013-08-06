From: Dave Jones <davej@redhat.com>
Subject: Re: 8139cp: Add dma_mapping_error checking
Date: Tue, 6 Aug 2013 11:01:14 -0400
Message-ID: <20130806150114.GA29184@redhat.com>
References: <20130804005227.CA1B0660D02@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10533 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753954Ab3HFPEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 11:04:14 -0400
Content-Disposition: inline
In-Reply-To: <20130804005227.CA1B0660D02@gitolite.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 04, 2013 at 12:52:27AM +0000, Linux Kernel wrote:
 > Gitweb:     http://git.kernel.org/linus/;a=commit;h=cf3c4c03060b688cbc389ebc5065ebcce5653e96
 > Commit:     cf3c4c03060b688cbc389ebc5065ebcce5653e96
 > Parent:     d9d10a30964504af834d8d250a0c76d4ae91eb1e
 > Author:     Neil Horman <nhorman@tuxdriver.com>
 > AuthorDate: Wed Jul 31 09:03:56 2013 -0400
 > Committer:  David S. Miller <davem@davemloft.net>
 > CommitDate: Wed Jul 31 17:01:43 2013 -0700
 > 
 >     8139cp: Add dma_mapping_error checking
 >     
 >     Self explanitory dma_mapping_error addition to the 8139 driver, based on this:
 >     https://bugzilla.redhat.com/show_bug.cgi?id=947250
 >     
 >     It showed several backtraces arising for dma_map_* usage without checking the
 >     return code on the mapping.  Add the check and abort the rx/tx operation if its
 >     failed.  Untested as I have no hardware and the reporter has wandered off, but
 >     seems pretty straightforward.
 >     
 >     Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
 >     CC: "David S. Miller" <davem@davemloft.net>
 >     CC: Francois Romieu <romieu@fr.zoreil.com>
 >     Signed-off-by: David S. Miller <davem@davemloft.net>
 > 
 > diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c

.. (allocation of new_skb occurs)
 

 > +		new_mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
 > +					 PCI_DMA_FROMDEVICE);
 > +		if (dma_mapping_error(&cp->pdev->dev, new_mapping)) {
 > +			dev->stats.rx_dropped++;
 > +			goto rx_next;
 > +		}
 > +

...

 547 rx_next:
 548                 cp->rx_ring[rx_tail].opts2 = 0;
 549                 cp->rx_ring[rx_tail].addr = cpu_to_le64(mapping);
 550                 if (rx_tail == (CP_RX_RING_SIZE - 1))
 551                         desc->opts1 = cpu_to_le32(DescOwn | RingEnd |
 552                                                   cp->rx_buf_sz);
 553                 else
 554                         desc->opts1 = cpu_to_le32(DescOwn | cp->rx_buf_sz);
 555                 rx_tail = NEXT_RX(rx_tail);
 556 
 557                 if (rx >= budget)
 558                         break;
 559         }

If we get to that 'break', we leak new_skb.

This maybe.... ?

	Dave


8139cp: Fix skb leak in rx_status_loop failure path.
Introduced in cf3c4c03060b688cbc389ebc5065ebcce5653e96

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 6f35f84..d2e5919 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -524,6 +524,7 @@ rx_status_loop:
 					 PCI_DMA_FROMDEVICE);
 		if (dma_mapping_error(&cp->pdev->dev, new_mapping)) {
 			dev->stats.rx_dropped++;
+			kfree_skb(new_skb);
 			goto rx_next;
 		}
 
