From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: kmemcheck: Caught 32-bit read from uninitialized memory
 (bf438284)
Date: Tue, 15 Sep 2009 10:59:03 +0200
Message-ID: <4AAF5757.30500@gmail.com>
References: <20090915080953.GA24958@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34813 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbZIOI7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 04:59:12 -0400
In-Reply-To: <20090915080953.GA24958@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
> FYI, we still have this one on latest mainline:
>=20
> [    2.159614] NET: Registered protocol family 16
> [    2.163109] initcall netlink_proto_init+0x0/0x1b0 returned 0 after=
 5859 usecs
> [    2.164008] WARNING: kmemcheck: Caught 32-bit read from uninitiali=
zed memory (bf438284)
> [    2.165006] 0100000002000000000000000000000000000000ad4eaddeffffff=
ffffffffff
> [    2.172006]  i i i i i i u u i i i i i i i i i i i i i i i i i i i=
 i i i i i
> [    2.179005]          ^
> [    2.180005]=20
> [    2.181008] Pid: 1, comm: swapper Not tainted (2.6.31-tip-02389-gc=
9f313c-dirty #151)=20
> [    2.182006] EIP: 0060:[<815a8101>] EFLAGS: 00010282 CPU: 0
> [    2.183009] EIP is at sock_init_data+0xe1/0x210
> [    2.184006] EAX: 0001b000 EBX: bf855938 ECX: 8233b614 EDX: 819ac7b=
f
> [    2.185006] ESI: bf855800 EDI: bf438280 EBP: bf867f10 ESP: 81b3afc=
c
> [    2.186006]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [    2.187006] CR0: 8005003b CR2: bf83bdf0 CR3: 01b2c000 CR4: 000006d=
0
> [    2.188006] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 0000000=
0
> [    2.189006] DR6: ffff4ff0 DR7: 00000400
> [    2.190005]  [<815d82b5>] __netlink_create+0x35/0xa0
> [    2.192005]  [<815dabaa>] netlink_kernel_create+0x5a/0x150
> [    2.194004]  [<815bc8ee>] rtnetlink_net_init+0x1e/0x40
> [    2.196005]  [<815af381>] register_pernet_operations+0x11/0x30
> [    2.198004]  [<815af4be>] register_pernet_subsys+0x1e/0x30
> [    2.200004]  [<81adb49c>] rtnetlink_init+0x4c/0x100
> [    2.202004]  [<81adbfe5>] netlink_proto_init+0x105/0x1b0
> [    2.204004]  [<81001127>] do_one_initcall+0x27/0x190
> [    2.206004]  [<81a9f567>] do_initcalls+0x27/0x40
> [    2.208004]  [<81a9f5a6>] do_basic_setup+0x26/0x30
> [    2.210004]  [<81a9f907>] kernel_init+0x57/0xa0
> [    2.212004]  [<81004867>] kernel_thread_helper+0x7/0x30
> [    2.214004]  [<ffffffff>] 0xffffffff
> [    2.216021] calling  bdi_class_init+0x0/0x30 @ 1
> [    2.217015] device class 'bdi': registering
> [    2.218702] initcall bdi_class_init+0x0/0x30 returned 0 after 976 =
usecs
> [    2.219041] calling  kobject_uevent_init+0x0/0x50 @ 1
>=20
> config attached.
>=20
> 	Ingo
>=20

I thought this was already discussed and fixed somehow ?

Either we add kmemcheck annotations, or we switch sock->type from short
to int to avoid the hole, and possibly to speedup things...

[PATCH] net: kmemcheck annotation in struct socket

struct socket has a 16 bit hole that triggers kmemcheck warnings.

As suggested by Ingo, use kmemcheck annotations

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/net.h |    5 +++++
 net/socket.c        |    1 +
 2 files changed, 6 insertions(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index 4fc2ffd..9040a10 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -57,6 +57,7 @@ typedef enum {
 #include <linux/random.h>
 #include <linux/wait.h>
 #include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
+#include <linux/kmemcheck.h>
=20
 struct poll_table_struct;
 struct pipe_inode_info;
@@ -127,7 +128,11 @@ enum sock_shutdown_cmd {
  */
 struct socket {
 	socket_state		state;
+
+	kmemcheck_bitfield_begin(type);
 	short			type;
+	kmemcheck_bitfield_end(type);
+
 	unsigned long		flags;
 	/*
 	 * Please keep fasync_list & wait fields in the same cache line
diff --git a/net/socket.c b/net/socket.c
index 6d47165..2a022c0 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -489,6 +489,7 @@ static struct socket *sock_alloc(void)
=20
 	sock =3D SOCKET_I(inode);
=20
+	kmemcheck_annotate_bitfield(sock, type);
 	inode->i_mode =3D S_IFSOCK | S_IRWXUGO;
 	inode->i_uid =3D current_fsuid();
 	inode->i_gid =3D current_fsgid();
