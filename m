From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH -next] gianfar, ucc_geth: Use proper address translation
	for MDIO buses
Date: Wed, 18 Mar 2009 22:21:52 +0300
Message-ID: <20090318192152.GA29621@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>,
	Scott Wood <scottwood@freescale.com>, Li Yang <leoli@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Currently the drivers just read "reg" property for constructing MDIO
bus IDs, but this won't work when we'll start using "ranges = <>" in
the device tree, so this will pop up:

Gianfar MII Bus: probed
sysfs: duplicate filename 'mdio@520' can not be created
------------[ cut here ]------------
Badness at c00c70c8 [verbose debug info unavailable]
NIP: c00c70c8 LR: c00c70c8 CTR: c018220c
REGS: cf82fc80 TRAP: 0700   Not tainted  (2.6.29-rc7-00607-g8deffe6)
MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 22044022  XER: 20000000
TASK = cf821bd0[1] 'swapper' THREAD: cf82e000
GPR00: c00c70c8 cf82fd30 cf821bd0 0000003b 000013a4 ffffffff c017f4f0 000013a4
GPR08: c03becbc c03b1f5c 000013a4 c03be810 22044022 00000000 0ffcd000 00000000
GPR16: 0ffc2420 0ffc6eb8 00000000 00000000 00000000 00000000 00000000 00000000
GPR24: 00000000 00000000 cf9d8c40 cf82fd78 cf86ec14 cf82fd48 cf9d78a4 ffffffef
NIP [c00c70c8] sysfs_add_one+0x4c/0x54
LR [c00c70c8] sysfs_add_one+0x4c/0x54
Call Trace:
[cf82fd30] [c00c70c8] sysfs_add_one+0x4c/0x54 (unreliable)
[cf82fd40] [c00c7628] create_dir+0x58/0xc0
[cf82fd70] [c00c76d0] sysfs_create_dir+0x40/0x70
[cf82fd90] [c0154d58] create_dir+0x28/0x78
[cf82fda0] [c01551f4] kobject_add_internal+0x98/0x13c
[cf82fdc0] [c0155868] kobject_add+0x60/0x98
[cf82fdf0] [c01854f4] device_add+0x98/0x2ac
[cf82fe10] [c01985d8] mdiobus_register+0xb4/0x1b8
[cf82fe30] [c0194f1c] gfar_mdio_probe+0x188/0x204
...

This patch fixes the issue by translating the "reg" property to a full
address, and thus avoids the duplicate names.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

This is for 2.6.30 since we don't use ranges = <> yet.

David, I believe Kumar would like to pick this patch into his tree
along with a patch set that adds "ranges = <>" properties to the
device tree... So would you mind if we take it via powerpc.git?

Thanks,

 drivers/net/gianfar_mii.c  |   10 +++++++---
 drivers/net/ucc_geth_mii.c |   10 +++++++---
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index f49a426..92bc1a7 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -193,11 +193,15 @@ static int *create_irq_map(struct device_node *np)
 
 void gfar_mdio_bus_name(char *name, struct device_node *np)
 {
-	const u32 *reg;
+	const u32 *addr;
+	u64 taddr = OF_BAD_ADDR;
 
-	reg = of_get_property(np, "reg", NULL);
+	addr = of_get_address(np, 0, NULL, NULL);
+	if (addr)
+		taddr = of_translate_address(np, addr);
 
-	snprintf(name, MII_BUS_ID_SIZE, "%s@%x", np->name, reg ? *reg : 0);
+	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
+		(unsigned long long)taddr);
 }
 
 /* Scan the bus in reverse, looking for an empty spot */
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 0ada4ed..99cbd14 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -286,10 +286,14 @@ void uec_mdio_exit(void)
 
 void uec_mdio_bus_name(char *name, struct device_node *np)
 {
-        const u32 *reg;
+	const u32 *addr;
+	u64 taddr = OF_BAD_ADDR;
 
-        reg = of_get_property(np, "reg", NULL);
+	addr = of_get_address(np, 0, NULL, NULL);
+	if (addr)
+		taddr = of_translate_address(np, addr);
 
-        snprintf(name, MII_BUS_ID_SIZE, "%s@%x", np->name, reg ? *reg : 0);
+	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
+		(unsigned long long)taddr);
 }
 
-- 
1.5.6.5
