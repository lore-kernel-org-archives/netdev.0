From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 13:18:56 -0800
Message-ID: <492F0EC0.5030802@kernel.org>
References: <492DD792.6080302@linux.intel.com>	<20081127115236.GE29013@elte.hu>	<492EE087.80708@linux.intel.com>	<20081127201836.GA16869@elte.hu> <20081127122800.45fc0b1a@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:34497 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752925AbYK0VUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 16:20:17 -0500
In-Reply-To: <20081127122800.45fc0b1a@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> On Thu, 27 Nov 2008 21:18:36 +0100
> Ingo Molnar <mingo@elte.hu> wrote:
> 
>> * Arjan van de Ven <arjan@linux.intel.com> wrote:
>>
>>> Ingo Molnar wrote:
>>>> * Arjan van de Ven <arjan@linux.intel.com> wrote:
>>>>
>>>>> Rank 8: mtrr_trim_uncached_memory (warning)
>>>>> 	Reported 227 times (619 total reports)
>>>>> 	There is a high number of machines where our MTRR checks
>>>>> 	trigger. I suspect we are too picky in accepting the MTRR
>>>>> 	configuration.
>>>> the warning here means: "the BIOS messed up but we fixed it up for
>>>> you just fine".
>>> I don't believe that right now. we see so many of these, including 
>>> many "there's no MTRRs at all", that I am seriously suspecting that 
>>> our code is just incorrect somehow and triggering too much.
>> well we looked at existing reports and Linux was right to fix them
>> up. Show us one that is incorrect, then we can fix it up.
>>
>> the "no MTRR's" are vmware/(also qemu?) guests not implementing a
>> full CPU emulation.
> 
> ... and it's still our fault in part, since we don't even check to see
> if a cpu claims to support MTRR before complaining about it...
> 
> easy to fix though:
> 
> From 7e987ae541c41ce908b414fee9d8e2fd2099a083 Mon Sep 17 00:00:00 2001
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Thu, 27 Nov 2008 12:25:47 -0800
> Subject: [PATCH] x86: make sure the CPU advertizes MTRR support before complaining about the lack thereoff...
> 
> We complain loudly if a CPU does not have MTRR support... but we don't check if the CPU
> exposes MTRR support in the CPUID flags first. While this might not fix all of the
> broken virtualization systems out there, it will at least fix those that properly don't
> advertize things they don't support.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
>  arch/x86/kernel/cpu/mtrr/main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/x86/kernel/cpu/mtrr/main.c b/arch/x86/kernel/cpu/mtrr/main.c
> index 1159e26..0044e61 100644
> --- a/arch/x86/kernel/cpu/mtrr/main.c
> +++ b/arch/x86/kernel/cpu/mtrr/main.c
> @@ -1567,6 +1567,8 @@ int __init mtrr_trim_uncached_memory(unsigned long end_pfn)
>  	 * Make sure we only trim uncachable memory on machines that
>  	 * support the Intel MTRR architecture:
>  	 */
> +	if (!cpu_has_mtrr)
> +		return 0;

that is not needed, we already check that in mtrr_bp_init before this function is called, and it will assign mtrr_if

and
#define is_cpu(vnd)     (mtrr_if && mtrr_if->vendor == X86_VENDOR_##vnd)

will make it sure mtrr is there.

ps: here INTEL mean any cpu has same interface like intel cpu's

YH

>  	if (!is_cpu(INTEL) || disable_mtrr_trim)
>  		return 0;
>  	rdmsr(MTRRdefType_MSR, def, dummy);

