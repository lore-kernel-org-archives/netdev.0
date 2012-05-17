From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: Re: [PATCH] e1000: Reset rx ring index on receive
	overrun
Date: Thu, 17 May 2012 23:22:31 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA891188439E0@ORSMSX102.amr.corp.intel.com>
References: <20120517230140.GZ683@type.famille.thibault.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Samuel Thibault <samuel.thibault@ens-lyon.org>, "Kirsher, Jeffrey T"
	<jeffrey.t.kirsher@intel.com>, "Brandeburg, Jesse"
	<jesse.brandeburg@intel.com>, "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>, "Skidmore, Donald C"
	<donald.c.skidmore@intel.com>, "Rose,
	Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>, "Duyck,
	Alexander H" <alexander.h.duyck@intel.com>, "Ronciak, John"
	<john.ronciak@intel.com>, "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Dean Nelson <dnelson@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120517230140.GZ683@type.famille.thibault.fr>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I am interested in to see if you have actual test case and more importantly test data that shows that kernel and device indexes are not synchronized any more.


-Tushar

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Samuel Thibault
>Sent: Thursday, May 17, 2012 4:02 PM
>To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
>Carolyn; Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P;
>Duyck, Alexander H; Ronciak, John; David S. Miller; Jiri Pirko; Dean
>Nelson; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
>Cc: linux-kernel@vger.kernel.org
>Subject: [PATCH] e1000: Reset rx ring index on receive overrun
>
>At high traffic rate, the rx ring may get completely filled before we
>manage to consume it.  After it is filled, the kernel and device indexes
>are not synchronized any more, so we have to reset them, otherwise the
>kernel will be stuck waiting for the wrong slot to be filled.
>
>Signed-off-by: Samuel Thibault <samuel.thibault@ens-lyon.org>
>
>---
>This is just a patch suggestion, I'm not an expert in network drivers, I
>leave to actual driver authors to bake a better version.
>
>diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c
>b/drivers/net/ethernet/intel/e1000/e1000_main.c
>index 37caa88..77c8dbc 100644
>--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>@@ -3759,6 +3759,21 @@ static irqreturn_t e1000_intr(int irq, void *data)
> 	if (unlikely(test_bit(__E1000_DOWN, &adapter->flags)))
> 		return IRQ_HANDLED;
>
>+	if (unlikely(icr & E1000_ICR_RXO)) {
>+		/* Receive Overrun */
>+		u32 rctl;
>+		int i;
>+		rctl = er32(RCTL);
>+		ew32(RCTL, rctl & ~E1000_RCTL_EN);
>+		for (i = 0; i < adapter->num_rx_queues; i++) {
>+			memset(adapter->rx_ring[i].desc, 0, adapter-
>>rx_ring[i].size);
>+			adapter->rx_ring[i].next_to_clean = 0;
>+		}
>+		ew32(RDH, 0);
>+		ew32(RCTL, rctl);
>+		adapter->netdev->stats.rx_fifo_errors++;
>+	}
>+
> 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
> 		hw->get_link_status = 1;
> 		/* guard against interrupt when we're going down */
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in the
>body of a message to majordomo@vger.kernel.org More majordomo info at
>http://vger.kernel.org/majordomo-info.html

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
