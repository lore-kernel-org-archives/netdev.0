From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: memory leak in ip_cmsg_send
Date: Thu, 4 Feb 2016 10:47:31 +0100
Message-ID: <CACT4Y+YMUc8j4_-oJfi0XmQebhaTZa2NTipSFY_ra38V-TAyXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kostya Serebryany <kcc@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've hit the following memory leak while running syzkaller fuzzer:

unreferenced object 0xffff88002ea39708 (size 64):
  comm "syz-executor", pid 19887, jiffies 4295848369 (age 8.676s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 04 00 00 00 04 00 00 00  ................
  backtrace:
    [<     inline     >] kzalloc include/linux/slab.h:607
    [<     inline     >] ip_options_get_alloc net/ipv4/ip_options.c:515
    [<ffffffff85836ea4>] ip_options_get+0x34/0x90 net/ipv4/ip_options.c:551
    [<ffffffff8584924d>] ip_cmsg_send+0x5bd/0x6f0 net/ipv4/ip_sockglue.c:252
    [<ffffffff858e8502>] raw_sendmsg+0xa52/0x25a0 net/ieee802154/socket.c:738
    [<ffffffff859246e7>] inet_sendmsg+0x2f7/0x4c0 net/ipv4/af_inet.c:736
    [<     inline     >] sock_sendmsg_nosec net/socket.c:611
    [<ffffffff854cdffa>] sock_sendmsg+0xca/0x110 net/socket.c:621
    [<ffffffff854cfe3a>] ___sys_sendmsg+0x72a/0x840 net/socket.c:1947
    [<ffffffff854d1e0e>] __sys_sendmsg+0xce/0x170 net/socket.c:1981
    [<     inline     >] SYSC_sendmsg net/socket.c:1992
    [<ffffffff854d1edd>] SyS_sendmsg+0x2d/0x50 net/socket.c:1988

ip_cmsg_send seems to forget to free ipc->opt when it returns an error
(all callers expect that there is nothing to cleanup if it returns an
error).

On commit 34229b277480f46c1e9a19f027f30b074512e68b.
