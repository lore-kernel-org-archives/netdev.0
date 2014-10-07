From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Tue, 07 Oct 2014 07:27:14 -0700
Message-ID: <1412692034.11091.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org
To: Lothar =?ISO-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-07 at 15:19 +0200, Lothar Wa=C3=9Fmann wrote:
> commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve rx =
performance")
> introduced a regression for i.MX28. The swap_buffer() function doing
> the endian conversion of the received data on i.MX28 may access memor=
y
> beyond the actual packet size in the DMA buffer. fec_enet_copybreak()
> does not copy those bytes, so that the last bytes of a packet may be
> filled with invalid data after swapping.
> This will likely lead to checksum errors on received packets.
> E.g. when trying to mount an NFS rootfs:
> UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:44662 ule=
n 36
>=20
> Do the byte swapping and copying to the new skb in one go if
> necessary.
>=20
> Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |   25 +++++++++++++++++++=
++----
>  1 file changed, 21 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/=
ethernet/freescale/fec_main.c
> index 87975b5..eaaebad 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -339,6 +339,18 @@ static void *swap_buffer(void *bufaddr, int len)
>  	return bufaddr;
>  }
> =20
> +static void *swap_buffer2(void *dst_buf, void *src_buf, int len)
> +{
> +	int i;
> +	unsigned int *src =3D src_buf;
> +	unsigned int *dst =3D dst_buf;
> +
> +	for (i =3D 0; i < DIV_ROUND_UP(len, 4); i++, src++, dst++)
> +		*dst =3D cpu_to_be32(*src);

No need for the DIV :

	for (i =3D 0; i < len; i +=3D sizeof(*dst), src++, dst++)
		*dst =3D cpu_to_be32(*src);

Also are you sure both src/dst are aligned to word boundaries, or is
this architecture OK with possible misalignment ?
