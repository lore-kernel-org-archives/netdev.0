From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Performance degradration 2.6.25->2.6.26
Date: Fri, 8 Aug 2008 09:23:10 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.1.10.0808080906590.5428@jbrandeb-MOBL1.amr.corp.intel.com>
References: <489C0F2C.9040101@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Elad Lahav <elad_lahav@users.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <489C0F2C.9040101@users.sourceforge.net>
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

On Fri, 8 Aug 2008, Elad Lahav wrote:

> I'm not sure this is the correct forum for this problem, but I'll give
> it a shot anyway.

I think besides netdev@vger.kernel.org, you found the right place.  I've 
CCd them too in case anyone there has an idea.  We can consider contacting 
lkml later if we find that the problem isn't networking related.

> I'm using a very simple UDP benchmark that attempts to send packets as
> quickly as possible. The platform is a dual Xeon 3.06GHz with

you could also try using the pktgen kernel module that does just what 
you've said, but doesn't use the stack at all.  What packet size?

> HyperThreading, for a total of 4 logical processors, and 4 Intel Gigabit
>   NICs on a PCI 64/66 bus (82546EB). In the experiments, I am pinning
> four sending processes (one per NIC) to logical processors 0 and 2, and
> the NIC interrupts to logical processors 1 and 3, such that interrupts
> are serviced by the sibling logical processor of the one sending the
> packets. I have used both the driver that comes with the Linux kernel
> (7.3.20-k2-NAPI), as well as a more recent one (7.6.15.5).

thanks for trying the standalone driver too, but lets just talk about the 
in-kernel one for right now.  BTW the PCIe controllers are significantly 
faster.

> On a vanilla 2.6.25.10 kernel, I can saturate all NICs (4 Gbps), and
> have some idle CPU cycles to spare. Moving to 2.6.26, with the same
> configuration file, I get at most 3.4 Gbps, and the sending processors
> are saturated. All bandwidth numbers were verified on the server and
> client sides with ethtool statistics.

myself and others will want to see your .config, and dmesg can you reply 
with those attached?  I'm suspecting the scheduler myself.

> Below are the mpstat averages for a 30 second experiment. There are a
> few anomalies:
> 1. The number of IRQs/sec goes down with the default settings. I used
> InterruptThrottleRate to bring it back to the 2.6.25.10 values, but with
> no effect on performance.

I'm guessing you're starting to poll (NAPI) more for some reason.

> 2. System time for the sending processors goes up in 2.6.26, as well as
> soft IRQ time for the interrupt-handling processors.

are you sure some memory manager debug didn't get turned on?  A diff of 
your previous config against the new config (or attach them both) might 
be interesting.

> 3. In both cases, soft IRQ time is attributed to the sending processors,
> even though the interrupts are pinned, and soft IRQs should execute on
> the same processors as the hard IRQs.

This sounds a little bit like lock contention possibly on the skb_free 
call in tx e1000_clean_tx_irq.

> 4. OProfile results (top 3 entries for each experiment attached below)
> suggest a huge increase in the time taken by e1000_clean_tx_irq. These
> should be taken with a grain of salt, as I have lost some confidence in
> OProfile, especially in a multi-processor, HyperThreaded environment.

have you tried both kernels without hyperthreading?  It usually doesn't 
help with I/O workloads.

> Any help would be greatly appreciated.
> Elad

If you're willing and have the time you can try isolating when the problem 
got introduced by first testing some of the 2.6.26-rcX kernels, then when 
you have one of those where the problem goes away, try using git-bisect to 
find your way down to the commit that introduced the problem.

e1000 shortlog between those two kernels shows no real changes that could 
effect performance besides the irq_sem fix.

git-shortlog v2.6.25..v2.6.26 drivers/net/e1000
warning: refname 'v2.6.25' is ambiguous.
Andy Gospodarek (1):
      e1000: only enable TSO6 via ethtool when using correct hardware

Jesse Brandeburg (1):
      e1000: remove irq_sem

Joe Perches (2):
      e1000: Convert boolean_t to bool
      e1000: convert uint16_t style integers to u16



> == 2.6.25.10 ==
> 
> mpstat:
> 
> CPU  %user   %sys   %irq  %soft  %idle   intr/s
> all   0.83  31.74   1.13  23.01  43.20 16017.44
>    0   1.57  63.85   0.00  15.77  18.81     1.73
>    1   0.07   0.10   4.50  27.54  67.52  8007.90
>    2   1.73  62.95   0.00  14.96  20.36     0.00
>    3   0.00   0.03   0.00  33.74  66.12  8007.90
>    4   0.00   0.00   0.00   0.00   0.00     0.00
> 
> oprofile:
> 
> 66325  26.4879  e1000.ko  e1000  e1000_xmit_frame
> 46852  18.7111  e1000.ko  e1000  e1000_clean_tx_irq
> 43968  17.5593  e1000.ko  e1000  e1000_intr
> 
> == 2.6.26 ==
> 
> mpstat:
> 
> CPU  %user   %sys   %irq  %soft  %idle   intr/s
> all   1.94  36.61   0.81  32.40  28.23 11586.84
>    0   3.50  73.18   0.00  23.33   0.00     1.73
>    1   0.63   0.20   3.27  37.03  58.87  5547.32
>    2   3.43  72.97   0.00  23.60   0.00     1.27
>    3   0.23   0.10   0.00  45.63  54.03  6036.52
>    4   0.00   0.00   0.00   0.00   0.00     0.00

you can check /proc/net/softnet_stat output to see how much you're NAPI 
polling during these tests.  It looks like the interrupt rate is coming 
down because you're polling in 26, but not in 25.

> oprofile:
> 
> 235946 52.8313  e1000.ko  e1000  e1000_clean_tx_irq
> 42654   9.5508  e1000.ko  e1000  e1000_xmit_frame
> 40120   8.9834  e1000.ko  e1000  e1000_set_mac_type

If you have the oprofile data, can you send me more details about the 
hotspots with opannotate --assembly -p /path/to/e1000_source e1000

Jesse

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
