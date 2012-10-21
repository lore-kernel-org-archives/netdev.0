From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Sun, 21 Oct 2012 14:52:21 +0200
Message-ID: <1350823941.13333.2167.camel@edumazet-glaptop>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	 <20121013163639.87abca00.bircoph@gmail.com>
	 <1350135860.21172.14606.camel@edumazet-glaptop>
	 <20121014031119.a60263d6.bircoph@gmail.com>
	 <20121021032543.09d1844f.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:46519 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab2JUMw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 08:52:26 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so543469eaa.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 05:52:24 -0700 (PDT)
In-Reply-To: <20121021032543.09d1844f.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-21 at 03:25 +0400, Andrew Savchenko wrote:
> Hello,
> 
> On Sun, 14 Oct 2012 03:11:19 +0400 Andrew Savchenko wrote:
> > On Sat, 13 Oct 2012 15:44:20 +0200 Eric Dumazet wrote:
> > > On Sat, 2012-10-13 at 16:36 +0400, Andrew Savchenko wrote:
> > > > On Wed, 3 Oct 2012 23:25:48 +0400 Andrew Savchenko wrote:
> > > > > I encountered a very weird bug: after a while of uptime kernel stops to deliver
> > > > > DNS reply to applications. Tcpdump shows that correct reply is recieved, but 
> > > > > strace shows inquiring application never recieves it and ends with timeout,
> > > > > epoll_wait() always returns 0:
> > > > > a slice from: $ host kernel.org 8.8.8.8:
> > [...]
> > > > > In a few days I'll try 3.4.12 (I need to rebuild kernel anyway due to unrelated
> > > > > issue) and will report if this bug will occur again. But please note it may
> > > > > take several weeks to check this.
> > > > 
> > > > I got this problem again with 3.4.12 kernel. System lasted less than
> > > > a week and reboot was the only option...
> > > 
> > > You should investigate and check where the incoming packet is lost
> > > 
> > > Tools :
> > > 
> > > netstat -s
> > > 
> > > drop_monitor module and dropwatch command
> > > 
> > > cat /proc/net/udp
> > 
> > Thank you for you reply; I updated my kernel to 3.4.14, enabled
> > CONFIG_NET_DROP_MONITOR, and installed dropwatch utility.
> > 
> > I will report back when the bug will struck again.
> > This may take a weak or two, however.
> 
> This bug is back again on kernel 3.4.14, but this time I was able to
> get debug data and to recover running kernel without reboot.
> 
> Drowpatch showed that DNS UDP replies are always dropped here:
> 1 drops at __udp_queue_rcv_skb+61 (0xffffffff813bd670)
> 
> Another observations:
> - only UDP replies are lost, TCP works fine;
> - if network load is dropped dramatically (ip_forward disabled, most
> network daemons are stopped) UDP DNS queries work again; but with
> gradual load increase replies became first slow and than cease at all.
> - CPU load is very low (uptime is below 0.05), so this shouldn't be
> an insufficient computing power issue.
> 
> I found __udp_queue_rcv_skb function in net/ipv4/udp.c. From the code
> and observations above it follows that this is likely to be a ENOMEM
> condition leading to a packet loss.
> 
> This is a memory data after bug happened:
> # cat /proc/meminfo
> MemTotal:        1021576 kB
> MemFree:           32056 kB
> Buffers:          105204 kB
> Cached:           646716 kB
> SwapCached:          236 kB
> Active:           205932 kB
> Inactive:         587156 kB
> Active(anon):      20636 kB
> Inactive(anon):    22488 kB
> Active(file):     185296 kB
> Inactive(file):   564668 kB
> Unevictable:        2152 kB
> Mlocked:            2152 kB
> SwapTotal:        995992 kB
> SwapFree:         995020 kB
> Dirty:                 0 kB
> Writeback:             0 kB
> AnonPages:         43120 kB
> Mapped:             7504 kB
> Shmem:               148 kB
> Slab:             176004 kB
> SReclaimable:     118636 kB
> SUnreclaim:        57368 kB
> KernelStack:         688 kB
> PageTables:         2948 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     1506780 kB
> Committed_AS:      62708 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:      262732 kB
> VmallocChunk:   34359474615 kB
> AnonHugePages:         0 kB
> DirectMap4k:       33536 kB
> DirectMap2M:     1013760 kB
> 
> # sysctl -a | grep mem
> net.core.optmem_max = 20480
> net.core.rmem_default = 229376
> net.core.rmem_max = 131071
> net.core.wmem_default = 229376
> net.core.wmem_max = 131071
> net.ipv4.igmp_max_memberships = 20
> net.ipv4.tcp_mem = 22350        29801   44700
> net.ipv4.tcp_rmem = 4096        87380   6291456
> net.ipv4.tcp_wmem = 4096        16384   4194304
> net.ipv4.udp_mem = 24150        32202   48300
> net.ipv4.udp_rmem_min = 4096
> net.ipv4.udp_wmem_min = 4096
> vm.lowmem_reserve_ratio = 256   256     32
> vm.overcommit_memory = 0
> 
> Sysctl memory parameters are system defaults, I haven't changed them
> via sysctl or /proc interfaces.
> 
> I tried to increase udm_mem values to the following:
> net.ipv4.udp_mem = 100000       150000  200000
> 
> This solved my issue, at least for a while: DNS queries are working
> fine now.
> 
> But I suspect that there is some memory loss in the kernel UDP stack,
> because this issue never happens after reboot and always after about
> a week of network operation. So this memory increase should help only
> for a month or so, if memory loss is linear.
> 
> If you need some memory debug information, let me know which one and
> what tools will be needed.

If drop is in __udp_queue_rcv_skb(), its not because you dont have
enough memory. Frame was already received and handled by IP stack.

Thats because sock_queue_rcv_skb() said : there are already enough
frames in socket receive buffer, I dont want to add another frame.

You forgot to attach :

cat /proc/net/udp
netstat -s

By the way, I suspect you are hit by skb recycling.
(skb truesize is too big after few iterations)

We removed skb recycling in linux-3.7-rc1

If so, linux-3.7-rc1 or linux-3.7-rc2 should be fine.

What NIC are you using ?
