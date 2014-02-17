From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 70681] New: broadcast gre causes oops
Date: Mon, 17 Feb 2014 11:24:19 -0800
Message-ID: <20140217112419.32778a96@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:53463 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbaBQTYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:24:22 -0500
Received: by mail-pb0-f41.google.com with SMTP id up15so15716374pbc.14
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 11:24:22 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id x5sm48309545pbw.26.2014.02.17.11.24.21
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 17 Feb 2014 11:24:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 16 Feb 2014 14:17:44 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 70681] New: broadcast gre causes oops


https://bugzilla.kernel.org/show_bug.cgi?id=70681

            Bug ID: 70681
           Summary: broadcast gre causes oops
           Product: Networking
           Version: 2.5
    Kernel Version: 3.13.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: ast@domdv.de
        Regression: No

I was trying to use broaddast (ahem, multicast) gre. This repeatably results in
an Oops and a kernel panic:

htpc2 ~ # ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 4074
        inet 10.1.9.61  netmask 255.255.255.0  broadcast 10.1.9.255
        inet6 2001:a60:10b3:c00:201:c0ff:fe13:db43  prefixlen 64  scopeid
0x0<global>
        inet6 fe80::201:c0ff:fe13:db43  prefixlen 64  scopeid 0x20<link>
        inet6 fdf2:e35b:1a0e:2c28:201:c0ff:fe13:db43  prefixlen 64  scopeid
0x0<global>
        inet6 fdf2:e35b:1a0e:2c28::61  prefixlen 64  scopeid 0x0<global>
        ether 00:01:c0:13:db:43  txqueuelen 1000  (Ethernet)
        RX packets 1943144  bytes 403477948 (384.7 MiB)
        RX errors 0  dropped 65686  overruns 0  frame 0
        TX packets 2135358  bytes 367947113 (350.9 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 20  memory 0xe0700000-e0720000  

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 0  (Local Loopback)
        RX packets 264059  bytes 16600869 (15.8 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 264059  bytes 16600869 (15.8 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

htpc2 ~ # route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.1.9.1        0.0.0.0         UG    2      0        0 eth0
10.1.9.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0 lo
127.0.0.0       127.0.0.1       255.0.0.0       UG    0      0        0 lo
224.0.0.0       0.0.0.0         240.0.0.0       U     10     0        0 eth0
htpc2 ~ # ip tunnel add test mode gre local 10.1.9.61 remote 224.66.66.66 ttl
16
htpc2 ~ # ip addr add 10.0.0.1/24 dev test
htpc2 ~ # ip link set test up



This results instantly in the following Oops (from /dev/pstore):

Oops#1 Part1
<4>R13: ffffffff816569c0 R14: ffff88043e250008 R15: ffffffff8166fc40
<4>FS:  0000000000000000(0000) GS:ffff88043e240000(0000) knlGS:0000000000000000
<4>CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>CR2: 00000000000000a2 CR3: 0000000410f41000 CR4: 00000000001407a0
<4>Stack:
<4> ffff880417fb2840 ffff88042c88a1c0 ffff88043e243dcc ffff8800a1644800
<4> ffffffff816569c0 ffffffffa016b33b 0000000000000012 ffff88042c88a1c0
<4> 0000000000000000 ffffffff816569c0 ffff88042d674000 ffffffffa015c4ac
<4>Call Trace:
<4> <IRQ> 
<4> [<ffffffffa016b33b>] ? ipgre_rcv+0xb4/0xc5 [ip_gre]
<4> [<ffffffffa015c4ac>] ? gre_cisco_rcv+0x3b/0x89 [gre]
<4> [<ffffffffa015c10b>] ? gre_rcv+0x66/0x8e [gre]
<4> [<ffffffff81342222>] ? ip_local_deliver_finish+0x92/0xfc
<4> [<ffffffff81313374>] ? __netif_receive_skb_core+0x612/0x6a5
<4> [<ffffffff813134e8>] ? process_backlog+0x8a/0x140
<4> [<ffffffff81313825>] ? net_rx_action+0xa5/0x1e4
<4> [<ffffffff81040f2e>] ? __do_softirq+0xf1/0x26d
<4> [<ffffffff8104128a>] ? irq_exit+0x35/0x7a
<4> [<ffffffff81020895>] ? smp_apic_timer_interrupt+0x3b/0x46
<4> [<ffffffff813ea60a>] ? apic_timer_interrupt+0x6a/0x70
<4> <EOI> 
<4> [<ffffffff812ee4dd>] ? cpuidle_enter_state+0x43/0xa6
<4> [<ffffffff812ee4d6>] ? cpuidle_enter_state+0x3c/0xa6
<4> [<ffffffff812ee649>] ? cpuidle_idle_call+0x109/0x1e3
<4> [<ffffffff81009b4d>] ? arch_cpu_idle+0x7/0x1a
<4> [<ffffffff8106f2ec>] ? cpu_startup_entry+0x133/0x206
<4>Code: 89 f3 50 44 0f b7 a6 ae 00 00 00 4c 03 a6 c0 00 00 00 41 8b 44 24 10
25 f0 00 00 00 3d e0 00 00 00 75 2c 48 8b 46 58 48 83 e0 fe <80> b8 a2 00 00 00
00 0f 84 53 03 00 00 48 8b 47 18 48 ff 80 48 
<1>RIP  [<ffffffff8137954f>] ip_tunnel_rcv+0x35/0x3d7
<4> RSP <ffff88043e243d68>
<4>CR2: 00000000000000a2
<4>---[ end trace 6a1568a07dacad07 ]---
Oops#1 Part2
<6>gre: GRE over IPv4 demultiplexor driver
<6>ip_gre: GRE over IPv4 tunneling driver
<1>BUG: unable to handle kernel NULL pointer dereference at 00000000000000a2
<1>IP: [<ffffffff8137954f>] ip_tunnel_rcv+0x35/0x3d7
<4>PGD 410f42067 PUD 410f43067 PMD 0 
<4>Oops: 0000 [#1] PREEMPT SMP 
<4>Modules linked in: ip_gre gre bnep autofs4 nls_iso8859_15 nls_cp850 vfat fat
configfs uinput snd_aloop snd_seq_midi snd_seq_midi_event snd_seq snd_rawmidi
snd_seq_device fuse tun hid_topseed hid_generic iwldvm led_class mac80211
usbhid cdc_acm snd_hda_codec_hdmi coretemp snd_hda_codec_realtek pcspkr iwlwifi
cfg80211 btusb i915 8250_pci snd_hda_intel i2c_algo_bit intel_agp snd_hda_codec
i2c_i801 intel_gtt r8169 snd_pcm drm_kms_helper snd_page_alloc rtc_cmos mii
iTCO_wdt drm snd_timer snd 8250 agpgart soundcore serial_core bluetooth
uhci_hcd ehci_pci ehci_hcd xhci_hcd usb_storage
<4>CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.13.2-gentoo-htpc2 #1
<4>Hardware name: CompuLab Intense-PC/Intense-PC, BIOS CR_2.2.0.400 X64
12/12/2013
<4>task: ffff88043c0fd9a0 ti: ffff88043c0fe000 task.ti: ffff88043c0fe000
<4>RIP: 0010:[<ffffffff8137954f>]  [<ffffffff8137954f>]
ip_tunnel_rcv+0x35/0x3d7
<4>RSP: 0018:ffff88043e243d68  EFLAGS: 00010246
<4>RAX: 0000000000000000 RBX: ffff88042c88a1c0 RCX: 0000000000000001
<4>RDX: ffff88043e243dcc RSI: ffff88042c88a1c0 RDI: ffff880417fb2840
<4>RBP: ffff880417fb2840 R08: 0000000000000000 R09: 00000000424242e0
<4>R10: ffff8800a1644a08 R11: ffff8800a1ca9680 R12: ffff880410eae054


The kernel then panics but I don't seem to get the panic reliably written to
/dev/pstore so I can't add it here.

-- 
You are receiving this mail because:
You are the assignee for the bug.
