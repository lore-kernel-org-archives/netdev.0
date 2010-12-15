From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid
 not used
Date: Tue, 14 Dec 2010 17:34:31 -0800
Message-ID: <20101215013431.GA21173@mcarlson.broadcom.com>
References: <20101205114404.7c0cddc2@xenia.leun.net>
 <AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
 <20101206203437.54b550e0@xenia.leun.net>
 <AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
 <20101206222703.32fbe852@xenia.leun.net>
 <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
 <20101213224510.GB17400@mcarlson.broadcom.com>
 <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
 <20101214191500.GD19951@mcarlson.broadcom.com>
 <20101215012430.120fd47f@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Jesse Gross" <jesse@nicira.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Ben Greear" <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Michael Leun" <lkml20101129@newton.leun.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101215012430.120fd47f@xenia.leun.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 04:24:30PM -0800, Michael Leun wrote:
> On Tue, 14 Dec 2010 11:15:00 -0800
> "Matt Carlson" <mcarlson@broadcom.com> wrote:
> > Michael, I'm wondering if the difference in behavior can be explained
> > by the presence or absence of management firmware.  Can you look at
> > the driver sign-on messages in your syslogs for ASF[]?  I'm half
> > expecting the 5752 to show "ASF[0]" and the 5714 to show "ASF[1]".
> > If you see this, and the below patch doesn't fix the problem, let me
> > know.  I have another test I'd like you to run.
> 
> Do I understand this correct? "Management firmware" or ASF is some
> feature, vendor decides to built into network card (firmware) or not?

Right.

> If so, would'nt one expect two oneboard network cards in one server
> to look alike?

Mostly, yes.  Except for.....

> HP Proliant DL320G5
> 
> <6>tg3.c:v3.113 (August 2, 2010)
> <6>tg3 0000:03:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> <6>tg3 0000:03:04.0: eth0: Tigon3 [partno(N/A) rev 9003] (PCIX:133MHz:64-bit) MAC address xx:xx:xx:xx:xx:xx
> <6>tg3 0000:03:04.0: eth0: attached PHY is 5714 (10/100/1000Base-T Ethernet) (WireSpeed[1])
> <6>tg3 0000:03:04.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
                                                      This =>  ^^^^^^
> <6>tg3 0000:03:04.0: eth0: dma_rwctrl[76148000] dma_mask[64-bit]
> <6>tg3 0000:03:04.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> <6>tg3 0000:03:04.1: eth1: Tigon3 [partno(N/A) rev 9003] (PCIX:133MHz:64-bit) MAC address xx:xx:xx:xx:xx:xx
> <6>tg3 0000:03:04.1: eth1: attached PHY is 5714 (10/100/1000Base-T Ethernet) (WireSpeed[1])
> <6>tg3 0000:03:04.1: eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
                                                  And this =>  ^^^^^^
> <6>tg3 0000:03:04.1: eth1: dma_rwctrl[76148000] dma_mask[64-bit]

So management firmware is turned off on the second port.

> Lenovo ThinkPad z61m
> 
> [    2.679130] tg3.c:v3.113 (August 2, 2010)
> [    2.679176] tg3 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    2.679188] tg3 0000:02:00.0: setting latency timer to 64
> [    2.728572] tg3 0000:02:00.0: eth0: Tigon3 [partno(BCM95752m) rev 6002] (PCI Express) MAC address xx:xx:xx:xx:xx:xx
> [    2.728577] tg3 0000:02:00.0: eth0: attached PHY is 5752 (10/100/1000Base-T Ethernet) (WireSpeed[1])
> [    2.728581] tg3 0000:02:00.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
                                                                           ^^^^^^
And it isn't present on the 5752.

> [    2.728585] tg3 0000:02:00.0: eth0: dma_rwctrl[76180000]
> dma_mask[64-bit]
> 
> 
> > ----
> > 
> > [PATCH] tg3: Use new VLAN code
> 
> Unfortunately had'nt time to try much now, but with 2.6.37-rc5 / your
> patch on the DL320, single user mode (nothing configured on eth) just
> after ifconfig eth0/eth1 up I see NO vlan tags on eth0 but I see vlan
> tags on eth1, so there clearly is a difference.
> 
> I should have checked if I still see vlan tags on eth1 if I configure
> some vlan there - if helpful maybe I can do this (have to look, when I
> can effort another downtime).

This would be helpful, just to solidify our findings.

> I wonder, if the difference in that both onboard cards is really there
> or if there is some malfunction in detecion?

Please run the above test first, but afterwards, can you apply the below
patch on top of your current sources.  I suspect eth1 will begin to act
like eth0.

This patch is just a test.

[PATCH] tg3: Always strip VLAN tags

This patch configures the hardware to always strip VLAN tags from
incoming packets.
---
 drivers/net/tg3.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3682205..964293f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9505,8 +9505,10 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 	/* When ASF is in use, we always keep the RX_MODE_KEEP_VLAN_TAG
 	 * flag clear.
 	 */
+#if 0
 	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
 		rx_mode |= RX_MODE_KEEP_VLAN_TAG;
+#endif
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Promiscuous mode. */
-- 
1.7.2.2
