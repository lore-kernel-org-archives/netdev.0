From: John Stoffel <john@quad.stoffel.home>
Subject: Re: 4.4-rc3, KVM, br0 and instant hang
Date: Sat, 5 Dec 2015 11:23:28 -0500
Message-ID: <20151205162328.GA32532@quad.stoffel.home>
References: <22114.26609.457727.203801@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: John Stoffel <john@stoffel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <22114.26609.457727.203801@quad.stoffel.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2015 at 11:28:33PM -0500, John Stoffel wrote:
> 
> Hi all,
> 
> I've been trying to upgrade to something newer than 4.2.6 since I want
> to use LVM Cache on my home NFS fileserver, KVM server, test server,
> etc.  So when it goes down, I lose all my other systems which mount
> stuff from it.
> 
> Right now I'm trying to figure out how to use Netconsole to grab a
> dump of the oops, but it's not working well.  But let me describe the
> situation as I've found it so far.
> 
> When the system boots up, it first starts with eth0 on the network,
> then switches to br0 since I have a KVM bridge setup so my VMs can
> run on the same home network, 192.168.1.0/24 which is pretty
> standard.  The system is an AMD Phenom(tm) II X4 945 Processor,
> running at a max of 3Ghz, with 16gb of RAM, mpt2 LSI PCI-E 8 port sata
> controller, on an ASUS motherboard.  I can get details if you like.
> It's an older box, but still runs really well, so why change?
> 
> Anyway, if I try to boot up anything past the 4.2.6 kernel, the system
> locks up pretty quickly with an oops message that scrolls off the
> screen too far.  I've got some pictures which I'll attach in a bit,
> maybe they'll help.  So at first I thought it was something to do with
> bad kworker threads, or SCSI or SATA interactions, but as I tried to
> configure Netconsole to log to my beaglebone black SBC, I found out
> that if I compiled and installed 4.4-rc3, started the bridge up (br0),
> even started KVM, but did NOT start my VMs, the system was stable.
> 
> And if I didn't start br0, I could start a VM, but the system wouldn't
> crash.  The VM wasn't on the network... but the system didn't crash.
> So I think I've found a wierd interaction here.  My KVMs are both
> Debian images, with 1-2gb of RAM and 1 CPU each.  Nothing strange.  My
> network config is:
> 
>      > cat /etc/network/interfaces
>      # This file describes the network interfaces available on your system
>      # and how to activate them. For more information, see interfaces(5).
> 
>      # The loopback network interface
>      auto lo
>      iface lo inet loopback
> 
>      # Bridge for VMs
>      auto br0
> 
>      iface br0 inet static
>        address 192.168.1.6
> 	 netmask 255.255.255.0
> 	   network 192.168.1.0
> 	     gateway 192.168.1.254
> 	       bridge_ports eth0
> 		 bridge_stp on
> 		   bridge_maxwait 0
> 		     bridge_fd 0
> 
>      # Old setup
>      # auto eth0
> 
>      # iface eth0 inet static
>      #    address 192.168.1.6
>      #    netmask 255.255.255.0
>      #    gateway 192.168.1.254
> 
> The currently running system version is:
> 
>      > cat /proc/version
>      Linux version 4.4.0-rc3 (john@quad) (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Thu Dec 3 12:13:30 EST 2015
> 
> And more detailed CPU info
> 
>      > cat /proc/cpuinfo
>      .....
> 
>      processor       : 3
>      vendor_id       : AuthenticAMD
>      cpu family      : 16
>      model           : 4
>      model name      : AMD Phenom(tm) II X4 945 Processor
>      stepping        : 3
>      microcode       : 0x10000b6
>      cpu MHz         : 800.000
>      cache size      : 512 KB
>      physical id     : 0
>      siblings        : 4
>      core id         : 3
>      cpu cores       : 4
>      apicid          : 3
>      initial apicid  : 3
>      fpu             : yes
>      fpu_exception   : yes
>      cpuid level     : 5
>      wp              : yes
>      flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
>      mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
>      fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc rep_good nopl
>      nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm cmp_legacy svm
>      extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit
>      wdt hw_pstate npt lbrv svm_lock nrip_save vmmcall
>      bugs            : tlb_mmatch apic_c1e fxsave_leak sysret_ss_attrs
>      bogomips        : 6027.13
>      TLB size        : 1024 4K pages
>      clflush size    : 64
>      cache_alignment : 64
>      address sizes   : 48 bits physical, 48 bits virtual
>      power management: ts ttp tm stc 100mhzsteps hwpstate
> 
> 
> Here's my bootup messages, unfortunately I don't have any oops
> messages.  For whatever reason, it kicks in so quickly, that I can't
> get anything out over the network.  I'm going to see if I can stuff
> another network card in there and use that to send traffic, instead of
> over the brige.
> 
> My next step is going to be to try and disable some of the bridge
> settings, like bridge_stp, bridge_maxwait and bridge_fd to just accept
> the defaults.  I set this up under Debian Wheezy a long time ago and
> never touched it since.
> 
> My network config is:
> 
>     quad:~> ifconfig -a
>     br0       Link encap:Ethernet  HWaddr 20:cf:30:95:5f:2f
> 	      inet addr:192.168.1.6  Bcast:192.168.1.255  Mask:255.255.255.0
> 	      inet6 addr: 2002:42bd:1ac0:1:22cf:30ff:fe95:5f2f/64 Scope:Global
> 	      inet6 addr: fe80::22cf:30ff:fe95:5f2f/64 Scope:Link
> 	      UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> 	      RX packets:24154 errors:0 dropped:0 overruns:0 frame:0
> 	      TX packets:16103 errors:0 dropped:0 overruns:0 carrier:0
> 	      collisions:0 txqueuelen:1000
> 	      RX bytes:68682293 (65.5 MiB)  TX bytes:2563964 (2.4 MiB)
> 
>     eth0      Link encap:Ethernet  HWaddr 20:cf:30:95:5f:2f
> 	      UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> 	      RX packets:66460 errors:0 dropped:0 overruns:0 frame:0
> 	      TX packets:18157 errors:0 dropped:0 overruns:0 carrier:0
> 	      collisions:0 txqueuelen:1000
> 	      RX bytes:71819217 (68.4 MiB)  TX bytes:2782126 (2.6 MiB)
> 
>     lo        Link encap:Local Loopback
> 	      inet addr:127.0.0.1  Mask:255.0.0.0
> 	      inet6 addr: ::1/128 Scope:Host
> 	      UP LOOPBACK RUNNING  MTU:65536  Metric:1
> 	      RX packets:7308 errors:0 dropped:0 overruns:0 frame:0
> 	      TX packets:7308 errors:0 dropped:0 overruns:0 carrier:0
> 	      collisions:0 txqueuelen:0
> 	      RX bytes:1539613 (1.4 MiB)  TX bytes:1539613 (1.4 MiB)
> 								      
> 
> Any suggestions on what else I can do to help debug this issue?  It's amazing how quickly the system locks up when I have all three steps taken.


I've found a crash dump picture that I took, and I might be off on the wrong track, but I 
really don't know what else to think here.  As a quick test, I'm making a new kernel with 
more modules compiled in, and more debugging options turned on.  Here's my by-hand copy of
the crash dump message I was able to take a picture of from my self compiled 4.4-rc3 kernel.  
Sorry for any typos:

Workqueue: kblockd_cfq_kick_queue
task: ffff8800cf9f3180 ti: ffff8800cf940000 task.ti ffff800cf940000
RIP: 0010: [<ffffffff8136adaf>]  [<ffffffff8136adaf>] scsi_init_sgtable+0x3e/0x59
RSP: 0018:ffff8800cf943cc0 EFLAGS: 00010002
RAX: 0000000000000006 RBX: ffff88040eaf2760 RCX: 0000000000000007
RDX: 0000000000000006 RSI: 00000000ffffffff RDI: 0000000000000009
RBP: ffff8800cf988010 R08: 0000000000000000 R09: 0000000000000000
R10: 0065706f63732e74 R11: ffffffff81c4ae00 R12: 0000000000000000
R13: ffff8800cf988010 R14: ffff88040cbff800 R15: ffff8800cf988010 
FS:  00007ff020f1b980(0000) GS: ffff88041fc40000(0000) knlGS: 0000000000000000
CS:  0010  DS:  0000 ES: 0000 CR0: 0000000008005003b
CR2: 000000000000809000 CR3: 00000000c9e72000 CR4: 00000000000006e0
Stack: 
  ffff88040eaf2680 ffff88040eaf2680 0000000000040000 ffffffff8136b42f
  ffff88040cbff800 ffff88040eaf2680 00000000b605e950 0000000000400000
  ffff88040c4b5000 ffff88040cbff800 ffff8800cf988010 ffffffff81391076
Call Trace:
  [<ffffffff8136b42f>] ? scsi_init_io+0x41/0x19d
  [<ffffffff81391076>] ? sd_init_command+0x3df/0xbaa
  [<ffffffff81365952>] ? scsi_host_alloc_command+0x3e/0ca3
  [<ffffffff810881e9>] ? init_timer_key+0xc/0x49
  [<ffffffff8136b738>] ? scsi_prep_fn+0xa1/0x132
  [<ffffffff81256481>] ? blk_peek_request+0x167/0x206
  [<ffffffff81252daf>] ? __blk_run_queue_uncond+0x1e/0x26
  [<ffffffff8126e12e>] ? cfq_kick_queue+0x24/0x32
  [<ffffffff81057f89>] ? process_one_work+0x154/0x27e
  [<ffffffff81058658>] ? worker_thread+0x1d5/0x278
  [<ffffffff81058483>] ? rescuer_thread+0x277/0x277
  [<ffffffff8105c04c?] ? kthread+0xa7/0xaf
  [<ffffffff8105bfa5>] ? kthread_parkme+0x16/0x16


And the rest is off the screen.  I guess I'll have to start a git bisect and see where I 
end up, but I was hoping to find something in the lkml archives, no such luck.

Any suggestions on how to make Netconsole work better over eth0 then br0 so I can try to catch
these crash dumps?  I guess I'll setup another ethernet card on there and try that too...

John
