From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH 0/9 v3] use efficient this_cpu_* helper
Date: Fri, 09 Nov 2012 10:20:06 +0800
Message-ID: <509C6856.6000302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: cl@linux-foundation.org, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48793 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264Ab2KICUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 21:20:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this_cpu_ptr/this_cpu_read is faster than per_cpu_ptr(p, smp_processor_=
id())=20
and can reduce  memory accesses.
The latter helper needs to find the offset for current cpu,
and needs more assembler instructions which objdump shows in following.=
=20

this_cpu_ptr relocates and address. this_cpu_read() relocates the addre=
ss
and performs the fetch. If you want to operate on rda(defined as per_cp=
u)=20
then you can only use this_cpu_ptr. this_cpu_read() saves you more inst=
ructions
since it can do the relocation and the fetch in one instruction.

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


Changelog V3:
1. use this_cpu_read directly read member of per-cpu variable,
   so that droping the this_cpu_ptr operation.
2. for preemption off and bottom halves off case,
   use __this_cpu_read instead of this_cpu_read.=20

Changelog V2:
1. Use this_cpu_read directly instead of ref to field of per-cpu variab=
le.
2. Patch5 about ftrace is dropped from this series.
3. Add new patch9 to replace get_cpu;per_cpu_ptr;put_cpu with this_cpu_=
add opt.
4. For preemption disable case, use __this_cpu_read instead.
 =20

$ git diff --stat 7da716aee2532399e213a14f656d304098f67a11..
 drivers/clocksource/arm_generic.c |    2 +-
 kernel/padata.c                   |    5 ++---
 kernel/rcutree.c                  |    2 +-
 kernel/trace/blktrace.c           |    2 +-
 kernel/trace/trace.c              |    5 +----
 net/batman-adv/main.h             |    4 +---
 net/core/flow.c                   |    4 +---
 net/openvswitch/datapath.c        |    4 ++--
 net/openvswitch/vport.c           |    5 ++---
 net/rds/ib_recv.c                 |    2 +-
 net/xfrm/xfrm_ipcomp.c            |    7 ++-----
 11 files changed, 15 insertions(+), 27 deletions(-)
