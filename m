From: "John Stoffel" <john@stoffel.org>
Subject: 4.4-rc3, KVM, br0 and instant hang
Date: Fri, 4 Dec 2015 23:28:33 -0500
Message-ID: <22114.26609.457727.203801@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi all,

I've been trying to upgrade to something newer than 4.2.6 since I want
to use LVM Cache on my home NFS fileserver, KVM server, test server,
etc.  So when it goes down, I lose all my other systems which mount
stuff from it.

Right now I'm trying to figure out how to use Netconsole to grab a
dump of the oops, but it's not working well.  But let me describe the
situation as I've found it so far.

When the system boots up, it first starts with eth0 on the network,
then switches to br0 since I have a KVM bridge setup so my VMs can
run on the same home network, 192.168.1.0/24 which is pretty
standard.  The system is an AMD Phenom(tm) II X4 945 Processor,
running at a max of 3Ghz, with 16gb of RAM, mpt2 LSI PCI-E 8 port sata
controller, on an ASUS motherboard.  I can get details if you like.
It's an older box, but still runs really well, so why change?

Anyway, if I try to boot up anything past the 4.2.6 kernel, the system
locks up pretty quickly with an oops message that scrolls off the
screen too far.  I've got some pictures which I'll attach in a bit,
maybe they'll help.  So at first I thought it was something to do with
bad kworker threads, or SCSI or SATA interactions, but as I tried to
configure Netconsole to log to my beaglebone black SBC, I found out
that if I compiled and installed 4.4-rc3, started the bridge up (br0),
even started KVM, but did NOT start my VMs, the system was stable.

And if I didn't start br0, I could start a VM, but the system wouldn't
crash.  The VM wasn't on the network... but the system didn't crash.
So I think I've found a wierd interaction here.  My KVMs are both
Debian images, with 1-2gb of RAM and 1 CPU each.  Nothing strange.  My
network config is:

     > cat /etc/network/interfaces
     # This file describes the network interfaces available on your system
     # and how to activate them. For more information, see interfaces(5).

     # The loopback network interface
     auto lo
     iface lo inet loopback

     # Bridge for VMs
     auto br0

     iface br0 inet static
       address 192.168.1.6
	 netmask 255.255.255.0
	   network 192.168.1.0
	     gateway 192.168.1.254
	       bridge_ports eth0
		 bridge_stp on
		   bridge_maxwait 0
		     bridge_fd 0

     # Old setup
     # auto eth0

     # iface eth0 inet static
     #    address 192.168.1.6
     #    netmask 255.255.255.0
     #    gateway 192.168.1.254

The currently running system version is:

     > cat /proc/version
     Linux version 4.4.0-rc3 (john@quad) (gcc version 4.9.2 (Debian 4.9.2-10) ) #1 SMP Thu Dec 3 12:13:30 EST 2015

And more detailed CPU info

     > cat /proc/cpuinfo
     .....

     processor       : 3
     vendor_id       : AuthenticAMD
     cpu family      : 16
     model           : 4
     model name      : AMD Phenom(tm) II X4 945 Processor
     stepping        : 3
     microcode       : 0x10000b6
     cpu MHz         : 800.000
     cache size      : 512 KB
     physical id     : 0
     siblings        : 4
     core id         : 3
     cpu cores       : 4
     apicid          : 3
     initial apicid  : 3
     fpu             : yes
     fpu_exception   : yes
     cpuid level     : 5
     wp              : yes
     flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
     mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
     fxsr_opt pdpe1gb rdtscp lm 3dnowext 3dnow constant_tsc rep_good nopl
     nonstop_tsc extd_apicid pni monitor cx16 popcnt lahf_lm cmp_legacy svm
     extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit
     wdt hw_pstate npt lbrv svm_lock nrip_save vmmcall
     bugs            : tlb_mmatch apic_c1e fxsave_leak sysret_ss_attrs
     bogomips        : 6027.13
     TLB size        : 1024 4K pages
     clflush size    : 64
     cache_alignment : 64
     address sizes   : 48 bits physical, 48 bits virtual
     power management: ts ttp tm stc 100mhzsteps hwpstate


Here's my bootup messages, unfortunately I don't have any oops
messages.  For whatever reason, it kicks in so quickly, that I can't
get anything out over the network.  I'm going to see if I can stuff
another network card in there and use that to send traffic, instead of
over the brige.

My next step is going to be to try and disable some of the bridge
settings, like bridge_stp, bridge_maxwait and bridge_fd to just accept
the defaults.  I set this up under Debian Wheezy a long time ago and
never touched it since.

My network config is:

    quad:~> ifconfig -a
    br0       Link encap:Ethernet  HWaddr 20:cf:30:95:5f:2f
	      inet addr:192.168.1.6  Bcast:192.168.1.255  Mask:255.255.255.0
	      inet6 addr: 2002:42bd:1ac0:1:22cf:30ff:fe95:5f2f/64 Scope:Global
	      inet6 addr: fe80::22cf:30ff:fe95:5f2f/64 Scope:Link
	      UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
	      RX packets:24154 errors:0 dropped:0 overruns:0 frame:0
	      TX packets:16103 errors:0 dropped:0 overruns:0 carrier:0
	      collisions:0 txqueuelen:1000
	      RX bytes:68682293 (65.5 MiB)  TX bytes:2563964 (2.4 MiB)

    eth0      Link encap:Ethernet  HWaddr 20:cf:30:95:5f:2f
	      UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
	      RX packets:66460 errors:0 dropped:0 overruns:0 frame:0
	      TX packets:18157 errors:0 dropped:0 overruns:0 carrier:0
	      collisions:0 txqueuelen:1000
	      RX bytes:71819217 (68.4 MiB)  TX bytes:2782126 (2.6 MiB)

    lo        Link encap:Local Loopback
	      inet addr:127.0.0.1  Mask:255.0.0.0
	      inet6 addr: ::1/128 Scope:Host
	      UP LOOPBACK RUNNING  MTU:65536  Metric:1
	      RX packets:7308 errors:0 dropped:0 overruns:0 frame:0
	      TX packets:7308 errors:0 dropped:0 overruns:0 carrier:0
	      collisions:0 txqueuelen:0
	      RX bytes:1539613 (1.4 MiB)  TX bytes:1539613 (1.4 MiB)
								      

Any suggestions on what else I can do to help debug this issue?  It's amazing how quickly the system locks up when I have all three steps taken.

John
