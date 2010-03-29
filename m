From: Michal Simek <michal.simek@petalogix.com>
Subject: Network performance - iperf
Date: Mon, 29 Mar 2010 13:33:53 +0200
Message-ID: <4BB09021.6020202@petalogix.com>
Reply-To: michal.simek@petalogix.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	John Linn <John.Linn@xilinx.com>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I am doing several network benchmarks on Microblaze cpu with MMU.
I am seeing one issue which is weird and I would like know where the 
problem is.
I am using the same hw design and the same Linux kernel. I have done 
only change in memory size (in DTS).

32MB: 18.3Mb/s
64MB: 15.2Mb/s
128MB: 10.6Mb/s
256MB: 3.8Mb/s

There is huge difference between systems with 32MB and 256MB ram.

I am running iperf TCP tests with these commands.
On x86: iperf -c 192.168.0.105 -i 5 -t 50
On microblaze: iperf -s

I look at pte misses which are the same on all configurations which 
means that the number of do_page_fault exceptions is the same on all 
configurations.
I added some hooks to low level kernel code to be able to see number of 
tlb misses. There is big differences between number of misses on system 
with 256MB and 32MB. I measured two kernel settings. First column is 
kernel with asm optimized memcpy/memmove function and the second is 
without optimization. (Kernel with asm optimized lib functions is 30% 
faster than system without optimization)

32MB: 12703	13641
64MB: 1021750	655644
128MB: 1031644	531879
256MB: 1011322	430027

Most of them are data tlb misses. Microblaze MMU doesn't use any LRU 
mechanism to find TLB victim that's why we there is naive TLB 
replacement strategy based on incrementing counter. We using 2 tlbs for 
kernel itself which are not updated that's why we can use "only" 62 TLBs 
from 64.

I am using two LL_TEMAC driver which use dma and I observe the same 
results on both that's why I think that the problem is in kernel itself.

It could be connection with memory management or with cache behavior.

Have you ever met with this system behavior?
Do you know about tests which I can do?



I also done several tests to identify weak kernel places via Qemu
and this is the most called functions.

Unknown label means functions outside kernel. Numbers are in %

TCP
31.47 - memcpy
15.00 - do_csum
11.93 - unknown
5.62 - __copy_tofrom_user
2.94 - memset
2.49 - default idle
1.66 - __invalidate_dcache_range
1.57 - __kmalloc
1.32 - skb_copy_bits
1.23 - __alloc_skb

UDP
51.86 - unknown
9.31 - default_idle
6.01 - __copy_tofrom_user
4.00 - do_csum
2.05 - schedule
1.92 - __muldi3
1.39 - update_curr
1.20 - __invalidate_dcache_range
1.12 - __enqueue_entity

I optimized copy_tofrom_user function to support word-copying. (Just 
cover aligned cases because the most copying is aligned.) Also uaccess 
unification was done.

Do you have any idea howto improve TCP/UDP performance in general?
Or tests which can point me on weak places.

I am using microblaze-next branch. The same code is in linux-next tree.

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-30090663
