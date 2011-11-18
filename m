From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Fri, 18 Nov 2011 14:26:39 -0500
Message-ID: <20111118192639.GA10531@elliptictech.com>
References: <20111117190925.GA23214@elliptictech.com>
 <20111118162709.GA8342@elliptictech.com>
 <1321634378.3277.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4EC6A38E.6060404@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:57773 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755090Ab1KRT0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 14:26:49 -0500
Content-Disposition: inline
In-Reply-To: <4EC6A38E.6060404@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-11-18 20:27 +0200, Timo Ter=E4s wrote:
> On 11/18/2011 06:39 PM, Eric Dumazet wrote:
> > Le vendredi 18 novembre 2011 =E0 11:27 -0500, Nick Bowler a =E9crit=
 :
> >> On 2011-11-17 14:09 -0500, Nick Bowler wrote:
> >>> One of the tests we do with IPsec involves sending and receiving =
UDP
> >>> datagrams of all sizes from 1 to N bytes, where N is much larger =
than
> >>> the MTU.  In this particular instance, the MTU is 1500 bytes and =
N is
> >>> 10000 bytes.  This test works fine with IPv4, but I'm getting an
> >>> occasional oops on Linus' master with IPv6 (output at end of emai=
l).  We
> >>> also run the same test where N is less than the MTU, and it does =
not
> >>> trigger this issue.  The resulting fallout seems to eventually lo=
ck up
> >>> the box (although it continues to work for a little while afterwa=
rds).
> >>>
> >>> The issue appears timing related, and it doesn't always occur.  T=
his
> >>> probably also explains why I've not seen this issue before now, a=
s we
> >>> recently upgraded all our lab systems to machines from this centu=
ry
> >>> (with newfangled dual core processors).  This also makes it somew=
hat
> >>> hard to reproduce, but I can trigger it pretty reliably by runnin=
g 'yes'
> >>> in an ssh session (which doesn't use IPsec) while running the tes=
t:
> >>> it'll usually trigger in 2 or 3 runs.  The choice of cipher suite
> >>> appears to be irrelevant.
[...]
> > Please note commit 80c802f307 added a known bug, fixed in commit
> > 0b150932197b (xfrm: avoid possible oopse in xfrm_alloc_dst)
> >=20
> > Given commit 80c802f307 complexity, we can assume other bugs are to=
 be
> > fixed as well.
[...]
> This looks quite different. And I've been trying to figure out what
> causes this. However, the OOPS happens at ip6_fragment(), indicating
> that there was not enough allocated headroom (skb underrun). My initi=
al
> thought is ipv6 bug that just got uncovered by my commit; especially
> since ipv4 side is happy. But I haven't yet been able to figure this =
one
> out.
>=20
> Could you also try Herbert's latest patch set:
>   [0/6] Replace LL_ALLOCATED_SPACE to allow needed_headroom adjustmen=
t
>=20
> This changes how the headroom is calculated, and *might* fix this iss=
ue
> too if it's caused by the same SMP race condition which got uncovered=
 by
> my other commit earlier.

I applied all six of those patches, but I still see a crash.  However,
the call trace seems to be slightly different.  I've appended the trace
from the run with these paches applied, just in case it's significant.

NOTE: I did not carefully look at the traces of all the crashes I've
triggered.  This particular backtrace could potentially have appeared
before applying these patches and I would not have noticed.

[   45.318137] NET: Registered protocol family 15
[  125.153082] skb_under_panic: text:c1215d1d len:1462 put:14 head:f2ff=
1000 data:f2ff0ffa tail:0xf2ff15b0 end:0xf2ff1780 dev:p10p1
[  125.165124] ------------[ cut here ]------------
[  125.166001] kernel BUG at net/core/skbuff.c:147!
[  125.166001] invalid opcode: 0000 [#1] PREEMPT SMP=20
[  125.166001] Modules linked in: authenc esp6 xfrm6_mode_transport def=
late zlib_deflate ctr twofish_generic twofish_common camellia serpent b=
lowfish_generic blowfish_common cast5 des_generic cbc xcbc rmd160 sha51=
2_generic sha256_generic sha1_generic md5 hmac crypto_null af_key nfs l=
ockd auth_rpcgss sunrpc rng_core iptable_filter ip_tables ip6table_filt=
er ip6_tables x_tables psmouse sg r8169 mii evdev button ipv6 autofs4 u=
sbhid ohci_hcd ehci_hcd usbcore usb_common sd_mod radeon ttm drm_kms_he=
lper drm backlight i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect [last=
 unloaded: scsi_wait_scan]
[  125.196579]=20
[  125.196579] Pid: 2792, comm: udp_burst Not tainted 3.2.0-rc2-00115-g=
8b662f5 #54 System manufacturer System Product Name/M4A785T-M
[  125.196579] EIP: 0060:[<c11ff2af>] EFLAGS: 00010246 CPU: 0
[  125.196579] EIP is at skb_push+0x52/0x5b
[  125.196579] EAX: 00000089 EBX: f39cb000 ECX: 00000080 EDX: 00000003
[  125.196579] ESI: f39cb000 EDI: f39cb000 EBP: f29abb10 ESP: f29abae4
[  125.196579]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  125.196579] Process udp_burst (pid: 2792, ti=3Df29aa000 task=3Df3d8a=
2c0 task.ti=3Df29aa000)
[  125.196579] Stack:
[  125.196579]  c13a2756 c1215d1d 000005b6 0000000e f2ff1000 f2ff0ffa f=
2ff15b0 f2ff1780
[  125.196579]  f39cb000 00000000 f4fcdec0 f29abb28 c1215d1d 000086dd c=
1215d01 f29a5600
[  125.196579]  00000002 f29abb44 c120ee6d f4fcdec0 00000000 000005a8 f=
4fcde00 f29a5600
[  125.196579] Call Trace:
[  125.196579]  [<c1215d1d>] ? eth_header+0x1c/0x8b
[  125.196579]  [<c1215d1d>] eth_header+0x1c/0x8b
[  125.196579]  [<c1215d01>] ? eth_rebuild_header+0x53/0x53
[  125.196579]  [<c120ee6d>] dev_hard_header.constprop.12+0x28/0x32
[  125.196579]  [<c120ef74>] neigh_resolve_output+0xfd/0x138
[  125.196579]  [<f838af19>] ip6_finish_output2+0x280/0x31a [ipv6]
[  125.196579]  [<f838bf61>] ip6_fragment+0x3bd/0x939 [ipv6]
[  125.196579]  [<f838ac99>] ? NF_HOOK.constprop.4+0x30/0x30 [ipv6]
[  125.196579]  [<f838c51c>] ip6_finish_output+0x3f/0x4c [ipv6]
[  125.196579]  [<f838c5e1>] ip6_output+0xb8/0xc0 [ipv6]
[  125.196579]  [<c12520f1>] xfrm_output_resume+0x75/0x2c5
[  125.196579]  [<c125234e>] xfrm_output2+0xd/0xf
[  125.196579]  [<c12523e3>] xfrm_output+0x93/0x9c
[  125.196579]  [<f83a8b32>] xfrm6_output_finish+0x13/0x15 [ipv6]
[  125.196579]  [<f83a8a1f>] __xfrm6_output+0x108/0x10d [ipv6]
[  125.196579]  [<f83a8b7b>] xfrm6_output+0x47/0x4c [ipv6]
[  125.196579]  [<f838a7b4>] dst_output+0x12/0x15 [ipv6]
[  125.196579]  [<f838b36a>] ip6_local_out+0x17/0x1a [ipv6]
[  125.196579]  [<f838d27b>] ip6_push_pending_frames+0x2a4/0x346 [ipv6]
[  125.196579]  [<f839a035>] udp_v6_push_pending_frames+0x213/0x271 [ip=
v6]
[  125.196579]  [<f839ae84>] ? udpv6_sendmsg+0x68d/0x832 [ipv6]
[  125.196579]  [<f839aea6>] udpv6_sendmsg+0x6af/0x832 [ipv6]
[  125.196579]  [<c123fe84>] ? ip_fast_csum+0x30/0x30
[  125.196579]  [<c12403c0>] inet_sendmsg+0x4e/0x57
[  125.196579]  [<c11f8de6>] sock_sendmsg+0xbe/0xd9
[  125.196579]  [<c1052d64>] ? trace_hardirqs_off+0xb/0xd
[  125.196579]  [<c1270f48>] ? restore_all+0xf/0xf
[  125.196579]  [<c1055715>] ? trace_hardirqs_on_caller+0x10e/0x13f
[  125.196579]  [<c10542df>] ? mark_lock+0x26/0x1ea
[  125.196579]  [<c10acdbb>] ? fget_light+0x28/0x7c
[  125.196579]  [<c11fa23a>] sys_sendto+0xb1/0xcd
[  125.196579]  [<c10548e7>] ? __lock_acquire+0x444/0xb17
[  125.196579]  [<c1270bb1>] ? _raw_spin_unlock_irq+0x39/0x45
[  125.196579]  [<c1055038>] ? lock_release_non_nested+0x7e/0x1bb
[  125.196579]  [<c11fa26e>] sys_send+0x18/0x1a
[  125.196579]  [<c11fa877>] sys_socketcall+0xce/0x19a
[  125.196579]  [<c11507c0>] ? trace_hardirqs_on_thunk+0xc/0x10
[  125.196579]  [<c1271650>] sysenter_do_call+0x12/0x36
[  125.196579] Code: c1 85 f6 0f 45 de 53 ff b1 98 00 00 00 ff b1 94 00=
 00 00 50 ff b1 9c 00 00 00 52 ff 71 50 ff 75 04 68 56 27 3a c1 e8 5a c=
7 06 00 <0f> 0b 8d 65 f8 5b 5e 5d c3 55 89 c1 89 e5 56 53 83 79 54 00 8=
b=20
[  125.196579] EIP: [<c11ff2af>] skb_push+0x52/0x5b SS:ESP 0068:f29abae=
4
[  125.544777] ---[ end trace 3ca7fd586035bfb5 ]---
[  125.549588] BUG: sleeping function called from invalid context at ke=
rnel/rwsem.c:21
[  125.557655] in_atomic(): 0, irqs_disabled(): 0, pid: 2792, name: udp=
_burst
[  125.565415] INFO: lockdep is turned off.
[  125.569682] Pid: 2792, comm: udp_burst Tainted: G      D      3.2.0-=
rc2-00115-g8b662f5 #54
[  125.578640] Call Trace:
[  125.581476]  [<c10307b1>] ? console_unlock+0x1b6/0x1c9
[  125.587209]  [<c1024dbd>] __might_sleep+0xe2/0xe9
[  125.592457]  [<c126ff47>] down_read+0x17/0x3b
[  125.597311]  [<c105fc85>] acct_collect+0x39/0x134
[  125.602749]  [<c1032c08>] do_exit+0x188/0x5de
[  125.607604]  [<c1031464>] ? kmsg_dump+0xdf/0xe7
[  125.612710]  [<c1004737>] oops_end+0x92/0x9a
[  125.617647]  [<c1004868>] die+0x51/0x59
[  125.622008]  [<c1002626>] do_trap+0x89/0xa2
[  125.626665]  [<c1002776>] ? do_bounds+0x52/0x52
[  125.631781]  [<c10027e7>] do_invalid_op+0x71/0x7b
[  125.637157]  [<c11ff2af>] ? skb_push+0x52/0x5b
[  125.642175]  [<c1270f48>] ? restore_all+0xf/0xf
[  125.647256]  [<c10307b1>] ? console_unlock+0x1b6/0x1c9
[  125.653106]  [<c102369b>] ? need_resched+0x14/0x1e
[  125.658517]  [<c126f1f7>] ? preempt_schedule+0x40/0x46
[  125.664271]  [<c1030c19>] ? vprintk+0x390/0x3ae
[  125.669417]  [<c1052d01>] ? trace_hardirqs_off_caller+0x2e/0x86
[  125.675999]  [<c11507d0>] ? trace_hardirqs_off_thunk+0xc/0x10
[  125.682561]  [<c127140b>] error_code+0x5f/0x64
[  125.687553]  [<c1002776>] ? do_bounds+0x52/0x52
[  125.692621]  [<c11ff2af>] ? skb_push+0x52/0x5b
[  125.697723]  [<c1215d1d>] ? eth_header+0x1c/0x8b
[  125.702905]  [<c1215d1d>] eth_header+0x1c/0x8b
[  125.707963]  [<c1215d01>] ? eth_rebuild_header+0x53/0x53
[  125.713945]  [<c120ee6d>] dev_hard_header.constprop.12+0x28/0x32
[  125.720617]  [<c120ef74>] neigh_resolve_output+0xfd/0x138
[  125.726714]  [<f838af19>] ip6_finish_output2+0x280/0x31a [ipv6]
[  125.733397]  [<f838bf61>] ip6_fragment+0x3bd/0x939 [ipv6]
[  125.739483]  [<f838ac99>] ? NF_HOOK.constprop.4+0x30/0x30 [ipv6]
[  125.746261]  [<f838c51c>] ip6_finish_output+0x3f/0x4c [ipv6]
[  125.752772]  [<f838c5e1>] ip6_output+0xb8/0xc0 [ipv6]
[  125.758684]  [<c12520f1>] xfrm_output_resume+0x75/0x2c5
[  125.764729]  [<c125234e>] xfrm_output2+0xd/0xf
[  125.769960]  [<c12523e3>] xfrm_output+0x93/0x9c
[  125.775292]  [<f83a8b32>] xfrm6_output_finish+0x13/0x15 [ipv6]
[  125.781988]  [<f83a8a1f>] __xfrm6_output+0x108/0x10d [ipv6]
[  125.788515]  [<f83a8b7b>] xfrm6_output+0x47/0x4c [ipv6]
[  125.794659]  [<f838a7b4>] dst_output+0x12/0x15 [ipv6]
[  125.800633]  [<f838b36a>] ip6_local_out+0x17/0x1a [ipv6]
[  125.806889]  [<f838d27b>] ip6_push_pending_frames+0x2a4/0x346 [ipv6]
[  125.814176]  [<f839a035>] udp_v6_push_pending_frames+0x213/0x271 [ip=
v6]
[  125.821792]  [<f839ae84>] ? udpv6_sendmsg+0x68d/0x832 [ipv6]
[  125.828447]  [<f839aea6>] udpv6_sendmsg+0x6af/0x832 [ipv6]
[  125.834931]  [<c123fe84>] ? ip_fast_csum+0x30/0x30
[  125.840522]  [<c12403c0>] inet_sendmsg+0x4e/0x57
[  125.845919]  [<c11f8de6>] sock_sendmsg+0xbe/0xd9
[  125.851343]  [<c1052d64>] ? trace_hardirqs_off+0xb/0xd
[  125.857271]  [<c1270f48>] ? restore_all+0xf/0xf
[  125.862642]  [<c1055715>] ? trace_hardirqs_on_caller+0x10e/0x13f
[  125.869618]  [<c10542df>] ? mark_lock+0x26/0x1ea
[  125.875028]  [<c10acdbb>] ? fget_light+0x28/0x7c
[  125.880431]  [<c11fa23a>] sys_sendto+0xb1/0xcd
[  125.885688]  [<c10548e7>] ? __lock_acquire+0x444/0xb17
[  125.891665]  [<c1270bb1>] ? _raw_spin_unlock_irq+0x39/0x45
[  125.898057]  [<c1055038>] ? lock_release_non_nested+0x7e/0x1bb
[  125.904803]  [<c11fa26e>] sys_send+0x18/0x1a
[  125.909815]  [<c11fa877>] sys_socketcall+0xce/0x19a
[  125.915539]  [<c11507c0>] ? trace_hardirqs_on_thunk+0xc/0x10
[  125.922127]  [<c1271650>] sysenter_do_call+0x12/0x36
[  185.166028] INFO: rcu_preempt detected stalls on CPUs/tasks: {} (det=
ected by 1, t=3D60002 jiffies)
[  185.167017] INFO: Stall ended before state dump start

--=20
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
