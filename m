From: Parav Pandit <parav@mellanox.com>
Subject: RE: [PATCH net 1/2] net/smc: replace function pointer get_netdev()
Date: Tue, 10 Oct 2017 17:01:42 +0000
Message-ID: <VI1PR0502MB300866E7828B277199DB4C2BD1750@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20171010141351.87700-1-ubraun@linux.vnet.ibm.com>
 <20171010141351.87700-2-ubraun@linux.vnet.ibm.com>
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
Received: from mail-db5eur01on0071.outbound.protection.outlook.com ([104.47.2.71]:17024
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756322AbdJJRBq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:01:46 -0400
In-Reply-To: <20171010141351.87700-2-ubraun@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Ursula Braun [mailto:ubraun@linux.vnet.ibm.com]
> Sent: Tuesday, October 10, 2017 9:14 AM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; linux-rdma@vger.kernel.org; linux-
> s390@vger.kernel.org; jwi@linux.vnet.ibm.com; schwidefsky@de.ibm.com;
> heiko.carstens@de.ibm.com; raspl@linux.vnet.ibm.com;
> ubraun@linux.vnet.ibm.com; Parav Pandit <parav@mellanox.com>
> Subject: [PATCH net 1/2] net/smc: replace function pointer get_netdev()
>=20
> SMC should not open code the function pointer get_netdev of the IB device=
.
> Replacing ib_query_gid(..., NULL) with ib_query_gid(..., gid_attr) allows=
 access
> to the netdev.
>=20
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Suggested-by: Parav Pandit <parav@mellanox.com>
Looks fine to me. Minor nit below.
Reviewed-by: Parav Pandit <parav@mellanox.com>

> ---
>  net/smc/smc_ib.c | 26 +++++++++-----------------
>  1 file changed, 9 insertions(+), 17 deletions(-)
>=20
> diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c index
> 0b5852299158..b428c0f6c782 100644
> --- a/net/smc/smc_ib.c
> +++ b/net/smc/smc_ib.c
> @@ -369,26 +369,17 @@ void smc_ib_buf_unmap_sg(struct smc_ib_device
> *smcibdev,
>=20
>  static int smc_ib_fill_gid_and_mac(struct smc_ib_device *smcibdev, u8 ib=
port)
> {
> -	struct net_device *ndev;
> +	struct ib_gid_attr gattr;
>  	int rc;
>=20
>  	rc =3D ib_query_gid(smcibdev->ibdev, ibport, 0,
> -			  &smcibdev->gid[ibport - 1], NULL);
> -	/* the SMC protocol requires specification of the roce MAC address;
> -	 * if net_device cannot be determined, it can be derived from gid 0
> -	 */
> -	ndev =3D smcibdev->ibdev->get_netdev(smcibdev->ibdev, ibport);
> -	if (ndev) {
> -		memcpy(&smcibdev->mac, ndev->dev_addr, ETH_ALEN);
> -		dev_put(ndev);
> -	} else if (!rc) {
> -		memcpy(&smcibdev->mac[ibport - 1][0],
> -		       &smcibdev->gid[ibport - 1].raw[8], 3);
> -		memcpy(&smcibdev->mac[ibport - 1][3],
> -		       &smcibdev->gid[ibport - 1].raw[13], 3);
> -		smcibdev->mac[ibport - 1][0] &=3D ~0x02;
> -	}
> -	return rc;
> +			  &smcibdev->gid[ibport - 1], &gattr);
> +	if (rc || !gattr.ndev)
> +		return -ENODEV;
> +
> +	memcpy(smcibdev->mac[ibport - 1], gattr.ndev->dev_addr, ETH_ALEN);
> +	dev_put(gattr.ndev);
> +	return 0;
>  }
>=20
>  /* Create an identifier unique for this instance of SMC-R.
> @@ -419,6 +410,7 @@ int smc_ib_remember_port_attr(struct smc_ib_device
> *smcibdev, u8 ibport)
>  			   &smcibdev->pattr[ibport - 1]);
>  	if (rc)
>  		goto out;
> +	/* the SMC protocol requires specification of the roce MAC address */
RoCE MAC address

>  	rc =3D smc_ib_fill_gid_and_mac(smcibdev, ibport);
>  	if (rc)
>  		goto out;
> --
> 2.13.5
