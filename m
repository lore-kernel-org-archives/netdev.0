From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: GPF in do_raw_spin_lock on Linux 4.1
Date: Wed, 30 Sep 2015 21:02:15 -0700
Message-ID: <CAM_iQpW1NbaKbCgUwPOKQ2zfewRjM-LHWZPwMcPOEo2unfZU8Q@mail.gmail.com>
References: <CAHTgTXVdvTJHg3Sj5bGcfsB8FUwwqnP6mCGGMcF0cQ0U7fVrEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Fan Du <fan.du@intel.com>, Tom Herbert <tom@herbertland.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Vinson Lee <vlee@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHTgTXVdvTJHg3Sj5bGcfsB8FUwwqnP6mCGGMcF0cQ0U7fVrEw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing Jamal)

On Wed, Sep 30, 2015 at 5:49 PM, Vinson Lee <vlee@twopensource.com> wrote:
> Hi.
>
> We've hit this GPF on several different machines on Linux 4.1.
>
> general protection fault: 0000 [#1] SMP
> Modules linked in: sch_htb cls_basic act_mirred cls_u32 veth
> sch_ingress netconsole configfs cpufreq_ondemand ipv6 dm_multipath
> scsi_dh video sbs sbshc hed acpi_pad acpi_ipmi sch_fq_codel parport_pc
> lp parport tcp_diag inet_diag ipmi_devintf sg iTCO_wdt
> iTCO_vendor_support igb serio_raw hpwdt hpilo i2c_algo_bit i2c_core
> ptp pps_core wmi ipmi_si ipmi_msghandler lpc_ich mfd_core sb_edac
> ioatdma dca edac_core shpchp microcode acpi_cpufreq ahci libahci
> libata sd_mod scsi_mod
> CPU: 8 PID: 45989 Comm: kworker/u128:0 Not tainted 4.1.1 #1
> Workqueue: netns cleanup_net
> task: ffff8809973d1890 ti: ffff880c96cc4000 task.ti: ffff880c96cc4000
> RIP: 0010:[<ffffffff8109c107>]  [<ffffffff8109c107>] do_raw_spin_lock+0x9/0x21
> RSP: 0018:ffff880c96cc7bc8  EFLAGS: 00010286
> RAX: 0000000000000100 RBX: dead000000100060 RCX: 0000000000000007
> RDX: 0000000000000012 RSI: 00000000fffffe01 RDI: dead0000001000d0
> RBP: ffff880c96cc7bc8 R08: 0000000000000000 R09: ffffffffa043f6b0
> R10: ffffffff8145dac7 R11: ffff8809843423f8 R12: ffff880528fa2800
> R13: dead0000001000d0 R14: ffffffff81ac9460 R15: ffff88080f219148
> FS:  0000000000000000(0000) GS:ffff88103f840000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffffffffff600000 CR3: 0000000fab9e7000 CR4: 00000000001407e0
> Stack:
>  ffff880c96cc7bd8 ffffffff8150290a ffff880c96cc7c08 ffffffffa043f041
>  0000000000000007 00000000ffffffee 0000000000000006 ffff880c96cc7ca0
>  ffff880c96cc7c48 ffffffff810815d6 ffff880c96cc7b38 0000000000000000
> Call Trace:
>  [<ffffffff8150290a>] _raw_spin_lock_bh+0x19/0x1b
>  [<ffffffffa043f041>] mirred_device_event+0x41/0x82 [act_mirred]
>  [<ffffffff810815d6>] notifier_call_chain+0x3e/0x61


Looks like the mirred action is already freed at that time, but I don't
see how, when we release the mirred action, we remove it from the
mirred_list, and the operations on mirred_list are always protected
by RTNL lock.

I suspect these are non-bind mirred actions, which exist independently
of network devices, so that when we remove the network namespace,
they still hang there. They seem only released when we remove the
whole module...

I will double check this tomorrow.
