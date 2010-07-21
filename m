From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 2/2] net: dsa: introduce MICREL
	KSZ8893MQL/BL ethernet switch chip support
Date: Wed, 21 Jul 2010 12:05:43 -0400
Message-ID: <AANLkTinoVsz1YsWc3VSAqPPgH_L19B541A72zkWPxjM8@mail.gmail.com>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	<1279719442-10174-2-git-send-email-vapier@gentoo.org> <20100721151608.GM21121@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Karl Beldan <karl.beldan@gmail.com>, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44907 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253Ab0GUQGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 12:06:06 -0400
Received: by fxm14 with SMTP id 14so3670893fxm.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 09:06:03 -0700 (PDT)
In-Reply-To: <20100721151608.GM21121@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 11:16, Lennert Buytenhek wrote:
> On Wed, Jul 21, 2010 at 09:37:22AM -0400, Mike Frysinger wrote:
>> +static int ksz8893m_setup(struct dsa_switch *ds)
>> +{
>> +     int i;
>> +     int ret;
>> +
>> +     ret = ksz8893m_switch_reset(ds);
>> +     if (ret < 0)
>> +             return ret;
>
> It's pretty ugly that the mdiobus is passed in via the normal means,
> but a reference to the SPI bus to use is just stuffed into some global
> variable.
>
> Can you not access all registers via MII?

it depends on the host mdio bus.  if it supports the semi-standard
behavior of toggling the OP field of MDIO frames, then yes, you can do
it via MII.  but i dont think the current mdio framework in the kernel
keeps track of that functionality, so there isnt a way in the driver
to say "is this possible, else fall back to SPI".

certainly the part that was used to develop this driver does not
support this behavior thus SPI is the only way of accessing the
extended registers.  i guess the driver could be extended so that
people could pick which mode they want to program the registers via
platform resources, but we have no way of testing that, so i say let
the person who actually can use & wants that functionality implement
it.

> (If not, struct dsa_chip_data will need go be extended with another
> struct device pointer that we can use to find the spi bus with.)

if the framework supports, i can convert the driver to it, but i'm not
sure we have the time atm to tackle reworking common frameworks.

>> +static int ksz8893m_port_to_phy_addr(int port)
>> +{
>> +     if (port >= 1 && port <= KSZ8893M_PORT_NUM)
>> +             return port;
>> +
>> +     pr_warning("use default phy addr 3\n");
>> +     return 3;
>
> Does this ever happen?  You should just be able to return -1 here, IMHO.

i dont recall seeing a warning, but presumably if it it did occur,
something else needs fixing.  so -1 is OK.

>> +/* MII Basic Control */
>> +#define SOFT_RESET        0x8000
>> +#define LOOPBACK          0x4000
>> +#define FORCE_100         0x2000
>> +#define AN_ENABLE         0x1000
>> +#define POWER_DOWN        0x0800
>> +#define ISOLATE           0x0400
>> +#define RESTART_AN        0x0200
>> +#define FORCE_FULL_DUPLEX 0x0100
>> +#define COLLISION_TEST    0x0080
>
> This part of the MII register is standard, and there are BMCR_*
> definitions for this in mii.h, no need to duplicate them.

most are copies of the MII headers, so i just converted them all and
punted the rest

>> +#define FAMILY_ID         0x88
>> +#define START_SWITCH      0x01
>> +#define TAG_INSERTION     0x04
>> +#define SPECIAL_TPID_MODE 0x01
>
> It would be nice to mention what registers these bitfields are part of.

done

>> +enum switch_phy_reg {
>> +     /* Global Registers: 0-15 */
>> +     ChipID0 = 0,
>> +     ChipID1_StartSwitch,
>> +     GlobalControl0,
>
> And here, just define the registers you need only.

i'm not sure that's necessary ... having the complete register layout
is useful for people who want to extend in the future
-mike
