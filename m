From: Bandan Das <bandan.das@stratus.com>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Tue, 31 Aug 2010 09:50:07 -0400
Message-ID: <20100831135007.GD10754@stratus.com>
References: <20100830200917.GA10754@stratus.com>
 <1283204118.2405.32.camel@edumazet-laptop>
 <20100830232147.GB10754@stratus.com>
 <1283232031.2405.38.camel@edumazet-laptop>
 <20100831082444.GB29281@gondor.apana.org.au>
 <1283246271.2550.35.camel@edumazet-laptop>
 <20100831123641.GA31017@gondor.apana.org.au>
 <1283260409.2550.87.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283260409.2550.87.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On  0, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le mardi 31 ao=C3=BBt 2010 =C3=A0 20:36 +0800, Herbert Xu a =C3=A9cri=
t :
> > On Tue, Aug 31, 2010 at 11:17:51AM +0200, Eric Dumazet wrote:
> > >
> > > Once again, the IP stack -> bridge -> IP stack flow bites us,
> > > because bridge likes to dirty IPCB.
> >=20
> > OK, so we're talking about a locally transmitted packet, with
> > IP options leaving the IP stack, entering bridging, and then
> > reentering the IP stack?
> >=20
> > In that case the packet should no longer be treated as an IP
> > packet when it enters the bridge.  So if it did have options
> > and we want to support that in bridging then we need to parse
> > IP options there as my comment suggested.
>=20
> Bandan did not provide a full stack trace,
> but I believe the problem was :
>=20
> br_nf_dev_queue_xmit() -> ip_fragment -> icmp_send() ->
> ip_options_echo() : crash, because ip_options_echo take bridge CB as
> IPCB data.
>=20
> http://www.spinics.net/lists/netdev/msg139370.html
>=20

That flow is correct. Sorry about the stack trace, it's now pasted=20
below. But I am still wondering : Why not make sure in ip_fragment()
that we do not have a corrupt CB ? Today, it's the bridge, tomorrow it =
will be=20
someone else that would be doing this.


08-31 09:38:23 [root@kvm ~]# Kernel panic - not syncing: stack-protecto=
r: Kernel stack is corrupted in: ffffffff8146dd13
08-31 09:38:32=20
08-31 09:38:32 Pid: 3209, comm: qemu-kvm Not tainted 2.6.32-63.el6.bdas=
=2Ex86_64 #1
08-31 09:38:32 Call Trace:
08-31 09:38:32 <IRQ>=20
08-31 09:38:32 Message from  [<ffffffff814c7fa5>] panic+0x78/0x137
08-31 09:38:32 syslogd@kvm at A [<ffffffff8146dd13>] ? icmp_send+0x743/=
0x780
08-31 09:38:32 ug 31 09:38:59 . [<ffffffff8106b30b>] __stack_chk_fail+0=
x1b/0x30
08-31 09:38:32 ..
08-31 09:38:32  kernel:Ker [<ffffffff8146dd13>] icmp_send+0x743/0x780
08-31 09:38:32 nel panic - not  [<ffffffffa03b9fe0>] ? br_nf_dev_queue_=
xmit+0x0/0x90 [bridge]
08-31 09:38:32 syncing: stack-p [<ffffffffa03b4400>] ? br_dev_queue_pus=
h_xmit+0x0/0xa0 [bridge]
08-31 09:38:32 rotector: Kernel [<ffffffff81436944>] ? nf_hook_slow+0x7=
4/0x100
08-31 09:38:32  stack is corrup [<ffffffffa03ba060>] ? br_nf_dev_queue_=
xmit+0x80/0x90 [bridge]
08-31 09:38:32 ted in: ffffffff [<ffffffffa03baa90>] ? br_nf_post_routi=
ng+0x1d0/0x280 [bridge]
08-31 09:38:32 8146dd13
08-31 09:38:32=20
08-31 09:38:32 M [<ffffffff8143688c>] ? nf_iterate+0x6c/0xb0
08-31 09:38:32 essage from sysl [<ffffffffa03b4400>] ? br_dev_queue_pus=
h_xmit+0x0/0xa0 [bridge]
08-31 09:38:32 ogd@kvm at Aug 3 [<ffffffff81436944>] ? nf_hook_slow+0x7=
4/0x100
08-31 09:38:32 1 09:38:59 ... [<ffffffffa03b4400>] ? br_dev_queue_push_=
xmit+0x0/0xa0 [bridge]
08-31 09:38:32=20
08-31 09:38:32  kernel:
08-31 09:38:32  [<ffffffffa03b44a0>] ? br_forward_finish+0x0/0x60 [brid=
ge]
08-31 09:38:32  [<ffffffffa03b44e3>] ? br_forward_finish+0x43/0x60 [bri=
dge]
08-31 09:38:32  [<ffffffffa03ba638>] ? br_nf_forward_finish+0x128/0x140=
 [bridge]
08-31 09:38:32  [<ffffffffa03bbb00>] ? br_nf_forward_ip+0x310/0x3c0 [br=
idge]
08-31 09:38:32  [<ffffffff8143688c>] ? nf_iterate+0x6c/0xb0
08-31 09:38:32  [<ffffffffa03b44a0>] ? br_forward_finish+0x0/0x60 [brid=
ge]
08-31 09:38:32  [<ffffffff81436944>] ? nf_hook_slow+0x74/0x100
08-31 09:38:32  [<ffffffffa03b44a0>] ? br_forward_finish+0x0/0x60 [brid=
ge]
08-31 09:38:32  [<ffffffffa03b4572>] ? __br_forward+0x72/0xc0 [bridge]
08-31 09:38:32  [<ffffffffa03b461d>] ? br_forward+0x5d/0x70 [bridge]
08-31 09:38:32  [<ffffffffa03b5359>] ? br_handle_frame_finish+0x129/0x2=
60 [bridge]
08-31 09:38:32  [<ffffffffa03baf88>] ? br_nf_pre_routing_finish+0x228/0=
x340 [bridge]
08-31 09:38:32  [<ffffffff81436944>] ? nf_hook_slow+0x74/0x100
08-31 09:38:32  [<ffffffffa03bad60>] ? br_nf_pre_routing_finish+0x0/0x3=
40 [bridge]
08-31 09:38:32  [<ffffffffa03bb4ef>] ? br_nf_pre_routing+0x44f/0x750 [b=
ridge]
08-31 09:38:32  [<ffffffff8143688c>] ? nf_iterate+0x6c/0xb0
08-31 09:38:32  [<ffffffffa03b5230>] ? br_handle_frame_finish+0x0/0x260=
 [bridge]
08-31 09:38:32  [<ffffffff81436944>] ? nf_hook_slow+0x74/0x100
08-31 09:38:32  [<ffffffffa03b5230>] ? br_handle_frame_finish+0x0/0x260=
 [bridge]
08-31 09:38:32  [<ffffffffa03b561c>] ? br_handle_frame+0x18c/0x250 [bri=
dge]
08-31 09:38:32  [<ffffffff8140f5e3>] ? netif_receive_skb+0x1c3/0x670
08-31 09:38:32  [<ffffffff81094962>] ? enqueue_hrtimer+0x82/0xd0
08-31 09:38:32  [<ffffffff8140fb13>] ? process_backlog+0x83/0xe0
08-31 09:38:32  [<ffffffff81410333>] ? net_rx_action+0x103/0x210
08-31 09:38:32  [<ffffffff81073597>] ? __do_softirq+0xb7/0x1e0
08-31 09:38:32  [<ffffffff810142cc>] ? call_softirq+0x1c/0x30
08-31 09:38:32  <EOI>  [<ffffffff81015f35>] ? do_softirq+0x65/0xa0
08-31 09:38:32  [<ffffffff814143a8>] ? netif_rx_ni+0x28/0x30
08-31 09:38:32  [<ffffffffa01bf445>] ? tun_chr_aio_write+0x295/0x580 [t=
un]
08-31 09:38:32  [<ffffffffa01bf1b0>] ? tun_chr_aio_write+0x0/0x580 [tun=
]
08-31 09:38:33  [<ffffffff8116c63b>] ? do_sync_readv_writev+0xfb/0x140
08-31 09:38:33  [<ffffffff810916d0>] ? autoremove_wake_function+0x0/0x4=
0
08-31 09:38:33  [<ffffffff8120c51f>] ? selinux_file_permission+0xbf/0x1=
50
08-31 09:38:33  [<ffffffff811ff936>] ? security_file_permission+0x16/0x=
20
08-31 09:38:33  [<ffffffff8116d6ff>] ? do_readv_writev+0xcf/0x1f0
08-31 09:38:33  [<ffffffff8117f94a>] ? do_vfs_ioctl+0x3aa/0x580
08-31 09:38:33  [<ffffffff8116d866>] ? vfs_writev+0x46/0x60
08-31 09:38:33  [<ffffffff8116d991>] ? sys_writev+0x51/0xb0
08-31 09:38:33  [<ffffffff81013172>] ? system_call_fastpath+0x16/0x1b
--=20


Bandan
