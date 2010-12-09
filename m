From: Paul Moore <paul.moore@hp.com>
Subject: Re: 2.6.37-rc5: NULL pointer oops in
 selinux_socket_unix_stream_connect
Date: Thu, 09 Dec 2010 14:42:26 -0500
Message-ID: <1291923746.5339.20.camel@sifl>
References: <4CFFF3F3.90100@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CFFF3F3.90100@goop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-12-08 at 13:09 -0800, Jeremy Fitzhardinge wrote:
> I just got this oops in a freshly booted 2.6.37-rc5 Xen domain, while
> sitting idle at the login prompt:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000210
> IP: [<ffffffff811d55d4>] selinux_socket_unix_stream_connect+0x29/0xa0
> PGD 1c99d067 PUD 1cb03067 PMD 0 
> Oops: 0000 [#1] SMP 
> last sysfs file: /sys/devices/system/cpu/sched_mc_power_savings
> CPU 0 
> Modules linked in: sunrpc dm_mirror dm_region_hash dm_log [last unloaded: scsi_wait_scan]
> 
> Pid: 2297, comm: at-spi-registry Not tainted 2.6.37-rc5+ #293 /
> RIP: e030:[<ffffffff811d55d4>]  [<ffffffff811d55d4>] selinux_socket_unix_stream_connect+0x29/0xa0
> RSP: e02b:ffff880006e7dd68  EFLAGS: 00010292
> RAX: ffff88001d1ed8c0 RBX: ffff88001d06d9a0 RCX: 0000000000000022
> RDX: ffff88001d1ed580 RSI: 0000000000000000 RDI: ffff88001b7d6ac0
> RBP: ffff880006e7de18 R08: 00000000ffff0201 R09: ffff88001e78c968
> R10: 000000001f47e9c2 R11: ffff88001fbf4400 R12: ffff88001d1ed8c0
> R13: ffff88001d1ed580 R14: ffff88001ca00cc0 R15: 0000000000000000
> FS:  00007fa643031920(0000) GS:ffff88001ff85000(0000) knlGS:0000000000000000
> CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000210 CR3: 000000001d78a000 CR4: 0000000000002660
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process at-spi-registry (pid: 2297, threadinfo ffff880006e7c000, task ffff88001cdd1140)
> Stack:
>  ffff88001d4c0bc0 000000004cffecc5 ffff880006e7ddc8 ffffffff81028dc5
>  ffff8800ffffffff 0001628b2ec3fe22 ffff880006e7dde8 ffff88001d1edb80
>  0000000000000001 0000936a4da34099 0000000000000000 00000000000000fa
> Call Trace:
>  [<ffffffff81028dc5>] ? pvclock_clocksource_read+0x48/0xb1
>  [<ffffffff810074ab>] ? xen_clocksource_read+0x20/0x22
>  [<ffffffff81008fd9>] ? xen_spin_lock+0xc6/0xd9
>  [<ffffffff811d1d1e>] security_unix_stream_connect+0x16/0x18
>  [<ffffffff81484366>] unix_stream_connect+0x215/0x3ff
>  [<ffffffff813f351d>] sys_connect+0x7a/0xa0
>  [<ffffffff8108cd9d>] ? audit_syscall_entry+0x1c2/0x1ee
>  [<ffffffff8100bb42>] system_call_fastpath+0x16/0x1b
> Code: c9 c3 55 48 89 e5 41 55 41 54 53 48 81 ec 98 00 00 00 0f 1f 44 00 00 b9 22 00 00 00 48 8b 47 20 48 8b 76 20 48 8b 98 10 02 00 00 <4c> 8b a6 10 02 00 00 31 c0 4c 8b aa 10 02 00 00 4c 8d 85 50 ff 
> RIP  [<ffffffff811d55d4>] selinux_socket_unix_stream_connect+0x29/0xa0
>  RSP <ffff880006e7dd68>
> CR2: 0000000000000210
> ---[ end trace 50030b578c1ee27e ]---
> 
> This corresponds to:
> 
> (gdb) list *0xffffffff811d55d4
> 0xffffffff811d55d4 is in selinux_socket_unix_stream_connect (/home/jeremy/git/upstream/security/selinux/hooks.c:3929).
> 3924	static int selinux_socket_unix_stream_connect(struct socket *sock,
> 3925						      struct socket *other,
> 3926						      struct sock *newsk)
> 3927	{
> 3928		struct sk_security_struct *sksec_sock = sock->sk->sk_security;
> 3929		struct sk_security_struct *sksec_other = other->sk->sk_security;
> 3930		struct sk_security_struct *sksec_new = newsk->sk_security;
> 3931		struct common_audit_data ad;
> 3932		int err;
> 3933	
> 
> 
> The system is a somewhat out of date Fedora 13 with
> selinux-policy-3.7.19-73.fc13.noarch and
> selinux-policy-targeted-3.7.19-73.fc13.noarch installed.
> 
> I'm not sure what at-spi-registry is or what it is trying to do here.
> The crash seems non-deterministic; I rebooted the domain without any issues.
> 
> Thanks,
>     J

Thanks for the report.

Unfortunately I don't have any great ideas off the top of my head but it
has been a couple of months since I've played with that code; I'll take
a look and see if anything jumps out at me.

For what it's worth, a quick Google makes me think that at-spi-registry
is part of Gnome's assistive technology functionality.  That said, I
have no idea what it does exactly, but evidently it does it over a UNIX
domain socket ...

If you're ever able to recreate the problem or if you can think of
anything else that might be useful please let me know.

Thanks.

-- 
paul moore
linux @ hp
