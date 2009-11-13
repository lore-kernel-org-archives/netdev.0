From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 07:12:35 +0100
Message-ID: <4AFCF8D3.6090905@gmail.com>
References: <200911130701.14847.opurdila@ixiacom.com> <200911130720.19671.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59504 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbZKMGMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 01:12:34 -0500
In-Reply-To: <200911130720.19671.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Friday 13 November 2009 07:01:14 you wrote:
>> This patch speeds up the network device name allocation for the case
>> where a significant number of devices of the same type are created
>> consecutively.
>>
>> Tests performed on a PPC750 @ 800Mhz machine with per device sysctl
>> and sysfs entries disabled:
>>
>> Without the patch           With the patch
>>
>> real    0m 43.43s	    real    0m 0.49s
>> user    0m 0.00s	    user    0m 0.00s
>> sys     0m 43.43s	    sys     0m 0.48s
>>
>=20
> Oops, pasting root prompts (e.g. # modprobe ....) directly into the g=
it commit message is not a good idea :) Here it is again, with the full=
 commit message.
>=20
> [net-next-2.6 PATCH] net: fast consecutive name allocation
>=20
> This patch speeds up the network device name allocation for the case
> where a significant number of devices of the same type are created
> consecutively.
>=20
> Tests performed on a PPC750 @ 800Mhz machine with per device sysctl
> and sysfs entries disabled:
>=20
> $ time insmod /lib/modules/dummy.ko numdummies=3D8000
>=20
> Without the patch           With the patch
>=20
> real    0m 43.43s	    real    0m 0.49s
> user    0m 0.00s	    user    0m 0.00s
> sys     0m 43.43s	    sys     0m 0.48s
>=20
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---

Honestly I dont like this bloat.

Changing dummy.c is trivial, and you can allocate 100.000.000 dummies i=
f you want now :)

I not tested yet this patch but here it is :

[PATCH] dummy: Allow more than 32768 dummies

And speedup name allocation : O(N) instead of O(N^2)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/dummy.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 37dcfdc..f600c4c 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -107,12 +107,14 @@ static struct rtnl_link_ops dummy_link_ops __read=
_mostly =3D {
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
=20
-static int __init dummy_init_one(void)
+static int __init dummy_init_one(int i)
 {
 	struct net_device *dev_dummy;
 	int err;
+	char name[IFNAMSIZ];
=20
-	dev_dummy =3D alloc_netdev(0, "dummy%d", dummy_setup);
+	snprintf(name, IFNAMSIZ, "dummy%d", i);
+	dev_dummy =3D alloc_netdev(0, name, dummy_setup);
 	if (!dev_dummy)
 		return -ENOMEM;
=20
@@ -139,7 +141,7 @@ static int __init dummy_init_module(void)
 	err =3D __rtnl_link_register(&dummy_link_ops);
=20
 	for (i =3D 0; i < numdummies && !err; i++)
-		err =3D dummy_init_one();
+		err =3D dummy_init_one(i);
 	if (err < 0)
 		__rtnl_link_unregister(&dummy_link_ops);
 	rtnl_unlock();

