From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: 6pack: stack-out-of-bounds in sixpack_receive_buf
Date: Sat, 3 Sep 2016 15:38:40 +0200
Message-ID: <CACT4Y+bhAODvzqOxQps+4y6xSRBXC7pr18wRA+bb26c2XgPFhA@mail.gmail.com>
References: <CACT4Y+ZXH227Gbwrr+dUN4WSFNsoSECYd-KaZyLJ8F0KCRWRBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Peter Hurley <peter@hurleysoftware.com>,
        Jiri Slaby <jslaby@suse.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Andreas Koensgen <ajk@comnets.uni-bremen.de>,
        linux-hams@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ZXH227Gbwrr+dUN4WSFNsoSECYd-KaZyLJ8F0KCRWRBw@mail.gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

While running syzkaller fuzzer I've got the following report:

BUG: KASAN: stack-out-of-bounds in sixpack_receive_buf+0xf8a/0x1450 at
addr ffff880037fbf850
Read of size 1 by task syz-executor/6759
page:ffffea0000dfefc0 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x1fffc0000000000()
page dumped because: kasan: bad access detected
CPU: 3 PID: 6759 Comm: syz-executor Not tainted 4.8.0-rc3-next-20160825+ #8
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff886b6fe0 ffff880037fbf520 ffffffff82db38d9 ffffffff37fbf5b0
 fffffbfff10d6dfc ffff880037fbf5b0 ffff880037fbf850 ffff880037fbf850
 ffff880037d3f180 dffffc0000000000 ffff880037fbf5a0 ffffffff8180a383
Call Trace:
 [<ffffffff8180a3ee>] __asan_report_load1_noabort+0x3e/0x40
mm/kasan/report.c:319
 [<     inline     >] sixpack_decode drivers/net/hamradio/6pack.c:1001
 [<ffffffff8425f96a>] sixpack_receive_buf+0xf8a/0x1450
drivers/net/hamradio/6pack.c:462
 [<ffffffff8323b368>] tty_ldisc_receive_buf+0x168/0x1b0
drivers/tty/tty_buffer.c:433
 [<ffffffff832616de>] paste_selection+0x27e/0x3e0 drivers/tty/vt/selection.c:363
 [<ffffffff8327f286>] tioclinux+0x126/0x410 drivers/tty/vt/vt.c:2683
 [<ffffffff8325c1ef>] vt_ioctl+0x13ef/0x2910 drivers/tty/vt/vt_ioctl.c:365
 [<ffffffff832245cd>] tty_ioctl+0x69d/0x21e0 drivers/tty/tty_io.c:2983
 [<     inline     >] vfs_ioctl fs/ioctl.c:43
 [<ffffffff818a1dfc>] do_vfs_ioctl+0x18c/0x1080 fs/ioctl.c:675
 [<     inline     >] SYSC_ioctl fs/ioctl.c:690
 [<ffffffff818a2d7f>] SyS_ioctl+0x8f/0xc0 fs/ioctl.c:681
 [<ffffffff86e10700>] entry_SYSCALL_64_fastpath+0x23/0xc1
Memory state around the buggy address:
 ffff880037fbf700: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff880037fbf780: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff880037fbf800: 00 00 00 00 00 00 00 00 00 00 f3 f3 f3 f3 00 00
                                                 ^
 ffff880037fbf880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff880037fbf900: 00 00 00 00 f1 f1 f1 f1 00 f4 f4 f4 f2 f2 f2 f2
==================================================================


It is then followed by similar reports that access subsequent stack bytes.
Unfortunately I can't reproduce it (though, I got 6 similar crashes in
different runs). Looking at code, the following looks suspicious -- we
limit copy by 512 bytes, but use the original count which can be
larger than 512:

static void sixpack_receive_buf(struct tty_struct *tty,
    const unsigned char *cp, char *fp, int count)
{
    unsigned char buf[512];
    ....
    memcpy(buf, cp, count < sizeof(buf) ? count : sizeof(buf));
    ....
    sixpack_decode(sp, buf, count1);


On commit 0f98f121e1670eaa2a2fbb675e07d6ba7f0e146f of linux-next.
