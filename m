From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 5 Feb 2016 10:24:16 +0100
Message-ID: <20160205092416.GB31671@gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
 <20160204093021.GB1553@gmail.com>
 <20160204105609.GA7870@gmail.com>
 <CALx6S3572jDaQ7am1EZGoFYRD_nOQcfOuj1pHf6pseKSZVqJrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, Kernel Team <kernel-team@fb.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALx6S3572jDaQ7am1EZGoFYRD_nOQcfOuj1pHf6pseKSZVqJrg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Tom Herbert <tom@herbertland.com> wrote:

> Thanks for the explanation and sample code. Expanding on your example, I added a 
> switch statement to perform to function (code below).

So I think your new switch() based testcase is broken in a subtle way.

The problem is that in your added testcase GCC effectively optimizes out the 
function call, because it is able to recognize that all the (trivial) functions 
are identical. (At least here, with GCC 5.2.1)

So all overhead of the workload goes into just that do_switch() function you 
added:

#
# Total Lost Samples: 0
#
# Samples: 5K of event 'cycles:pp'
# Event count (approx.): 5738959683
#
# Overhead  Command      Shared Object      Symbol                     
# ........  ...........  .................  ...........................
#
    99.94%  jump-table2  jump-table2        [.] do_switch              
     0.02%  jump-table2  [kernel.kallsyms]  [k] native_read_msr_safe   
     0.02%  jump-table2  [kernel.kallsyms]  [k] native_apic_mem_write  
     0.01%  jump-table2  [kernel.kallsyms]  [k] __fput                 
     0.00%  jump-table2  [kernel.kallsyms]  [k] change_protection_range
     0.00%  perf         [kernel.kallsyms]  [k] strrchr                
     0.00%  perf         [kernel.kallsyms]  [k] intel_pmu_handle_irq   
     0.00%  perf         [kernel.kallsyms]  [k] native_write_msr_safe  


... and per instruction overhead in the do_switch() looks like this:

         :
         :      Disassembly of section .text:
         :
         :      0000000000401100 <do_switch>:
         :      do_switch():
    0.00 :        401100:       mov    0x201f61(%rip),%r8        # 603068 <loops>
    0.00 :        401107:       test   %r8,%r8
    0.00 :        40110a:       je     401178 <do_switch+0x78>
    0.00 :        40110c:       mov    0x201f5d(%rip),%rdi        # 603070 <table_size>
    0.00 :        401113:       xor    %esi,%esi
    0.00 :        401115:       xor    %ecx,%ecx
    0.00 :        401117:       nopw   0x0(%rax,%rax,1)
    0.00 :        401120:       mov    0x201f61(%rip),%rax        # 603088 <global>
    1.46 :        401127:       xor    %edx,%edx
    0.00 :        401129:       add    $0x1,%rax
    0.00 :        40112d:       mov    %rax,0x201f54(%rip)        # 603088 <global>
    0.00 :        401134:       mov    0x201f4d(%rip),%rax        # 603088 <global>
   51.68 :        40113b:       div    %rdi
    0.00 :        40113e:       cmp    $0x3f,%rdx
    1.34 :        401142:       ja     40116b <do_switch+0x6b>
    0.02 :        401144:       mov    0x201f3d(%rip),%r9        # 603088 <global>
    0.10 :        40114b:       mov    0x201f36(%rip),%rax        # 603088 <global>
    6.91 :        401152:       jmpq   *0x401420(,%rdx,8)
    0.00 :        401159:       nopl   0x0(%rax)
    0.02 :        401160:       xor    %edx,%edx
   35.71 :        401162:       div    %r9
    1.07 :        401165:       add    %rdx,%r9
    1.69 :        401168:       add    %r9,%rsi
    0.00 :        40116b:       add    $0x1,%rcx
    0.00 :        40116f:       cmp    %r8,%rcx
    0.00 :        401172:       jne    401120 <do_switch+0x20>
    0.00 :        401174:       mov    %rsi,%rax
    0.00 :        401177:       retq   
    0.00 :        401178:       xor    %esi,%esi
    0.00 :        40117a:       jmp    401174 <do_switch+0x74>

Note that as you remarked there _is_ an indirect jump in there:

    6.91 :        401152:       jmpq   *0x401420(,%rdx,8)

But:

> gcc seems to be implementing this switch as a jump table:
> 
>    jmpq   *0x400ac8(,%rdx,8)

... the 'jump table' has identical entries:

  40141f:       00 60 11                add    %ah,0x11(%rax)
  401422:       40 00 00                add    %al,(%rax)
  401425:       00 00                   add    %al,(%rax)
  401427:       00 60 11                add    %ah,0x11(%rax)
  40142a:       40 00 00                add    %al,(%rax)
  40142d:       00 00                   add    %al,(%rax)
  40142f:       00 60 11                add    %ah,0x11(%rax)
  401432:       40 00 00                add    %al,(%rax)
  401435:       00 00                   add    %al,(%rax)
  401437:       00 60 11                add    %ah,0x11(%rax)
  40143a:       40 00 00                add    %al,(%rax)

(misaligned dump - jump table starts at 0x401420)

Every jump table entry points to 0x401160 - which is the code after the indirect 
jump in do_switch().

So the hardware predictor simply recognizes that it's the same target address all 
the time, and thus (understandably) performs much faster - none of the functions 
are actually executed.

That is why there are no function call entries in perf report, while in the 
function pointer case we get:

#
# Total Lost Samples: 0
#
# Samples: 4K of event 'cycles:pp'
# Event count (approx.): 5482523153
#
# Overhead  Command      Shared Object      Symbol                    
# ........  ...........  .................  ..........................
#
    13.47%  jump-table2  jump-table2        [.] fun_1                 
    13.22%  jump-table2  jump-table2        [.] fun_6                 
    13.12%  jump-table2  jump-table2        [.] fun_5                 
    12.87%  jump-table2  jump-table2        [.] fun_7                 
    12.23%  jump-table2  jump-table2        [.] fun_2                 
    12.09%  jump-table2  jump-table2        [.] fun_0                 
     8.23%  jump-table2  jump-table2        [.] do_funcptr            
     7.43%  jump-table2  jump-table2        [.] fun_3                 
     7.27%  jump-table2  jump-table2        [.] fun_4                 
     0.02%  jump-table2  [kernel.kallsyms]  [k] page_add_new_anon_rmap
     0.02%  jump-table2  [kernel.kallsyms]  [k] native_read_msr_safe  
     0.02%  jump-table2  [kernel.kallsyms]  [k] perf_pmu_sched_task   
     0.00%  jump-table2  [kernel.kallsyms]  [k] flush_tlb_mm_range    
     0.00%  perf         [kernel.kallsyms]  [k] _raw_spin_lock        
     0.00%  perf         [kernel.kallsyms]  [k] intel_bts_enable_local
     0.00%  perf         [kernel.kallsyms]  [k] native_write_msr_safe 

Same-target indirect jumps were optimized well starting from PentiumM IIRC, so 
this would perform well all across the x86 spectrum.

Btw., I think it's a bit weird that GCC didn't eliminate the switch jump table 
itself. (Maybe newer versions of GCC do?)

> Which is a different call than the function table implementation:
> 
>    callq  *(%rsp,%rdx,8)

> So the switch implementation does not seem to be causing branch-misses to be 
> counted and is a lot faster. This is also what I see when looking at the 
> branch-misses with the checksum code-- I haven't yet found any test case 
> thrashing lengths or alignments increase branch-misses and shows a performance 
> degradation over the case where they are static.

That's because AFAICS there's no indirect branching in your testcase! :-)

And before you spend too much time on this, I do concede your general point: that 
jump tables are simpler than call tables, and that newer x86 uarchs are able to 
distinguish between multiple target branches pretty well indexed by a wide range 
of input registers, resulting in pretty good branch prediction.

Anyway - I think Linus's C based approach is vastly superior, so the jump tables 
vs. call tables topic is somewhat of a side track.

Thanks,

	Ingo
