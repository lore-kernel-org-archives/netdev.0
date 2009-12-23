From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: ucc_geth broken in 2.6.32 by
	864fdf884e82bacbe8ca5e93bd43393a61d2e2b4
Date: Wed, 23 Dec 2009 15:15:46 -0500
Message-ID: <20091223201546.GG760@caffeine.csclub.uwaterloo.ca>
References: <20091223174019.GB762@caffeine.csclub.uwaterloo.ca>
	<20091223180415.GA12987@oksana.dev.rtsoft.ru>
	<20091223200948.GF760@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Anton Vorontsov <avorontsov@ru.mvista.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20091223200948.GF760@caffeine.csclub.uwaterloo.ca>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 03:09:48PM -0500, Lennart Sorensen wrote:
> On Wed, Dec 23, 2009 at 09:04:15PM +0300, Anton Vorontsov wrote:
> > On Wed, Dec 23, 2009 at 12:40:19PM -0500, Lennart Sorensen wrote:
> > > We use the ucc_geth for 6 ports (4 100Mbit and 2 Gbit ports) on an
> > > mpc8360e.  Up to 2.6.31 this worked fine.  2.6.32 on the other hand
> > > crashes very quickly after boot.
> > 
> > Hm. Just curious, what CPU revision you use? So that I could try
> > to reproduce the issue... I have MPC8360E-MDS boards, rev 2.0 and
> > rev rev 2.1 CPUs, Marvell PHYs. I also have MPC8360E-RDK (rev 2.1).
> > And I didn't see any issues with this patch.
> 
> Hmm, I have an MDS around, so I could probably try and see if it is
> reproduceable there.
> 
> CPU:   e300c1, MPC8360EA, Rev: 2.1 at 533.333 MHz, CSB: 266.667 MHz
> BOARD: 12-86-0016-001 [00000000]                                   
> UPMA:  Configured for Compact Flash PIO Mode                        
> I2C:   ready                                                       
> SPI:   ready                                                       
> DRAM:  512 MB                                                      
> MTEST: Testing data bus                                            
> MTEST: Testing address bus                                         
> MTEST: PASS                                                        
> BCSR:  Ver A000B                                                   
> FLASH: 32 MB
> 
> The PHY we use is KSZ8001LS for the 100Mbit ports, and on the port
> that usually fails first is a marvel 88E1111 running fixed gigabit link
> (converts to serdes before connecting to a switch chip).
> 
> I am actually surprised this code should matter at all given out of the
> 6 ethernet ports only two actually go to external ports, the rest are
> fixed link.
> 
> If relevant here are some chunks from the dtb related to ethernet:
> 
>         aliases {
>                 ethernet0 = &enet0;
>                 ethernet1 = &enet1;
>                 ethernet2 = &enet2;
>                 ethernet3 = &enet3;
>                 ethernet4 = &enet4;
>                 ethernet5 = &enet5;
>                 serial0 = &serial0;
>                 serial1 = &serial1;
>         };
> 
>                 mdio {
>                         compatible = "virtual,mdio-gpio";
>                         #address-cells = <1>;
>                         #size-cells = <0>;
>                         /* MDC = PG6 MDIO = PG7 */
>                         gpios = <&qe_pio_g 6 0 &qe_pio_g 7 0>;
> 
>                         phy0: ethernet-phy@00 {
>                                 reg = <0x18>;
>                                 device_type = "ethernet-phy";
>                         };
>                         phy1: ethernet-phy@01 {
>                                 reg = <0x06>;
>                                 device_type = "ethernet-phy";
>                         };
>                         phy2: ethernet-phy@02 {
>                                 reg = <0x0F>;
>                                 device_type = "ethernet-phy";
>                         };
>                         phy3: ethernet-phy@03 {
>                                 reg = <0x17>;
>                                 device_type = "ethernet-phy";
>                         };
>                 };
> 
>                 /* UCC5 Linux fe-cm-1 */
>                 enet0: ethernet@2400 {
>                         device_type = "network";
>                         compatible = "ucc_geth";
>                         cell-index = <0x5>;
>                         reg = <0x2400 0x200>;
>                         interrupts = <0x28>;
>                         interrupt-parent = <&qeic>;
>                         local-mac-address = [ 00 00 00 00 00 00 ]; /* [U-BOOT] */
>                         rx-clock-name = "clk16";
>                         tx-clock-name = "clk14";
>                         phy-handle = <&phy2>;
>                         phy-connection-type = "mii";
>                         pio-handle = <&ucc5>;
>                 };
>                 /* UCC 6 Linux fe-em-1 */
>                 enet1: ethernet@3400 {
>                         device_type = "network";
>                         compatible = "ucc_geth";
>                         cell-index = <0x6>;
>                         reg = <0x3400 0x200>;
>                         interrupts = <0x29>;
>                         interrupt-parent = <&qeic>;
>                         local-mac-address = [ 00 00 00 00 00 00 ]; /* [U-BOOT] */
>                         rx-clock-name = "clk7";
>                         tx-clock-name = "clk8";
>                         phy-handle = <&phy3>;
>                         phy-connection-type = "mii";
>                         pio-handle = <&ucc6>;
>                 };
>                 /* UCC 1 & 3  1000BT Data Plane dp0 */
>                 enet2: ethernet@2000 {
>                         device_type = "network";
>                         compatible = "ucc_geth";
>                         cell-index = <0x1>;
>                         reg = <0x2000 0x200>;
>                         interrupts = <0x20>;
>                         interrupt-parent = <&qeic>;
>                         local-mac-address = [ 00 00 00 00 00 00 ]; /* [U-BOOT] */
>                         rx-clock-name = "none";
>                         tx-clock-name = "clk9";
>                         fixed-link = <0x03 1 1000 0 0>; /* P3 on data plane switch on SM */
>                         phy-connection-type = "gmii";
>                         pio-handle = <&ucc1>;
>                 };
>                 /* UCC 7 100BT Data Plane dp1 */
>                 enet3: ethernet@2600 {
>                         device_type = "network";
>                         compatible = "ucc_geth";
>                         cell-index = <0x7>;
>                         reg = <0x2600 0x200>;
>                         interrupts = <0x2a>;
>                         interrupt-parent = <&qeic>;
>                         local-mac-address = [ 00 00 00 00 00 00 ]; /* [U-BOOT] */
>                         rx-clock-name = "clk20";
>                         tx-clock-name = "clk19";
>                         fixed-link = <0x02 1 100 0 0>; /* P2 on data-plane switch on SM */
>                         phy-connection-type = "mii";
>                         pio-handle = <&ucc7>;
>                 };
>                 /* UCC 2 & 4 1000 BT Control Plane cp0 */
>                 enet4: ethernet@3000 {
>                         device_type = "network";
>                         compatible = "ucc_geth";
>                         cell-index = <0x2>;
>                         reg = <0x3000 0x200>;
>                         interrupts = <0x21>;
>                         interrupt-parent = <&qeic>;
>                         local-mac-address = [ 00 00 00 00 00 00 ]; /* [U-BOOT] */
>                         rx-clock-name = "none";
>                         tx-clock-name = "clk4";
>                         tx-thread-num = <2>; /* Reduced to allow all enet to come up */
>                         fixed-link = <10 1 1000 0 0>; /* P10 on control-plane switch on CM */
>                         phy-connection-type = "gmii";
>                         pio-handle = <&ucc2>;
>                 };
>                 /* UCC 8 100 BT Control Plane cp1 */
>                 enet5: ethernet@3600 {
>                         device_type = "network";
>                         compatible = "ucc_geth";
>                         cell-index = <0x8>;
>                         reg = <0x3600 0x200>;
>                         interrupts = <0x2b>;
>                         interrupt-parent = <&qeic>;
>                         local-mac-address = [ 00 00 00 00 00 00 ]; /* [U-BOOT] */
>                         rx-clock-name = "clk5";
>                         tx-clock-name = "clk21";
>                         fixed-link = <9 1 100 0 0>; /* P9 on control-plane switch on CM */
>                         phy-connection-type = "mii";
>                         pio-handle = <&ucc8>;
>                 };
> 
> > I don't see any point in reverting, because it will surely break my boards.
> > So, we need to fix this, not just hide.
> 
> I agree with that.
> 
> > > unless someone can fix it.
> > 
> > Well, I'm ready to help you with debugging.
> 
> Excellent.
> 
> > > Now I must add that I run with the xenomai/adeos-ipipe patches as well,
> > > which do change interrupt handling a little,
> > 
> > It could be that it takes too long to stop the UCC, and xenomai
> > makes the timings worse, so the watchdog triggers.
> > 
> > Can you try the following patch?
> 
> Sure thing.
> 
> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> > index afaf088..2f73e3f 100644
> > --- a/drivers/net/ucc_geth.c
> > +++ b/drivers/net/ucc_geth.c
> > @@ -1563,6 +1563,8 @@ static int ugeth_disable(struct ucc_geth_private *ugeth, enum comm_dir mode)
> >  
> >  static void ugeth_quiesce(struct ucc_geth_private *ugeth)
> >  {
> > +	netif_device_detach(ugeth->ndev);
> > +
> >  	/* Wait for and prevent any further xmits. */
> >  	netif_tx_disable(ugeth->ndev);
> >  
> > @@ -1577,7 +1579,7 @@ static void ugeth_activate(struct ucc_geth_private *ugeth)
> >  {
> >  	napi_enable(&ugeth->napi);
> >  	enable_irq(ugeth->ug_info->uf_info.irq);
> > -	netif_tx_wake_all_queues(ugeth->ndev);
> > +	netif_device_attach(ugeth->ndev);
> >  }
> >  
> >  /* Called every time the controller might need to be made
> 
> So there result is:
> 
> Unable to handle kernel paging request for data at address 0x00000058
> Faulting instruction address: 0xc024f2fc
> Oops: Kernel access of bad area, sig: 11 [#1]
> RC8360 CM
> Modules linked in: rclibapi xeno_native max6369_wdt ucc_geth_driver spi_mpc8xxx ltc4215 lm75
> NIP: c024f2fc LR: e30aa0a4 CTR: c024f2e8
> REGS: df857ca0 TRAP: 0300   Not tainted  (2.6.32-trunk-8360e)
> MSR: 00009032 <EE,ME,IR,DR>  CR: 44042088  XER: 00000000
> DAR: 00000058, DSISR: 20000000
> TASK = df848c90[4] 'events/0' THREAD: df856000
> GPR00: e30aa0a4 df857d50 df848c90 00000000 00000640 00000001 c0428df4 dfa40b80
> GPR08: 000000c8 e30ad2b8 df084360 c024f2e8 44042082 1001af90 e30ad2b8 00000000
> GPR16: 00000048 00000001 00000000 00000000 df08436c df08440c 00000190 df08455c
> GPR24: df0844ec df0842c0 df084000 180005ea dfa40b80 00000000 df0842c0 00000000
> NIP [c024f2fc] skb_recycle_check+0x14/0x100
> LR [e30aa0a4] ucc_geth_poll+0xd8/0x4e0 [ucc_geth_driver]
> Call Trace:
> [df857d50] [c000b03c] __ipipe_grab_irq+0x3c/0xa4 (unreliable)
> [df857d60] [e30aa0a4] ucc_geth_poll+0xd8/0x4e0 [ucc_geth_driver]
> [df857dd0] [c0258cf8] net_rx_action+0xf8/0x1b8
> [df857e10] [c0032a38] __do_softirq+0xb8/0x13c
> [df857e60] [c00065cc] do_softirq+0xa0/0xac
> [df857e70] [c003280c] irq_exit+0x7c/0x9c
> [df857e80] [c000b1f4] __ipipe_do_IRQ+0x50/0x68
> [df857ea0] [c0064098] __ipipe_sync_stage+0x21c/0x24c
> [df857ee0] [c0064a4c] __ipipe_unstall_root+0x5c/0x60
> [df857ef0] [c005fb4c] enable_irq+0x88/0xc4
> [df857f10] [e30a73d0] adjust_link+0x1fc/0x2f0 [ucc_geth_driver]
> [df857f40] [c0209c0c] phy_state_machine+0x3a4/0x610
> [df857f60] [c003fec4] worker_thread+0x124/0x1a4
> [df857fc0] [c0044310] kthread+0x78/0x7c
> [df857ff0] [c0013c30] kernel_thread+0x4c/0x68
> Instruction dump:
> 4e800020 4800fcb5 4bffff50 4802782d 4bffffc8 48076dd9 4bffff6c 9421fff0
> 7c0802a6 93e1000c 7c7f1b78 90010014 <80030058> 2f800000 409e00cc 81630068
> Kernel panic - not syncing: Fatal exception in interrupt
> Rebooting in 180 seconds..
> 
> So it seems as soon as it touched the phy settings, it blew up.
> 
> Now perhaps the ipipe interrupt handling code changes the behaviour
> enough that it makes the spinlock_irqsave necesary and that is why it
> worked before.  Maybe ipipe is doing something wrong, given ipipe only
> supports 2.6.30 for powerpc and I personally ported it to 2.6.31 and
> then 2.6.32.  Everything else works fine though as long as I revert this
> particular patch.

Oh and I will be off on vacation for about a week by tomorrow, so if I
don't fix it today, I will be a bit slow at getting back to you
on this.  Not that it is bothering any real users yet (they are using
2.6.30 for now).

-- 
Len Sorensen
