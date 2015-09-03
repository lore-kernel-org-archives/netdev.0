From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Thu, 03 Sep 2015 02:12:45 +0200
Message-ID: <55E7907D.9000606@iogearbox.net>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com> <20150826074959.48aea34c@as> <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com> <1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com> <D20CE2AD.43744%Shaun.Crampton@metaswitch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Marineau <michael.marineau@coreos.com>,
	Chuck Ebbert <cebbert.lkml@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Peter White <Peter.White@metaswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D20CE2AD.43744%Shaun.Crampton@metaswitch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/02/2015 06:39 PM, Shaun Crampton wrote:
>> Make sure you backported commit
>> 10e2eb878f3ca07ac2f05fa5ca5e6c4c9174a27a
>> ("udp: fix dst races with multicast early demux")
>
> I just tried the latest CoreOS alpha, which had that patch.  Sadly, I saw
> just as many reboots.  Here's a sample of the different types of Oopses I
> see (I've put the rest up in a gist:
> https://gist.github.com/fasaxc/d801ced5608f2657abd8):
>
> [ 4024.564479] BUG: unable to handle kernel NULL pointer dereference at
>         (null)
> [ 4024.565452] IP: [<          (null)>]           (null)
> [ 4024.565452] PGD 2297067 PUD 2296067 PMD 0
> [ 4024.565452] Oops: 0010 [#1] SMP
> [ 4024.565452] Modules linked in: xt_mac xt_mark veth ip_set_hash_net
> nf_conntrack_ipv6 nf_defrag_ipv6 xt_comment xt_set ip_set_hash_ip ip_set
> nfnetlink ipip tunnel4 ip_tunnel ip6table_filter ip6_tables xt_conntrack
> ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4
> nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype iptable_filter br_netfilter nf_nat
> nf_conntrack bridge stp llc overlay nls_ascii nls_cp437 vfat fat ext4
> crc16 mbcache jbd2 sd_mod crc32c_intel virtio_scsi scsi_mod aesni_intel
> virtio_net mousedev aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd
> microcode firmware_class virtio_pci virtio_ring psmouse virtio i2c_piix4
> i2c_core acpi_cpufreq button evdev sch_fq_codel ip_tables autofs4
> [ 4024.565452] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.1.6-coreos-r1 #2
> [ 4024.565452] Hardware name: Google Google, BIOS Google 01/01/2011
> [ 4024.565452] task: ffffffff81a154c0 ti: ffffffff81a00000 task.ti:
> ffffffff81a00000
> [ 4024.565452] RIP: 0010:[<0000000000000000>]  [<          (null)>]
>     (null)
> [ 4024.565452] RSP: 0018:ffff88021fc03c00  EFLAGS: 00010246
> [ 4024.565452] RAX: ffff880003375d00 RBX: ffff880003375d00 RCX:
> 0000000000000001
> [ 4024.565452] RDX: ffff88000306c000 RSI: 0000000000000000 RDI:
> ffff880003375d00
> [ 4024.565452] RBP: ffff88021fc03c28 R08: 0000000000005608 R09:
> 000000000000bb84
> [ 4024.565452] R10: 0000000000000003 R11: ffff880215a30dc0 R12:
> ffff880214bfb000
> [ 4024.565452] R13: ffff88000306c000 R14: ffff88000306c000 R15:
> 0000000000000008
> [ 4024.565452] FS:  0000000000000000(0000) GS:ffff88021fc00000(0000)
> knlGS:0000000000000000
> [ 4024.565452] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 4024.565452] CR2: 0000000000000000 CR3: 0000000001d92000 CR4:
> 00000000001406f0
> [ 4024.600761] Stack:
> [ 4024.601081]  ffffffff814ac9dc ffff880000000002 ffff88000306c000
> ffff880003375d00
> [ 4024.601081]  ffff88008cbba84e ffff88021fc03c58 ffffffff81486628
> ffff88021690a000
> [ 4024.601081]  ffff88008cbba84e ffff880003375d00 ffff88000306c000
> ffff88021fc03cb8
> [ 4024.601081] Call Trace:
> [ 4024.601081]  <IRQ>
> [ 4024.601081]  [<ffffffff814ac9dc>] ? tcp_v4_early_demux+0x11c/0x160
> [ 4024.601081]  [<ffffffff81486628>] ip_rcv_finish+0xb8/0x360
> [ 4024.601081]  [<ffffffff81486f84>] ip_rcv+0x2a4/0x400
> [ 4024.601081]  [<ffffffff81486570>] ? inet_del_offload+0x40/0x40
> [ 4024.601081]  [<ffffffff81449053>] __netif_receive_skb_core+0x6c3/0x9a0
> [ 4024.601081]  [<ffffffff8143b507>] ? build_skb+0x17/0x90
> [ 4024.601081]  [<ffffffff81449348>] __netif_receive_skb+0x18/0x60
> [ 4024.601081]  [<ffffffff814493c3>] netif_receive_skb_internal+0x33/0xa0
> [ 4024.601081]  [<ffffffff8144944c>] netif_receive_skb_sk+0x1c/0x70
> [ 4024.601081]  [<ffffffffa008772b>] 0xffffffffa008772b
> [ 4024.601081]  [<ffffffff81096cb0>] ? check_preempt_curr+0x80/0xa0
> [ 4024.601081]  [<ffffffffa0087d81>] 0xffffffffa0087d81

Looking at this one, I am still puzzeled where 0xffffffffa008772b and
0xffffffffa008772b comes from ... some driver, bridge ...? Also the call
to inet_del_offload() seems a bit odd. Even in 4.1, there's only one (buggy)
instance that calls inet_del_offload(), which is ipv6_exthdrs_offload_init(),
but IPPROTO_ROUTING shouldn't have much of an effect on the v4 table as
far as I can see. Maybe rather a false positive that address, hmm? Perhaps
some callback/infrastructure vanished underneath us as ip/rip is both null
... maybe due to that also 0xffffffffa008772b / 0xffffffffa008772b don't
resolve?

> [ 4024.601081]  [<ffffffff81449819>] net_rx_action+0x159/0x340
> [ 4024.601081]  [<ffffffff810715f4>] __do_softirq+0xf4/0x290
> [ 4024.601081]  [<ffffffff810719fd>] irq_exit+0xad/0xc0
> [ 4024.601081]  [<ffffffff815527fa>] do_IRQ+0x5a/0xf0
> [ 4024.601081]  [<ffffffff815506ae>] common_interrupt+0x6e/0x6e
> [ 4024.601081]  <EOI>
> [ 4024.601081]  [<ffffffff81059bd6>] ? native_safe_halt+0x6/0x10
> [ 4024.601081]  [<ffffffff8101f17e>] default_idle+0x1e/0xc0
> [ 4024.601081]  [<ffffffff8101fc5f>] arch_cpu_idle+0xf/0x20
> [ 4024.601081]  [<ffffffff810b0ab4>] cpu_startup_entry+0x314/0x3e0
> [ 4024.601081]  [<ffffffff8153bbec>] rest_init+0x7c/0x80
> [ 4024.601081]  [<ffffffff81b130e0>] start_kernel+0x483/0x490
> [ 4024.601081]  [<ffffffff81b12a4d>] ? set_init_arg+0x55/0x55
> [ 4024.601081]  [<ffffffff81b12120>] ? early_idt_handler_array+0x120/0x120
> [ 4024.601081]  [<ffffffff81b125ee>] x86_64_start_reservations+0x2a/0x2c
> [ 4024.601081]  [<ffffffff81b12728>] x86_64_start_kernel+0x138/0x147
> [ 4024.601081] Code:  Bad RIP value.
> [ 4024.601081] RIP  [<          (null)>]           (null)
> [ 4024.601081]  RSP <ffff88021fc03c00>
> [ 4024.601081] CR2: 0000000000000000
> [ 4024.601081] ---[ end trace cdabfe9d7380aaab ]---
> [ 4024.601081] Kernel panic - not syncing: Fatal exception in interrupt
> [ 4024.601081] Kernel Offset: disabled
> [ 4024.601081] Rebooting in 60 seconds..
> [ 4024.601081] ACPI MEMORY or I/O RESET_REG.
