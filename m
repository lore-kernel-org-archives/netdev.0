From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: Re: [e1000][net-2.6 tree] Regression: driver doesn't detect card on my
 node.
Date: Wed, 06 Feb 2008 00:20:24 -0800
Message-ID: <200802060020.25492.yinghai.lu@sun.com>
References: <47A89A77.1050608@openvz.org>
 <200802050943.01652.yinghai.lu@sun.com> <47A95D60.5090203@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, Denis Lunev <den@openvz.org>,
	Justin Piszcz <jpiszcz@lucidpixels.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:49595 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbYBFIM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 03:12:57 -0500
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m168Cubs023872
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 00:12:56 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JVT00A015H65Z00@fe-sfbay-10.sun.com>
 (original mail from Yinghai.Lu@Sun.COM) for netdev@vger.kernel.org; Wed,
 06 Feb 2008 00:12:56 -0800 (PST)
In-reply-to: <47A95D60.5090203@openvz.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 February 2008 11:10:24 pm Pavel Emelyanov wrote:
> [snip]
> 
> >>> What other info from me is required?
> > 
> > boot log please. with the patch and reverting the patch.
> 
> Here they are (attached).
> BTW, I found, that the sky2 adapter is broken by this patch as well.
> To simplify the analysis, here's their diff:
> 
> --- bad-log	2008-02-06 10:06:40.000000000 +0300
> +++ good-log	2008-02-06 10:06:40.000000000 +0300
> @@ -1,4 +1,4 @@
> -Linux version 2.6.24 (pavel@xemulnb) (gcc version 4.1.3 20070724 (prerelease) (SUSE Linux)) #22 SMP Tue Feb 5 20:09:11 MSK 2008
> +Linux version 2.6.24 (pavel@xemulnb) (gcc version 4.1.3 20070724 (prerelease) (SUSE Linux)) #23 SMP Wed Feb 6 10:03:53 MSK 2008
>  BIOS-provided physical RAM map:
>   BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
>   BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
> @@ -19,29 +19,6 @@ Scan SMP from c0000000 for 1024 bytes.
>  Scan SMP from c009fc00 for 1024 bytes.
>  Scan SMP from c00f0000 for 65536 bytes.
>  found SMP MP-table at [c00ff780] 000ff780
> -***************
> -**** WARNING: likely BIOS bug
> -**** MTRRs don't cover all of memory, trimmed 786432 pages
> -***************
> -update e820 for mtrr
> -modified physical RAM map:
> - modified: 0000000000000000 - 000000000009f800 (usable)
> - modified: 000000000009f800 - 00000000000a0000 (reserved)
> - modified: 00000000000e0000 - 0000000000100000 (reserved)
> - modified: 0000000000100000 - 0000000040000000 (usable)
> - modified: 0000000040000000 - 00000000bfff0000 (reserved)
> - modified: 00000000bfff0000 - 00000000bffff000 (ACPI data)
> - modified: 00000000bffff000 - 00000000c0000000 (ACPI NVS)
> - modified: 00000000c0000000 - 0000000100000000 (reserved)
> - modified: 0000000100000000 - 0000000140000000 (usable)

the root cause could be your mtrr last entry for RAM has strange type

please apply the following line to print the mtrr before trimming to current linus tree.

Thanks

YH

diff --git a/arch/x86/kernel/cpu/mtrr/main.c b/arch/x86/kernel/cpu/mtrr/main.c
index 1e27b69..c0c44e0 100644
--- a/arch/x86/kernel/cpu/mtrr/main.c
+++ b/arch/x86/kernel/cpu/mtrr/main.c
@@ -680,6 +680,7 @@ int __init mtrr_trim_uncached_memory(unsigned long end_pfn)
 	/* Find highest cached pfn */
 	for (i = 0; i < num_var_ranges; i++) {
 		mtrr_if->get(i, &base, &size, &type);
+		printk(KERN_INFO "i=%d %lx - %lx %d\n", i, base, base + size, type);
 		if (type != MTRR_TYPE_WRBACK)
 			continue;
 		base <<= PAGE_SHIFT;
