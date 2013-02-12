From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] tg3: Convert chip type macros to inline functions
Date: Mon, 11 Feb 2013 17:43:13 -0800
Message-ID: <1360633393.5128.13.camel@joe-AO722>
References: <1360194298.12464.35.camel@joe-AO722>
	 <20130210.193927.632140014473940921.davem@davemloft.net>
	 <1360546445.2028.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hauke@hauke-m.de, mcarlson@broadcom.com,
	mchan@broadcom.com, nsujir@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:32807 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932808Ab3BLBnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2013 20:43:14 -0500
In-Reply-To: <1360546445.2028.8.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-02-10 at 17:34 -0800, Joe Perches wrote:
> On Sun, 2013-02-10 at 19:39 -0500, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Wed, 06 Feb 2013 15:44:58 -0800
> > > To me the negative to these conversions is at
> > > least for gcc 4.7.2, the overall code size
> > > increases
> > > $ size drivers/net/ethernet/broadcom/tg3.o*
> > >    text          data     bss     dec     hex filename
> > >  203426         13446   55744  272616   428e8 drivers/net/ethernet/broadcom/tg3.o.new
> > >  202135         13446   55144  270725   42185 drivers/net/ethernet/broadcom/tg3.o.old
> > > I'm not sure why gcc doesn't do the optimization
> > > and code generation the same way.
> > Out of curiosity I looked at the assembler difference on sparc
> > and one thing stood out.
[]
> > The assembler is hard to compare manually, because the inlining
> > changes how hard registers are allocated, and issues like the above
> > will change all of the branch and file offsets as well. :-/
[]
> If the inlines return int instead of u32, x86 objects
> do change trivially (using 2 jg vs ja) , but the size
> is unchanged from u32 to int (still bigger).

Another option would be to change the macro names
and add comments for why these aren't static inlines.

btw: I tried statement expressions too.

Simple statement expressions are the same size.
Oddly, SE macros like:

#define tg3_asic_rev(tp)			\
({						\
	typecheck(struct tg3 *, tp);		\
	((tp)->pci_chip_rev_id >> 12);		\
})

produce larger code even though I expected the
optimizer to effectively remove the typecheck.

Maybe something like:

 drivers/net/ethernet/broadcom/tg3.h | 27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index ef6ced2..2613691 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -120,9 +120,6 @@
 #define  MISC_HOST_CTRL_TAGGED_STATUS	 0x00000200
 #define  MISC_HOST_CTRL_CHIPREV		 0xffff0000
 #define  MISC_HOST_CTRL_CHIPREV_SHIFT	 16
-#define  GET_CHIP_REV_ID(MISC_HOST_CTRL) \
-	 (((MISC_HOST_CTRL) & MISC_HOST_CTRL_CHIPREV) >> \
-	  MISC_HOST_CTRL_CHIPREV_SHIFT)
 #define  CHIPREV_ID_5700_A0		 0x7000
 #define  CHIPREV_ID_5700_A1		 0x7001
 #define  CHIPREV_ID_5700_B0		 0x7100
@@ -163,7 +160,7 @@
 #define  CHIPREV_ID_5719_A0		 0x05719000
 #define  CHIPREV_ID_5720_A0		 0x05720000
 #define  CHIPREV_ID_5762_A0		 0x05762000
-#define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
+
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
 #define   ASIC_REV_5703			 0x01
@@ -187,7 +184,6 @@
 #define   ASIC_REV_5720			 0x5720
 #define   ASIC_REV_57766		 0x57766
 #define   ASIC_REV_5762			 0x5762
-#define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
 #define   CHIPREV_5700_CX		 0x72
@@ -200,7 +196,6 @@
 #define   CHIPREV_5784_AX		 0x57840
 #define   CHIPREV_5761_AX		 0x57610
 #define   CHIPREV_57765_AX		 0x577650
-#define  GET_METAL_REV(CHIP_REV_ID)	((CHIP_REV_ID) & 0xff)
 #define   METAL_REV_A0			 0x00
 #define   METAL_REV_A1			 0x01
 #define   METAL_REV_B0			 0x00
@@ -3357,4 +3352,23 @@ struct tg3 {
 	bool				link_up;
 };
 
+/* Accessor macros for chip and asic attributes
+ *
+ * nb: Using static inlines equivalent to the accessor macros generates
+ *     larger object code with gcc 4.7.
+ *     Using statement expression macros to check tp with
+ *     typecheck(struct tg3 *, tp) also creates larger objects.
+ */
+#define tg3_chip_rev_id(tp)					\
+	((tp)->pci_chip_rev_id)
+#define tg3_asic_rev(tp)					\
+	((tp)->pci_chip_rev_id >> 12)
+#define tg3_chip_rev(tp)					\
+	((tp)->pci_chip_rev_id >> 8)
+#define tg3_metal_rev(tp)					\
+	((tp)->pci_chip_rev_id & 0xff)
+#define tg3_misc_host_ctrl(tp)					\
+	(((tp)->misc_host_ctrl & MISC_HOST_CTRL_CHIPREV) >>	\
+	 MISC_HOST_CTRL_CHIPREV_SHIFT)
+
 #endif /* !(_T3_H) */
