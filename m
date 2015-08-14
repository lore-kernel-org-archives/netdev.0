From: Michael Heimpold <mhei@heimpold.de>
Subject: Re: [PATCH v2] net: phy: workaround for buggy cable detection by LAN8700 after cable plugging
Date: Fri, 14 Aug 2015 18:31:11 +0200
Message-ID: <3066235.RJEkKeJLOx@kerker>
References: <1439493514-10793-1-git-send-email-plyatov@gmail.com> <5164251.N6KMl6pkAR@kerker> <55CDA0B8.5000200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	f.fainelli@gmail.com, joe@perches.com, luwei.zhou@freescale.com,
	richardcochran@gmail.com, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, Fabio.Estevam@freescale.com,
	LW@karo-electronics.de, Frank.Li@freescale.com
To: plyatov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CDA0B8.5000200@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Igor,

Am Freitag, 14. August 2015, 11:03:04 schrieb Igor Plyatov:
> Dear Michael,
> 
> > Hi Igor,
> >
> > Am Donnerstag, 13. August 2015, 22:18:34 schrieben Sie:
> >
> > > * Due to HW bug, LAN8700 sometimes does not detect presence of 
> > energy in the
> >
> > > Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN 
> > bit is
> >
> > > set, the ENERGYON bit does not asserted sometimes). This is a common 
> > bug of
> >
> > > LAN87xx family of PHY chips.
> >
> > Is there any offical errata sheet for this PHY family? How do you 
> > know, that this is a
> >
> > common HW bug?
> >
> 
> The LAN8700, LAN8710, LAN8720 is a product of the SMSC company. 
> Microchip acquired SMSC in August 2012.
> 
> The LAN8700 is a legacy product for Microchip and they will not update 
> anything about it. So, even if Microchip know about HW bug, then there 
> is no chance to have Errata sheet or any new documents about LAN8700.

Long time ago, I worked on a custom device with a PHY of the same family.
Errata sheet existed but was only available by signing a NDA. So I simply
wondered whether this changed since SMSC is now Microchip or if they keep
it still so covered...

> 
> I think same history is for LAN8710/LAN8720 even if they are not marked 
> as legacy. They are SMSC products.
> 
> The workarounds for same issue in LAN8710/LAN8720 was committed by:
>   * Marek Vasut <marex@denx.de> as b629820d18fa65cc598390e4b9712fd5f83ee693.
>   * Patrick Trantham <patrick.trantham@fuel7.com> as 
> 4223dbffed9f89596177ff2b256ef3258b20fa46.
> 
> > Me too, I think that this family has some problems with this mode, 
> > however, without
> >
> > hard evidence, I would put it softer.
> >
> 
> I have discovered this bug by just monitoring of data to/from MDIO 
> registers of LAN8700.
> And HW issue is proven on 100 % by rare absence of ENERGYON bit when 
> cable is plugged in.
> Sometimes, it is required to make 2-20 tests to catch this issue.
> 
> The configuration of CPU pins, responsible for the MDIO interface, was 
> checked carefully by oscilloscope and they are fine (no spikes, no 
> garbage, good shape of edges).
> 
> > > * The lan87xx_read_status() was improved to acquire ENERGYON bit. 
> > Its previous
> >
> > > algorythm still not reliable on 100 % and sometimes skip cable plugging.
> >
> > >
> >
> > > Signed-off-by: Igor Plyatov <plyatov@gmail.com>
> >
> > > ---
> >
> > > drivers/net/phy/smsc.c | 15 ++++++++++++---
> >
> > > 1 file changed, 12 insertions(+), 3 deletions(-)
> >
> > >
> >
> > > diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> >
> > > index c0f6479..8559ff1 100644
> >
> > > --- a/drivers/net/phy/smsc.c
> >
> > > +++ b/drivers/net/phy/smsc.c
> >
> > > @@ -104,6 +104,7 @@ static int lan911x_config_init(struct phy_device 
> > *phydev)
> >
> > > static int lan87xx_read_status(struct phy_device *phydev)
> >
> > > {
> >
> > > int err = genphy_read_status(phydev);
> >
> > > + int i;
> >
> > >
> >
> > > if (!phydev->link) {
> >
> > > /* Disable EDPD to wake up PHY */
> >
> > > @@ -116,8 +117,16 @@ static int lan87xx_read_status(struct 
> > phy_device *phydev)
> >
> > > if (rc < 0)
> >
> > > return rc;
> >
> > >
> >
> > > - /* Sleep 64 ms to allow ~5 link test pulses to be sent */
> >
> > > - msleep(64);
> >
> > > + /* Wait max 640 ms to detect energy */
> >
> > Why 640ms and not e.g. 650ms?
> >
> > I'm no PHY expert, but this looks like an ugly workaround.
> >
> 
> Such a value was adopted after many trial and probes. It allows to 
> detect cable plugging on 100 %.
> Ugly or not, but it works and reliable.
> 
> > Maybe it would be better to avoid this power saving mode at all, when 
> > it is not
> >
> > reliable, but this are just my 2cts. :-)
> >
> 
> Power saving mode allow to save around 220 mW of energy consumed from 
> power supply, when Ethernet cable is not plugged in.
> This is a good value for embedded devices.
> Better to keep power save mode on.

Ok, I was not aware, that this is so much.

> 
> > Anyway, I guess you should also update the explanation on top of the 
> > function to reflect
> >
> > your new approach.
> >
> 
> I propose following comment for the lan87xx_read_status():
> /*
>   * The LAN87xx suffers from rare absence of the ENERGYON-bit when 
> Ethernet cable
>   * plugs in while LAN87xx is in Energy Detect Power-Down mode. This 
> leads to
>   * unstable detection of plugging in Ethernet cable.
>   * This workaround disables Energy Detect Power-Down mode and waiting for
>   * response on link pulses to detect presence of plugged Ethernet cable.
>   * The Energy Detect Power-Down mode enabled again in the end of 
> procedure to
>   * save approximately 220 mW of power if cable is unplugged.
>   */

Nice. Only one nitpick: ... _is_ enabled again...

> 
> > > + for (i = 0; i < 64; i++) {
> >
> > > + /* Sleep to allow link test pulses to be sent */
> >
> > > + msleep(10);
> >
> > > + rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> >
> > > + if (rc < 0)
> >
> > > + return rc;
> >
> > > + if (rc & MII_LAN83C185_ENERGYON)
> >
> > > + break;
> >
> > > + };
> >
> > >
> >
> > > /* Re-enable EDPD */
> >
> > > rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> >
> > > @@ -191,7 +200,7 @@ static struct phy_driver smsc_phy_driver[] = {
> >
> > >
> >
> > > /* basic functions */
> >
> > > .config_aneg = genphy_config_aneg,
> >
> > > - .read_status = genphy_read_status,
> >
> > > + .read_status = lan87xx_read_status,
> >
> > This one makes sense, since I really guess, that the whole PHY family 
> > behave very similar.
> >
> > But this change alone does not solve your problem, right?
> >
> 
> Yes, use of non modified lan87xx_read_status() only reduce amount of 
> false cable detections, but does not resolve issue completely.
> 
> > > .config_init = smsc_phy_config_init,
> >
> > > .soft_reset = smsc_phy_reset,
> >
> > >
> >
> > >
> >
> > Regards,
> >
> > Michael
> >
> 
> Best wishes.
> 
> 
Thanks, Michael
