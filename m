From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Mon, 23 Feb 2015 15:10:47 +0100
Message-ID: <54EB34E7.7060400@monstr.eu>
References: <1424258975-28611-1-git-send-email-achandran@mvista.com>	<54E5D5A0.90005@monstr.eu> <CAFdej03U7mMVC8H5SJJNCPq3nYRHZYHLshALvxusQvm24QPuSw@mail.gmail.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="alJgH8kUUJFG8Jqxd5A4CB0g0aPQILODU"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arun Chandran <achandran@mvista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFdej03U7mMVC8H5SJJNCPq3nYRHZYHLshALvxusQvm24QPuSw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--alJgH8kUUJFG8Jqxd5A4CB0g0aPQILODU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Arun,

On 02/20/2015 12:45 PM, Arun Chandran wrote:
> On Thu, Feb 19, 2015 at 5:52 PM, Michal Simek <monstr@monstr.eu> wrote:=

>>
>> On 02/18/2015 12:29 PM, Arun Chandran wrote:
>>> This patch converts all __raw_readl and __raw_writel function calls
>>> to their corresponding readl_relaxed and writel_relaxed variants.
>>>
>>> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg=

>>> when the CPU is configured in big endian mode.
>>>
>>> Signed-off-by: Arun Chandran <achandran@mvista.com>
>>> ---
>>>       This patch is tested on xilinx ZC702 evaluation board with
>>>       CONFIG_CPU_BIG_ENDIAN=3Dy and booting NFS rootfs
>>> ---
>>> ---
>>>  drivers/net/ethernet/cadence/macb.c | 18 ++++++++++++------
>>>  drivers/net/ethernet/cadence/macb.h | 15 ++++++++-------
>>>  2 files changed, 20 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
>>> index ad76b8e..05fb36d 100644
>>> --- a/drivers/net/ethernet/cadence/macb.c
>>> +++ b/drivers/net/ethernet/cadence/macb.c
>>> @@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
>>>       WARN_ON((unsigned long)(end - p - 1) !=3D (MACB_TPF - MACB_PFR)=
 / 4);
>>>
>>>       for(; p < end; p++, reg++)
>>> -             *p +=3D __raw_readl(reg);
>>> +             *p +=3D readl_relaxed(reg);
>>>  }
>>>
>>>  static int macb_halt_tx(struct macb *bp)
>>> @@ -1585,7 +1585,11 @@ static void macb_configure_dma(struct macb *bp=
)
>>>               if (bp->dma_burst_length)
>>>                       dmacfg =3D GEM_BFINS(FBLDO, bp->dma_burst_lengt=
h, dmacfg);
>>>               dmacfg |=3D GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
>>> -             dmacfg &=3D ~GEM_BIT(ENDIA);
>>> +             dmacfg &=3D ~GEM_BIT(ENDIA_PKT);
>>> +             /* Tell the chip to byteswap descriptors on big-endian =
hosts */
>>> +#ifdef __BIG_ENDIAN
>>> +             dmacfg |=3D GEM_BIT(ENDIA_DESC);
>>> +#endif
>>
>> I don't think this is the best way what you should do.
>> Instead of having this ifdef here you should find out any reg and dete=
ct if the IP
>> is in big endian or little endian mode. I have done it for some xilinx=
 IPs which
>> can run on big or little endian system.
>> In general find reg which some field which has some meaning - write th=
ere 1
>> and read expected value and based on that decide if you are on big or =
little endian system.
>=20
> Hi Michal,
>=20
> I was not able to find any such registers for GEM in the TRM
> http://www.xilinx.com/support/documentation/user_guides/ug585-Zynq-7000=
-TRM.pdf
>=20
> I tried writing to dma_cfg (0x00000010) and reading from design_cfg5
> (0x00000290)
> Its not reflecting anything(design_cfg5 always reads same value); It
> is not helping.
>=20
> The only way (I don't think its not right way either) I can think of
> eliminating that
>  #ifdef __BIG_ENDIAN is reading some register in ARM cpu to identify it=
s
> current endianness and write dma_cfg accordingly.

Definitely no to detect cpu endianess.

What about this?
writel(0x2, 0xE000b000); //write little endian
if (readl(0xE000b000) =3D=3D 0x2) { //read little endian
	printf("little endian\n")
	disable 0x2 bit (loopback)
} else {
	printf("big endian\n");

	definitely good to check writing 0x2 here that IP is
	in big endian and reacts - if not BUG()
}


I have written this to spi-xilinx.c and you can use similar construction
for macb too (of course with checking above).

	/*
	 * Detect endianess on the IP via loop bit in CR. Detection
	 * must be done before reset is sent because incorrect reset
	 * value generates error interrupt.
	 * Setup little endian helper functions first and try to use them
	 * and check if bit was correctly setup or not.
	 */
	xspi->read_fn =3D xspi_read32;
	xspi->write_fn =3D xspi_write32;

	xspi->write_fn(XSPI_CR_LOOP, xspi->regs + XSPI_CR_OFFSET);
	tmp =3D xspi->read_fn(xspi->regs + XSPI_CR_OFFSET);
	tmp &=3D XSPI_CR_LOOP;
	if (tmp !=3D XSPI_CR_LOOP) {
		xspi->read_fn =3D xspi_read32_be;
		xspi->write_fn =3D xspi_write32_be;
	}

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--alJgH8kUUJFG8Jqxd5A4CB0g0aPQILODU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlTrNOcACgkQykllyylKDCGkMQCfS8/5arlQvJj+jBSoRG+NESQI
0U4AnA50DzGU9wT2TvjsBa4LE2JPtSV+
=UkW/
-----END PGP SIGNATURE-----

--alJgH8kUUJFG8Jqxd5A4CB0g0aPQILODU--
