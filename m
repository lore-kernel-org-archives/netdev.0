From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH -next] fsl_pq_mdio: Use proper address translation
Date: Thu, 19 Mar 2009 19:48:08 +0300
Message-ID: <20090319164808.GA17795@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	linuxppc-dev@ozlabs.org
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

Currently the driver just read "reg" property for constructing MDIO
bus IDs, but this won't work when we'll start using "ranges = <>" in
the device tree, so this will pop up:

Freescale PowerQUICC MII Bus: probed
sysfs: duplicate filename 'mdio@520' can not be created
------------[ cut here ]------------
Badness at c00cb6b8 [verbose debug info unavailable]
NIP: c00cb6b8 LR: c00cb6b8 CTR: c001271c
REGS: cf82fc10 TRAP: 0700   Not tainted  (2.6.29-rc7-03702-g7ccd10f)
MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 42044022  XER: 20000000
TASK = cf81fbd0[1] 'swapper' THREAD: cf82e000
GPR00: c00cb6b8 cf82fcc0 cf81fbd0 0000003b 00000e42 ffffffff 00004000 00000e42
GPR08: c03cb0fc c03bfbdc 00000e42 c03cac50 22044022 1006a2bc 0ffcb000 00000000
GPR16: 0ffc04b0 0ffc5a40 00000000 0ffc79a8 0f7863a8 00000004 00000000 00000000
GPR24: c033a6a8 d1014520 cf85e840 cf82fd08 cf87cf2c cf82fcd8 cf85dea8 ffffffef
NIP [c00cb6b8] sysfs_add_one+0x4c/0x54
LR [c00cb6b8] sysfs_add_one+0x4c/0x54
Call Trace:
[cf82fcc0] [c00cb6b8] sysfs_add_one+0x4c/0x54 (unreliable)
[cf82fcd0] [c00cbc18] create_dir+0x58/0xc0
[cf82fd00] [c00cbcc0] sysfs_create_dir+0x40/0x70
[cf82fd20] [c0159388] create_dir+0x28/0x78
[cf82fd30] [c0159824] kobject_add_internal+0x98/0x13c
[cf82fd50] [c0159e98] kobject_add+0x60/0x98
[cf82fd80] [c018a480] device_add+0x98/0x2ac
[cf82fda0] [c01a2380] mdiobus_register+0xbc/0x1c0
[cf82fdc0] [c019f31c] fsl_pq_mdio_probe+0x284/0x2a0
[cf82fe00] [c0223814] of_platform_device_probe+0x5c/0x84
...

This patch fixes the issue by translating the "reg" property to a full
address, and thus avoids the duplicate names.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

On Thu, Mar 19, 2009 at 03:57:10AM -0500, Kumar Gala wrote:
[...]
>> This is for 2.6.30 since we don't use ranges = <> yet.
>>
>> David, I believe Kumar would like to pick this patch into his tree
>> along with a patch set that adds "ranges = <>" properties to the
>> device tree... So would you mind if we take it via powerpc.git?
>>
>> Thanks,
>>
>> drivers/net/gianfar_mii.c  |   10 +++++++---
>> drivers/net/ucc_geth_mii.c |   10 +++++++---
>> 2 files changed, 14 insertions(+), 6 deletions(-)
>
> Andy merged these in net-next to just have drivers/net/fsl_pq_mdio.c.
>
> My suggestion is to update the patch against -next and have David put it 
> into net-next.
>
> (I'll deal w/the .dts updates in powerpc.git and cherry pick commits out 
> of net-next into my testing branching)

OK.

David, I guess it's yours now. :-)

Thanks.

 drivers/net/fsl_pq_mdio.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index 6be36b9..b3079a5 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -194,11 +194,15 @@ static int *create_irq_map(struct device_node *np)
 
 void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
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
-- 
1.5.6.5
