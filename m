From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: silent hang using tc/qos on -rt kernel
Date: Wed, 16 Dec 2009 07:54:14 +0000
Message-ID: <20091216075414.GA6800@ff.dom.local>
References: <1260921424-sup-3333@bubs>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Vernon Mauery <vernux@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:54382 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891AbZLPHyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 02:54:22 -0500
Received: by fg-out-1718.google.com with SMTP id 22so128214fge.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 23:54:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1260921424-sup-3333@bubs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-2009 00:58, Vernon Mauery wrote:
> I am seeing a silent hang on -rt kernels that is getting provoked
> when using tc (traffic control) to enforce bandwidth limiting on
> a network interface.  I set up the rate-limiting using HTB (or CBQ)
> and then send traffic out on the interface and the machine hangs.
> 
> When the machine hangs, it is nearly completely unresponsive, with
> sysrq sometimes working, but I can crash it with an NMI.  Sometimes
> the machine will also spit out messages from the SCSI or SAN or
> NIC drivers that are getting timeouts because of the hang.
> 
> Here is how I have been able to cause the hang:
...

It's most probably a hrtimers race, very similar to the one which was
temporarily fixed here (only for HTB):

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.27.y.git;a=commitdiff;h=9befaf375925471a49159d775b38d42c04e218a1

hrtimers were fixed by Peter Zijlstra's patches in 2.6.28 around this
one IIRC:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ca109491f612aab5c8152207631c0444f63da97f

Jarek P.

> I can reproduce it on 2.6.24-rt and on 2.6.31-rt, but not on 2.6.32 vanilla.
> 
> Often when it hangs, the machine will only to a single sysrq call, but
> after that, it will stop responding to anything but an NMI.
> 
> Once, I did see the machine give an oops when running this scenario, but
> it is much much more common to see a silent hang.  Here is the oops message:
> 
> Unable to handle kernel NULL pointer dereference at 0000000000000010 RIP:
>  [<ffffffff8113b38c>] rb_erase+0x1f3/0x2b1
> PGD 14e150067 PUD 142d34067 PMD 0
> Oops: 0000 [1] PREEMPT SMP
> CPU 2
> Modules linked in: sch_htb pktgen nfs nfsd lockd nfs_acl auth_rpcgss exportfs
> ipmi_devintf ipmi_si ipmi_msghandler ibm_rtl ipv6 autofs4 i2c_dev i2c_core hidp
> rfcomm l2cap bluetooth sunrpc dm_mirror dm_multipath scsi_dh dm_mod video
> output sbs sbshc battery ac parport_pc lp parport sg bnx2 button netxen_nic
> serio_raw amd64_edac edac_core pcspkr shpchp mptsas mptscsih mptbase
> scsi_transport_sas sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd
> Pid: 38, comm: sirq-hrtimer/2 Not tainted 2.6.24-rt #1
> RIP: 0010:[<ffffffff8113b38c>]  [<ffffffff8113b38c>] rb_erase+0x1f3/0x2b1
> RSP: 0018:ffff81014f16fe50  EFLAGS: 00010082
> RAX: 0000000000000000 RBX: ffff81014640bac8 RCX: ffff810001085780
> RDX: 0000000000000000 RSI: ffff8100010076a8 RDI: 0000000000000000
> RBP: ffff81014f16fe60 R08: ffff81033f15dac8 R09: 0000000000000000
> R10: 0000000000000002 R11: 0000000000000000 R12: ffff8100010076a8
> R13: 0000000000000000 R14: 0000000000000002 R15: 0000000000000080
> FS:  00007ff9960016e0(0000) GS:ffff81014fc09cc0(0000) knlGS:0000000000000000
> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: 0000000000000010 CR3: 000000014e188000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process sirq-hrtimer/2 (pid: 38, threadinfo ffff81014f16e000, task
> ffff81014f16c300)
> Stack:  ffff81013a5e67d0 ffff810001007698 ffff81014f16fe90 ffffffff81054dfc
>  ffffffff81227401 ffff81013a5e67d0 ffff810001085640 0000000000000002
>  ffff81014f16fec0 ffffffff81055cbb 0000000000000002 ffffffff815005e8
> Call Trace:
>  [<ffffffff81054dfc>] __remove_hrtimer+0x6e/0x7b
>  [<ffffffff81227401>] ? qdisc_watchdog+0x0/0x23
>  [<ffffffff81055cbb>] run_hrtimer_softirq+0x7a/0x14e
>  [<ffffffff81043d26>] ksoftirqd+0x16a/0x26f
>  [<ffffffff81043bbc>] ? ksoftirqd+0x0/0x26f
>  [<ffffffff81043bbc>] ? ksoftirqd+0x0/0x26f
>  [<ffffffff8105261c>] kthread+0x49/0x79
>  [<ffffffff8100d088>] child_rip+0xa/0x12
>  [<ffffffff810525d3>] ? kthread+0x0/0x79
>  [<ffffffff8100d07e>] ? child_rip+0x0/0x12
> 
> 
> Code: e8 d2 fb ff ff e9 8b 00 00 00 48 8b 07 a8 01 75 1a 48 83 c8 01 4c 89 e6
> 48 89 07 48 83 23 fe 48 89 df e8 10 fc ff ff 48 8b 7b 10 <48> 8b 57 10 48 85 d2
> 74 05 f6 02 01 74 2c 48 8b 47 08 48 85 c0
> RIP  [<ffffffff8113b38c>] rb_erase+0x1f3/0x2b1
>  RSP <ffff81014f16fe50>
> 
> 
> Any help in debugging this would be greatly appreciated.
> 
> --Vernon
