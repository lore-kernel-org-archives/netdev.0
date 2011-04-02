From: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Subject: [PATCH] bonding-tlb: better balance when choosing slaves
Date: Sat,  2 Apr 2011 22:09:54 +0800
Message-ID: <1301753395-1205-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Weiping=20Pan (=E6=BD=98=E5=8D=AB=E5=B9=B3) ?=
	<panweiping3@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com> (supporter:BONDING DRIVER),
	Andy Gospodarek <andy@greyhouse.net> (supporter:BONDING DRIVER),
	netdev@vger.kernel.org (open list:BONDING DRIVER),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tlb_get_least_loaded_slave() always chooses slave from
bonding->first_slave, that gives the beginnig slaves more chances to be=
 used.

Let tlb_get_least_loaded_slave() chooses slave from a random positon in=
 the
slave list, make all slaves transmit packets more balanced.

Signed-off-by: Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) <panweiping3@gm=
ail.com>
---
 drivers/net/bonding/bond_alb.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_=
alb.c
index 9bc5de3..9fa64b0 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -36,6 +36,7 @@
 #include <linux/if_bonding.h>
 #include <linux/if_vlan.h>
 #include <linux/in.h>
+#include <linux/random.h>
 #include <net/ipx.h>
 #include <net/arp.h>
 #include <net/ipv6.h>
@@ -206,15 +207,27 @@ static long long compute_gap(struct slave *slave)
 /* Caller must hold bond lock for read */
 static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 {
-	struct slave *slave, *least_loaded;
+	struct slave *slave, *least_loaded, *start_slave;
 	long long max_gap;
 	int i;
+	u8 n;
=20
 	least_loaded =3D NULL;
+	start_slave =3D bond->first_slave;
 	max_gap =3D LLONG_MIN;
+       =20
+	get_random_bytes(&n, 1);
+
+	if (bond->slave_cnt =3D=3D 0)
+		return NULL;
+	n =3D n % bond->slave_cnt;
+
+	for (i=3D0; i<n; ++i) {
+		start_slave =3D start_slave->next;
+	}
=20
 	/* Find the slave with the largest gap */
-	bond_for_each_slave(bond, slave, i) {
+	bond_for_each_slave_from(bond, slave, i, start_slave) {
 		if (SLAVE_IS_OK(slave)) {
 			long long gap =3D compute_gap(slave);
=20
--=20
1.7.4
