From: Parav Pandit <parav@mellanox.com>
Subject: RE: [PATCH net 2/2] net/smc: dev_put for netdev after usage of
 ib_query_gid()
Date: Tue, 10 Oct 2017 17:09:08 +0000
Message-ID: <VI1PR0502MB30088E4F58036AB3A06822E8D1750@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20171010141351.87700-1-ubraun@linux.vnet.ibm.com>
 <20171010141351.87700-3-ubraun@linux.vnet.ibm.com>
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
Received: from mail-db5eur01on0042.outbound.protection.outlook.com ([104.47.2.42]:31926
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932287AbdJJRJN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:09:13 -0400
In-Reply-To: <20171010141351.87700-3-ubraun@linux.vnet.ibm.com>
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
> Subject: [PATCH net 2/2] net/smc: dev_put for netdev after usage of
> ib_query_gid()
>=20
> For ROCEs ib_query_gid() takes a reference count on the net_device.
> This reference count must be decreased by the caller.
>=20
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reported-by: Parav Pandit <parav@mellanox.com>

> ---
>  net/smc/smc_core.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c index
> 20b66e79c5d6..e93a31ec3cc2 100644
> --- a/net/smc/smc_core.c
> +++ b/net/smc/smc_core.c
> @@ -380,10 +380,13 @@ static int smc_link_determine_gid(struct
> smc_link_group *lgr)
>  		if (ib_query_gid(lnk->smcibdev->ibdev, lnk->ibport, i, &gid,
>  				 &gattr))
>  			continue;
> -		if (gattr.ndev &&
> -		    (vlan_dev_vlan_id(gattr.ndev) =3D=3D lgr->vlan_id)) {
> -			lnk->gid =3D gid;
> -			return 0;
> +		if (gattr.ndev) {
> +			if (vlan_dev_vlan_id(gattr.ndev) =3D=3D lgr->vlan_id) {

This needs to be changed to=20
If (gattr.ndev) {
	if (is_vlan_dev(gattr.ndev)) &&=20
	    vlan_dev_vlan_id(gattr.ndev) =3D=3D lgr->vlan_id) {
	...
}

Without this check, on vlan disabled kernel at compile time, kernel will cr=
ash on vlan_dev_vlan_id().
Please fix this part, rest code looks fine.
