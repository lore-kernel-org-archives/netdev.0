From: Ben Greear <greearb@candelatech.com>
Subject: Re: Hard freeze (linux 2.6.7) or OOPS (linux 2.6.8.1) with e1000
 + vlan, possible bug
Date: Mon, 13 Sep 2004 09:35:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4145CC53.8080405@candelatech.com>
References: <20040913141059.GJ21600@nohope.patoche.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux.nics@intel.com,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick <patrick@alliance21.org>
In-Reply-To: <20040913141059.GJ21600@nohope.patoche.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick wrote:
> Hello,
> 
> I'm contacting you both because I believe there may be a problem in
> the e1000 driver for linux, the vlan module or both.

There were some recent locking changes, which included a bug,
in the VLAN code.  This was fixed late last week, but I don't know
if the fix is in the version that you are running.

The 2.6.8.1 oops looks like it could be the bug introduced recently,
but I don't think that bug exists at all in 2.6.7.

I'm cc'ing netdev as well, maybe someone else has some better
ideas.  To trouble-shoot, any chance you could try with a different
NIC (maybe broadcom running the tg3 driver)?  Can you reproduce if
you do not use SAMBA?

> 
> I have a box with an Intel Xeon 2.40 GHz with on-board Intel gigabit
> connections (two) and an additionnal 2 gigabit ports PCI card.
> So I'm using 3 of those 4 gigabit ports with the e1000 driver, and
> some vlans.
> e1000 and 8021q are compiled as modules (loaded at boot with /etc/modules, 8021q listed before e1000).
> Kernel output:
> Linux version 2.6.8.1 (root@zatras) (gcc version 3.3.4 (Debian 1:3.3.4-4)) #1 SMP Mon Sep 13 10:31:31 CEST 2004
> [..]
> 511MB LOWMEM available.
> [..]
> 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
> All bugs added by David S. Miller <davem@redhat.com>
> [..]
> Intel(R) PRO/1000 Network Driver - version 5.2.52-k4
> Copyright (c) 1999-2004 Intel Corporation.
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> [..]
> e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex
> e1000: eth3: e1000_watchdog: NIC Link is Up 10 Mbps Half Duplex
> [..]
> e1000: eth2: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex
> 
> 
> The eth2 nic has currently 3 vlans.
> 
> 
> Here is what is happening:
> - with kernels 2.6.6 or 2.6.7 : 2 or 3 times per day, the box freeze
> completely (keyboard unresponsive), nothing printed on console or in
> log files. Does not seem to be related to network traffic (very low)
> or anything else.
> 
> - with kernel 2.6.8.1 : I have an OOPS right at boot and many
> problems just after, so it may be an idea of the problem with
> previous kernels
> 
> Here is the relevant log:
> Sep 13 12:30:02 whitestar kernel: e08390f5
> Sep 13 12:30:02 whitestar kernel: SMP 
> Sep 13 12:30:02 whitestar kernel: Modules linked in: af_packet md5 ipv6 8250 serial_core ipt_multiport ipt_MASQUERADE ipt_REJECT ipt_state ipt_limit ipt_LOG ip_nat_irc ip_nat_ftp iptable_nat iptable_mangle iptable_filter ip_conntrack_irc ip_conntrack_ftp ip_conntrack ip_tables dm_mod p4_clockmod speedstep_lib w83627hf_wdt w83627hf i2c_sensor i2c_isa i2c_core e1000 8021q
> Sep 13 12:30:02 whitestar kernel: CPU:    0
> Sep 13 12:30:02 whitestar kernel: EIP:    0060:[__crc_scm_detach_fds+103817/677563]    Not tainted
> Sep 13 12:30:02 whitestar kernel: EFLAGS: 00010212   (2.6.8.1) 
> Sep 13 12:30:02 whitestar kernel: EIP is at e1000_shift_out_mdi_bits+0x22/0x8c [e1000]
> Sep 13 12:30:02 whitestar kernel: eax: fffffffc   ebx: 00000001   ecx: 0000001f   edx: 00000000
> Sep 13 12:30:02 whitestar kernel: esi: de70bc10   edi: dca05e6c   ebp: ffffffff   esp: dca05e64
> Sep 13 12:30:02 whitestar kernel: ds: 007b   es: 007b   ss: 0068
> Sep 13 12:30:02 whitestar kernel: Process snmpd (pid: 1025, threadinfo=dca04000 task=dc9f1390)
> Sep 13 12:30:02 whitestar kernel: Stack: 00000000 c0374000 0000000a 00001820 de70bc10 dca05ee2 dca05f30 e0839301 
> Sep 13 12:30:02 whitestar kernel:        de70bc10 ffffffff 00000020 dca05ecc de70ba20 dca05edc e0836a0c de70bc10 
> Sep 13 12:30:02 whitestar kernel:        00000000 dca05ee2 dca05ecc de903005 dca05edc e0814688 de70b800 dca05ecc 
> Sep 13 12:30:02 whitestar kernel: Call Trace:
> Sep 13 12:30:02 whitestar kernel:  [__crc_scm_detach_fds+104341/677563] e1000_read_phy_reg_ex+0x92/0xb3 [e1000]
> Sep 13 12:30:02 whitestar kernel:  [__crc_scm_detach_fds+93856/677563] e1000_mii_ioctl+0x1c8/0x1ca [e1000]
> Sep 13 12:30:02 whitestar kernel:  [__crc_journal_load+4760390/4806698] vlan_dev_ioctl+0xb5/0xe9 [8021q]
> Sep 13 12:30:02 whitestar kernel:  [dev_ifsioc+851/957] dev_ifsioc+0x353/0x3bd
> Sep 13 12:30:02 whitestar kernel:  [dev_ioctl+355/618] dev_ioctl+0x163/0x26a
> Sep 13 12:30:02 whitestar kernel:  [inet_ioctl+142/158] inet_ioctl+0x8e/0x9e
> Sep 13 12:30:02 whitestar kernel:  [sock_ioctl+238/641] sock_ioctl+0xee/0x281
> Sep 13 12:30:02 whitestar kernel:  [sys_ioctl+273/605] sys_ioctl+0x111/0x25d
> Sep 13 12:30:02 whitestar kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
> Sep 13 12:30:02 whitestar kernel: Code: 8b 02 d3 e3 0d 00 00 00 03 85 db 89 44 24 08 74 47 85 eb 74 
> 
> 
> ksymoops says:
> Error (regular_file): read_ksyms stat /proc/ksyms failed
> ksymoops: No such file or directory
> No modules in ksyms, skipping objects
> No ksyms, skipping lsmod
> Sep 13 12:30:02 whitestar kernel: e08390f5
> Sep 13 12:30:02 whitestar kernel: CPU:    0
> Sep 13 12:30:02 whitestar kernel: EIP:    0060:[__crc_scm_detach_fds+103817/677563]    Not tainted
> Sep 13 12:30:02 whitestar kernel: EFLAGS: 00010212   (2.6.8.1)
> Sep 13 12:30:02 whitestar kernel: eax: fffffffc   ebx: 00000001   ecx: 0000001f   edx: 00000000
> Sep 13 12:30:02 whitestar kernel: esi: de70bc10   edi: dca05e6c   ebp: ffffffff   esp: dca05e64
> Sep 13 12:30:02 whitestar kernel: ds: 007b   es: 007b   ss: 0068
> Sep 13 12:30:02 whitestar kernel: Stack: 00000000 c0374000 0000000a 00001820 de70bc10 dca05ee2 dca05f30 e0839301
> Sep 13 12:30:02 whitestar kernel:        de70bc10 ffffffff 00000020 dca05ecc de70ba20 dca05edc e0836a0c de70bc10
> Sep 13 12:30:02 whitestar kernel:        00000000 dca05ee2 dca05ecc de903005 dca05edc e0814688 de70b800 dca05ecc
> Sep 13 12:30:02 whitestar kernel: Call Trace:
> Warning (Oops_read): Code line not seen, dumping what data is available
> 
> 
> 
>>>eax; fffffffc <__kernel_rt_sigreturn+1bbc/????>
>>>esi; de70bc10 <__crc_cap_inode_removexattr+6c19a/188f0f>
>>>edi; dca05e6c <__crc_wait_on_sync_kiocb+1c4c11/294abb>
>>>ebp; ffffffff <__kernel_rt_sigreturn+1bbf/????>
>>>esp; dca05e64 <__crc_wait_on_sync_kiocb+1c4c09/294abb>
> 
> 
> Sep 13 12:30:02 whitestar kernel: Code: 8b 02 d3 e3 0d 00 00 00 03 85 db 89 44 24 08 74 47 85 eb 74
> Using defaults from ksymoops -t elf32-i386 -a i386
> 
> 
> Code;  00000000 Before first symbol
> 00000000 <_EIP>:
> Code;  00000000 Before first symbol
>    0:   8b 02                     mov    (%edx),%eax
> Code;  00000002 Before first symbol
>    2:   d3 e3                     shl    %cl,%ebx
> Code;  00000004 Before first symbol
>    4:   0d 00 00 00 03            or     $0x3000000,%eax
> Code;  00000009 Before first symbol
>    9:   85 db                     test   %ebx,%ebx
> Code;  0000000b Before first symbol
>    b:   89 44 24 08               mov    %eax,0x8(%esp,1)
> Code;  0000000f Before first symbol
>    f:   74 47                     je     58 <_EIP+0x58>
> Code;  00000011 Before first symbol
>   11:   85 eb                     test   %ebp,%ebx
> Code;  00000013 Before first symbol
>   13:   74 00                     je     15 <_EIP+0x15>
> 
> 
> 1 warning and 1 error issued.  Results may not be reliable.
> 
> 
> 
> I've tried with and without HyperThreading enabled in Bios, and nosmp
> flag at boot, but I have the same results in both cases.
> I've also tried with boot options: noapic nolapic noacpi
> without change.
> 
> This message comes exactly 5 minutes after boot (probably due to snmp/mrtg generating network traffic).
> After what I encounter problems: ifconfig hangs for example
> (when running correctly with other kernel), here is the end of the strace:
> 
> uname({sys="Linux", node="whitestar", ...}) = 0
> access("/proc/net", R_OK)               = 0
> access("/proc/net/unix", R_OK)          = 0
> socket(PF_FILE, SOCK_DGRAM, 0)          = 3
> socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
> access("/proc/net/if_inet6", R_OK)      = 0
> socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 5
> access("/proc/net/ax25", R_OK)          = -1 ENOENT (No such file or directory)
> access("/proc/net/nr", R_OK)            = -1 ENOENT (No such file or directory)
> access("/proc/net/rose", R_OK)          = -1 ENOENT (No such file or directory)
> access("/proc/net/ipx", R_OK)           = -1 ENOENT (No such file or directory)
> access("/proc/net/appletalk", R_OK)     = -1 ENOENT (No such file or directory)
> access("/proc/sys/net/econet", R_OK)    = -1 ENOENT (No such file or directory)
> access("/proc/sys/net/ash", R_OK)       = -1 ENOENT (No such file or directory)
> access("/proc/net/x25", R_OK)           = -1 ENOENT (No such file or directory)
> open("/proc/net/dev", O_RDONLY)         = 6
> fstat64(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
> mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x40018000
> read(6, "Inter-|   Receive               "..., 1024) = 1024
> read(6, "44    0    0    0     0       0 "..., 1024) = 292
> read(6, "", 1024)                       = 0
> close(6)                                = 0
> munmap(0x40018000, 4096)                = 0
> ioctl(4, SIOCGIFCONF, {
> 
> 
> and sits there indefinitely.
> 
> Samba process (nmbd) is then in uninterruptible sleep (according to
> ps), when it runs correctly under previous versions of kernel.
> When I try to shutdown, it hangs when trying to deconfigure all network interfaces.
> 
> 
> When I try to stress test with multiple ping -f/crashme/bonnie++ in parallel, the box has no problem,
> and do not freeze.
> 
> 
> Can you please let me know if you believe this to be a kernel bug and
> in which part exactly, and/or what I can do to alleviate the problem
> ?
> The box is used in production as a firewall and was running correctly
> until I started to use vlans (3 currently) and samba.
> 
> Thanks for your help in advance, and do not hesitate to let me know
> if I have forgotten to include needed information.
> 
> Regards.
> Patrick Mevzek.
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
