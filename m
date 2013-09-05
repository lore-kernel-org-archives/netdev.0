From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Thu, 5 Sep 2013 08:40:36 +0200
Message-ID: <20130905064036.GC26000@1wt.eu>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130904163245.GI20552@1wt.eu>
 <CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
 <20130905051223.GB26000@1wt.eu>
 <CACzLR4uCQhGzgABV2nMG45EQBNsrW8=j5X7x-=eTSUmSvthLxg@mail.gmail.com>
 <ca521df880b08225cb34214e3ef0fc2c@cheny.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Content-Transfer-Encoding: 8bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Lior Amsalem <alior@marvell.com>,
 Jochen De Smet <jochen.armkernel@leahnim.org>,
 Simon Guinot <simon.guinot@sequanux.org>, Ryan Press <ryan@presslab.us>,
 netdev@vger.kernel.org, vdonnefort@lacie.com,
 Ethan Tuttle <ethan@ethantuttle.com>, stable@vger.kernel.org,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Peter Sanford <psanford@nearbuy.io>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: yves@cheny.fr
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <ca521df880b08225cb34214e3ef0fc2c@cheny.fr>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Thu, Sep 05, 2013 at 08:23:12AM +0200, yves@cheny.fr wrote:
> Hi Willy,
> i would be interested too !
> 
> thx
> Yves
> 
> Le 2013-09-05 07:22, Ethan Tuttle a écrit :
> >Understood.  Ultimately, I'll use this board as a router, and stable
> >mac addresses would be better than random.  So I would be interested
> >to try your atag -> device tree patches.  Have they been posted
> >somewhere I can find them?

OK guys, here they come. Note that they're now simplified since the
eth* aliases have been added to the dts.

Willy


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-ARM-atags-add-support-for-Marvell-s-u-boot.patch"

>From d8254ce7d6b199eb0114ee1229a066bd24d7f339 Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Sun, 2 Dec 2012 19:59:28 +0100
Subject: ARM: atags: add support for Marvell's u-boot

Marvell uses a specific atag in its u-boot which includes among other
information the MAC addresses for up to 4 network interfaces.

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 arch/arm/include/uapi/asm/setup.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/arm/include/uapi/asm/setup.h b/arch/arm/include/uapi/asm/setup.h
index 979ff40..d1d0c19 100644
--- a/arch/arm/include/uapi/asm/setup.h
+++ b/arch/arm/include/uapi/asm/setup.h
@@ -143,6 +143,18 @@ struct tag_memclk {
 	__u32 fmemclk;
 };
 
+/* Marvell uboot parameters */
+#define ATAG_MV_UBOOT          0x41000403
+struct tag_mv_uboot {
+	__u32 uboot_version;
+	__u32 tclk;
+	__u32 sysclk;
+	__u32 isUsbHost;
+	__u8  macAddr[4][6];
+	__u16 mtu[4];
+	__u32 nand_ecc;
+};
+
 struct tag {
 	struct tag_header hdr;
 	union {
@@ -165,6 +177,11 @@ struct tag {
 		 * DC21285 specific
 		 */
 		struct tag_memclk	memclk;
+
+		/*
+		 * Marvell specific
+		 */
+		struct tag_mv_uboot	mv_uboot;
 	} u;
 };
 
-- 
1.7.12.2.21.g234cd45.dirty


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-ARM-atags-fdt-retrieve-MAC-addresses-from-Marvell-bo.patch"

>From f2242fcc35ea1548bab13095a8d82dbf526ba9f7 Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Sun, 2 Dec 2012 19:56:58 +0100
Subject: ARM: atags/fdt: retrieve MAC addresses from Marvell boot loader

The atags are parsed and if a Marvell atag is found, up to 4 MAC
addresses are extracted there and assigned to node aliases eth0..3
with the name "mac-address".

This was tested on my Mirabox and the two NICs had their correct
address set.

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 arch/arm/boot/compressed/atags_to_fdt.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/compressed/atags_to_fdt.c b/arch/arm/boot/compressed/atags_to_fdt.c
index d1153c8..24b31ae 100644
--- a/arch/arm/boot/compressed/atags_to_fdt.c
+++ b/arch/arm/boot/compressed/atags_to_fdt.c
@@ -16,7 +16,7 @@ static int node_offset(void *fdt, const char *node_path)
 }
 
 static int setprop(void *fdt, const char *node_path, const char *property,
-		   uint32_t *val_array, int size)
+		   void *val_array, int size)
 {
 	int offset = node_offset(fdt, node_path);
 	if (offset < 0)
@@ -177,6 +177,12 @@ int atags_to_fdt(void *atag_list, void *fdt, int total_space)
 					initrd_start);
 			setprop_cell(fdt, "/chosen", "linux,initrd-end",
 					initrd_start + initrd_size);
+		} else if (atag->hdr.tag == ATAG_MV_UBOOT) {
+			/* This ATAG provides up to 4 MAC addresses */
+			setprop(fdt, "eth0", "mac-address", atag->u.mv_uboot.macAddr[0], 6);
+			setprop(fdt, "eth1", "mac-address", atag->u.mv_uboot.macAddr[1], 6);
+			setprop(fdt, "eth2", "mac-address", atag->u.mv_uboot.macAddr[2], 6);
+			setprop(fdt, "eth3", "mac-address", atag->u.mv_uboot.macAddr[3], 6);
 		}
 	}
 
-- 
1.7.12.2.21.g234cd45.dirty


--wac7ysb48OaltWcw
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--wac7ysb48OaltWcw--
