From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/bonding: stack-out-of-bounds in bond_enslave
Date: Thu, 20 Apr 2017 14:46:55 -0700
Message-ID: <CAM_iQpUvPtAyjbope=zShOTLEUOGkGbUW4VGx0jAp4it_2g8Ng@mail.gmail.com>
References: <CAAeHK+zNAbwp3MNOq1WUSxHw2Yx-K=v1KzJH38dY=A88gFsbAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+zNAbwp3MNOq1WUSxHw2Yx-K=v1KzJH38dY=A88gFsbAg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2017 at 9:32 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On linux-next commit 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3 (4.11-rc7).
>
> A reproducer and .config are attached.
>
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in bond_enslave+0xe0a/0x4ef0 at addr
> ffff8800666b7792
> Write of size 16 by task a.out/3894
> page:ffffea000199adc0 count:0 mapcount:0 mapping:          (null) index:0x0
> flags: 0x100000000000000()
> raw: 0100000000000000 0000000000000000 0000000000000000 00000000ffffffff
> raw: 0000000000000000 ffffea000199ade0 0000000000000000 0000000000000000
> page dumped because: kasan: bad access detected
> CPU: 1 PID: 3894 Comm: a.out Not tainted 4.11.0-rc7+ #251
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16
>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>  kasan_report_error mm/kasan/report.c:212
>  kasan_report+0x4d8/0x510 mm/kasan/report.c:347
>  check_memory_region_inline mm/kasan/kasan.c:326
>  check_memory_region+0x139/0x190 mm/kasan/kasan.c:333
>  memcpy+0x37/0x50 mm/kasan/kasan.c:369
>  bond_enslave+0xe0a/0x4ef0 drivers/net/bonding/bond_main.c:1491
>  bond_do_ioctl+0xb5d/0xec0 drivers/net/bonding/bond_main.c:3449
>  dev_ifsioc+0x53f/0x9f0 net/core/dev_ioctl.c:338
>  dev_ioctl+0x249/0x1160 net/core/dev_ioctl.c:532
>  sock_do_ioctl+0x94/0xb0 net/socket.c:913
>  sock_ioctl+0x28f/0x440 net/socket.c:1004
>  vfs_ioctl fs/ioctl.c:45
>  do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
>  SYSC_ioctl fs/ioctl.c:700
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691

IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len
but in many places we use struct sockaddr to set dev addr,
whose ->sa_data only has 14 bytes...
