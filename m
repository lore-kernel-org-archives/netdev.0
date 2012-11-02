From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH 0/9 v2] use efficient this_cpu_* helper
Date: Sat, 03 Nov 2012 00:03:14 +0800
Message-ID: <5093EEC2.7000109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: cl@linux-foundation.org, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this_cpu_ptr is faster than per_cpu_ptr(p, smp_processor_id())=20
and can reduce  memory accesses.
The latter helper needs to find the offset for current cpu,
and needs more assembler instructions which objdump shows in following.=
=20

per_cpu_ptr(p, smp_processor_id())=EF=BC=9A
  1e:   65 8b 04 25 00 00 00 00         mov    %gs:0x0,%eax
  26:   48 98                           cltq
  28:   31 f6                           xor    %esi,%esi
  2a:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi
  31:   48 8b 04 c5 00 00 00 00         mov    0x0(,%rax,8),%rax
  39:   c7 44 10 04 14 00 00 00         movl   $0x14,0x4(%rax,%rdx,1)

this_cpu_ptr(p)
  1e:   65 48 03 14 25 00 00 00 00      add    %gs:0x0,%rdx
  27:   31 f6                           xor    %esi,%esi
  29:   c7 42 04 14 00 00 00            movl   $0x14,0x4(%rdx)
  30:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi

Changelog V2:
1. Use this_cpu_read directly instead of ref to field of per-cpu variab=
le.
2. Patch5 about ftrace is dropped from this series.
3. Add new patch9 to replace get_cpu;per_cpu_ptr;put_cpu with this_cpu_=
add opt.
4. For preemption disable case, use __this_cpu_read instead.
 =20
$ git diff --stat b77bc2069d1e437d5a1a71bb5cfcf4556ee40015=20
 drivers/clocksource/arm_generic.c |    2 +-
 kernel/padata.c                   |    5 ++---
 kernel/rcutree.c                  |    2 +-
 kernel/trace/blktrace.c           |    2 +-
 kernel/trace/trace.c              |    4 +---
 net/batman-adv/main.h             |    4 +---
 net/core/flow.c                   |    4 +---
 net/openvswitch/datapath.c        |    4 ++--
 net/openvswitch/vport.c           |    5 ++---
 net/rds/ib_recv.c                 |    2 +-
 net/xfrm/xfrm_ipcomp.c            |    7 +++----
 11 files changed, 16 insertions(+), 25 deletions(-)
