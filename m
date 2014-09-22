From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 84991] New: Adding a gre tunnel causes a kernel panic
Date: Mon, 22 Sep 2014 09:02:42 -0700
Message-ID: <20140922090242.5ef15c83@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:42047 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943AbaIVQCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 12:02:50 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so4791821pad.41
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 09:02:49 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id nx15sm9724635pdb.88.2014.09.22.09.02.48
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 09:02:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not good, and user did bisection.

using git bisect, the below commit introduced the above bug.

[7d442fab0a6777fd7612cfcada32ea859553d370] ipv4: Cache dst in tunnels


commit 7d442fab0a6777fd7612cfcada32ea859553d370
Author: Tom Herbert <therbert@google.com>
Date:   Thu Jan 2 11:48:26 2014 -0800

    ipv4: Cache dst in tunnels

    Avoid doing a route lookup on every packet being tunneled.

    In ip_tunnel.c cache the route returned from ip_route_output if
    the tunnel is "connected" so that all the rouitng parameters are
    taken from tunnel parms for a packet. Specifically, not NBMA tunnel
    and tos is from tunnel parms (not inner packet).

    Signed-off-by: Tom Herbert <therbert@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


Begin forwarded message:

Date: Sun, 21 Sep 2014 16:56:08 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 84991] New: Adding a gre tunnel causes a kernel panic


https://bugzilla.kernel.org/show_bug.cgi?id=84991

            Bug ID: 84991
           Summary: Adding a gre tunnel causes a kernel panic
           Product: Networking
           Version: 2.5
    Kernel Version: 3.17.0-rc5 #82 SMP PREEMPT
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: joe9mail@gmail.com
        Regression: No

command:

sudo ip tunnel add mastergrevpn mode gre local 192.168.1.232 remote
192.168.0.11 ttl 255

192.168.0.11 is connected over an ipsec connection.

extract from kern.log

Sep 22 05:04:45 br kernel: [   23.550046] r8169 0000:03:00.0 enp3s0: link up
Sep 22 05:04:46 br kernel: [   24.811978] NET: Registered protocol family 10
Sep 22 05:05:55 br kernel: [   94.471313] NET: Registered protocol family 15
Sep 22 05:05:55 br kernel: [   94.502502] Initializing XFRM netlink socket
Sep 22 05:05:55 br kernel: [   94.550294] gre: GRE over IPv4 demultiplexor
driver
Sep 22 05:05:55 br kernel: [   94.550682] ip_gre: GRE over IPv4 tunneling
driver
Sep 22 05:05:55 br kernel: [   94.608310] BUG: using smp_processor_id() in
preemptible [00000000] code: ip/2261
Sep 22 05:05:55 br kernel: [   94.608316] caller is
tunnel_dst_set.isra.28+0x20/0x60 [ip_tunnel]
Sep 22 05:05:55 br kernel: [   94.608319] CPU: 3 PID: 2261 Comm: ip Not tainted
3.17.0-rc5 #82
Sep 22 05:05:55 br kernel: [   94.608321] Hardware name: System manufacturer
System Product Name/F2A85-M, BIOS 5202 01/22/2013
Sep 22 05:05:55 br kernel: [   94.608323]  0000000000000000 ffffffff816b4926
ffffffff8155f634 0000000000000003
Sep 22 05:05:55 br kernel: [   94.608326]  ffffffff8128e1e1 ffffffff817a3b80
ffffffff816ac8e9 00000000000199b8
Sep 22 05:05:55 br kernel: [   94.608329]  ffff88013922e6c0 00000000e801a8c0
ffffffffa05a1f40 ffff880093237000
Sep 22 05:05:55 br kernel: [   94.608331] Call Trace:
Sep 22 05:05:55 br kernel: [   94.608339]  [<ffffffff8155f634>] ?
dump_stack+0x4a/0x75
Sep 22 05:05:55 br kernel: [   94.608343]  [<ffffffff8128e1e1>] ?
check_preemption_disabled+0xf1/0x100
Sep 22 05:05:55 br kernel: [   94.608346]  [<ffffffffa05a1f40>] ?
tunnel_dst_set.isra.28+0x20/0x60 [ip_tunnel]
Sep 22 05:05:55 br kernel: [   94.608349]  [<ffffffffa05a209e>] ?
ip_tunnel_bind_dev+0x11e/0x190 [ip_tunnel]
Sep 22 05:05:55 br kernel: [   94.608352]  [<ffffffffa05a332b>] ?
ip_tunnel_ioctl+0x25b/0x360 [ip_tunnel]
Sep 22 05:05:55 br kernel: [   94.608357]  [<ffffffffa05ac5fb>] ?
ipgre_tunnel_ioctl+0x16b/0x270 [ip_gre]
Sep 22 05:05:55 br kernel: [   94.608361]  [<ffffffff814dd562>] ?
dev_ifsioc+0x352/0x390
Sep 22 05:05:55 br kernel: [   94.608363]  [<ffffffff814dd726>] ?
dev_ioctl+0xc6/0x530
Sep 22 05:05:55 br kernel: [   94.608366]  [<ffffffff814af7a2>] ?
sock_ioctl+0xd2/0x260
Sep 22 05:05:55 br kernel: [   94.608370]  [<ffffffff811174ae>] ?
do_vfs_ioctl+0x7e/0x510
Sep 22 05:05:55 br kernel: [   94.608373]  [<ffffffff8110839f>] ?
alloc_file+0x1f/0xc0
Sep 22 05:05:55 br kernel: [   94.608376]  [<ffffffff81061339>] ?
get_parent_ip+0x9/0x20
Sep 22 05:05:55 br kernel: [   94.608378]  [<ffffffff81061397>] ?
preempt_count_add+0x47/0x90
Sep 22 05:05:55 br kernel: [   94.608382]  [<ffffffff815645ae>] ?
_raw_spin_lock+0xe/0x30
Sep 22 05:05:55 br kernel: [   94.608385]  [<ffffffff811220ad>] ?
__fd_install+0x2d/0x70
Sep 22 05:05:55 br kernel: [   94.608387]  [<ffffffff81117987>] ?
SyS_ioctl+0x47/0xa0
Sep 22 05:05:55 br kernel: [   94.608390]  [<ffffffff81566462>] ?
page_fault+0x22/0x30
Sep 22 05:05:55 br kernel: [   94.608392]  [<ffffffff81564e56>] ?
system_call_fastpath+0x1a/0x1f


uname -a
Linux br 3.17.0-rc5 #82 SMP PREEMPT Mon Sep 22 05:01:36 IST 2014 x86_64 AMD
A10-5800K APU with Radeon(tm) HD Graphics AuthenticAMD GNU/Linux

cat /proc/cpuinfo
processor    : 0
vendor_id    : AuthenticAMD
cpu family    : 21
model        : 16
model name    : AMD A10-5800K APU with Radeon(tm) HD Graphics
stepping    : 1
microcode    : 0x6001116
cpu MHz        : 3800.000
cache size    : 2048 KB
physical id    : 0
siblings    : 4
core id        : 0
cpu cores    : 2
apicid        : 16
initial apicid    : 0
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb
rdtscp lm constant_tsc rep_good nopl nonstop_tsc extd_apicid aperfmperf pni
pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 popcnt aes xsave avx f16c
lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch
osvw ibs xop skinit wdt lwp fma4 tce nodeid_msr tbm topoext perfctr_core
perfctr_nb arat cpb hw_pstate npt lbrv svm_lock nrip_save tsc_scale vmcb_clean
flushbyasid decodeassists pausefilter pfthreshold bmi1
bugs        : fxsave_leak
bogomips    : 7641.38
TLB size    : 1536 4K pages
clflush size    : 64
cache_alignment    : 64
address sizes    : 48 bits physical, 48 bits virtual
power management: ts ttp tm 100mhzsteps hwpstate cpb eff_freq_ro

processor    : 1
vendor_id    : AuthenticAMD
cpu family    : 21
model        : 16
model name    : AMD A10-5800K APU with Radeon(tm) HD Graphics
stepping    : 1
microcode    : 0x6001116
cpu MHz        : 3800.000
cache size    : 2048 KB
physical id    : 0
siblings    : 4
core id        : 1
cpu cores    : 2
apicid        : 17
initial apicid    : 1
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb
rdtscp lm constant_tsc rep_good nopl nonstop_tsc extd_apicid aperfmperf pni
pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 popcnt aes xsave avx f16c
lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch
osvw ibs xop skinit wdt lwp fma4 tce nodeid_msr tbm topoext perfctr_core
perfctr_nb arat cpb hw_pstate npt lbrv svm_lock nrip_save tsc_scale vmcb_clean
flushbyasid decodeassists pausefilter pfthreshold bmi1
bugs        : fxsave_leak
bogomips    : 7641.38
TLB size    : 1536 4K pages
clflush size    : 64
cache_alignment    : 64
address sizes    : 48 bits physical, 48 bits virtual
power management: ts ttp tm 100mhzsteps hwpstate cpb eff_freq_ro

processor    : 2
vendor_id    : AuthenticAMD
cpu family    : 21
model        : 16
model name    : AMD A10-5800K APU with Radeon(tm) HD Graphics
stepping    : 1
microcode    : 0x6001116
cpu MHz        : 3800.000
cache size    : 2048 KB
physical id    : 0
siblings    : 4
core id        : 2
cpu cores    : 2
apicid        : 18
initial apicid    : 2
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb
rdtscp lm constant_tsc rep_good nopl nonstop_tsc extd_apicid aperfmperf pni
pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 popcnt aes xsave avx f16c
lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch
osvw ibs xop skinit wdt lwp fma4 tce nodeid_msr tbm topoext perfctr_core
perfctr_nb arat cpb hw_pstate npt lbrv svm_lock nrip_save tsc_scale vmcb_clean
flushbyasid decodeassists pausefilter pfthreshold bmi1
bugs        : fxsave_leak
bogomips    : 7641.38
TLB size    : 1536 4K pages
clflush size    : 64
cache_alignment    : 64
address sizes    : 48 bits physical, 48 bits virtual
power management: ts ttp tm 100mhzsteps hwpstate cpb eff_freq_ro

processor    : 3
vendor_id    : AuthenticAMD
cpu family    : 21
model        : 16
model name    : AMD A10-5800K APU with Radeon(tm) HD Graphics
stepping    : 1
microcode    : 0x6001116
cpu MHz        : 3800.000
cache size    : 2048 KB
physical id    : 0
siblings    : 4
core id        : 3
cpu cores    : 2
apicid        : 19
initial apicid    : 3
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb
rdtscp lm constant_tsc rep_good nopl nonstop_tsc extd_apicid aperfmperf pni
pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 popcnt aes xsave avx f16c
lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch
osvw ibs xop skinit wdt lwp fma4 tce nodeid_msr tbm topoext perfctr_core
perfctr_nb arat cpb hw_pstate npt lbrv svm_lock nrip_save tsc_scale vmcb_clean
flushbyasid decodeassists pausefilter pfthreshold bmi1
bugs        : fxsave_leak
bogomips    : 7641.38
TLB size    : 1536 4K pages
clflush size    : 64
cache_alignment    : 64
address sizes    : 48 bits physical, 48 bits virtual
power management: ts ttp tm 100mhzsteps hwpstate cpb eff_freq_ro

Please let me know if you need more details.

Thanks
Joe

--
You are receiving this mail because:
You are the assignee for the bug.
