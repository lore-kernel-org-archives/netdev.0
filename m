From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridge netfilter output bug on 2.6.39
Date: Tue, 24 May 2011 17:39:03 +0200
Message-ID: <1306251543.3026.57.camel@edumazet-laptop>
References: <20110524074156.58eb30f8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42266 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab1EXPjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 11:39:08 -0400
Received: by wwa36 with SMTP id 36so7469112wwa.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 08:39:06 -0700 (PDT)
In-Reply-To: <20110524074156.58eb30f8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 mai 2011 =C3=A0 07:41 -0700, Stephen Hemminger a =C3=A9crit=
 :
> Got this bug report against 2.6.39.  Looks like ip_fragment() is now
> getting confused when called from bridge netfilter. Probably related =
to
> the changes to do ip_options_compile for the bridge input path.
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D35672
>=20
> May 23 02:04:24 lxc kernel: [99498.329036] BUG: unable to handle kern=
el NULL
> pointer dereference at 00000004
> May 23 02:04:24 lxc kernel: [99498.330017] IP: [<c143d6bf>] dst_mtu+0=
xb/0x1c
> May 23 02:04:24 lxc kernel: [99498.330017] *pdpt =3D 000000001fb55001=
 *pde =3D
> 0000000000000000
> May 23 02:04:24 lxc kernel: [99498.330017] Oops: 0000 [#1] SMP
> May 23 02:04:24 lxc kernel: [99498.330017] last sysfs file:
> /sys/devices/virtual/vc/vcsa8/uevent
> May 23 02:04:24 lxc kernel: [99498.330017] Modules linked in: lp ppde=
v
> parport_pc parport fuse firewire_ohci firewire_core crc_itu_t intel_a=
gp
> intel_gtt
> May 23 02:04:24 lxc kernel: [99498.330017]
> May 23 02:04:24 lxc kernel: [99498.330017] Pid: 0, comm: swapper Not =
tainted
> 2.6.39-lxc #2 .   .  /IP35 Pro XE(Intel P35-ICH9R)
> May 23 02:04:24 lxc kernel: [99498.330017] EIP: 0060:[<c143d6bf>] EFL=
AGS:
> 00010246 CPU: 0
> May 23 02:04:24 lxc kernel: [99498.330017] EIP is at dst_mtu+0xb/0x1c
> May 23 02:04:24 lxc kernel: [99498.330017] EAX: 00000000 EBX: e90b6b4=
0 ECX:
> effc981c EDX: effc9000
> May 23 02:04:24 lxc kernel: [99498.330017] ESI: c1a0d84e EDI: dda6331=
e EBP:
> f080bb44 ESP: f080bb44
> May 23 02:04:24 lxc kernel: [99498.330017]  DS: 007b ES: 007b FS: 00d=
8 GS: 0000
> SS: 0068
> May 23 02:04:24 lxc kernel: [99498.330017] Process swapper (pid: 0, t=
i=3Df080a000
> task=3Dc172b7e0 task.ti=3Dc1724000)
> May 23 02:04:24 lxc kernel: [99498.330017] Stack:
> May 23 02:04:24 lxc kernel: [99498.330017]  f080bb8c c143e20d 0000000=
4 f080bb88
> c141aab2 c14b46db effc9000 00000014
> May 23 02:04:24 lxc kernel: [99498.330017]  c14b8a44 effc9000 e90b6b4=
0 00000014
> effc981c e90b6b58 cd472800 e90b6b40
> May 23 02:04:24 lxc kernel: [99498.330017]  c14b8a44 dda6331e f080bb9=
8 c14b8aa0
> e90b6b40 f080bba8 c14b881a e90b6b40
> May 23 02:04:24 lxc kernel: [99498.330017] Call Trace:
> May 23 02:04:24 lxc kernel: [99498.330017]  [<c143e20d>] ip_fragment+=
0xb5/0x66c
> May 23 02:04:24 lxc kernel: [99498.330017]  [<c141aab2>] ?
> nf_hook_slow+0x43/0xd1
> May 23 02:04:24 lxc kernel: [99498.330017]  [<c14b46db>] ? br_flood+0=
x83/0x83
> May 23 02:04:24 lxc kernel: [99498.330017]  [<c14b8a44>] ?
> br_parse_ip_options+0x1b0/0x1b0
> May 23 02:04:24 lxc kernel: [99498.330017]  [<c14b8a44>] ?
> br_parse_ip_options+0x1b0/0x1b0
> May 23 02:04:24 lxc kernel: [99498.330017]  [<c14b8aa0>]
> br_nf_dev_queue_xmit+0x5c/0x68
> --

I would say its more likely a problem with dst metrics changes

In this crash, we dereference a NULL dst->_metrics 'pointer' in
dst_metric_raw(dst, RTAX_MTU);

Hmm, it seems __dst_destroy_metrics_generic() doesnt add the
DST_METRICS_READ_ONLY flag ?

[PATCH] net: fix __dst_destroy_metrics_generic()

dst_default_metrics is readonly, we dont want to kfree() it later.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/core/dst.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 81a4fa1..1badc98 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -315,7 +315,7 @@ void __dst_destroy_metrics_generic(struct dst_entry=
 *dst, unsigned long old)
 {
 	unsigned long prev, new;
=20
-	new =3D (unsigned long) dst_default_metrics;
+	new =3D ((unsigned long) dst_default_metrics) | DST_METRICS_READ_ONLY=
;
 	prev =3D cmpxchg(&dst->_metrics, old, new);
 	if (prev =3D=3D old)
 		kfree(__DST_METRICS_PTR(old));


