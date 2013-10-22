From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH] net: wan: sbni: remove assembly crc32 code
Date: Tue, 22 Oct 2013 20:36:25 +0200
Message-ID: <20131022183625.GA4382@breakpoint.cc>
References: <1382458346-24811-1-git-send-email-andi@firstfloor.org>
 <1382458346-24811-12-git-send-email-andi@firstfloor.org>
 <20131022.135928.2040131908206663695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, ak@linux.intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131022.135928.2040131908206663695.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is also a C function doing the same thing. Unless the asm code is
110% faster we could stick to the C function.

Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---

On Tue, Oct 22, 2013 at 01:59:28PM -0400, David Miller wrote:
> 
> Is it really impossible to use the generic crc32 support instead of this
> unsightly custom inline assembler?

Since you asked for this here step 1.

 drivers/net/wan/sbni.c | 89 --------------------------------------------------
 1 file changed, 89 deletions(-)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 5bbcb5e..388ddf6 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -148,10 +148,6 @@ static int  enslave( struct net_device *, struct net_device * );
 static int  emancipate( struct net_device * );
 #endif
 
-#ifdef __i386__
-#define ASM_CRC 1
-#endif
-
 static const char  version[] =
 	"Granch SBNI12 driver ver 5.0.1  Jun 22 2001  Denis I.Timofeev.\n";
 
@@ -1551,88 +1547,6 @@ __setup( "sbni=", sbni_setup );
 
 /* -------------------------------------------------------------------------- */
 
-#ifdef ASM_CRC
-
-static u32
-calc_crc32( u32  crc,  u8  *p,  u32  len )
-{
-	register u32  _crc;
-	_crc = crc;
-	
-	__asm__ __volatile__ (
-		"xorl	%%ebx, %%ebx\n"
-		"movl	%2, %%esi\n" 
-		"movl	%3, %%ecx\n" 
-		"movl	$crc32tab, %%edi\n"
-		"shrl	$2, %%ecx\n"
-		"jz	1f\n"
-
-		".align 4\n"
-	"0:\n"
-		"movb	%%al, %%bl\n"
-		"movl	(%%esi), %%edx\n"
-		"shrl	$8, %%eax\n"
-		"xorb	%%dl, %%bl\n"
-		"shrl	$8, %%edx\n"
-		"xorl	(%%edi,%%ebx,4), %%eax\n"
-
-		"movb	%%al, %%bl\n"
-		"shrl	$8, %%eax\n"
-		"xorb	%%dl, %%bl\n"
-		"shrl	$8, %%edx\n"
-		"xorl	(%%edi,%%ebx,4), %%eax\n"
-
-		"movb	%%al, %%bl\n"
-		"shrl	$8, %%eax\n"
-		"xorb	%%dl, %%bl\n"
-		"movb	%%dh, %%dl\n" 
-		"xorl	(%%edi,%%ebx,4), %%eax\n"
-
-		"movb	%%al, %%bl\n"
-		"shrl	$8, %%eax\n"
-		"xorb	%%dl, %%bl\n"
-		"addl	$4, %%esi\n"
-		"xorl	(%%edi,%%ebx,4), %%eax\n"
-
-		"decl	%%ecx\n"
-		"jnz	0b\n"
-
-	"1:\n"
-		"movl	%3, %%ecx\n"
-		"andl	$3, %%ecx\n"
-		"jz	2f\n"
-
-		"movb	%%al, %%bl\n"
-		"shrl	$8, %%eax\n"
-		"xorb	(%%esi), %%bl\n"
-		"xorl	(%%edi,%%ebx,4), %%eax\n"
-
-		"decl	%%ecx\n"
-		"jz	2f\n"
-
-		"movb	%%al, %%bl\n"
-		"shrl	$8, %%eax\n"
-		"xorb	1(%%esi), %%bl\n"
-		"xorl	(%%edi,%%ebx,4), %%eax\n"
-
-		"decl	%%ecx\n"
-		"jz	2f\n"
-
-		"movb	%%al, %%bl\n"
-		"shrl	$8, %%eax\n"
-		"xorb	2(%%esi), %%bl\n"
-		"xorl	(%%edi,%%ebx,4), %%eax\n"
-	"2:\n"
-		: "=a" (_crc)
-		: "0" (_crc), "g" (p), "g" (len)
-		: "bx", "cx", "dx", "si", "di"
-	);
-
-	return  _crc;
-}
-
-#else	/* ASM_CRC */
-
 static u32
 calc_crc32( u32  crc,  u8  *p,  u32  len )
 {
@@ -1642,9 +1556,6 @@ calc_crc32( u32  crc,  u8  *p,  u32  len )
 	return  crc;
 }
 
-#endif	/* ASM_CRC */
-
-
 static u32  crc32tab[] __attribute__ ((aligned(8))) = {
 	0xD202EF8D,  0xA505DF1B,  0x3C0C8EA1,  0x4B0BBE37,
 	0xD56F2B94,  0xA2681B02,  0x3B614AB8,  0x4C667A2E,
-- 
1.8.4.rc3
