From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9124] New: Netconsole race crashed the system
Date: Thu, 4 Oct 2007 16:43:43 -0700
Message-ID: <20071004164343.ca01c06b.akpm@linux-foundation.org>
References: <bug-9124-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: tina.yang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52930 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758269AbXJDXoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 19:44:08 -0400
In-Reply-To: <bug-9124-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(Please resoind by emailed reply-to-all, not via the bugzilla web interface)

On Thu,  4 Oct 2007 16:24:18 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9124
> 
>            Summary: Netconsole race crashed the system
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.9, 2.6.18, 2.6.23
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: tina.yang@oracle.com
> 
> 
> Most recent kernel where this bug did not occur:
> Think the problem has always been there.
> Distribution:
> Hardware Environment:
> DELL PowerEdge 2650 (x86)
> DELL PowerEdge 2850(x86_64)
> HP ProLiant DL380 G5 (x86_64) 
> with various NICs - e1000, tg3, bnx2
> Software Environment:
> 2.6.9, 2.6.18, 2.6.23
> Problem Description:
> On 2.6.18 found this issue on e1000 and tg3. On mainline 2.6.23-rc* found this
>  issue on e100,tgs and bnx2.  It either panicked
> at netdevice.h:890 or hung the system, and sometimes depending
> on which NIC are used, the following console message,
>  e1000:
>       "e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang"
>  tg3:
>       "NETDEV WATCHDOG: eth4: transmit timed out"
>       "tg3: eth4: transmit timed out, resetting"
> 
> Steps to reproduce:
> 1. On 2.6.18 (both x86_x86_64) insert netconsole module.(NIC: e1000 and tg3)
> 2. Run a moderate io load , preferably fio - one process doing async+directIO
> using libaio 
> 
> fio jobfile:
> [global]
> iodepth=1024
> iodepth_batch=60
> randrepeat=1
> size=1024m
> directory=/home/oracle
> numjobs=2
> [job1]
> bs=8k
> direct=1
> ioengine=libaio
> rw=randrw
> filename=file1:file2
> 
> 3. From second console as root do " echo t > /proc/sysrq-trigger"
> 
> Machine will instantly hang.
> 
> 
> Crash stack captured on 2.6.9
>        PANIC: "kernel BUG at include/linux/netdevice.h:888!"
> #0 [ 23c5e60] disk_dump at f9ca71a2
> #1 [ 23c5e64] printk at 21228d6
> #2 [ 23c5e70] freeze_other_cpus at f9ca6ef5
> #3 [ 23c5e80] start_disk_dump at f9ca6fa0
> #4 [ 23c5e90] try_crashdump at 2133766
> #5 [ 23c5e98] die at 2106354
> #6 [ 23c5ecc] do_invalid_op at 210672f
> #7 [ 23c5f7c] error_code (via invalid_op) at fffecede
>    EAX: 00000006  EBX: 00200202  ECX: 00000000  EDX: df287000  EBP: e05ca000
>    DS:  007b      ESI: 00000001  ES:  007b      EDI: e05ca240 
>    CS:  0060      EIP: f8c82a08  ERR: ffffffff  EFLAGS: 00210046 
> #8 [ 23c5fb8] tg3_poll at f8c82a08
> #9 [ 23c5fd0] net_rx_action at 227a8da
> #10 [ 23c5fe8] __do_softirq at 2126422
> --- <soft IRQ> ---
> #0 [25c71cac] do_softirq at 2108460
> #1 [25c71cb4] dev_queue_xmit at 227a0d2
> #2 [25c71ccc] ip_finish_output at 229288d
> #3 [25c71ce4] ip_queue_xmit at 2292fa9
> #4 [25c71dac] tcp_transmit_skb at 22a0ff7
> #5 [25c71dec] tcp_write_xmit at 22a1901
> #6 [25c71e10] tcp_sendmsg at 2297d6d
> #7 [25c71e80] sock_aio_write at 2272512
> #8 [25c71eec] do_sync_write at 215a444
> #9 [25c71f88] vfs_write at 215a53a
> #10 [25c71fa4] sys_write at 215a5f4
> #11 [25c71fc0] system_call at fffec219 
> 
> net_device in memory,
>   name = "eth0\000\000\000\000\000\000\000\000\000\000\000", 
>  ...
> 
> 
> Crash stack captured on 2.6.18
>        PANIC: "kernel BUG at include/linux/netdevice.h:890!"
>  #0 [c072ce30] crash_kexec at c044418a
>  #1 [c072ce74] die at c04054d0
>  #2 [c072cea4] do_invalid_op at c0405c20
>  #3 [c072cf54] error_code (via invalid_op) at c0404ab3
>     EAX: 00000007  EBX: 00000202  ECX: 00000000  EDX: f6d9c000  EBP: f6d9c400 
>     DS:  007b      ESI: 00000001  ES:  007b      EDI: cb02b280 
>     CS:  0060      EIP: f8927791  ERR: ffffffff  EFLAGS: 00010046 
>  #4 [c072cf88] tg3_poll at f8927791
> --- <soft IRQ> ---
>  #0 [f7e54f60] do_softirq at c0406433
>  #1 [f7e54f6c] do_IRQ at c0406425
>  #2 [f7e54fb4] cpu_idle at c0402c8e
> 
> net_device in memory,
>   name = "eth4\000\000\000\000\000\000\000\000\000\000\000", 
>   name_hlist = {
>     next = 0x0, 
>     pprev = 0xc07d0148
>   }, 
>   ...
> 

OK, but in my 2.6.18, include/linux/netdevice.h:890 is a
local_irq_restore() in netif_rx_complete().  I don't see how that can go
BUG.

Does your 2.6.18 have any patches applied?

Please tell us what is at include/linux/netdevice.h:890 in your 2.6.18
tree.

