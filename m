From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: "hw csum failure" error on skge driver with 4.3 kernel upon
 receiving ICMPv6 multicast listener discovery packets
Date: Tue, 1 Dec 2015 13:37:03 -0800
Message-ID: <20151201133703.70ab9d06@xeon-e3>
References: <20151115184402.GA6614@achernar.madore.org>
	<CAAxjCEzSzwj+iDKXkqkEcZvcgguOywp2SNErm-zGhFtSpf6TRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Linux Kernel mailing-list <linux-kernel@vger.kernel.org>,
	Linux network mailing-list <netdev@vger.kernel.org>
To: Stefan Ring <stefanrin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAxjCEzSzwj+iDKXkqkEcZvcgguOywp2SNErm-zGhFtSpf6TRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Dec 2015 22:07:45 +0100
Stefan Ring <stefanrin@gmail.com> wrote:

> On Sun, Nov 15, 2015 at 7:44 PM, David Madore <david+ml@madore.org> wrote:
> > The skge driver in the 4.3 kernel reports hardware checksum errors
> > upon receiving (certain?) IPv6 multicast packets containing ICMPv6
> > multicast listener discovery messages.  This is a regression since 4.1
> > (I believe between 4.1 and 4.2).  The e1000e driver on a different
> > Ethernet port of the same machine is not affected.  Disabling offload
> > rx checksumming suppresses the errors.  Nor are all IPv6 multicast
> > packets affected: for some reason, it seems only those containing
> > ICMPv6 multicast listener discovery messages trigger the problem.
> >
> > In case it also matters, the skge interface in question (eth1 in what
> > follows) is part of a bridge that contains another Ethernet interface
> > and a Wifi card.
> >
> > Here is a frame, with its link-level headers, that caused an error
> > when received by skge:
> >
> > 0000   33 33 ff 62 30 d8 60 fb 42 f1 b1 36 86 dd 60 00  33.b0.`.B..6..`.
> > 0010   00 00 00 20 00 01 fe 80 00 00 00 00 00 00 62 fb  ... ..........b.
> > 0020   42 ff fe f1 b1 36 ff 02 00 00 00 00 00 00 00 00  B....6..........
> > 0030   00 01 ff 62 30 d8 3a 00 01 00 05 02 00 00 83 00  ...b0.:.........
> > 0040   c9 8a 00 00 00 00 ff 02 00 00 00 00 00 00 00 00  ................
> > 0050   00 01 ff 62 30 d8                                ...b0.
> >
> > (Network dumps performed on another network device suggest that the
> > checksum is, indeed, correct.)
> >
> > And here is the syslog produced upon receiving the above packet:
> >
> > Nov 15 17:52:13 pleiades kernel: [  661.393163] eth1: hw csum failure
> > Nov 15 17:52:13 pleiades kernel: [  661.394203] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.3.0-pleiades #1
> > Nov 15 17:52:13 pleiades kernel: [  661.395192] Hardware name: System manufacturer System Product Name/P5WD2-Premium, BIOS 0709     03/31/2006
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  ffff88013a9d5d00 ffff88013fc03aa8 ffffffff8129a186 ffff88013afe0000
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  ffff88013fc03ac0 ffffffff81436425 0000000000000000 ffff88013fc03af0
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  ffffffff8142b87a 1027316b3fc03b30 ffff88013a9d5d00 0000000000000030
> > Nov 15 17:52:13 pleiades kernel: [  661.395192] Call Trace:
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  <IRQ>  [<ffffffff8129a186>] dump_stack+0x44/0x5e
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff81436425>] netdev_rx_csum_fault+0x35/0x40
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff8142b87a>] __skb_checksum_complete+0xca/0xd0
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff815062db>] ipv6_mc_validate_checksum+0xab/0x140
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff8142858f>] skb_checksum_trimmed+0x8f/0x180
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff81506475>] ipv6_mc_check_mld+0x105/0x330
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffffa0d2840c>] br_multicast_rcv+0x8c/0xce0 [bridge]
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff814364d3>] ? __netif_receive_skb+0x13/0x60
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff8143654e>] ? netif_receive_skb_internal+0x2e/0x90
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffffa0d2006c>] br_handle_frame_finish+0x28c/0x5b0 [bridge]
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffffa00217e4>] ? usb_hcd_submit_urb+0xa4/0x960 [usbcore]
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffffa0d204e1>] br_handle_frame+0x151/0x270 [bridge]
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffffa0023092>] ? usb_submit_urb+0x2d2/0x510 [usbcore]
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff81433c82>] __netif_receive_skb_core+0x1c2/0x990
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffffa0020472>] ? __usb_hcd_giveback_urb+0x82/0xe0 [usbcore]
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff814364d3>] __netif_receive_skb+0x13/0x60
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff8143654e>] netif_receive_skb_internal+0x2e/0x90
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff81436d70>] napi_gro_receive+0xa0/0xd0
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffffa01cecc0>] skge_poll+0x380/0x7a0 [skge]
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff81032438>] ? lapic_next_event+0x18/0x20
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff81437cec>] net_rx_action+0x13c/0x300
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff8104fef7>] __do_softirq+0xc7/0x240
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff81050240>] irq_exit+0x70/0x90
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff810060b1>] do_IRQ+0x51/0xd0
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff8151ee7c>] common_interrupt+0x7c/0x7c
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  <EOI>  [<ffffffff8100da47>] ? mwait_idle+0x87/0x140
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff8100dffa>] arch_cpu_idle+0xa/0x10
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff81081f45>] default_idle_call+0x25/0x30
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff8108223c>] cpu_startup_entry+0x29c/0x310
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff815194e2>] rest_init+0x72/0x80
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff817db00f>] start_kernel+0x471/0x47e
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff817da989>] ? set_init_arg+0x55/0x55
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff817da5ad>] x86_64_start_reservations+0x2a/0x2c
> > Nov 15 17:52:13 pleiades kernel: [  661.395192]  [<ffffffff817da694>] x86_64_start_kernel+0xe5/0xe8
> >
> 
> I have basically the same issue starting with v4.2, with the sky2 driver.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=1266601

Same symptom and once again it is not the drivers fault.
It is somewhere in the tunnel path not using postpull_rcsum
