From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Sun, 31 Jan 2010 23:18:35 +0100
Message-ID: <20100131221835.GA3317@del.dom.local>
References: <20100128223447.GC3109@del.dom.local>
 <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local>
 <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam>
 <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local>
 <4B650D53.2010607@majjas.com>
 <4B65D0F9.2020602@majjas.com>
 <4B65FD12.7090101@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753458Ab0AaWSo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B65FD12.7090101@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 31, 2010 at 04:58:42PM -0500, Michael Breuer wrote:
> On 1/31/2010 1:50 PM, Michael Breuer wrote:
> >On 1/30/2010 11:55 PM, Michael Breuer wrote:
> >>On 01/30/2010 07:34 PM, Jarek Poplawski wrote:
> >>>
> >>>Could you try the patch below to show maybe some other users of
> >>>dma-debug entries?
> >>>
> >>>Jarek P.
> >>>---
> >>>
> >>With the default # entries & dma_debug_driver=sky2:
> >>
> >>6:00 is eth0 & 4:00 is eth1.
> >>
> >>Jan 30 23:53:14 mail kernel: DMA-API: 0000:06:00.0: entries: 31961
> >>...
> >>
> >I put a printk as a third else case in sky2_tx_unmap. Looks like
> >the issue is that a large number (perhaps all) calls to
> >sky2_tx_unmap have re->flags set to neither TX_MAP_SINGLE or
> >TX_MAP_PAGE. Thus the elements are never being unmapped.
> >
> >I suspect that the system collapses when using DMAR sooner than if
> >not using DMAR. Probably some hardware limitation on the number of
> >mapped elements that is less than the software limitation. I don't
> >see at present how a ring element can ever get to this code
> >without re->flags being set to one or the other.
> >
> >
> Put some more debugging code in... re->flags is always NULL upon
> entry to sky2_tx_unmap.
> 

Yes, good point! Could you try if this patch can fix it. (not compiled)

Thanks,
Jarek P.
---

 drivers/net/sky2.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d760650..3437917 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1025,9 +1025,10 @@ static void sky2_prefetch_init(struct sky2_hw *hw, u32 qaddr,
 static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
 {
 	struct sky2_tx_le *le = sky2->tx_le + *slot;
-	struct tx_ring_info *re = sky2->tx_ring + *slot;
+	struct tx_ring_info *re;
 
 	*slot = RING_NEXT(*slot, sky2->tx_ring_size);
+	re = sky2->tx_ring + *slot;
 	re->flags = 0;
 	re->skb = NULL;
 	le->ctrl = 0;
@@ -1036,13 +1037,16 @@ static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
 
 static void tx_init(struct sky2_port *sky2)
 {
-	struct sky2_tx_le *le;
+	struct sky2_tx_le *le = sky2->tx_le;
+	struct tx_ring_info *re = sky2->tx_ring;
 
 	sky2->tx_prod = sky2->tx_cons = 0;
 	sky2->tx_tcpsum = 0;
 	sky2->tx_last_mss = 0;
 
-	le = get_tx_le(sky2, &sky2->tx_prod);
+	re->flags = 0;
+	re->skb = NULL;
+	le->ctrl = 0;
 	le->addr = 0;
 	le->opcode = OP_ADDR64 | HW_OWNER;
 	sky2->tx_last_upper = 0;
