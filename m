From: Parav Pandit <parav@mellanox.com>
Subject: RE: [PATCH net-next 01/10] net/smc: add missing dev_put
Date: Mon, 2 Oct 2017 20:39:56 +0000
Message-ID: <VI1PR0502MB300805E68E1191986EBFFD45D17D0@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
 <20170920115813.63745-2-ubraun@linux.vnet.ibm.com>
 <VI1PR0502MB30089D06B9C95D682E21511BD17D0@VI1PR0502MB3008.eurprd05.prod.outlook.com>
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
To: Parav Pandit <parav@mellanox.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10073.outbound.protection.outlook.com ([40.107.1.73]:54192
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751696AbdJBUj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 16:39:59 -0400
In-Reply-To: <VI1PR0502MB30089D06B9C95D682E21511BD17D0@VI1PR0502MB3008.eurprd05.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Parav Pandit
> Sent: Monday, October 02, 2017 3:36 PM
> To: Ursula Braun <ubraun@linux.vnet.ibm.com>; davem@davemloft.net
> Cc: netdev@vger.kernel.org; linux-rdma@vger.kernel.org; linux-
> s390@vger.kernel.org; jwi@linux.vnet.ibm.com; schwidefsky@de.ibm.com;
> heiko.carstens@de.ibm.com; raspl@linux.vnet.ibm.com
> Subject: RE: [PATCH net-next 01/10] net/smc: add missing dev_put
>=20
> Hi Ursula, Dave, Hans,
>=20
> > -----Original Message-----
> > From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> > owner@vger.kernel.org] On Behalf Of Ursula Braun
> > Sent: Wednesday, September 20, 2017 6:58 AM
> > To: davem@davemloft.net
> > Cc: netdev@vger.kernel.org; linux-rdma@vger.kernel.org; linux-
> > s390@vger.kernel.org; jwi@linux.vnet.ibm.com; schwidefsky@de.ibm.com;
> > heiko.carstens@de.ibm.com; raspl@linux.vnet.ibm.com;
> > ubraun@linux.vnet.ibm.com
> > Subject: [PATCH net-next 01/10] net/smc: add missing dev_put
> >
> > From: Hans Wippel <hwippel@linux.vnet.ibm.com>
> >
> > In the infiniband part, SMC currently uses get_netdev which calls
> > dev_hold on the returned net device. However, the SMC code never calls
> > dev_put on that net device resulting in a wrong reference count.
> >
> > This patch adds a dev_put after the usage of the net device to fix the =
issue.
> >
> > Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
> > Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> > ---
> >  net/smc/smc_ib.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c index
> > 547e0e113b17..0b5852299158 100644
> > --- a/net/smc/smc_ib.c
> > +++ b/net/smc/smc_ib.c
> > @@ -380,6 +380,7 @@ static int smc_ib_fill_gid_and_mac(struct
> > smc_ib_device *smcibdev, u8 ibport)
> >  	ndev =3D smcibdev->ibdev->get_netdev(smcibdev->ibdev, ibport);
> >  	if (ndev) {
> >  		memcpy(&smcibdev->mac, ndev->dev_addr, ETH_ALEN);
> > +		dev_put(ndev);
>=20
> I am sorry for providing late comments. smc_ib_fill_gid_and_mac() is not =
coded
> correctly.
> Few fixes are needed.
> 1. ULP such as SMC should not open code/deference any function pointer li=
ke
> get_netdev() of the IB device.
> 2. Replace ib_query_gid(..., NULL)
> With
> ib_query_gid(..., gid_attr);
>=20
> Use gid_attr.ndev to get the MAC address.
> Do dev_put(gid_attr.ndev);
>=20
> Code should look like below,
>=20
> struct ib_gid_attr gid_attr;
>=20
> rc =3D ib_query_gid(..., &gid_attr);
> if (rc || !gid_addr.ndev)
> 	return -ENODEV;
> else
> 	memcpy(smcibdev->mac, ndev->dev_addr, ETH_ALEN);
> dev_put(gid_addr.ndev);
> --

Also,
smc_link_determine_gid() doesn't do dev_put(gattr.ndev) in for loop.
Please fix it as well.
