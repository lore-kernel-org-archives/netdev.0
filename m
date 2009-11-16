From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net/can: add driver for mscan family & mpc52xx_mscan
Date: Mon, 16 Nov 2009 09:40:33 +0100
Message-ID: <4B011001.807@grandegger.com>
References: <1258128892-28800-1-git-send-email-w.sang@pengutronix.de>
	<fa686aa40911130939x54ac53f9x173a875a5a4435d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <fa686aa40911130939x54ac53f9x173a875a5a4435d3@mail.gmail.com>
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

Grant Likely wrote:
> On Fri, Nov 13, 2009 at 9:14 AM, Wolfram Sang <w.sang@pengutronix.de> wrote:
>> Taken from socketcan-svn, fixed remaining todos, cleaned up, tested with a
>> phyCORE-MPC5200B-IO and a custom board.
>>
>> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
>> Cc: Wolfgang Grandegger <wg@grandegger.com>
>> Cc: Grant Likely <grant.likely@secretlab.ca>
>> Cc: David Miller <davem@davemloft.net>
> 
> I don't see any locking in this driver.  What keeps the mscan_isr or
> other routines from conflicting with each other?  What is the
> concurrency model for CAN devices?

There is concurrency between the mscan_start_xmit() and mscan_irq()
routine, which is handled by disabling/enabling the TX interrupt source.
CAN configuration (bit-timing) can only be changed when the device is
stopped (down) and bus-off recovery requires that interrupts are
disabled or the hadrware does not send/receive messages after the
bus-off occurred.

> More comments below.  I don't have the background to delve into the
> CAN details, but I can make some comments on the general structure of
> the driver.

[snip]
>> +static unsigned int  __devinit mpc52xx_can_clock_freq(struct of_device *of,
>> +                                                     int clock_src)
>> +{
>> +       unsigned int pvr;
>> +
>> +       pvr = mfspr(SPRN_PVR);
>> +
>> +       if (clock_src == MSCAN_CLKSRC_BUS || pvr == 0x80822011)
>> +               return mpc5xxx_get_bus_frequency(of->node);
>> +
>> +       return mpc52xx_can_xtal_freq(of);
>> +}
> 
> mpc52xx_can_xtal_freq() is only used by this function.  Do they need
> to be separate?

Not really, and it would save some lines of code.

[snip]
>> +static int mscan_set_mode(struct net_device *dev, u8 mode)
>> +{
>> +       struct mscan_priv *priv = netdev_priv(dev);
>> +       struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
>> +       int ret = 0;
>> +       int i;
>> +       u8 canctl1;
>> +
>> +       if (mode != MSCAN_NORMAL_MODE) {
>> +
>> +               if (priv->tx_active) {
>> +                       /* Abort transfers before going to sleep */#
>> +                       out_8(&regs->cantarq, priv->tx_active);
>> +                       /* Suppress TX done interrupts */
>> +                       out_8(&regs->cantier, 0);
>> +               }
>> +
>> +               canctl1 = in_8(&regs->canctl1);
>> +               if ((mode & MSCAN_SLPRQ) && (canctl1 & MSCAN_SLPAK) == 0) {
>> +                       out_8(&regs->canctl0,
>> +                             in_8(&regs->canctl0) | MSCAN_SLPRQ);
>> +                       for (i = 0; i < MSCAN_SET_MODE_RETRIES; i++) {
>> +                               if (in_8(&regs->canctl1) & MSCAN_SLPAK)
>> +                                       break;
>> +                               udelay(100);
> 
> Ugh.  Can you sleep instead?  This burns a lot of CPU cycles to no purpose.

A real sleep for 100us? The usual jiffy based sleep would take 1..10 ms,
at least. I think we should check how much time/cycles it usually takes.

[snip]
>> +static int mscan_do_set_mode(struct net_device *dev, enum can_mode mode)
>> +{
>> +
>> +       struct mscan_priv *priv = netdev_priv(dev);
>> +       int ret = 0;
>> +
>> +       if (!priv->open_time)
>> +               return -EINVAL;
>> +
>> +       switch (mode) {
>> +       case CAN_MODE_SLEEP:
>> +       case CAN_MODE_STOP:
>> +               netif_stop_queue(dev);
>> +               mscan_set_mode(dev,
>> +                              (mode ==
>> +                               CAN_MODE_STOP) ? MSCAN_INIT_MODE :
>> +                              MSCAN_SLEEP_MODE);
> 
> A little hard on the eyes.  Can you rework to not spill over 4 lines?
> (ie. calc mode flag on the line above?)

These cases can safely be removed as currently only CAN_MODE_START is
supported by the upper layer.

Wolfgang.
