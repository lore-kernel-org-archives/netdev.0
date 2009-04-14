From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.30-rc1 A few issues and a stall (nmi_watchdog traceback)
Date: Tue, 14 Apr 2009 16:09:26 -0700
Message-ID: <20090414160926.52e07a3d@nehalam>
References: <200904121124.07193.edt@aei.ca>
	<200904140832.25057.edt@aei.ca>
	<49E4840E.6010300@redhat.com>
	<200904141854.43205.edt@aei.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, bridge@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org
To: Ed Tomlinson <edt@aei.ca>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200904141854.43205.edt@aei.ca>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Apr 2009 18:54:42 -0400
Ed Tomlinson <edt@aei.ca> wrote:

> On Tuesday 14 April 2009 08:39:42 Avi Kivity wrote:
> > Ed Tomlinson wrote:
> > > On Tuesday 14 April 2009 06:03:58 Avi Kivity wrote:
> > >   
> > >> Ed Tomlinson wrote:
> > >>     
> > >>> Once the above networking stuff is setup I start kvm with the command below
> > >>>
> > >>> QEMU_AUDIO_DRV=alsa kvm -m 1024 -cdrom /mnt/sdc4/divx/archlinux-2009.02-ftp-i686.iso -boot c -smp 3 -usb -usbdevice tablet -vga std -drive file=arch.img -net nic,macaddr=52:54:00:12:34:23 -net tap,ifname=qtap0,script=no -soundhw all -mem-path /hugepages
> > >>>
> > >>> which works and the kvm session boots just fine.  
> > >>>
> > >>> Issue 2.  When I attempt to ping outside the kvm session the pc (not just the kvm session) hangs.
> > >>> Its impossible to kill the kvm session and there are numerious info messages from RCU (tree RCU enabled)
> > >>> about stalls.  
> > >>>   
> > >>>       
> > >> The rcu messages are likely because a processor has died.
> > >>
> > >> Do things work if you drop -mem-path?
> > >>     
> > >
> > > It makes no difference.  I did notice that one cpu is peged at 100% though.  I'll be trying
> > > CONFIG_PROVE_LOCKING tonight for another problem - might give interesting results.
> > >   
> > 
> > Oh, so this goes away without CONFIG_PROVE_LOCKING?
> >
> 
> With CONFIG_PROVE_LOCKING, DEBUG_PAGE_ALLOC and the nmi_watchdog=2, I get the following info:
> 
> I used the following sequence to start the kvm:
> 
> ed@grover ~/vm $ sudo modprobe tun
> ed@grover ~/vm $ sudo modprobe nf_nat
> ed@grover ~/vm $ sudo modprobe ipt_MASQUERADE
> ed@grover ~/vm $ sudo brctl addbr br0
> ed@grover ~/vm $ sudo ifconfig br0 192.168.100.254 netmask 255.255.255.0 up
> ed@grover ~/vm $ sudo tunctl -b -u ed -t qtap0
> qtap0
> ed@grover ~/vm $ sudo brctl addif br0 qtap0
> ed@grover ~/vm $ sudo ifconfig qtap0 up 0.0.0.0 promisc
> ed@grover ~/vm $ sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
> iptables v1.4.2: can't initialize iptables table `nat': Table does not exist (do you need to insmod?)
> Perhaps iptables or your kernel needs to be upgraded.
> ed@grover ~/vm $ sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
> 
> (Yes I really did have to run iptables twice and it did work the second time...)
> 
> Looks like the spinning lock is the the bridge code.
> 
> [  369.387893] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> [  393.537476] device qtap0 entered promiscuous mode
> [  394.585998] br0: no IPv6 routers present
> [  398.171309] br0: port 1(qtap0) entering learning state
> [  403.081910] ip_tables: (C) 2000-2006 Netfilter Core Team
> [  408.945932] qtap0: no IPv6 routers present
> [  413.183725] br0: topology change detected, propagating
> [  413.189027] br0: port 1(qtap0) entering forwarding state
> [  434.211892] kvm: 7758: cpu0 kvm_set_msr_common: MSR_IA32_MC0_STATUS 0x0, nop
> [  434.420571] kvm: 7758: cpu1 kvm_set_msr_common: MSR_IA32_MC0_STATUS 0x0, nop
> [  434.452731] kvm: 7758: cpu2 kvm_set_msr_common: MSR_IA32_MC0_STATUS 0x0, nop
> [  499.270674] BUG: NMI Watchdog detected LOCKUP on CPU2, ip ffffffff802c97a3, registers:
> [  499.270674] CPU 2
> [  499.270674] Modules linked in: iptable_nat ip_tables ipt_MASQUERADE x_tables nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4
> btrfs zlib_deflate zlib_inflate crc32c libcrc32c radeon drm bridge rfcomm stp llc bnep l2cap bluetooth tun sit tunnel4 ipv6 af_packet
>  snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss edac_core kvm_amd kvm video1394 sbp2 l
> gdt330x em28xx_dvb dvb_core em28xx_alsa tuner_xc2028 tuner tvp5150 em28xx ir_common v4l2_common videodev v4l2_compat_ioctl32 videobuf
> _vmalloc videobuf_core tveeprom pl2303 i2c_core usbserial usbhid usb_storage sr_mod cdrom asus_atk0110 rtc_cmos snd_hda_codec_atihdmi
>  rtc_core snd_hda_codec_realtek rtc_lib ohci1394 ieee1394 snd_hda_intel sky2 snd_hda_codec wmi thermal processor snd_pcm button pcspk
> r snd_timer snd ata_generic soundcore snd_page_alloc ehci_hcd pata_atiixp ohci_hcd evdev unix [last unloaded: floppy]
> [  499.270674] Pid: 7759, comm: kvm Tainted: G      D    2.6.30-rc1-crc #7 System Product Name
> [  499.270674] RIP: 0010:[<ffffffff802c97a3>]  [<ffffffff802c97a3>] ftrace_likely_update+0x23/0x50
> [  499.270674] RSP: 0018:ffff88002813aa68  EFLAGS: 00000002
> [  499.270674] RAX: 000000005c8eefb8 RBX: 0000000000000000 RCX: 0000000000000000
> [  499.270674] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff8087e280
> [  499.270674] RBP: ffff88002813aa78 R08: 0000000000000000 R09: 0000000000000001
> [  499.270674] R10: 0000000000000000 R11: ffff880140c75e20 R12: 0000000049d2f025
> [  499.270674] R13: 0000000000000001 R14: 0000000049d2f068 R15: 0000000000000002
> [  499.270674] FS:  00007f8ba8a4d950(0000) GS:ffff880028137000(0000) knlGS:0000000000000000
> [  499.270674] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  499.270674] CR2: 00007fcea464e680 CR3: 0000000145013000 CR4: 00000000000006e0
> [  499.270674] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  499.270674] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  499.270674] Process kvm (pid: 7759, threadinfo ffff8801450de000, task ffff880140c75e20)
> [  499.270674] Stack:
> [  499.270674]  000000005c8eefb8 000000005c8eefb8 ffff88002813aac8 ffffffff80445f3d
> [  499.270674]  000000005c8eefb8 0000000000000046 000000005c8eefb8 000000000393fe6c
> [  499.270674]  ffff88013f947a38 000000007d7d7530 0000000000000001 0000000000000000
> [  499.270674] Call Trace:
> [  499.270674]  <IRQ> <0> [<ffffffff80445f3d>] delay_tsc+0x10d/0x140
> [  499.270674]  [<ffffffff80445d92>] __delay+0x22/0x40
> [  499.270674]  [<ffffffff8044c07f>] _raw_spin_lock+0x16f/0x1f0
> [  499.270674]  [<ffffffff80624d1d>] _spin_lock_irqsave+0x5d/0x80
> [  499.270674]  [<ffffffff8023ee68>] ? __wake_up_sync_key+0x78/0xd0
> [  499.270674]  [<ffffffff8023ee68>] __wake_up_sync_key+0x78/0xd0
> [  499.270674]  [<ffffffffa03d36b9>] ? br_flood+0xf9/0x110 [bridge]
> [  499.270674]  [<ffffffff8023eee3>] __wake_up_sync+0x23/0x40
> [  500.092533]  [<ffffffffa0385a47>] tun_sock_write_space+0x57/0xb0 [tun]
> [  500.092533]  [<ffffffff80581a79>] sock_wfree+0x79/0x90
> [  500.092533]  [<ffffffff80288dc2>] ? trace_hardirqs_on_caller+0x32/0x1e0
> [  500.092533]  [<ffffffff80584ad8>] skb_release_head_state+0x98/0x120
> [  500.092533]  [<ffffffff80594d98>] ? netif_receive_skb+0x118/0x4a0
> [  500.092533]  [<ffffffff80584585>] __kfree_skb+0x25/0xe0
> [  500.092533]  [<ffffffff80584858>] kfree_skb+0x138/0x180
> [  500.092533]  [<ffffffffa03d36b9>] br_flood+0xf9/0x110 [bridge]
> [  500.092533]  [<ffffffff80594d98>] ? netif_receive_skb+0x118/0x4a0
> [  500.092533]  [<ffffffffa03d38a0>] ? __br_forward+0x0/0x120 [bridge]
> [  500.092533]  [<ffffffffa03d36f8>] br_flood_forward+0x28/0x50 [bridge]
> [  500.157359]  [<ffffffffa03d4b4b>] br_handle_frame_finish+0x19b/0x1c0 [bridge]
> [  500.157359]  [<ffffffff80594d98>] ? netif_receive_skb+0x118/0x4a0
> [  500.157359]  [<ffffffffa03d4dba>] br_handle_frame+0x24a/0x260 [bridge]
> [  500.157359]  [<ffffffff80594ee3>] netif_receive_skb+0x263/0x4a0
> [  500.157359]  [<ffffffff80594d98>] ? netif_receive_skb+0x118/0x4a0
> [  500.157359]  [<ffffffff805951b7>] process_backlog+0x97/0xf0
> [  500.157359]  [<ffffffff80594017>] net_rx_action+0x277/0x370
> [  500.157359]  [<ffffffff80593e85>] ? net_rx_action+0xe5/0x370
> [  500.157359]  [<ffffffff8025a8a2>] __do_softirq+0x142/0x2e0
> [  500.157359]  [<ffffffff8020d0fc>] call_softirq+0x1c/0xb0
> [  500.157359]  <EOI> <0> [<ffffffff8020ec1d>] do_softirq+0x9d/0x150
> [  500.157359]  [<ffffffff80593955>] netif_rx_ni+0xa5/0xc0
> [  500.157359]  [<ffffffffa0386de1>] tun_chr_aio_write+0x3c1/0x4b0 [tun]
> [  500.157359]  [<ffffffffa0386a20>] ? tun_chr_aio_write+0x0/0x4b0 [tun]
> [  500.157359]  [<ffffffff8031d8b3>] do_sync_readv_writev+0x103/0x160
> [  500.157359]  [<ffffffff80272de0>] ? autoremove_wake_function+0x0/0x70
> [  500.157359]  [<ffffffff80316515>] ? kfree+0xd5/0x270
> [  500.157359]  [<ffffffff80407319>] ? security_file_permission+0x29/0x50
> [  500.157359]  [<ffffffff8031dcdf>] ? rw_verify_area+0x10f/0x180
> [  500.157359]  [<ffffffff8031ea7c>] do_readv_writev+0xec/0x220
> [  500.283996]  [<ffffffff80628d69>] ? sub_preempt_count+0x69/0x70
> [  500.283996]  [<ffffffff8031f716>] ? __rcu_read_unlock+0x66/0xa0
> [  500.283996]  [<ffffffff8031f807>] ? fget_light+0xb7/0x190
> [  500.283996]  [<ffffffff8031ec18>] vfs_writev+0x68/0x90
> [  500.283996]  [<ffffffff8031efc6>] sys_writev+0x66/0xf0
> [  500.283996]  [<ffffffff8020bf5b>] system_call_fastpath+0x16/0x1b
> [  500.283996] Code: ff 90 90 90 90 90 90 90 55 48 89 e5 48 83 ec 10 65 48 8b 04 25 28 00 00 00 48 89 45 f8 31 c0 39 d6 74 15 48 ff 4
> 7 20 48 8b 45 f8 <65> 48 33 04 25 28 00 00 00 75 0c c9 c3 48 ff 47 18 0f 1f 40 00
> [  500.283996] ---[ end trace 19d93ad2f835aa80 ]---        
> 
> Ideas?
> Ed                                                                

Since bridge is echoing back packets to TUN device (flood),
maybe there is some way the tun socket is still locked in that path?
