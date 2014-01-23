From: Rick Jones <rick.jones2@hp.com>
Subject: getifaddrs performance, sudo and Linux vs FreeBSD
Date: Thu, 23 Jan 2014 12:37:52 -0800
Message-ID: <52E17DA0.9080501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:36285 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932432AbaAWUqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 15:46:46 -0500
Received: from g5t0007.atlanta.hp.com (g5t0007.atlanta.hp.com [15.192.0.44])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 0101166151
	for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 20:38:04 +0000 (UTC)
Received: from g5t0030.atlanta.hp.com (g5t0030.atlanta.hp.com [16.228.8.142])
	by g5t0007.atlanta.hp.com (Postfix) with ESMTP id B8CD714009
	for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 20:37:53 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some performance work I've been doing lately has led me down a path to 
the performance of sudo on a system with a Very Large Number (tm) of 
interfaces (four digits).  I noticed that the time it took for an "sudo 
sleep 1" (chosen as a nice, consequences-free something to pass to sudo) 
to complete could have hundreds of milliseconds added to it on a system 
with that large number of interfaces.  How much could vary - on the 
system on which I was looking initially, there were interfaces coming 
and going at the same time.  An strace showed an AF_NETLINK sendto() 
followed by 1600 recvfrom's on that fd seemed to be the the source of 
all the added time.

I went then to an inactive system and did some synthetic things and 
found that the added time for sudo was coming from its getifaddrs() 
call, which it makes at start-up to gather information which might be 
used later by one or more sudo plugins.

I brought this to the attention of the sudo-workers mailing list to see 
if there might be a way to make the getifaddrs() call "lazy" - 
http://www.sudo.ws/pipermail/sudo-workers/2014-January/000826.html and 
was told that other platforms don't take so much time in getifaddrs().

As I was using a 3.5 kernel on the bare-iron, and don't have flexibility 
to put a later kernel there, nor to run another OS there, for the rest 
of this I've spun-up two equal configuration VMs, one with a 3.11 kernel 
(via Ubuntu 13.10) and the other with FreeBSD 9.2.  Indeed, performance 
work in VMs is problematic, but this is just to give a demonstration.

On the FreeBSD VM I created 8000 additional interfaces via "ifconfig 
greN create" and on the 3.11 VM I did that via "ip tuntap add mode tun" 
.  I then brought sudo 1.8.9p4 source bits onto each and compiled them, 
with a couple of printf's bracketing the getifaddrs() call to make 
finding it in a system call trace later easier.

Under FreeBSD the times for sudo sleep 1 are:

# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs
         1.02 real         0.00 user         0.00 sys
# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs
         1.02 real         0.00 user         0.01 sys
# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs
         1.02 real         0.00 user         0.01 sys


Under 3.11 the times for sudo sleep 1 are:
root@ubuntu1310:~/sudo-1.8.9p4# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs

real	0m1.133s
user	0m0.049s
sys	0m0.083s
root@ubuntu1310:~/sudo-1.8.9p4# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs

real	0m1.108s
user	0m0.035s
sys	0m0.070s
root@ubuntu1310:~/sudo-1.8.9p4# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs

real	0m1.133s
user	0m0.033s
sys	0m0.099s

(not as dramatic as on the "doing real work" systems where I'd see the 
added time, with fewer added interfaces, be as much as 800 milliseconds, 
but it does give the flavor)

A truss -dD taken on FreeBSD shows:
0.015641137 0.000277260 write(1,"Calling getifaddrs\n",19) = 19 (0x13)
0.020622446 0.004852609 
__sysctl(0x7fffffffd3d0,0x6,0x0,0x7fffffffd3e8,0x0,0x0) = 0 (0x0)
0.025353806 0.004647170 
__sysctl(0x7fffffffd3d0,0x6,0x8010b7000,0x7fffffffd3e8,0x0,0x0) = 0 (0x0)
0.025864666 0.000200780 
mmap(0x0,8388608,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANON,-1,0x0) = 
34380709888 (0x801400000)
0.026154166 0.000052810 munmap(0x801800000,4194304) = 0 (0x0)
0.028974145 0.000661820 
madvise(0x8010b7000,0x1b6000,0x5,0xb6,0x7fffffffca60,0x1) = 0 (0x0)
0.029470295 0.000196330 write(1,"Called getifaddrs\n",18) = 18 (0x12)

and strace -tttT under Linux 3.11 shows:
1390506086.363045 write(1, "Calling getifaddrs\n", 19) = 19 <0.000024>
1390506086.363088 socket(PF_NETLINK, SOCK_RAW, 0) = 3 <0.001267>
1390506086.364360 bind(3, {sa_family=AF_NETLINK, pid=0, 
groups=00000000}, 12) = 0 <0.000032>
1390506086.364392 getsockname(3, {sa_family=AF_NETLINK, pid=8957, 
groups=00000000}, [12]) = 0 <0.000020>
1390506086.364419 sendto(3, "\24\0\0\0\22\0\1\3fp\341R\0\0\0\0\0\0\0\0", 
20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20 <0.000000>
1390506086.364419 recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, 
groups=00000000}, 
msg_iov(1)=[{"(\4\0\0\20\0\2\0fp\341R\375\"\0\0\0\0\376\377\0\37\0\0\220\20\0\0\0\0\0\0"..., 
4096}], msg_controllen=0, msg_flags=0}, 0) = 3192 <0.000000>
1390506086.364419 recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, 
groups=00000000}, 
msg_iov(1)=[{"(\4\0\0\20\0\2\0fp\341R\375\"\0\0\0\0\376\377\0\34\0\0\220\20\0\0\0\0\0\0"..., 
4096}], msg_controllen=0, msg_flags=0}, 0) = 3192 <0.000000>
...
1390506086.557375 recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, 
groups=00000000}, 
msg_iov(1)=[{"@\0\0\0\24\0\2\0gp\341R\375\"\0\0\n\200\200\376\1\0\0\0\24\0\1\0\0\0\0\0"..., 
4096}], msg_controllen=0, msg_flags=0}, 0) = 128 <0.000011>
1390506086.557421 recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0, 
groups=00000000}, 
msg_iov(1)=[{"\24\0\0\0\3\0\2\0gp\341R\375\"\0\0\0\0\0\0", 4096}], 
msg_controllen=0, msg_flags=0}, 0) = 20 <0.000007>
1390506086.558258 mmap(NULL, 2211840, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f7246eb4000 <0.000013>
1390506086.630268 close(3)              = 0 <0.000046>
1390506086.630344 write(1, "Called getifaddrs\n", 18) = 18 <0.000033>

There were something like 2700 recvmsg calls there.

Admittedly, one probably aught to minimize the use of sudo wherever she 
can, but there ma be limits to that and sudo is not the only thing that 
might call getifaddrs().  Similarly, the number of times one puts four 
or even perhaps three digits worth of interfaces on a system is somewhat 
rare, but I suspect it isn't unheard of.  So, I thought I might post 
this to solicit input/ideas.

happy benchmarking,

rick jones

FWIW, here is a perf report for a single sudo sleep 1 from the vm, only 
those routines > 1% shown:
# Samples: 392  of event 'cpu-clock'
# Event count (approx.): 98000000
#
# Overhead      Shared Object                            Symbol
# ........  .................  ................................
#
     32.40%  libc-2.17.so       [.] 0x00000000000811c8
     17.60%  [kernel.kallsyms]  [k] snmp_fold_field
      6.63%  [kernel.kallsyms]  [k] inet6_fill_ifla6_attrs
      5.87%  [kernel.kallsyms]  [k] rtnl_fill_ifinfo
      4.85%  [kernel.kallsyms]  [k] memcpy
      4.08%  [kernel.kallsyms]  [k] find_next_bit
      2.30%  [kernel.kallsyms]  [k] netdev_master_upper_dev_get
      2.30%  [kernel.kallsyms]  [k] inet6_dump_addr
      2.04%  [kernel.kallsyms]  [k] inet_fill_link_af
      1.79%  [kernel.kallsyms]  [k] clear_page_c
      1.53%  [kernel.kallsyms]  [k] memset
      1.53%  [kernel.kallsyms]  [k] inet_dump_ifaddr
      1.28%  [kernel.kallsyms]  [k] _raw_read_lock_bh
      1.02%  [kernel.kallsyms]  [k] handle_mm_fault
      1.02%  [kernel.kallsyms]  [k] __nla_reserve
      1.02%  [kernel.kallsyms]  [k] __nla_put
      1.02%  [kernel.kallsyms]  [k] rtnl_dump_ifinfo
      1.02%  [kernel.kallsyms]  [k] __do_page_fault



For the curious, here are the times for when there aren't those 8000 
added interfaces.  FreeBSD:

# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs
         1.01 real         0.00 user         0.00 sys
# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs
         1.00 real         0.00 user         0.00 sys
# time src/sudo sleep 1
Calling getifaddrs
Called getifaddrs
         1.00 real         0.00 user         0.00 sys

and the Linux 3.11:


Oh, and if you've read this far, I've also noticed that perhaps not 
surprisingly, sysctl -a can take an exceedingly long time on a system 
with lots of added interfaces.
