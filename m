From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: Keystone 2 boards boot failure
Date: Wed, 3 Feb 2016 09:08:03 -0800
Message-ID: <56B233F3.40000@oracle.com>
References: <56B0DE61.2000704@ti.com> <10700980.gTvMTB9pzv@wuerfel>
 <56B15591.7080409@ti.com> <1682165.IJ7dHXqc6L@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: m-karicheri2@ti.com, netdev@vger.kernel.org, w-kwok2@ti.com,
	davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>,
	"Franklin S Cooper Jr." <fcooper@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39380 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757943AbcBCRIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 12:08:12 -0500
In-Reply-To: <1682165.IJ7dHXqc6L@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/2016 8:35 AM, Arnd Bergmann wrote:
> On Tuesday 02 February 2016 19:19:13 Franklin S Cooper Jr. wrote:
>> On 02/02/2016 05:26 PM, Arnd Bergmann wrote:
>>> On Tuesday 02 February 2016 16:59:34 Franklin Cooper wrote:
>>>> On 02/02/2016 03:26 PM, Arnd Bergmann wrote:
>>>>> On Tuesday 02 February 2016 15:01:33 Franklin S Cooper Jr. wrote:
>>>> Keystone 2 devices are little-endian 32-bit devices.
>>> I meant the kernel you are running on it, not the hardware.
>>> You should always be able to run both a big-endian kernel and
>>> a littl-endian kernel on any ARMv7 machine, and a couple of
>>> platforms use 64-bit physical addresses even on 32-bit machines
>>> (with the normal 32-bit instruction set).
>>
>> I'm not sure if Keystone 2 devices support this or if we
>> have support for this. I'll have to double check.
>
I missed this thread so far but noticed after RMK's idmap
changes series.

> Don't worry about it, there is nothing you need to check:
>
> As I said, all ARMv7 *hardware* can be run in either mode, and
> that includes Keystone 2.
>
Right. Keystone isn't special from ARMv7 perspective.

> As for the kernel, it's obvious that nobody tried to run
> a Keystone based machine with a big-endian kernel, or they
> would have run into the broken network driver.
>
> I believe you also require this patch, unless the firmware is
> clever enough to figure out endianess by itself (very unlikely)
>
> diff --git a/arch/arm/mach-keystone/keystone.h b/arch/arm/mach-keystone/keystone.h
> index 33eaa037af5a..016ae7644e73 100644
> --- a/arch/arm/mach-keystone/keystone.h
> +++ b/arch/arm/mach-keystone/keystone.h
> @@ -16,7 +16,7 @@
>   #ifndef __ASSEMBLER__
>
>   extern const struct smp_operations keystone_smp_ops;
> -extern void secondary_startup(void);
> +extern void keystone_secondary_startup(void);
>   extern u32 keystone_cpu_smc(u32 command, u32 cpu, u32 addr);
>   extern int keystone_pm_runtime_init(void);
>
> diff --git a/arch/arm/mach-keystone/platsmp.c b/arch/arm/mach-keystone/platsmp.c
> index 5665276972ec..c427787f78d1 100644
> --- a/arch/arm/mach-keystone/platsmp.c
> +++ b/arch/arm/mach-keystone/platsmp.c
> @@ -26,7 +26,7 @@
>   static int keystone_smp_boot_secondary(unsigned int cpu,
>   						struct task_struct *idle)
>   {
> -	unsigned long start = virt_to_idmap(&secondary_startup);
> +	unsigned long start = virt_to_idmap(&keystone_secondary_startup);
>   	int error;
>
>   	pr_debug("keystone-smp: booting cpu %d, vector %08lx\n",
> diff --git a/arch/arm/mach-keystone/smc.S b/arch/arm/mach-keystone/smc.S
> index d15de8179fab..3ce858ce426e 100644
> --- a/arch/arm/mach-keystone/smc.S
> +++ b/arch/arm/mach-keystone/smc.S
> @@ -23,6 +23,13 @@
>    */
>   ENTRY(keystone_cpu_smc)
>   	stmfd   sp!, {r4-r11, lr}
> +ARM_BE8(setend	le)			@ call SMC as LE
>   	smc	#0
> +ARM_BE8(setend	be)			@ go back to BE8
>   	ldmfd   sp!, {r4-r11, pc}
>   ENDPROC(keystone_cpu_smc)
> +
> +ENTRY(keystone_secondary_startup)
> +ARM_BE8(setend	be)			@ go BE8 if entered LE
> +	b	secondary_startup
> +ENDPROC(keyston_secondary_startup)
>
> It would be nice to give this a go once the network driver problem
> is solved.
>
Big endian kernel has worked on Keystone in past.
Yes, above secondary hook needs to be modified along with
drivers endian macro conversion was what was needed IIRC.

Indeed, it will be good to get the BE working but for 4.5-rcx,
we need to fix the boot problem on priority.

Regards,
Santosh
