From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression, bisected: WARNING spam with ipsec since 2.6.35
Date: Fri, 17 Sep 2010 00:27:50 +0200
Message-ID: <1284676070.4784.25.camel@edumazet-laptop>
References: <20100916213138.GA6605@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37016 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab0IPW14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 18:27:56 -0400
In-Reply-To: <20100916213138.GA6605@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 septembre 2010 =C3=A0 17:31 -0400, Nick Bowler a =C3=A9crit=
 :
> Attempting to use IPSec since 2.6.35 has resulted in WARNINGs (one of
> them is included further down) being spammed to the kernel log.  The
> packets seem to be transmitted fine, but the constant printk's degrad=
e
> performance to the point of uselessness (there are about a half dozen
> call traces for every packet transmitted).  I've attached the full lo=
g
> after booting the kernel, running the setkey script, and sending a
> single ping.
>=20
> This is the setkey script I used to produce the issue:
>=20
>   add 192.168.0.1 192.168.0.2 esp 0x6B8B4567  -f seq-pad
>    -E rijndael-cbc 0x643C98696633487374B0DC5119495CFF
>    -A null;
>  =20
>   add 192.168.0.2 192.168.0.1 esp 0x327B23C6  -f seq-pad
>    -E rijndael-cbc 0x3D1B58BA507ED7AB2EB141F241B71EFB
>    -A null;
>  =20
>   spdadd 192.168.0.2 192.168.0.1 any -P out ipsec
>    esp/transport//require;
>   spdadd 192.168.0.1 192.168.0.2 any -P in ipsec
>    esp/transport//require;
>=20
> and here's the first warning:
>=20
>   ------------[ cut here ]------------
>   WARNING: at include/linux/skbuff.h:472 xfrm_output_resume+0x4b8/0x5=
0d()
>   Hardware name:        =20
>   Modules linked in: authenc esp4 deflate zlib_deflate ctr aes_generi=
c des_generic cbc sha256_generic sha1_generic md5 crypto_null af_key au=
tofs4 sunrpc iptable_filter ip_tables ip6t_REJECT xt_tcpudp nf_conntrac=
k_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 l=
oop parport_pc sg psmouse parport evdev skge rng_core button ext4 mbcac=
he jbd2 crc16 sr_mod sd_mod cdrom ata_piix libata ehci_hcd uhci_hcd scs=
i_mod usbcore dm_mod [last unloaded: scsi_wait_scan]
>   Pid: 2391, comm: ping Not tainted 2.6.35 #3
>   Call Trace:
>    [<c102e21f>] warn_slowpath_common+0x65/0x7a
>    [<c127ee2e>] ? xfrm_output_resume+0x4b8/0x50d
>    [<c102e243>] warn_slowpath_null+0xf/0x13
>    [<c127ee2e>] xfrm_output_resume+0x4b8/0x50d
>    [<c127ee90>] xfrm_output2+0xd/0xf
>    [<c127ef57>] xfrm_output+0xc5/0xce
>    [<c1277f55>] xfrm4_output_finish+0xa1/0xa4
>    [<c1277fe0>] xfrm4_output+0x88/0x8f
>    [<c124ce58>] ip_local_out+0x50/0x53
>    [<c124d0c4>] ip_push_pending_frames+0x269/0x2b2
>    [<c126578f>] raw_sendmsg+0x614/0x691
>    [<c1051c01>] ? trace_hardirqs_on_caller+0x1e/0x121
>    [<c126d46c>] inet_sendmsg+0xbd/0xc6
>    [<c1223f62>] sock_sendmsg+0xa5/0xbb
>    [<c108deb6>] ? might_fault+0x6e/0x88
>    [<c108deb6>] ? might_fault+0x6e/0x88
>    [<c122bd43>] ? verify_iovec+0x3e/0x6b
>    [<c1224368>] sys_sendmsg+0x149/0x196
>    [<c1023c2b>] ? get_parent_ip+0xb/0x31
>    [<c107e377>] ? unlock_page+0x3b/0x3e
>    [<c108f99a>] ? handle_mm_fault+0x219/0x49b
>    [<c1053d13>] ? lock_release_non_nested+0x86/0x221
>    [<c108deb6>] ? might_fault+0x6e/0x88
>    [<c108deb6>] ? might_fault+0x6e/0x88
>    [<c12255ba>] sys_socketcall+0x146/0x18b
>    [<c110b4b4>] ? trace_hardirqs_on_thunk+0xc/0x10
>    [<c1002690>] sysenter_do_call+0x12/0x36
>   ---[ end trace c8ae605bd7809dcc ]---
>=20
> Bisection implicates the following commit:
>=20
>   8764ab2ca7ab5055e1ca80f9cfa4970c34acb804 is the first bad commit
>   commit 8764ab2ca7ab5055e1ca80f9cfa4970c34acb804
>   Author: Steffen Klassert <steffen.klassert@secunet.com>
>   Date:   Fri Jun 4 01:57:38 2010 +0000
>  =20
>       net: check for refcount if pop a stacked dst_entry
>      =20
>       xfrm triggers a warning if dst_pop() drops a refcount
>       on a noref dst. This patch changes dst_pop() to
>       skb_dst_pop(). skb_dst_pop() drops the refcnt only
>       on a refcounted dst. Also we don't clone the child
>       dst_entry, so it is not refcounted and we can use
>       skb_dst_set_noref() in xfrm_output_one().
>      =20
>       Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>       Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>       Signed-off-by: David S. Miller <davem@davemloft.net>
>  =20
>   :040000 040000 3f0e1574919d0e581b3e9537a4d59ce397a926f1 f272ab5b895=
c46b3166d321a2da759c2a6e08ae0 M	include
>   :040000 040000 a4fbff22e9ae9f57f4f8c5416f5a7be186635cab eb04849588c=
be4b2b99030c2aa59e3433187c6df M	net
>  =20
>   git bisect start
>   # bad: [9c03f1622af051004416dd3e24d8a0fa31e34178] Merge ssh://maste=
r.kernel.org/home/hpa/tree/sec
>   git bisect bad 9c03f1622af051004416dd3e24d8a0fa31e34178
>   # bad: [9fe6206f400646a2322096b56c59891d530e8d51] Linux 2.6.35
>   git bisect bad 9fe6206f400646a2322096b56c59891d530e8d51
>   # good: [e40152ee1e1c7a63f4777791863215e3faa37a86] Linus 2.6.34
>   git bisect good e40152ee1e1c7a63f4777791863215e3faa37a86
>   # good: [e0bc5d4a54938eedcde14005210e6c08aa9727e4] Merge branch 'i2=
c-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jdelvare/=
staging
>   git bisect good e0bc5d4a54938eedcde14005210e6c08aa9727e4
>   # good: [d30fda355188272430d3865db2ff9e24b4135ae3] posix-cpu-timers=
: avoid "task->signal !=3D NULL" checks
>   git bisect good d30fda355188272430d3865db2ff9e24b4135ae3
>   # good: [9a9620db07b27700a4de9e86985735fffb78e2f8] Merge branch 'li=
nux_next' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/i7co=
re
>   git bisect good 9a9620db07b27700a4de9e86985735fffb78e2f8
>   # bad: [985b823b919273fe1327d56d2196b4f92e5d0fae] drm/i915: fix hib=
ernation since i915 self-reclaim fixes
>   git bisect bad 985b823b919273fe1327d56d2196b4f92e5d0fae
>   # bad: [b5edfefc65526b34960bbff3477ded477b0328f6] Merge branch 'for=
-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/securi=
ty-testing-2.6
>   git bisect bad b5edfefc65526b34960bbff3477ded477b0328f6
>   # bad: [fcdcddbcbbd39a3363bd48414bfe44553b6d698a] microblaze: Fix s=
g_dma_len() regression
>   git bisect bad fcdcddbcbbd39a3363bd48414bfe44553b6d698a
>   # bad: [ed7dc1dfbcef301407a1e3138a49dc94e5a19d0a] Merge git://git.k=
ernel.org/pub/scm/linux/kernel/git/davem/net-2.6
>   git bisect bad ed7dc1dfbcef301407a1e3138a49dc94e5a19d0a
>   # good: [90ec7819737d42a0ad1c2df1ff56016facae3c6e] Merge git://git.=
kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6-for-linus
>   git bisect good 90ec7819737d42a0ad1c2df1ff56016facae3c6e
>   # good: [a1868dc2878e61778b9d6d8c61d5368e51d68a29] ixgbe: return IX=
GBE_ERR_RAR_INDEX when out of range
>   git bisect good a1868dc2878e61778b9d6d8c61d5368e51d68a29
>   # good: [7926e0bfbbc5ff81ddad0fda831eef7060e40997] Merge branch 'fo=
r-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/ryusuke/nilfs=
2
>   git bisect good 7926e0bfbbc5ff81ddad0fda831eef7060e40997
>   # bad: [ca739481662137b8f717bc21f16719cda3c33d6b] ixgbe: only check=
 pfc bits in hang logic if pfc is enabled
>   git bisect bad ca739481662137b8f717bc21f16719cda3c33d6b
>   # good: [51a0d38de26226f2779912d92f155b93d539da9a] mac80211: fix di=
alog token allocator
>   git bisect good 51a0d38de26226f2779912d92f155b93d539da9a
>   # bad: [8764ab2ca7ab5055e1ca80f9cfa4970c34acb804] net: check for re=
fcount if pop a stacked dst_entry
>   git bisect bad 8764ab2ca7ab5055e1ca80f9cfa4970c34acb804
>   # good: [4f4aeb7fd0f7e6ca008bb2147ba36cee13876595] Merge branch 'ma=
ster' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireles=
s-2.6
>   git bisect good 4f4aeb7fd0f7e6ca008bb2147ba36cee13876595
>=20

Thanks Nick !

CC netdev

ip_local_out() is called with rcu_read_lock() from ip_queue_xmit()
but not from other call sites.

I suspect following patch is needed, before further changes.


[PATCH] xfrm: dont assume rcu_read_lock in xfrm_output_one()

ip_local_out() is called with rcu_read_lock() held from ip_queue_xmit()
but not from other call sites.

Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/xfrm/xfrm_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index a3cca0a..64f2ae1 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -101,7 +101,7 @@ resume:
 			err =3D -EHOSTUNREACH;
 			goto error_nolock;
 		}
-		skb_dst_set_noref(skb, dst);
+		skb_dst_set(skb, dst_clone(dst));
 		x =3D dst->xfrm;
 	} while (x && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL));
=20


