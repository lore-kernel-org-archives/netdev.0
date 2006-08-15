From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] move skb->dev assignment into netdev_alloc_skb
Date: Mon, 14 Aug 2006 18:00:48 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0608141742290.336@jbrandeb-desk.amr.corp.intel.com>
References: <20060805130109.GB24121@lst.de> <20060807.161056.85410448.davem@davemloft.net>
 <4807377b0608071729p3c744d1fn6859178874019418@mail.gmail.com>
 <20060812135707.GA5950@lst.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39183 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S932465AbWHOBA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 21:00:58 -0400
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20060812135707.GA5950@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Aug 2006, Christoph Hellwig wrote:
> > >> Signed-off-by: Christoph Hellwig <hch@lst.de>
> > >
> > >Since the e1000 change is non-trivial I'm not going to bypass
> > >the driver author on it, sorry.
> > >
> > >What I did do was put the netdev_alloc_skb() change into my
> > >tree, and since I'm co-author of the tg3 driver I'll apply
> > >that bit too.
> > >
> > >The e1000 bit will need to go through the e1000 maintainers.
> > 
> > Thank you, I'll take a look at this tomorrow, as I need to digest the
> > patch in context.
> 
> Did you get a chance to look at it?  For your conveniance here's just
> the e1000 bits, without the hunks Dave has commited already:
> 

I'm okay with this change.  Auke will shortly be submitting a patch set 
for 2.6.19 and it should include this.

Thanks for the feedback Christoph!

Jesse

for reference this is the patch, but like i said auke will enqueue it in 
GIT and send it to Jeff for inclusion.

e1000: clean up skb allocation code, patch submitted by Christoph

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

---

 drivers/net/e1000/e1000_main.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 627f224..66c0325 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -36,7 +36,7 @@ static char e1000_driver_string[] = "Int
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION "7.1.9-k4"DRIVERNAPI
+#define DRV_VERSION "7.1.9-k6"DRIVERNAPI
 char e1000_driver_version[] = DRV_VERSION;
 static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -3711,7 +3711,6 @@ e1000_clean_rx_irq(struct e1000_adapter 
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				new_skb->dev = netdev;
 				memcpy(new_skb->data - NET_IP_ALIGN,
 				       skb->data - NET_IP_ALIGN,
 				       length + NET_IP_ALIGN);
@@ -3978,13 +3977,13 @@ e1000_alloc_rx_buffers(struct e1000_adap
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (cleaned_count--) {
-		if (!(skb = buffer_info->skb))
-			skb = netdev_alloc_skb(netdev, bufsz);
-		else {
+		skb = buffer_info->skb;
+		if (skb) {
 			skb_trim(skb, 0);
 			goto map_skb;
 		}
 
+		skb = netdev_alloc_skb(netdev, bufsz);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
 			adapter->alloc_rx_buff_failed++;
@@ -4009,10 +4008,10 @@ e1000_alloc_rx_buffers(struct e1000_adap
 				dev_kfree_skb(skb);
 				dev_kfree_skb(oldskb);
 				break; /* while !buffer_info->skb */
-			} else {
-				/* Use new allocation */
-				dev_kfree_skb(oldskb);
 			}
+
+			/* Use new allocation */
+			dev_kfree_skb(oldskb);
 		}
 		/* Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
@@ -4020,8 +4019,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 map_skb:
@@ -4135,8 +4132,6 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 
-		skb->dev = netdev;
-
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_ps_bsize0;
 		buffer_info->dma = pci_map_single(pdev, skb->data,
