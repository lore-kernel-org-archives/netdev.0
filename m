From: Parav Pandit <parav@mellanox.com>
Subject: RE: [PATCH net-next 01/10] net/smc: add missing dev_put
Date: Mon, 2 Oct 2017 20:36:29 +0000
Message-ID: <VI1PR0502MB30089D06B9C95D682E21511BD17D0@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
 <20170920115813.63745-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        "jwi@linux.vnet.ibm.com" <jwi@linux.vnet.ibm.com>,
        "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>,
        "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
        "raspl@linux.vnet.ibm.com" <raspl@linux.vnet.ibm.com>
To: Ursula Braun <ubraun@linux.vnet.ibm.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20067.outbound.protection.outlook.com ([40.107.2.67]:55383
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751158AbdJBUgc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 16:36:32 -0400
In-Reply-To: <20170920115813.63745-2-ubraun@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ursula, Dave, Hans,

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Ursula Braun
> Sent: Wednesday, September 20, 2017 6:58 AM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; linux-rdma@vger.kernel.org; linux-
> s390@vger.kernel.org; jwi@linux.vnet.ibm.com; schwidefsky@de.ibm.com;
> heiko.carstens@de.ibm.com; raspl@linux.vnet.ibm.com;
> ubraun@linux.vnet.ibm.com
> Subject: [PATCH net-next 01/10] net/smc: add missing dev_put
>=20
> From: Hans Wippel <hwippel@linux.vnet.ibm.com>
>=20
> In the infiniband part, SMC currently uses get_netdev which calls dev_hol=
d on
> the returned net device. However, the SMC code never calls dev_put on tha=
t net
> device resulting in a wrong reference count.
>=20
> This patch adds a dev_put after the usage of the net device to fix the is=
sue.
>=20
> Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> ---
>  net/smc/smc_ib.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c index
> 547e0e113b17..0b5852299158 100644
> --- a/net/smc/smc_ib.c
> +++ b/net/smc/smc_ib.c
> @@ -380,6 +380,7 @@ static int smc_ib_fill_gid_and_mac(struct smc_ib_devi=
ce
> *smcibdev, u8 ibport)
>  	ndev =3D smcibdev->ibdev->get_netdev(smcibdev->ibdev, ibport);
>  	if (ndev) {
>  		memcpy(&smcibdev->mac, ndev->dev_addr, ETH_ALEN);
> +		dev_put(ndev);

I am sorry for providing late comments. smc_ib_fill_gid_and_mac() is not co=
ded correctly.
Few fixes are needed.
1. ULP such as SMC should not open code/deference any function pointer like=
 get_netdev() of the IB device.
2. Replace ib_query_gid(..., NULL)
With
ib_query_gid(..., gid_attr);

Use gid_attr.ndev to get the MAC address.
Do dev_put(gid_attr.ndev);

Code should look like below,

struct ib_gid_attr gid_attr;

rc =3D ib_query_gid(..., &gid_attr);
if (rc || !gid_addr.ndev)
	return -ENODEV;
else
	memcpy(smcibdev->mac, ndev->dev_addr, ETH_ALEN);
dev_put(gid_addr.ndev);
