From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/9 v4] use efficient this_cpu_* helper
Date: Thu, 15 Nov 2012 14:19:38 +0000
Message-ID: <0000013b047079ab-01971b64-07e2-4f2e-a204-6baff2180fc3-000000@email.amazonses.com>
References: <50A1A7A9.6050501@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="288502408-889817205-1352989090=:10714"
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, Shan Wei <shanwei88@gmail.com>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Tejun Heo <htejun@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A1A7A9.6050501@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--288502408-889817205-1352989090=:10714
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

Tejon: Could you pick up this patchset?

On Tue, 13 Nov 2012, Shan Wei wrote:

> this_cpu_ptr/this_cpu_read is faster than per_cpu_ptr(p, smp_processor_id())
> and can reduce  memory accesses.
> The latter helper needs to find the offset for current cpu,
> and needs more assembler instructions which objdump shows in following.
>
> this_cpu_ptr relocates and address. this_cpu_read() relocates the address
> and performs the fetch. If you want to operate on rda(defined as per_cpu)
> then you can only use this_cpu_ptr. this_cpu_read() saves you more instructions
> since it can do the relocation and the fetch in one instruction.
>
> per_cpu_ptr(p, smp_processor_id())：
>   1e:   65 8b 04 25 00 00 00 00         mov    %gs:0x0,%eax
>   26:   48 98                           cltq
>   28:   31 f6                           xor    %esi,%esi
>   2a:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi
>   31:   48 8b 04 c5 00 00 00 00         mov    0x0(,%rax,8),%rax
>   39:   c7 44 10 04 14 00 00 00         movl   $0x14,0x4(%rax,%rdx,1)
>
> this_cpu_ptr(p)
>   1e:   65 48 03 14 25 00 00 00 00      add    %gs:0x0,%rdx
>   27:   31 f6                           xor    %esi,%esi
>   29:   c7 42 04 14 00 00 00            movl   $0x14,0x4(%rdx)
>   30:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi
>
>
>
> Changelog V4:
> 1. [read|write]ing fields of struct rds_ib_cache_head using __this_cpu_* operation for rds subsystem.
>    see patch2
> 2. fix bug in xfrm to read pointer. see patch3.
> 3. avoid type cast in patch7.
>
> Changelog V3:
> 1. use this_cpu_read directly read member of per-cpu variable,
>    so that droping the this_cpu_ptr operation.
> 2. for preemption off and bottom halves off case,
>    use __this_cpu_read instead of this_cpu_read.
>
> Changelog V2:
> 1. Use this_cpu_read directly instead of ref to field of per-cpu variable.
> 2. Patch5 about ftrace is dropped from this series.
> 3. Add new patch9 to replace get_cpu;per_cpu_ptr;put_cpu with this_cpu_add opt.
> 4. For preemption disable case, use __this_cpu_read instead.
>
>
> $ git diff --stat d4185bbf62a5d8d777ee445db1581beb17882a07
>  drivers/clocksource/arm_generic.c |    2 +-
>  kernel/padata.c                   |    5 ++---
>  kernel/rcutree.c                  |    2 +-
>  kernel/trace/blktrace.c           |    2 +-
>  kernel/trace/trace.c              |    5 +----
>  net/batman-adv/main.h             |    4 +---
>  net/core/flow.c                   |    4 +---
>  net/openvswitch/datapath.c        |    4 ++--
>  net/openvswitch/vport.c           |    5 ++---
>  net/rds/ib.h                      |    2 +-
>  net/rds/ib_recv.c                 |   24 +++++++++++++-----------
>  net/xfrm/xfrm_ipcomp.c            |    8 +++-----
>  12 files changed, 29 insertions(+), 38 deletions(-)
>
--288502408-889817205-1352989090=:10714--
