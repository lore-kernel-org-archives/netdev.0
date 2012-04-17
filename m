From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next] dmfe: enforce consistent timing delay.
Date: Tue, 17 Apr 2012 14:45:38 -0700
Message-ID: <CANEJEGsb6_6btnu4OdriK=V2MbHcmxmvGy8UgsjNG1VPS_B0oQ@mail.gmail.com>
References: <20120417211140.GA12909@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:32805 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207Ab2DQVpl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 17:45:41 -0400
Received: by ghrr11 with SMTP id r11so3389448ghr.19
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 14:45:40 -0700 (PDT)
In-Reply-To: <20120417211140.GA12909@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 17, 2012 at 2:11 PM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> The driver does not always use the same timing for what looks like
> the same operations.
>
> - DCR0
> =C2=A0Use the same udelay everywhere for reset. Upper bound is 100 us=
=2E
> - DCR9
> =C2=A0Use 5us delay for srom clock. 1us delay for phy_write_1bit (wri=
tes
> =C2=A0PHY_DATA_[01]) are not changed as they stay withing a 2,5MHz MD=
IO
> =C2=A0clock range.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>


Reviewed-by: Grant Grundler <grundler@parisc-linux.org>

> ---
>
> I noticed those while staring at the driver.
>
> Grant, regarding your previous remarks, I do not see where the proble=
m
> could be with posted writes MMIO accesses:
> - the driver has always used the first (#0) bar register. It's hardco=
ded.
> =C2=A0The driver still uses this same bar register.
> - the driver has never checked whether bar #0 was related to I/O or
> =C2=A0memory space. It assumed an I/O decoder and issued out* instruc=
tions.
> - the DM9102 datasheet states BAR #0 is an IO only BAR. No idea for t=
he
> =C2=A0DM9132, 9100 and 9009 though.

I didn't realize BAR0 is hard coded in the driver. BAR0 unlikely to
become MMIO for other devices. I think you are right - there is no
problem.

> My changes have replaced in/out* accesses with ioread/write* - mostly
> to help detecting places where type checking would have uncloaked a
> forgotten net_device.base_addr.
>
> Thus, if someone has a dmfe device including a MMIO space decoder beh=
ind
> bar #0, iowrite* will now emit memory write instructions where the dr=
iver
> previously used I/O operations. It may not work very well due to post=
ed
> writes issues, sure.

unlikely. I'll worry about it when someone does in fact find this confi=
guration.

> However I wonder on which platform - if any - the
> former MMIO space + I/O accesses (!) combo would have behaved correct=
ly.
> ?

MMIO and I/O can interoperate to the same device since the device
registers are just having transactions sent to them via different
address decoders. Drivers typically only use one or the other though
if both are available.

thanks,
grant

>
> =C2=A0drivers/net/ethernet/dec/tulip/dmfe.c | =C2=A0 =C2=A06 +++++-
> =C2=A01 files changed, 5 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethe=
rnet/dec/tulip/dmfe.c
> index 0ef5b68..4d6fe60 100644
> --- a/drivers/net/ethernet/dec/tulip/dmfe.c
> +++ b/drivers/net/ethernet/dec/tulip/dmfe.c
> @@ -767,7 +767,7 @@ static int dmfe_stop(struct DEVICE *dev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Reset & stop DM910X board */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dw32(DCR0, DM910X_RESET);
> - =C2=A0 =C2=A0 =C2=A0 udelay(5);
> + =C2=A0 =C2=A0 =C2=A0 udelay(100);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0phy_write(ioaddr, db->phy_addr, 0, 0x8000,=
 db->chip_id);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free interrupt */
> @@ -1601,7 +1601,9 @@ static u16 read_srom_word(void __iomem *ioaddr,=
 int offset)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dw32(DCR9, CR9_SROM_READ);
> + =C2=A0 =C2=A0 =C2=A0 udelay(5);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
> + =C2=A0 =C2=A0 =C2=A0 udelay(5);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send the Read Command 110b */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0srom_clk_write(ioaddr, SROM_DATA_1);
> @@ -1615,6 +1617,7 @@ static u16 read_srom_word(void __iomem *ioaddr,=
 int offset)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
> + =C2=A0 =C2=A0 =C2=A0 udelay(5);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 16; i > 0; i--) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dw32(DCR9, CR9=
_SROM_READ | CR9_SRCS | CR9_SRCLK);
> @@ -1626,6 +1629,7 @@ static u16 read_srom_word(void __iomem *ioaddr,=
 int offset)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dw32(DCR9, CR9_SROM_READ);
> + =C2=A0 =C2=A0 =C2=A0 udelay(5);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return srom_data;
> =C2=A0}
>
> --
> 1.7.7.6
>
