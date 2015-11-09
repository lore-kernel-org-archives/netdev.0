From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH RFC 6/6] net/faraday: Enable offload checksum according
 to device-tree
Date: Mon, 09 Nov 2015 11:36:10 +1100
Message-ID: <1447029370.8727.33.camel@kernel.crashing.org>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <1447027806-4744-7-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54266 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468AbbKIAgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 19:36:19 -0500
In-Reply-To: <1447027806-4744-7-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-09 at 11:10 +1100, Gavin Shan wrote:
> This enables IP/UDP/TCP offload checksum according to information
> passed on from bootloader through device-tree. The offload doesn't
> working properly when the interface works in NCSI mode.
>=20
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> ---
> =C2=A0drivers/net/ethernet/faraday/ftgmac100.c | 5 ++++-
> =C2=A01 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/e=
thernet/faraday/ftgmac100.c
> index 1b13fd4..1e2f4d2 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -1377,7 +1377,10 @@ static int ftgmac100_probe(struct platform_dev=
ice *pdev)
> =C2=A0
> =C2=A0> 	> netdev->ethtool_ops =3D &ftgmac100_ethtool_ops;
> =C2=A0> 	> netdev->netdev_ops =3D &ftgmac100_netdev_ops;
> -> 	> netdev->features =3D NETIF_F_IP_CSUM | NETIF_F_GRO;
> +> 	> netdev->features =3D NETIF_F_GRO;
> +> 	> if (pdev->dev.of_node &&
> +> 	> =C2=A0=C2=A0=C2=A0=C2=A0of_property_read_bool(pdev->dev.of_node=
, "no-hw-checksum"))
> +> 	> 	> netdev->features |=3D NETIF_F_IP_CSUM;

Am I reading properly that if you put "no-hw-checksum" in the device-
tree you *enable* HW checksum ? This doesn't look right to me...

The logic should be:

	if (pdev->dev.of_node &&
		of_property_read_bool(pdev->dev.of_node, "no-hw-checksum"))
		netdev->features &=3D ~NETIF_F_IP_CSUM;
