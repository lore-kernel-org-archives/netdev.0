From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10556] New: IPVS sync_backup oops
Date: Sat, 26 Apr 2008 04:04:52 -0700
Message-ID: <20080426040452.4fcbc962.akpm@linux-foundation.org>
References: <bug-10556-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, l0op8ack@hotmail.com
To: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35428 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752131AbYDZLFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 07:05:13 -0400
In-Reply-To: <bug-10556-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Apr 2008 21:27:18 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10556
> 
>            Summary: IPVS sync_backup oops
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24.x
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: l0op8ack@hotmail.com
> 
> 
> Latest working kernel version: 2.6.23.17
> Earliest failing kernel version: 2.6.24

It's a regression.

> Distribution: kernel.org
> Hardware Environment: i386,P4
> Software Environment: ipvsadm-1.24
> Problem Description:
> MATSER ipvs box will push connection table to BACKUP one using multicast,
> while the BACKUP ipvs box received the multicast message, 
> the BACKUP ipvs box will report BUG() and crash
> 
> Steps to reproduce:
>                +-------------+
>                |192.168.1.123|
>                +------+------+
>                       |
> --------------+-------+------------+--------
>               |  VIP:192.168.1.219 |
>  MASTER +-----+-----+        +-----+-----+  BACKUP
>    eth1 |192.168.1.1|   eth1 |192.168.1.2|
>    eth0 |192.168.0.1|   eth0 |192.168.0.2|
>         +-----+-----+        +-----+-----+
>               |-> multicast sync ->|
> --------------+-------+------------+--------
>                       |
>    real-server +------------+ www service open
>                |192.168.0.80| gateway 192.168.0.1
>                +------+-----+
> 
> 1)
> MASTER ipvs box:
> ipvsadm --start-daemon master --mcast-interface eth0 --syncid 80
> 
> BACKUP ipvs box:
> ipvsadm --start-daemon backup --mcast-interface eth0 --syncid 80
> 
> 2)
> Both MASTER and BACKUP box:
> 2.1) define service
> ipvsadm -A -t 192.168.1.219:80 -s rr
> 2.2) add real-server
> ipvsadm -a -t 192.168.1.219:80 -r 192.168.0.80:80 -m
> # set real-server gateway = 192.168.0.1
> 
> 3)
> client(192.168.1.123) access http://192.168.1.219,
> MATSER ipvs box will push connection table to BACKUP one using multicast,
> while the BACKUP ipvs box received the multicast message, 
> the BACKUP ipvs box report BUG() and crash.
> 

Also,

BUG: unable to handle kernel NULL pointer dereference at virtual address
00000014
printing eip: c030659e *pde = 00000000 
Oops: 0000 [#1] SMP 
Modules linked in: xt_tcpudp iptable_mangle xt_MARK xt_multiport ip_tables
x_tables ip_vs_wrr ip_vs_wlc ip_vs_sh ip_vs_sed ip_vs_rr ip_vs_nq ip_vs_lc
ip_vs_lblcr ip_vs_lblc ip_vs_ftp ip_vs_dh pcnet32 crc32 e1000 e100 mii

Pid: 3960, comm: ipvs_syncbackup Not tainted (2.6.24.4 #3)
EIP: 0060:[<c030659e>] EFLAGS: 00010246 CPU: 0
EIP is at sync_thread+0x919/0xa3c
EAX: 00000000 EBX: f6fe6800 ECX: e3ba2c00 EDX: 00000000
ESI: 00000000 EDI: 00000000 EBP: f7310034 ESP: f699bf54
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process ipvs_syncbackup (pid: 3960, ti=f699a000 task=f6995030 task.ti=f699a000)
Stack: 01000000 00000000 23035e0a 00000000 00001183 00000000 f699bfc0 f6d04860 
       00000002 00000034 f7310000 f78f1800 00000001 f731001c c0000000 00000000 
       00000010 f699bfc0 00000001 00000000 00000000 00000000 00000000 f6995030 
Call Trace:
 [<c011c53a>] default_wake_function+0x0/0x8
 [<c0305c85>] sync_thread+0x0/0xa3c
 [<c0104aa7>] kernel_thread_helper+0x7/0x10
 =======================
Code: a1 20 64 3e c0 89 43 54 8b 54 24 34 0f b7 42 16 66 c1 c0 08 0f b7 c0 66
89 43 42 0f b6 42 01 e8 90 06 00 00 0f b7 53 42 0f b7 d2 <8b> 40 14 8b 04 90 89
43 38 89 d8 e8 8a 8e ff ff 8b 44 24 28 03 
EIP: [<c030659e>] sync_thread+0x919/0xa3c SS:ESP 0068:f699bf54
Kernel panic - not syncing: Fatal exception in interrupt


Which will be a bit hard to track down because it seems that pretty much
the whole world got inlined into sync_thread().

