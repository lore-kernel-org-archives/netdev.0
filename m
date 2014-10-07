From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: fec: fix regression on i.MX28 introduced by rx_copybreak
 support
Date: Tue, 07 Oct 2014 20:07:00 +0400
Message-ID: <54340FA4.509@cogentembedded.com>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org
To: =?UTF-8?B?TG90aGFyIFdhw59tYW5u?= <LW@KARO-electronics.de>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/07/2014 05:19 PM, Lothar Wa=C3=9Fmann wrote:

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

> Do the byte swapping and copying to the new skb in one go if
> necessary.

> Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> ---
>   drivers/net/ethernet/freescale/fec_main.c |   25 ++++++++++++++++++=
+++----
>   1 file changed, 21 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/=
ethernet/freescale/fec_main.c
> index 87975b5..eaaebad 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
[...]
> @@ -1348,7 +1360,7 @@ fec_enet_new_rxbdp(struct net_device *ndev, str=
uct bufdesc *bdp, struct sk_buff
>   }
>
>   static bool fec_enet_copybreak(struct net_device *ndev, struct sk_b=
uff **skb,
> -			       struct bufdesc *bdp, u32 length)
> +			       struct bufdesc *bdp, u32 length, int swap)

    'bool swap' perhaps?

> @@ -1393,6 +1408,7 @@ fec_enet_rx_queue(struct net_device *ndev, int =
budget, u16 queue_id)
>   	u16	vlan_tag;
>   	int	index =3D 0;
>   	bool	is_copybreak;
> +	bool need_swap =3D id_entry->driver_data & FEC_QUIRK_SWAP_FRAME;

    ... especially talking this into account...

WBR, Sergei
