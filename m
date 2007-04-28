From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Sat, 28 Apr 2007 01:04:14 -0700
Message-ID: <20070428010414.2ba43a30.akpm@linux-foundation.org>
References: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Apr 2007 01:55:49 +0900 (JST) Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:

> +static int __init rbtx4938_ne_init(void)
> +{
> +	struct resource res[] = {
> +		{
> +			.start	= RBTX4938_RTL_8019_BASE,
> +			.end	= RBTX4938_RTL_8019_BASE + 0x20 - 1,
> +			.flags	= IORESOURCE_IO,
> +		}, {
> +			.start	= RBTX4938_RTL_8019_IRQ,
> +			.flags	= IORESOURCE_IRQ,
> +		}
> +	};
> +	struct platform_device *dev =
> +		platform_device_register_simple("ne", -1,
> +						res, ARRAY_SIZE(res));
> +	return IS_ERR(dev) ? PTR_ERR(dev) : 0;
> +}

platform_device_register_simple() copies *res by value, so I believe we can
make res[] static __initdata.  This way we don't need to evaluate the array
on the stack at runtime, and the data gets discarded after initcalls have
run.

Can you please review and test the below?  I had a go but wasn't able to
fumble my way to a suitable config (I hope):

<stdin>:1176:2: warning: #warning syscall fadvise64_64 not implemented
arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c: In function `toshiba_rbtx4927_time_init':
arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c:1026: error: `tx4927_cpu_clock' undeclared (first use in this function)
arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c:1026: error: (Each undeclared identifier is reported only once
arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c:1026: error: for each function it appears in.)
make[1]: *** [arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.o] Error 1
make: *** [arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.o] Error 2
make: *** Waiting for unfinished jobs....
arch/mips/tx4938/toshiba_rbtx4938/setup.c:41: warning: 'tx4938_report_pcic_status1' declared `static' but never defined
arch/mips/tx4938/toshiba_rbtx4938/setup.c:56: warning: 'tx4938_pcic_trdyto' defined but not used
arch/mips/tx4938/toshiba_rbtx4938/setup.c:57: warning: 'tx4938_pcic_retryto' defined but not used



From: Andrew Morton <akpm@linux-foundation.org>

Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c~ne-mips-use-platform_driver-for-ne-on-rbtx49xx-fix arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
--- a/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c~ne-mips-use-platform_driver-for-ne-on-rbtx49xx-fix
+++ a/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
@@ -1039,7 +1039,7 @@ void __init toshiba_rbtx4927_timer_setup
 
 static int __init toshiba_rbtx4927_rtc_init(void)
 {
-	struct resource res = {
+	static struct resource __initdata res = {
 		.start	= 0x1c010000,
 		.end	= 0x1c010000 + 0x800 - 1,
 		.flags	= IORESOURCE_MEM,
@@ -1052,7 +1052,7 @@ device_initcall(toshiba_rbtx4927_rtc_ini
 
 static int __init rbtx4927_ne_init(void)
 {
-	struct resource res[] = {
+	static struct resource __initdata res[] = {
 		{
 			.start	= RBTX4927_RTL_8019_BASE,
 			.end	= RBTX4927_RTL_8019_BASE + 0x20 - 1,
_
