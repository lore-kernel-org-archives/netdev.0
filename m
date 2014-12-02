From: Dmitry Vyukov <dvyukov@google.com>
Subject: Out-of-bounds access in nfnetlink_bind
Date: Tue, 2 Dec 2014 11:53:09 +0400
Message-ID: <CACT4Y+bZu5UHu90F8wWqckcE13D5H2LDexna6vVEMBy+X4RiZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kasan-dev <kasan-dev@googlegroups.com>,
	Dmitry Chernenkov <dmitryc@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am working on Kernel AddressSanitizer, a fast memory error detector
for kernel:
https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel

Here is an error report that I got while running trinity:

==================================================================
BUG: AddressSanitizer: out of bounds access in
nfnetlink_bind+0xbf/0xe0 at addr ffffffff82eef710
Read of size 4 by task trinity-main/2533
Out-of-bounds access to the global variable 'nfnl_group2type'
[ffffffff82eef6e0-ffffffff82eef704) defined at
net/netfilter/nfnetlink.c:43:18
CPU: 0 PID: 2533 Comm: trinity-main Not tainted 3.18.0-rc1+ #44
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff835173e8 ffff8800b989fd18 ffffffff82a3d66f 0000000000000007
 ffff8800b989fdc0 ffff8800b989fda8 ffffffff813a3826 0000000000000012
 0000000000000000 0000000100000018 0000000000000296 ffff8800b989fd88
Call Trace:
 [<ffffffff813a39c1>] __asan_report_load4_noabort+0x41/0x50
mm/kasan/report.c:236
 [<ffffffff824769cf>] nfnetlink_bind+0xbf/0xe0 net/netfilter/nfnetlink.c:467
 [<ffffffff82469b71>] netlink_bind+0x221/0x7e0 net/netlink/af_netlink.c:1472
 [<ffffffff8238bf77>] SYSC_bind+0x117/0x170 net/socket.c:1541
 [<ffffffff8238dc29>] SyS_bind+0x9/0x10 net/socket.c:1527
 [<ffffffff82a522a9>] system_call_fastpath+0x12/0x17
arch/x86/kernel/entry_64.S:422
Memory state around the buggy address:
 ffffffff82eef480: 00 00 00 00 00 00 00 00 00 00 00 00 00 f8 f8 f8
 ffffffff82eef500: f8 f8 f8 f8 00 00 00 00 f8 f8 f8 f8 00 00 00 01
 ffffffff82eef580: f8 f8 f8 f8 00 00 00 00 05 f8 f8 f8 f8 f8 f8 f8
 ffffffff82eef600: 00 00 04 f8 f8 f8 f8 f8 00 00 f8 f8 f8 f8 f8 f8
 ffffffff82eef680: 00 00 00 00 07 f8 f8 f8 f8 f8 f8 f8 00 00 00 00
>ffffffff82eef700: 04 f8 f8 f8 f8 f8 f8 f8 00 06 f8 f8 f8 f8 f8 f8
                         ^
 ffffffff82eef780: 00 00 00 05 f8 f8 f8 f8 00 00 00 00 00 f8 f8 f8
 ffffffff82eef800: f8 f8 f8 f8 00 00 00 00 02 f8 f8 f8 f8 f8 f8 f8
 ffffffff82eef880: 00 00 00 00 06 f8 f8 f8 f8 f8 f8 f8 00 00 00 04
 ffffffff82eef900: f8 f8 f8 f8 00 00 00 00 00 04 f8 f8 f8 f8 f8 f8
 ffffffff82eef980: 00 00 00 07 f8 f8 f8 f8 00 00 00 06 f8 f8 f8 f8
==================================================================

My source is on revision f114040e3ea6e07372334ade75d1ee0

As far as I see netlink_bind just calls nfnetlink_bind with whatever
groups user has requested; nfnetlink_bind in turn do not do any checks
before indexing the global nfnl_group2type array with the group.
