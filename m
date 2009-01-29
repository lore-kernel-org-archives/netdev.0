From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Oops / Warning report for the week of January 28th, 2009: The
	200.000th trace.
Date: Thu, 29 Jan 2009 11:49:10 +0100
Message-ID: <20090129104910.GA10987@elte.hu>
References: <4980A0D8.80209@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Dave Airlie <airlied@redhat.com>
To: Arjan van de Ven <arjan@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:60564 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768AbZA2KtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 05:49:24 -0500
Content-Disposition: inline
In-Reply-To: <4980A0D8.80209@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Arjan van de Ven <arjan@linux.intel.com> wrote:

> Rank 3: mtrr_trim_uncached_memory (warning)
> 	Reported 709 times (14696 total reports)
> 	BIOS bug (often in VMWare) where the MTRR's are set up incorrectly or not at all
> 	This warning was last seen in version 2.6.29-rc2-git1, and first seen in 2.6.24.
> 	More info: http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory

This bug is not finding any real issues for us anymore and this rate of 
false positives is a distraction - so i've queued up the patch below in 
tip/x86/urgent.

	Ingo

--------------------->
>From bf3647c44bc76c43c4b2ebb4c37a559e899ac70e Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 29 Jan 2009 11:45:35 +0100
Subject: [PATCH] x86: tone down mtrr_trim_uncached_memory() warning

kerneloops.org is reporting a lot of these warnings that come due to
vmware not setting up any MTRRs for emulated CPUs:

| Reported 709 times (14696 total reports)
| BIOS bug (often in VMWare) where the MTRR's are set up incorrectly
| or not at all
|
| This warning was last seen in version 2.6.29-rc2-git1, and first
| seen in 2.6.24.
|
| More info:
|   http://www.kerneloops.org/searchweek.php?search=mtrr_trim_uncached_memory

Keep a one-liner KERN_INFO about it - so that we have so notice if empty
MTRRs are caused by native hardware/BIOS weirdness.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/kernel/cpu/mtrr/main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/main.c b/arch/x86/kernel/cpu/mtrr/main.c
index d259e5d..236a401 100644
--- a/arch/x86/kernel/cpu/mtrr/main.c
+++ b/arch/x86/kernel/cpu/mtrr/main.c
@@ -1594,8 +1594,7 @@ int __init mtrr_trim_uncached_memory(unsigned long end_pfn)
 
 	/* kvm/qemu doesn't have mtrr set right, don't trim them all */
 	if (!highest_pfn) {
-		WARN(!kvm_para_available(), KERN_WARNING
-				"WARNING: strange, CPU MTRRs all blank?\n");
+		printk(KERN_INFO "CPU MTRRs all blank - virtualized system.\n");
 		return 0;
 	}
 
