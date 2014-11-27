From: "=?UTF-8?B?0JTQtdC90LjRgdC60LAt0YDQtdC00LjRgdC60LA=?="
	<slim@inbox.lv>
Subject: Re: bug in networking code causes GPF
Date: Thu, 27 Nov 2014 17:41:50 +0200
Message-ID: <1417102910.5477463ec9948@mail.inbox.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com, fw@strlen.de
To: "Daniel Borkmann" <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

well, I will try to disable CONFIG_PAX_MEMORY_SANITIZE.
Will take some time to make sure that this resolve the issue

=D0=A6=D0=B8=D1=82=D0=B8=D1=80=D0=BE=D0=B2=D0=B0=D0=BD=D0=B8=D0=B5 Dani=
el Borkmann <dborkman@redhat.com> :
> On 11/27/2014 02:35 PM, =D0=94=D0=B5=D0=BD=D0=B8=D1=81=D0=BA=D0=B0-=D1=
=80=D0=B5=D0=B4=D0=B8=D1=81=D0=BA=D0=B0 wrote:
> > hello,
> >
> > i run ipvs DR on 2 servers under heavy load - up to 1Gbps of traffi=
c.
> > Time to time the server where ipvs runs master IP (VIP) get general=
 protection fault. Switching master to another server make no differenc=
e - after some time GPF come. So I assume it is not hardware issue.
> >
> > There are logs from both servers with different kernels (i run kern=
el with grsecurity patch set from Gentoo hardened portage tree):

> Hmm, looks pretty much like ...

> http://thread.gmane.org/gmane.comp.security.firewalls.netfilter.devel=
/54903

> ... which was a bug in the grsec patch set.

> Does your grsec kernel have:

> commit 0fa213cce614ad25a79acbd06f37f1e9022134d9
> Author: Brad Spengler <spender@grsecurity.net>
> Date: Fri Oct 31 17:29:20 2014 -0400

> From: Mathias Krause <minipli@googlemail.com>
> To: PaX Team <pageexec@freemail.hu>
> Cc: Brad Spengler <spender@grsecurity.net>, Mathias Krause
> <minipli@googlemail.com>
> Subject: [PATCH] pax: don't sanitize RCU slab caches

> We cannot sanitize SLAB_DESTROY_BY_RCU slab caches in kmem_cache_free=
()
> as there might be readers in this RCU period, wanting to access the
> object.

> Fix this, for now, by marking those with SLAB_NO_SANITIZE. Hopefully =
we
> can have a real fix later on. But this should fix the RCU stalls and
> netfilter conntrack related problems.

> This patch should go on top of the previous patch.

> Signed-off-by: Mathias Krause <minipli@googlemail.com>

> > [354497.931834] general protection fault: 0000 [#1] SMP
> > [354497.931903] CPU: 14 PID: 0 Comm: swapper/14 Not tainted 3.13.10=
-hardened.standart.20140515 #1
> > [354497.931993] Hardware name: Supermicro H8DG6/H8DGi/H8DG6/H8DGi, =
BIOS 3.5 11/25/2013
> > [354497.932082] task: ffff88021e4b2ca0 ti: ffff88021e4b3100 task.ti=
: ffff88021e4b3100
> > [354497.932167] RIP: 0010:[<ffffffff81653ca2>] [<ffffffff81653ca2>]=
 ffffffff81653ca2
> > [354497.932278] RSP: 0000:ffff88021fd03b98 EFLAGS: 00010246
> > [354497.932330] RAX: 0000000000013ba0 RBX: fefefefefefefefe RCX: 00=
0000000001bc30
> > [354497.932413] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00=
00000000000000
> > [354497.932497] RBP: ffff88021fd03c40 R08: 00000000cacb7f0b R09: ff=
ff88021fd03c58
> > [354497.932580] R10: ffffffffffffffff R11: ffff88041de33280 R12: 80=
00000000000000
> > [354497.932663] R13: 0000000000003786 R14: ffffffff81a82540 R15: 00=
00000000000000
> > [354497.932749] FS: 000003853a8a7740(0000) GS:ffff88021fd00000(0000=
) knlGS:0000000000000000
> > [354497.932836] CS: 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [354497.932891] CR2: 000003d8a933b2d0 CR3: 000000000174a000 CR4: 00=
000000000407f0
> > [354497.932973] Stack:
> > [354497.933013] 0000000000000000 ffffffff81a82540 00000000de1b1efe =
0000000000000000
> > [354497.933110] ffff88021fd03c40 ffffffff81653f6d ffffffff81a92cc0 =
ffffffff81a82540
> > [354497.933206] ffff88041d70c500 0000000000000000 00000000de1b1efe =
ffffffff81654f6c
> > [354497.933304] Call Trace:
> > [354497.933347] <IRQ>
> > [354497.933357] [<ffffffff81653f6d>] ? __nf_conntrack_find_get+0x28=
/0x13b
> > [354497.933484] [<ffffffff81654f6c>] ? nf_conntrack_in+0x253/0x73e
> > [354497.933544] [<ffffffff8164eeb6>] ? nf_iterate+0x40/0x7d
> > [354497.933601] [<ffffffff816a90a4>] ? inet_del_offload+0x39/0x39
> > [354497.933658] [<ffffffff8164ef5f>] ? nf_hook_slow+0x6c/0x104
> > [354497.933714] [<ffffffff816a90a4>] ? inet_del_offload+0x39/0x39
> > [354497.933770] [<ffffffff816a98c8>] ? ip_rcv+0x313/0x35f
> > [354497.933824] [<ffffffff816a93d1>] ? ip_local_deliver_finish+0xb8=
/0x11f
> > [354497.933885] [<ffffffff81627dfd>] ? __netif_receive_skb_core+0x4=
4d/0x4e2
> > [354497.933944] [<ffffffff8162afba>] ? netif_receive_skb+0x4c/0x81
> > [354497.934000] [<ffffffff8162b488>] ? napi_gro_receive+0x35/0x7a
> > [354497.934058] [<ffffffff81515ddc>] ? igb_poll+0xa49/0xd13
> > [354497.934115] [<ffffffff810ce5b1>] ? __wake_up+0x38/0x49
> > [354497.934169] [<ffffffff8162b773>] ? net_rx_action+0xa6/0x172
> > [354497.934225] [<ffffffff810a31cc>] ? __do_softirq+0xb9/0x1ae
> > [354497.934280] [<ffffffff810a3499>] ? irq_exit+0x37/0x7a
> > [354497.934335] [<ffffffff81003ce2>] ? do_IRQ+0x96/0xb0
> > [354497.934389] [<ffffffff81725a97>] ? common_interrupt+0x97/0x97
> > [354497.934441] <EOI>
> > [354497.934451] [<ffffffff810e3080>] ? update_ts_time_stats+0x30/0x=
76
> > [354497.934548] [<ffffffff81009d20>] ? arch_remove_reservations+0x6=
a/0x6a
> > [354497.934607] [<ffffffff81009d23>] ? default_idle+0x3/0x9
> > [354497.934676] [<ffffffff8100a333>] ? arch_cpu_idle+0x6/0x1e
> > [354497.934732] [<ffffffff81009d20>] ? arch_remove_reservations+0x6=
a/0x6a
> > [354497.934791] [<ffffffff810d434a>] ? cpu_startup_entry+0xe9/0x15b
> > [354497.934850] [<ffffffff81024ccf>] ? start_secondary+0x2f9/0x32c
> > [354497.934903] Code: c2 85 d2 49 8b 86 d0 04 00 00 74 14 66 45 85 =
ff 75 0e 65 ff 40 04 e8 85 f6 a4 ff 48 89 d8 eb 69 65 ff 00 48 8b 1b f6=
 c3 01 75 0f <8b> 43 10 39 45 00 b8 00 00 00 00 74 83 eb 9d 48 d1 eb 4c=
 39 eb
> > [354497.935402] RIP [<ffffffff81653ca2>] ffffffff81653ca2
> > [354497.935456] RSP <ffff88021fd03b98>
> > [354497.935965] ---[ end trace 7d6f660245b2d541 ]---
> > [354497.936080] Kernel panic - not syncing: Fatal exception in inte=
rrupt
> > [354498.016801] Rebooting in 10 seconds.
> >
> >
> > [674944.621564] general protection fault: 0000 [#1] SMP
> > [674944.621637] CPU: 12 PID: 17984 Comm: nginx Not tainted 3.15.10-=
hardened-r1.standart.20140925 #1
> > [674944.621728] Hardware name: Supermicro H8DG6/H8DGi/H8DG6/H8DGi, =
BIOS 3.5 11/25/2013
> > [674944.621817] task: ffff88021e1d7700 ti: ffff88021e1d7c68 task.ti=
: ffff88021e1d7c68
> > [674944.621903] RIP: 0010:[<ffffffff816f2be8>] [<ffffffff816f2be8>]=
 ffffffff816f2be8
> > [674944.621990] RSP: 0000:ffff88021fc03ce8 EFLAGS: 00010246
> > [674944.622057] RAX: ffffc90011901000 RBX: 822098c2102098c2 RCX: 00=
0000005823edca
> > [674944.622143] RDX: fefefefefefefefe RSI: 000000009e90f1ad RDI: ff=
ffffff81a8ad40
> > [674944.622226] RBP: 000000000050abb3 R08: 000000000050abb3 R09: 00=
0000000001f106
> > [674944.622310] R10: ffffea00100cbd80 R11: ffffea00100cbd80 R12: 80=
00000000000000
> > [674944.622394] R13: ffffffff81a8ad40 R14: 0000000049c3f106 R15: ff=
ffc900119f9830
> > [674944.622479] FS: 0000029d6fd04740(0000) GS:ffff88021fc00000(0000=
) knlGS:0000000000000000
> > [674944.622566] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [674944.622619] CR2: ffffffffff600400 CR3: 0000000001787000 CR4: 00=
000000000407f0
> > [674944.622701] Stack:
> > [674944.622741] ffffffff816e9360 ffffffff00000050 ffffffff822098c2 =
abb3000280000000
> > [674944.622839] ffff88006e9c2b00 ffff88011cbd1bce ffff88021e0c0000 =
0000000000000008
> > [674944.622935] ffffffff81a955b0 ffffffff8170920a ffff880100000003 =
0000000000000008
> > [674944.623031] Call Trace:
> > [674944.623077] <IRQ>
> > [674944.623087] [<ffffffff816e9360>] ? inet_del_offload+0x39/0x39
> > [674944.623192] [<ffffffff8170920a>] ? tcp_v4_early_demux+0x14c/0x1=
bd
> > [674944.623250] [<ffffffff816e93b0>] ? ip_rcv_finish+0x50/0x2c1
> > [674944.623326] [<ffffffff8165ee92>] ? __netif_receive_skb_core+0x3=
c8/0x456
> > [674944.623386] [<ffffffff8165f10c>] ? netif_receive_skb_internal+0=
x4c/0x81
> > [674944.623447] [<ffffffff816623b3>] ? napi_gro_receive+0x36/0x7c
> > [674944.623511] [<ffffffff815485a5>] ? igb_poll+0xa8b/0xd5b
> > [674944.623572] [<ffffffff810f7fda>] ? __note_gp_changes+0x31/0x61
> > [674944.623630] [<ffffffff816626cf>] ? net_rx_action+0xa6/0x172
> > [674944.623688] [<ffffffff810bc995>] ? __do_softirq+0xf6/0x1fb
> > [674944.623744] [<ffffffff810bcbf4>] ? irq_exit+0x38/0x7c
> > [674944.623798] [<ffffffff81003ce3>] ? do_IRQ+0xb3/0xce
> > [674944.623853] [<ffffffff81767217>] ? common_interrupt+0x97/0x97
> > [674944.623906] <EOI>
> > [674944.623917] Code: 6a d4 75 0e 48 39 5a c8 74 51 eb 06 3b 44 24 =
50 74 50 4c 89 4c 24 08 e8 e8 fe ff ff 4c 8b 4c 24 08 eb 83 48 8b 12 f6=
 c2 01 75 0b <44> 39 72 d0 75 f2 e9 75 ff ff ff 48 d1 ea 4c 39 ca 0f 85=
 64 ff
> > [674944.624456] RIP [<ffffffff816f2be8>] ffffffff816f2be8
> > [674944.624536] RSP <ffff88021fc03ce8>
> > [674944.625020] ---[ end trace 8035e2b5322bab00 ]---
> > [674944.625126] Kernel panic - not syncing: Fatal exception in inte=
rrupt
> > [674944.706563] Kernel Offset: 0x0 from 0xffffffff81000000 (relocat=
ion range: 0xffffffff80000000-0xffffffff9fffffff)
> > [674944.706711] Rebooting in 10 seconds.
> >
> >
> > [7523332.314991] general protection fault: 0000 [#1] SMP
> > [7523332.315078] CPU: 4 PID: 25432 Comm: nginx Not tainted 3.15.8-h=
ardened.standart.20140901 #1
> > [7523332.315172] Hardware name: Supermicro H8DG6/H8DGi/H8DG6/H8DGi,=
 BIOS 3.0 09/10/2012
> > [7523332.315266] task: ffff88041eb98000 ti: ffff88041eb98568 task.t=
i: ffff88041eb98568
> > [7523332.315355] RIP: 0010:[<ffffffff8168db79>] [<ffffffff8168db79>=
] ffffffff8168db79
> > [7523332.315446] RSP: 0018:ffff88021fa03bf8 EFLAGS: 00010246
> > [7523332.316983] RAX: 00000000000149c0 RBX: ffffffff81a8ac80 RCX: 0=
0000000000011d5
> > [7523332.317070] RDX: 0000000000000000 RSI: 0000000000008ea8 RDI: f=
fffffff81a8acfe
> > [7523332.317187] RBP: ffff88021fa03c5c R08: 00000000b96542ae R09: f=
fff88021fa03c74
> > [7523332.317274] R10: 0000000000000002 R11: ffff880238b8ce00 R12: 8=
000000000000000
> > [7523332.317360] R13: fefefefefefefefe R14: 0000000000000000 R15: 0=
000000047567b68
> > [7523332.317448] FS: 0000031d200c5740(0000) GS:ffff88021fa00000(000=
0) knlGS:0000000000000000
> > [7523332.317538] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [7523332.317594] CR2: 000004373dcef000 CR3: 0000000001779000 CR4: 0=
0000000000007f0
> > [7523332.317679] Stack:
> > [7523332.317722] 0000000000000000 ffffffff81a8ac80 ffff880003e08200=
 0000000000000000
> > [7523332.317824] ffffffff81a9bf60 ffffffff8168ef87 ffffffff81a9bf60=
 ffffffff81a96970
> > [7523332.317925] 0000000047567b68 ffffffff81a96970 0000000281a90002=
 0000000000000014
> > [7523332.318026] Call Trace:
> > [7523332.318072] <IRQ>
> > [7523332.318085] [<ffffffff8168ef87>] ? nf_conntrack_in+0x2c1/0x846
> > [7523332.318199] [<ffffffff81688956>] ? nf_iterate+0x41/0x81
> > [7523332.318259] [<ffffffff816ea4b8>] ? inet_del_offload+0x39/0x39
> > [7523332.318321] [<ffffffff81688a0c>] ? nf_hook_slow+0x76/0x111
> > [7523332.318393] [<ffffffff816ea4b8>] ? inet_del_offload+0x39/0x39
> > [7523332.318453] [<ffffffff816eacf2>] ? ip_rcv+0x2f4/0x356
> > [7523332.318512] [<ffffffff81660173>] ? __netif_receive_skb_core+0x=
3d9/0x410
> > [7523332.318575] [<ffffffff8166039c>] ? netif_receive_skb_internal+=
0x6d/0x77
> > [7523332.318640] [<ffffffff816634c1>] ? napi_gro_receive+0x36/0x7c
> > [7523332.318702] [<ffffffff8154a30d>] ? igb_poll+0xa46/0xd09
> > [7523332.318762] [<ffffffff813bbd0d>] ? __list_add+0x1b/0x37
> > [7523332.318820] [<ffffffff816637d2>] ? net_rx_action+0xa0/0x171
> > [7523332.318882] [<ffffffff810bcb7a>] ? __do_softirq+0xf7/0x1fa
> > [7523332.318943] [<ffffffff8176a29c>] ? do_softirq_own_stack+0x1c/0=
x30
> > [7523332.318999] <EOI>
> > [7523332.319013] [<ffffffff810bcccb>] ? do_softirq+0x24/0x2c
> > [7523332.319112] [<ffffffff810bcd39>] ? __local_bh_enable_ip+0x66/0=
x74
> > [7523332.319174] [<ffffffff8172f029>] ? ipt_do_table+0x5c6/0x5f0
> > [7523332.319235] [<ffffffff81688956>] ? nf_iterate+0x41/0x81
> > [7523332.319293] [<ffffffff816ed488>] ? ip_options_rcv_srr+0x1c7/0x=
1c7
> > [7523332.319354] [<ffffffff81688a0c>] ? nf_hook_slow+0x76/0x111
> > [7523332.319412] [<ffffffff816ed488>] ? ip_options_rcv_srr+0x1c7/0x=
1c7
> > [7523332.319473] [<ffffffff816ee3a2>] ? __ip_local_out+0x64/0x6e
> > [7523332.319533] [<ffffffff8164f4a3>] ? __sk_dst_check+0x34/0x63
> > [7523332.319617] [<ffffffff816ee3be>] ? ip_local_out_sk+0x12/0x39
> > [7523332.319676] [<ffffffff816eea83>] ? ip_queue_xmit+0x2ab/0x2db
> > [7523332.319739] [<ffffffff81703a1e>] ? tcp_transmit_skb+0x6eb/0x73=
5
> > [7523332.319801] [<ffffffff81704323>] ? tcp_write_xmit+0x82e/0x969
> > [7523332.319861] [<ffffffff816f7278>] ? tcp_sendpage+0x50b/0x5e4
> > [7523332.319923] [<ffffffff811845e9>] ? direct_splice_actor+0x49/0x=
49
> > [7523332.319986] [<ffffffff8171a807>] ? inet_sendpage+0xbc/0xe0
> > [7523332.320045] [<ffffffff8164eacc>] ? kernel_sendpage+0x49/0x59
> > [7523332.320104] [<ffffffff8164eb23>] ? sock_sendpage+0x47/0x53
> > [7523332.320163] [<ffffffff81184658>] ? pipe_to_sendpage+0x6f/0x7c
> > [7523332.320223] [<ffffffff81185aa8>] ? splice_from_pipe_feed+0x7f/=
0x10e
> > [7523332.320285] [<ffffffff811845e9>] ? direct_splice_actor+0x49/0x=
49
> > [7523332.320347] [<ffffffff81185c2e>] ? __splice_from_pipe+0x3a/0x6=
b
> > [7523332.320408] [<ffffffff81185dff>] ? splice_from_pipe+0x66/0x87
> > [7523332.320468] [<ffffffff811845e9>] ? direct_splice_actor+0x49/0x=
49
> > [7523332.320533] [<ffffffff811845df>] ? direct_splice_actor+0x3f/0x=
49
> > [7523332.320599] [<ffffffff811860f5>] ? splice_direct_to_actor+0xd3=
/0x18d
> > [7523332.320661] [<ffffffff811845a0>] ? generic_pipe_buf_nosteal+0x=
c/0xc
> > [7523332.320723] [<ffffffff81186249>] ? do_splice_direct+0x9a/0xb6
> > [7523332.320783] [<ffffffff8115e7f2>] ? do_sendfile+0x182/0x32a
> > [7523332.320856] [<ffffffff811602bd>] ? SyS_sendfile64+0x137/0x1bc
> > [7523332.320916] [<ffffffff81768f37>] ? system_call_fastpath+0x16/0=
x1b
> > [7523332.320972] Code: 00 02 00 00 48 c7 c7 4d db 68 81 65 ff 40 04=
 e8 71 f1 a2 ff 4d 85 ed 75 58 e9 94 01 00 00 65 ff 00 4d 8b 6d 00 41 f=
6 c5 01 75 18 <41> 8b 55 10 31 c0 39 55 00 41 8a 7d 37 0f 85 14 ff ff f=
f e9 e7
> > [7523332.321522] RIP [<ffffffff8168db79>] ffffffff8168db79
> > [7523332.321579] RSP <ffff88021fa03bf8>
> > [7523332.322094] ---[ end trace 0e21b79561002306 ]---
> > [7523332.322210] Kernel panic - not syncing: Fatal exception in int=
errupt
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at http://vger.kernel.org/majordomo-info.html
>
