From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 11/11] ixgb: Add prefetch
Date: Sat, 22 Apr 2006 07:34:41 +0200
Message-ID: <4449C071.5000107@cosmosbay.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com> <20060422010055.24255.71946.stgit@jk-desktop.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:33980 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1751040AbWDVT0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 15:26:46 -0400
Received: from smtp.cegetel.net (mf00.sitadelle.com [212.94.174.67])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k3M5Yxij012537
	for <netdev@vger.kernel.org>; Sat, 22 Apr 2006 05:35:00 GMT
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <20060422010055.24255.71946.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher a =E9crit :
> - This patch is to improve performance by adding prefetch to the ixgb=
 driver
> - Add driver comments
>=20
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: John Ronciak <john.ronciak@intel.com>
> ---
>=20
>  drivers/net/ixgb/ixgb_main.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_mai=
n.c
> index 26cb0d5..98303cb 100644
> --- a/drivers/net/ixgb/ixgb_main.c
> +++ b/drivers/net/ixgb/ixgb_main.c
> @@ -29,6 +29,13 @@
>  #include "ixgb.h"
> =20
>  /* Change Log
> + * 1.0.104 10-Jan-2006
> + * - fix for copybreak/recycle
> + * 1.0.103 Oct-3
> + * - suck in some e1000 changes, including copybreak and LLTX
> + * - support for CX4 adapters
> + * 1.0.102 June-20-2005
> + * - add a workaround for a hardware issue when using TSO
>   * 1.0.96 04/19/05
>   * - Make needlessly global code static -- bunk@stusta.de
>   * - ethtool cleanup -- shemminger@osdl.org
> @@ -1916,7 +1923,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
>  		skb =3D buffer_info->skb;
>  		buffer_info->skb =3D NULL;
> =20
> -		prefetch(skb->data);
> +		prefetch(skb->data - NET_IP_ALIGN);

I doubt this change is usefull.

skb->data and dkb->dta - NET_IP_ALIGN are on the same cache line.
So prefetch(skb->data) is cheaper for he compiler and has the same effe=
ct on=20
the memory prefetch that is eventually done by the cpu.


> =20
>  		if(++i =3D=3D rx_ring->count) i =3D 0;
>  		next_rxd =3D IXGB_RX_DESC(*rx_ring, i);
> @@ -1929,6 +1936,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
>  		next_buffer =3D &rx_ring->buffer_info[i];
>  		next_skb =3D next_buffer->skb;
>  		prefetch(next_skb);
> +		prefetch(next_skb->data - NET_IP_ALIGN);

I doubt that next->skb_data is available for free just after a=20
prefetch(next_skb). This second prefetch has a hidden cost : The memory=
=20
location (&next_skb->data) must be in L1 cache. So basically the=20
prefetch(next_skb) is useless...

prefetch are not magic things. They have a cost (they increase the code=
 size),=20
and should be used carefully.

Eric
