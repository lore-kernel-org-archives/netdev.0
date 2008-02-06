From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: [PATCH] x86_32: fix regression caused by trim ram according to mtrr on
 system with 4G more RAM
Date: Wed, 06 Feb 2008 01:49:25 -0800
Message-ID: <200802060149.26083.yinghai.lu@sun.com>
References: <47A89A77.1050608@openvz.org>
 <200802060119.25278.yinghai.lu@sun.com> <47A97E28.1010400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, Denis Lunev <den@openvz.org>,
	Justin Piszcz <jpiszcz@lucidpixels.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:50289 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760847AbYBFJl5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:41:57 -0500
In-reply-to: <47A97E28.1010400@openvz.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] x86_32: fix regression caused by trim ram according to mtrr on =
system with 4G more RAM

Pravel report:
"
The commit

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0093af8d7f0ba3c6be148597=
3508584ef081e9f93
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0x86_32: trim memory by =
updating e820

broke my e1000 card: on loading driver says that

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e1000: probe of 0000:04=
:03.0 failed with error -5

and the interface doesn't appear.
"

on 32 bit kernel, base will overflow when try to do PAGE_SHIFT.
and highest_addr will always less 4G.

so use pfn instead of address to avoid overflow when more than 4g
 ram installed on 32bit kernel
Many thanks for Pavel Emelyanov to report and test it.

Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
Tested-by: Pavel Emelyanov <xemul@openvz.org>

diff --git a/arch/x86/kernel/cpu/mtrr/main.c b/arch/x86/kernel/cpu/mtrr=
/main.c
index 1e27b69..4e7490f 100644
--- a/arch/x86/kernel/cpu/mtrr/main.c
+++ b/arch/x86/kernel/cpu/mtrr/main.c
@@ -659,7 +659,7 @@ static __init int amd_special_default_mtrr(void)
  */
 int __init mtrr_trim_uncached_memory(unsigned long end_pfn)
 {
-	unsigned long i, base, size, highest_addr =3D 0, def, dummy;
+	unsigned long i, base, size, highest_pfn =3D 0, def, dummy;
 	mtrr_type type;
 	u64 trim_start, trim_size;
=20
@@ -682,28 +682,27 @@ int __init mtrr_trim_uncached_memory(unsigned lon=
g end_pfn)
 		mtrr_if->get(i, &base, &size, &type);
 		if (type !=3D MTRR_TYPE_WRBACK)
 			continue;
-		base <<=3D PAGE_SHIFT;
-		size <<=3D PAGE_SHIFT;
-		if (highest_addr < base + size)
-			highest_addr =3D base + size;
+		if (highest_pfn < base + size)
+			highest_pfn =3D base + size;
 	}
=20
 	/* kvm/qemu doesn't have mtrr set right, don't trim them all */
-	if (!highest_addr) {
+	if (!highest_pfn) {
 		printk(KERN_WARNING "WARNING: strange, CPU MTRRs all blank?\n");
 		WARN_ON(1);
 		return 0;
 	}
=20
-	if ((highest_addr >> PAGE_SHIFT) < end_pfn) {
+	if (highest_pfn < end_pfn) {
 		printk(KERN_WARNING "WARNING: BIOS bug: CPU MTRRs don't cover"
 			" all of memory, losing %LdMB of RAM.\n",
-			(((u64)end_pfn << PAGE_SHIFT) - highest_addr) >> 20);
+			(end_pfn - highest_pfn) >> (20 - PAGE_SHIFT));
=20
 		WARN_ON(1);
=20
 		printk(KERN_INFO "update e820 for mtrr\n");
-		trim_start =3D highest_addr;
+		trim_start =3D highest_pfn;
+		trim_start <<=3D PAGE_SHIFT;
 		trim_size =3D end_pfn;
 		trim_size <<=3D PAGE_SHIFT;
 		trim_size -=3D trim_start;
