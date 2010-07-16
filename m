From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Badness with the kernel version 2.6.35-rc1-git1 running on P6
 box
Date: Fri, 16 Jul 2010 14:20:42 +0200
Message-ID: <1279282842.2549.16.camel@edumazet-laptop>
References: <4C401D56.3070108@linux.vnet.ibm.com>
	 <1279274185.2549.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@ozlabs.org,
	sachinp@linux.vnet.ibm.com, benh@kernel.crashing.org,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jan-Bernd Themann <ossthema@de.ibm.com>
To: divya <dipraksh@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279274185.2549.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 16 juillet 2010 =C3=A0 11:56 +0200, Eric Dumazet a =C3=A9cr=
it :

> [PATCH] ehea: ehea_get_stats() should use GFP_KERNEL
>=20
> ehea_get_stats() is called in process context and should use GFP_KERN=
EL
> allocation instead of GFP_ATOMIC.
>=20
> Clearing stats at beginning of ehea_get_stats() is racy in case of
> concurrent stat readers.
>=20
> get_stats() can also use netdev net_device_stats, instead of a privat=
e
> copy.
>=20
> Reported-by: divya <dipraksh@linux.vnet.ibm.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  drivers/net/ehea/ehea.h      |    1 -
>  drivers/net/ehea/ehea_main.c |    6 ++----
>  2 files changed, 2 insertions(+), 5 deletions(-)
>=20
>=20

Hmm, net-next-2.6 contains following patch :

commit 3d8009c780ee90fccb5c171caf30aff839f13547
Author: Brian King <brking@linux.vnet.ibm.com>
Date:   Wed Jun 30 11:59:12 2010 +0000

    ehea: Allocate stats buffer with GFP_KERNEL
   =20
    Since ehea_get_stats calls ehea_h_query_ehea_port, which
    can sleep, we can also sleep when allocating a page in
    this function. This fixes some memory allocation failure
    warnings seen under low memory conditions.
   =20
    Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.=
c
index 8b92acb..3beba70 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -335,7 +335,7 @@ static struct net_device_stats
*ehea_get_stats(struct net_device *dev)
=20
        memset(stats, 0, sizeof(*stats));
=20
-       cb2 =3D (void *)get_zeroed_page(GFP_ATOMIC);
+       cb2 =3D (void *)get_zeroed_page(GFP_KERNEL);
        if (!cb2) {
                ehea_error("no mem for cb2");
                goto out;
