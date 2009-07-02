From: =?iso-8859-15?q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: use after free bug in socket code
Date: Thu, 2 Jul 2009 13:26:30 +0200
Message-ID: <19020.39270.408816.360526@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:51813 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbZGBMQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 08:16:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

while developing a canbus driver (with kernel 2.6.30-rc4) I
encountered a use-after-free bug that led to the following crash (due
to CONFIG_DEBUG_SLAB being enabled):
|Unable to handle kernel paging request at virtual address 6b6b6b6b
|pgd =3D d1b4c000
|[6b6b6b6b] *pgd=3D00000000
|Internal error: Oops: 1 [#1] PREEMPT
|Modules linked in: can_raw can flexcan [last unloaded: usbcore]
|CPU: 0    Tainted: G        W   (2.6.30-rc4 #215)
|PC is at __wake_up_common+0x30/0x88
|LR is at __wake_up_sync_key+0x48/0x64
|pc : [<c00418a4>]    lr : [<c0041d10>]    psr: 90000093
|sp : d18f5d70  ip : 6b6b6b5f  fp : d18f5d9c
|r10: 00000001  r9 : 00000304  r8 : d1517aec
|r7 : 00000001  r6 : 00000001  r5 : 00000001  r4 : a0000013
|r3 : 00000001  r2 : 00000001  r1 : 00000001  r0 : d1517aec
|Flags: NzcV  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment user
|Control: 0005317f  Table: 91b4c000  DAC: 00000015
|Process ifconfig (pid: 893, stack limit =3D 0xd18f4268)
|Stack: (0xd18f5d70 to 0xd18f6000)
|5d60:                                     d18f4000 a0000013 00000001 0=
0000001=20
|5d80: 00000304 d1517ad0 d18f4000 d18f5ea8 d18f5dcc d18f5da0 c0041d10 c=
0041884=20
|5da0: 00000304 d18f5ea8 00000000 d1b029f0 d1b02b44 d1a1c398 c035a8c0 0=
0008914=20
|5dc0: 00000000 d18f5dd0 c01d8070 c0041cd8 d1517ad0 6b6b6b6b 6b6b6b6b c=
006b594=20
|5de0: 00000001 d1b029f0 d1a1c280 c01d8434 d1b1ad88 c01d95fc d1b1ad88 c=
01db6d8=20
|5e00: d1b1ad88 c01dabdc d1a1c348 c01f4bac d1a1c280 d1b4a5a8 d1a1c2dc c=
01f3c1c=20
|5e20: d1a1c280 c01f3df4 00000000 00000000 00000000 d1afe8e0 00000081 c=
01f45a4=20
|5e40: 000000c0 d1afe8e0 bf086344 000000c0 00000081 00008914 d18f5ea8 c=
01e3c08=20
|5e60: 00008914 00000041 d1afe8e0 c01e3a14 c070d97c be90cbe8 d18f4000 0=
0000000=20
|5e80: 00000000 c0227bc0 00000020 d18f5eb8 00008913 c01e66cc 00000000 d=
1b8ed30=20
|5ea0: d1afe8e0 00000000 316e6163 00000000 00000000 00000000 000000c0 4=
0012ed0=20
|5ec0: be90ced1 00050918 000000c0 40012ed0 be90ced1 00050918 be90ced1 0=
0008914=20
|5ee0: be90cbe8 be90cbe8 d187ed10 c0027f68 d18f4000 00000000 00000000 c=
01d3510=20
|5f00: d187ed10 be90cbe8 00008914 c00ac4d0 00000003 d187ed10 be90cbe8 c=
00ac924=20
|5f20: 00000001 00000000 d1b0ba48 60000013 401b2100 d1b0ba44 00000000 d=
18f5fb0=20
|5f40: 00000200 c025c3e4 d1b0ba48 60000013 d1b0ba10 401b2100 d1b0ba44 0=
0000000=20
|5f60: d1b0ba48 00000003 be90cbe8 00008914 d187ed10 c0027f68 d18f4000 0=
0000000=20
|5f80: 00000000 c00acc0c be90cdd8 00000000 00000001 00052928 00000001 b=
e90cddc=20
|5fa0: 00000036 c0027dc0 00052928 00000001 00000003 00008914 be90cbe8 0=
0052928=20
|5fc0: 00052928 00000001 be90cddc 00000036 00000028 be90cbe8 00000003 0=
0000000=20
|5fe0: 00052a78 be90cbc8 0000ca40 401b210c 60000010 00000003 00000000 0=
0000000=20
|[<c00418a4>] (__wake_up_common+0x30/0x88) from [<c0041d10>] (__wake_up=
_sync_key+0x48/0x64)
|[<c0041d10>] (__wake_up_sync_key+0x48/0x64) from [<c01d8070>] (sock_de=
f_write_space+0xcc/0xec)
|[<c01d8070>] (sock_def_write_space+0xcc/0xec) from [<c01d8434>] (sock_=
wfree+0x70/0x74)
|[<c01d8434>] (sock_wfree+0x70/0x74) from [<c01d95fc>] (skb_release_hea=
d_state+0x38/0x5c)
|[<c01d95fc>] (skb_release_head_state+0x38/0x5c) from [<c01db6d8>] (skb=
_release_all+0xc/0x18)
|[<c01db6d8>] (skb_release_all+0xc/0x18) from [<c01dabdc>] (__kfree_skb=
+0xc/0xc4)
|[<c01dabdc>] (__kfree_skb+0xc/0xc4) from [<c01f4bac>] (pfifo_fast_rese=
t+0x44/0x6c)
|[<c01f4bac>] (pfifo_fast_reset+0x44/0x6c) from [<c01f3c1c>] (qdisc_res=
et+0x1c/0x30)
|[<c01f3c1c>] (qdisc_reset+0x1c/0x30) from [<c01f3df4>] (dev_deactivate=
_queue+0x5c/0x74)
|[<c01f3df4>] (dev_deactivate_queue+0x5c/0x74) from [<c01f45a4>] (dev_d=
eactivate+0x34/0x204)
|[<c01f45a4>] (dev_deactivate+0x34/0x204) from [<c01e3c08>] (dev_close+=
0x70/0xc8)
|[<c01e3c08>] (dev_close+0x70/0xc8) from [<c01e3a14>] (dev_change_flags=
+0x74/0x180)
|[<c01e3a14>] (dev_change_flags+0x74/0x180) from [<c0227bc0>] (devinet_=
ioctl+0x5f8/0x748)
|[<c0227bc0>] (devinet_ioctl+0x5f8/0x748) from [<c01d3510>] (sock_ioctl=
+0x60/0x264)
|[<c01d3510>] (sock_ioctl+0x60/0x264) from [<c00ac4d0>] (vfs_ioctl+0x2c=
/0x90)
|[<c00ac4d0>] (vfs_ioctl+0x2c/0x90) from [<c00ac924>] (do_vfs_ioctl+0x2=
c8/0x578)
|[<c00ac924>] (do_vfs_ioctl+0x2c8/0x578) from [<c00acc0c>] (sys_ioctl+0=
x38/0x60)
|[<c00acc0c>] (sys_ioctl+0x38/0x60) from [<c0027dc0>] (ret_fast_syscall=
+0x0/0x2c)
|Code: e1a0a001 e1a08000 e1a06002 e59b9004 (e59c300c)=20
|Kernel panic - not syncing: Fatal exception in interrupt
|[<c002db6c>] (unwind_backtrace+0x0/0xe8) from [<c0047aec>] (panic+0x58=
/0x148)
|[<c0047aec>] (panic+0x58/0x148) from [<c002bed8>] (die+0x120/0x150)
|[<c002bed8>] (die+0x120/0x150) from [<c002ed44>] (__do_kernel_fault+0x=
70/0x80)
|[<c002ed44>] (__do_kernel_fault+0x70/0x80) from [<c0030b48>] (do_align=
ment+0x174/0x58c)
|[<c0030b48>] (do_alignment+0x174/0x58c) from [<c0027254>] (do_DataAbor=
t+0x34/0x98)
|[<c0027254>] (do_DataAbort+0x34/0x98) from [<c00279cc>] (__dabt_svc+0x=
4c/0x60)
|Exception stack(0xd18f5d28 to 0xd18f5d70)
|5d20:                   d1517aec 00000001 00000001 00000001 a0000013 0=
0000001=20
|5d40: 00000001 00000001 d1517aec 00000304 00000001 d18f5d9c 6b6b6b5f d=
18f5d70=20
|5d60: c0041d10 c00418a4 90000093 ffffffff                             =
       =20
|[<c00279cc>] (__dabt_svc+0x4c/0x60) from [<c0041d10>] (__wake_up_sync_=
key+0x48/0x64)
|[<c0041d10>] (__wake_up_sync_key+0x48/0x64) from [<c0041d10>] (__wake_=
up_sync_key+0x48/0x64)
|[<c0041d10>] (__wake_up_sync_key+0x48/0x64) from [<c01d8070>] (sock_de=
f_write_space+0xcc/0xec)
|[<c01d8070>] (sock_def_write_space+0xcc/0xec) from [<c01d8434>] (sock_=
wfree+0x70/0x74)
|[<c01d8434>] (sock_wfree+0x70/0x74) from [<c01d95fc>] (skb_release_hea=
d_state+0x38/0x5c)
|[<c01d95fc>] (skb_release_head_state+0x38/0x5c) from [<c01db6d8>] (skb=
_release_all+0xc/0x18)
|[<c01db6d8>] (skb_release_all+0xc/0x18) from [<c01dabdc>] (__kfree_skb=
+0xc/0xc4)
|[<c01dabdc>] (__kfree_skb+0xc/0xc4) from [<c01f4bac>] (pfifo_fast_rese=
t+0x44/0x6c)
|[<c01f4bac>] (pfifo_fast_reset+0x44/0x6c) from [<c01f3c1c>] (qdisc_res=
et+0x1c/0x30)
|[<c01f3c1c>] (qdisc_reset+0x1c/0x30) from [<c01f3df4>] (dev_deactivate=
_queue+0x5c/0x74)
|[<c01f3df4>] (dev_deactivate_queue+0x5c/0x74) from [<c01f45a4>] (dev_d=
eactivate+0x34/0x204)
|[<c01f45a4>] (dev_deactivate+0x34/0x204) from [<c01e3c08>] (dev_close+=
0x70/0xc8)
|[<c01e3c08>] (dev_close+0x70/0xc8) from [<c01e3a14>] (dev_change_flags=
+0x74/0x180)
|[<c01e3a14>] (dev_change_flags+0x74/0x180) from [<c0227bc0>] (devinet_=
ioctl+0x5f8/0x748)
|[<c0227bc0>] (devinet_ioctl+0x5f8/0x748) from [<c01d3510>] (sock_ioctl=
+0x60/0x264)
|[<c01d3510>] (sock_ioctl+0x60/0x264) from [<c00ac4d0>] (vfs_ioctl+0x2c=
/0x90)
|[<c00ac4d0>] (vfs_ioctl+0x2c/0x90) from [<c00ac924>] (do_vfs_ioctl+0x2=
c8/0x578)
|[<c00ac924>] (do_vfs_ioctl+0x2c8/0x578) from [<c00acc0c>] (sys_ioctl+0=
x38/0x60)
|[<c00acc0c>] (sys_ioctl+0x38/0x60) from [<c0027dc0>] (ret_fast_syscall=
+0x0/0x2c)
|Rebooting in 1 seconds..

I found that the problem occured due to a 'struct sock' being released
that still contained pointers (sk_socket and sk_sleep) to a socket
which had already been released earlier and the function
sock_def_write_space() tried to wake the wait queue referenced by the
dangling sk_sleep pointer.

Checking the code that frees those objects I found a call to
sock_orphan() in sk_release_common() that invalidates the pointers to
the socket object inside the sk. But IMO this call would be more
appropriate in sock_release() which releases the object those pointers
are referring to.

=46urthermore adding some debug messages in sock_release() and
sk_release_common() showed that sock_release() seems to be commonly
called before sk_release_common() which is also a strong point for
invalidating the pointers from sock_release() rather than
sk_release_common():
|__sock_create: Created socket d14b5d28 sk d1a06050
|sk_alloc: Allocated sk d1a06310
|sk_free: Freeing sk d1a06310 socket (null)
|sock_release: releasing socket d14b5d28 sk d1a06050 ops c025ea84
|sock_release: orphaning sk d1a06050 from socket d14b5d28
|sk_free: Freeing sk d1a06050 socket (null)

With the following patch I could alleviate the problem and did not
find any negative side effects, but I'm not sure, whether this is the
Right Thing(TM), since I'm not too familiar with the networking code:

a/net/socket.c
b/net/socket.c
--- net/socket.c	1 Jul 2009 09:30:42 -0000
+++ net/socket.c	2 Jul 2009 10:25:27 -0000
@@ -524,7 +524,9 @@ void sock_release(struct socket *sock)
 	if (sock->ops) {
 		struct module *owner =3D sock->ops->owner;
=20
+		if (sock->sk)
+			sock_orphan(sock->sk);
 		sock->ops->release(sock);
 		sock->ops =3D NULL;
 		module_put(owner);
a/net/core/sock.c
b/net/core/sock.c
--- net/core/sock.c	2 Jun 2009 15:37:50 -0000
+++ net/core/sock.c	2 Jul 2009 10:42:33 -0000
@@ -1982,7 +1983,9 @@ void sk_common_release(struct sock *sk)
 	 * until the last reference will be released.
 	 */
=20
-	sock_orphan(sk);
+	//sock_orphan(sk);
+	if (WARN_ON(sk->sk_sleep || sk->sk_socket))
+		sock_orphan(sk);
=20
 	xfrm_sk_free_policy(sk);
=20

Any comments on this?


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
