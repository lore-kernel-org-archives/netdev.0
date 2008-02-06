From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [e1000][net-2.6 tree] Regression: driver doesn't
 detect card on my node.
Date: Wed, 06 Feb 2008 12:30:16 +0300
Message-ID: <47A97E28.1010400@openvz.org>
References: <47A89A77.1050608@openvz.org>
	<200802060020.25492.yinghai.lu@sun.com>
	<47A972AB.5060107@openvz.org>
	<200802060119.25278.yinghai.lu@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Thomas Gleixner <tglx@linutronix.de>, jeffrey.t.kirsher@intel.com,
	Denis Lunev <den@openvz.org>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	Justin Piszcz <jpiszcz@lucidpixels.com>
To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200802060119.25278.yinghai.lu@sun.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
> On Wednesday 06 February 2008 12:41:15 am Pavel Emelyanov wrote:
>> Yinghai Lu wrote:
>>> On Tuesday 05 February 2008 11:10:24 pm Pavel Emelyanov wrote:
>>>> [snip]
>>>>
>>>>>>> What other info from me is required?
>>>>> boot log please. with the patch and reverting the patch.
>>>> Here they are (attached).
>>>> BTW, I found, that the sky2 adapter is broken by this patch as well.
>>>> To simplify the analysis, here's their diff:
>>>>
>>>> --- bad-log	2008-02-06 10:06:40.000000000 +0300
>>>> +++ good-log	2008-02-06 10:06:40.000000000 +0300
>>>> @@ -1,4 +1,4 @@
>>>> -Linux version 2.6.24 (pavel@xemulnb) (gcc version 4.1.3 20070724 (prerelease) (SUSE Linux)) #22 SMP Tue Feb 5 20:09:11 MSK 2008
>>>> +Linux version 2.6.24 (pavel@xemulnb) (gcc version 4.1.3 20070724 (prerelease) (SUSE Linux)) #23 SMP Wed Feb 6 10:03:53 MSK 2008
>>>>  BIOS-provided physical RAM map:
>>>>   BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
>>>>   BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
>>>> @@ -19,29 +19,6 @@ Scan SMP from c0000000 for 1024 bytes.
>>>>  Scan SMP from c009fc00 for 1024 bytes.
>>>>  Scan SMP from c00f0000 for 65536 bytes.
>>>>  found SMP MP-table at [c00ff780] 000ff780
>>>> -***************
>>>> -**** WARNING: likely BIOS bug
>>>> -**** MTRRs don't cover all of memory, trimmed 786432 pages
>>>> -***************
>>>> -update e820 for mtrr
>>>> -modified physical RAM map:
>>>> - modified: 0000000000000000 - 000000000009f800 (usable)
>>>> - modified: 000000000009f800 - 00000000000a0000 (reserved)
>>>> - modified: 00000000000e0000 - 0000000000100000 (reserved)
>>>> - modified: 0000000000100000 - 0000000040000000 (usable)
>>>> - modified: 0000000040000000 - 00000000bfff0000 (reserved)
>>>> - modified: 00000000bfff0000 - 00000000bffff000 (ACPI data)
>>>> - modified: 00000000bffff000 - 00000000c0000000 (ACPI NVS)
>>>> - modified: 00000000c0000000 - 0000000100000000 (reserved)
>>>> - modified: 0000000100000000 - 0000000140000000 (usable)
>>> the root cause could be your mtrr last entry for RAM has strange type
>>>
>>> please apply the following line to print the mtrr before trimming to current linus tree.
>> OK, here's the dmesg diff:
>> --- bad-log     2008-02-06 10:01:21.000000000 +0300
>> +++ bad-log-info        2008-02-06 11:37:51.000000000 +0300
>> @@ -19,6 +19,14 @@ Scan SMP from c0000000 for 1024 bytes.
>>  Scan SMP from c009fc00 for 1024 bytes.
>>  Scan SMP from c00f0000 for 65536 bytes.
>>  found SMP MP-table at [c00ff780] 000ff780
>> +i=0 c0000 - 100000 0
>> +i=1 0 - 100000 6
>> +i=2 100000 - 140000 6
>> +i=3 0 - 0 0
>> +i=4 0 - 0 0
>> +i=5 0 - 0 0
>> +i=6 0 - 0 0
>> +i=7 0 - 0 0
>>  ***************
>>  **** WARNING: likely BIOS bug
>>  **** MTRRs don't cover all of memory, trimmed 786432 pages
> 
> please try following patch

Today's Linus tree works perfect with this patch, thanks :)
BTW, this also fixed the broken sky2 adapter.

> diff --git a/arch/x86/kernel/cpu/mtrr/main.c b/arch/x86/kernel/cpu/mtrr/main.c
> index 1e27b69..4e7490f 100644
> --- a/arch/x86/kernel/cpu/mtrr/main.c
> +++ b/arch/x86/kernel/cpu/mtrr/main.c
> @@ -659,7 +659,7 @@ static __init int amd_special_default_mtrr(void)
>   */
>  int __init mtrr_trim_uncached_memory(unsigned long end_pfn)
>  {
> -	unsigned long i, base, size, highest_addr = 0, def, dummy;
> +	unsigned long i, base, size, highest_pfn = 0, def, dummy;
>  	mtrr_type type;
>  	u64 trim_start, trim_size;
>  
> @@ -682,28 +682,27 @@ int __init mtrr_trim_uncached_memory(unsigned long end_pfn)
>  		mtrr_if->get(i, &base, &size, &type);
>  		if (type != MTRR_TYPE_WRBACK)
>  			continue;
> -		base <<= PAGE_SHIFT;
> -		size <<= PAGE_SHIFT;
> -		if (highest_addr < base + size)
> -			highest_addr = base + size;
> +		if (highest_pfn < base + size)
> +			highest_pfn = base + size;
>  	}
>  
>  	/* kvm/qemu doesn't have mtrr set right, don't trim them all */
> -	if (!highest_addr) {
> +	if (!highest_pfn) {
>  		printk(KERN_WARNING "WARNING: strange, CPU MTRRs all blank?\n");
>  		WARN_ON(1);
>  		return 0;
>  	}
>  
> -	if ((highest_addr >> PAGE_SHIFT) < end_pfn) {
> +	if (highest_pfn < end_pfn) {
>  		printk(KERN_WARNING "WARNING: BIOS bug: CPU MTRRs don't cover"
>  			" all of memory, losing %LdMB of RAM.\n",
> -			(((u64)end_pfn << PAGE_SHIFT) - highest_addr) >> 20);
> +			(end_pfn - highest_pfn) >> (20 - PAGE_SHIFT));
>  
>  		WARN_ON(1);
>  
>  		printk(KERN_INFO "update e820 for mtrr\n");
> -		trim_start = highest_addr;
> +		trim_start = highest_pfn;
> +		trim_start <<= PAGE_SHIFT;
>  		trim_size = end_pfn;
>  		trim_size <<= PAGE_SHIFT;
>  		trim_size -= trim_start;
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
