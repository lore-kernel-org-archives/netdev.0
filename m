From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: Add default_advmss() methods to blackhole dst_ops
Date: Fri, 18 Feb 2011 10:57:03 +0100
Message-ID: <1298023023.2595.170.camel@edumazet-laptop>
References: <20110218050321.10415.qmail@science.horizon.com>
	 <1298010735.2642.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>
To: George Spelvin <linux@horizon.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298010735.2642.9.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 07:32 +0100, Eric Dumazet a =C3=
=A9crit :
> Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 00:03 -0500, George Spelvin a=
 =C3=A9crit :
> > But wonder of wonders, kernel mode switching worked so I got to see=
 the
> > oops on the text-mode console.  It happened just as I tried to ssh =
out.
> >=20
>=20
> CC netdev (removed linux-netdev)
>=20
> I'll take a look this morning, thanks for the report.
>=20
> > It's a Core 2 duo laptop (Dell E1405), 2 GB RAM, running a 32-bit k=
ernel.
> > It's worth noting that I was using wired internet (b44 driver) and
> > not wireless.
> >=20
> > I've been having a lot of weird lockups with 2.6.38-rcX, quite a ch=
ange
> > from the very stable 2.6.36, but this is the first time I booted -r=
c5.
> > Also, the symptoms are very different; before the lockup did not se=
en
> > correlated with any particular activity, but the "lockup" was more =
like
> > something getting wedged in the kernel that more and more tasks wou=
ld
> > get stuck on until everything stopped responding.
> >=20
> > I should mention that this is transcribed by hand from the screen.
> > Oh, and also, it is far from the first time I ran ssh this boot.
> > (I re-tested it ater rebooting, just to be sure.  Not a consistent
> > crash.)
> >=20
> > Anyway, jumping to address 0 looks "interesting", so it seems worth=
 reporting.
> >=20
> > BUG: unable to handle kernel NULL pointer dereference at   (null)
> > IP: [<  (null)>]   (null)
> > *pde =3D 00000000
> > Oops: 0000 [#1] SMP
> > last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0=
:0:0/0:0:0:0/block/sda/uevent
> > Modules linked in: rfcomm btusb sco l2cap crc16 bluetooth b43 mac80=
211 cfg80211 [last unloaded: sha256_generic]
> >=20
> > Pid: 12178, comm: ssh Not tainted 2.6.38-rc5 #227 Dell Inc. MXC061 =
                         /0MG532
> > EIP: 0060:[<00000000>] EFLAGS: 0021246 CPU: 0
> > EIP is at 0x0
> > EAX: f5947e00 EBX: f5982f80 ECX: 00000024 EDX: c148fe00
> > ESI: f5947e00 EDI: ebf29e54 EBP: ebf29ee0 ESP: ebf29dd0
> >  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> > Process ssh (pid: 12178, ti=3Debf28000 task=3Debefc6c0 task.ti =3D =
ebef28000)
> > Stack:
> >  c12c83ea 07e2427d 02000000 7b018f79 c117b827 0b996609 7b018f79 5f5=
f6644
> >  f5982f80 00000000 ebf29e58 ebf29ee0 c12cc0e0 00001600 00000000 000=
00001
> >  03641600 00000000 00000000 00000000 00000000 036423c0 3e6423c0 000=
00000
> > Call Trace:
> >  [<c12c83ea>] ? tcp_connect+0xdd/0x3fd
> >  [<c117b827>] ? secure_tcp_sequence_number+0x4f/0x65
> >  [<c12cc0e0>] ? tcp_v4_connect+0x3c1/0x417
> >  [<c12d6726>] ? inet_stream_connect+0x88/0x1fc
> >  [<c1110705>] ? _copy_from_user+0x2b/0x10e
> >  [<c129307d>] ? sys_connect+0x70/0x98
> >  [<c108df0f>] ? get_empty_filp+0x9f/0x121
> >  [<c108dfa0>] ? alloc_file+0xf/0x85
> >  [<c1293287>] ? sock_alloc_file+0x97/0xeb
> >  [<c108b758>] ? fd_install+0x1b/0x38
> >  [<c12932f6>] ? sock_map_fd+0x1b/0x20
> >  [<c1293bdf>] ? sys_socketcall+0x9d/0x291
> >  [<c1002750>] ? sysenter_do_call+0x12/0x26
> > Code:  Bad EIP value
> > EIP: [<00000000>] 0x0 SS:ESP 0068:ebf29dd0
> > CR2: 0000000000000000


I suspect following patch is needed

CC Roland Dreier <roland@purestorage.com> because he fixed the
default_mtu problem in commit ec831ea72ee5d7d47
(net: Add default_mtu() methods to blackhole dst_ops)

Thanks !

[PATCH] net: Add default_advmss() methods to blackhole dst_ops

Commit 0dbaee3b37e118a (net: Abstract default ADVMSS behind an
accessor.) introduced a possible crash in tcp_connect_init(), when
dst->default_advmss() is called from dst_metric_advmss()

Reported-by: George Spelvin <linux@horizon.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Roland Dreier <roland@purestorage.com>
---
 net/ipv4/route.c |    7 +++++++
 net/ipv6/route.c |    6 ++++++
 2 files changed, 13 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 788a3e7..5edb605 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2712,6 +2712,12 @@ static unsigned int ipv4_blackhole_default_mtu(c=
onst struct dst_entry *dst)
 	return 0;
 }
=20
+static unsigned int ipv4_blackhole_default_advmss(const struct dst_ent=
ry *dst)
+{
+	return 256;
+}
+
+
 static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 m=
tu)
 {
 }
@@ -2722,6 +2728,7 @@ static struct dst_ops ipv4_dst_blackhole_ops =3D =
{
 	.destroy		=3D	ipv4_dst_destroy,
 	.check			=3D	ipv4_blackhole_dst_check,
 	.default_mtu		=3D	ipv4_blackhole_default_mtu,
+	.default_advmss		=3D	ipv4_blackhole_default_advmss,
 	.update_pmtu		=3D	ipv4_rt_blackhole_update_pmtu,
 };
=20
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1c29f95..2eeeabb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -118,6 +118,11 @@ static unsigned int ip6_blackhole_default_mtu(cons=
t struct dst_entry *dst)
 	return 0;
 }
=20
+static unsigned int ip6_blackhole_default_advmss(const struct dst_entr=
y *dst)
+{
+	return 256;
+}
+
 static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mt=
u)
 {
 }
@@ -128,6 +133,7 @@ static struct dst_ops ip6_dst_blackhole_ops =3D {
 	.destroy		=3D	ip6_dst_destroy,
 	.check			=3D	ip6_dst_check,
 	.default_mtu		=3D	ip6_blackhole_default_mtu,
+	.default_advmss		=3D	ip6_blackhole_default_advmss,
 	.update_pmtu		=3D	ip6_rt_blackhole_update_pmtu,
 };
=20
