From: Parav Pandit <parav@mellanox.com>
Subject: RE: [PATCH v2 net 2/2] net/smc: dev_put for netdev after usage of
 ib_query_gid()
Date: Wed, 11 Oct 2017 14:43:05 +0000
Message-ID: <VI1PR0502MB300838CF1E188B2D7831D28CD14A0@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20171011114723.30733-1-ubraun@linux.vnet.ibm.com>
 <20171011114723.30733-3-ubraun@linux.vnet.ibm.com>
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
Received: from mail-ve1eur01on0083.outbound.protection.outlook.com ([104.47.1.83]:50720
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751814AbdJKOnI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Oct 2017 10:43:08 -0400
In-Reply-To: <20171011114723.30733-3-ubraun@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ursula Braun [mailto:ubraun@linux.vnet.ibm.com]
> Sent: Wednesday, October 11, 2017 6:47 AM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; linux-rdma@vger.kernel.org; linux-
> s390@vger.kernel.org; jwi@linux.vnet.ibm.com; schwidefsky@de.ibm.com;
> heiko.carstens@de.ibm.com; raspl@linux.vnet.ibm.com;
> ubraun@linux.vnet.ibm.com; Parav Pandit <parav@mellanox.com>
> Subject: [PATCH v2 net 2/2] net/smc: dev_put for netdev after usage of
> ib_query_gid()
>=20
> For RoCEs ib_query_gid() takes a reference count on the net_device.
> This reference count must be decreased by the caller.
>=20
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Reported-by: Parav Pandit <parav@mellanox.com>
> Reviewed-by: Parav Pandit <parav@mellanox.com>
> Fixes: 0cfdd8f92cac ("smc: connection and link group creation")
> ---
>  net/smc/smc_core.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c index
> 20b66e79c5d6..5f6a20084157 100644
> --- a/net/smc/smc_core.c
> +++ b/net/smc/smc_core.c
> @@ -380,10 +380,14 @@ static int smc_link_determine_gid(struct
> smc_link_group *lgr)
>  		if (ib_query_gid(lnk->smcibdev->ibdev, lnk->ibport, i, &gid,
>  				 &gattr))
>  			continue;
> -		if (gattr.ndev &&
> -		    (vlan_dev_vlan_id(gattr.ndev) =3D=3D lgr->vlan_id)) {
> -			lnk->gid =3D gid;
> -			return 0;
> +		if (gattr.ndev) {
> +			if (is_vlan_dev(gattr.ndev) &&
> +			    vlan_dev_vlan_id(gattr.ndev) =3D=3D lgr->vlan_id) {
> +				lnk->gid =3D gid;
> +				dev_put(gattr.ndev);
> +				return 0;
> +			}
> +			dev_put(gattr.ndev);
>  		}
>  	}
>  	return -ENODEV;
> --
> 2.13.5

Looks fine now.
