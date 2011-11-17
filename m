From: Nick Bowler <nbowler@elliptictech.com>
Subject: Occasional oops with IPSec and IPv6.
Date: Thu, 17 Nov 2011 14:09:25 -0500
Message-ID: <20111117190925.GA23214@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.elliptictech.com ([209.217.122.41]:55881 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118Ab1KQTJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 14:09:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

One of the tests we do with IPsec involves sending and receiving UDP
datagrams of all sizes from 1 to N bytes, where N is much larger than
the MTU.  In this particular instance, the MTU is 1500 bytes and N is
10000 bytes.  This test works fine with IPv4, but I'm getting an
occasional oops on Linus' master with IPv6 (output at end of email).  W=
e
also run the same test where N is less than the MTU, and it does not
trigger this issue.  The resulting fallout seems to eventually lock up
the box (although it continues to work for a little while afterwards).

The issue appears timing related, and it doesn't always occur.  This
probably also explains why I've not seen this issue before now, as we
recently upgraded all our lab systems to machines from this century
(with newfangled dual core processors).  This also makes it somewhat
hard to reproduce, but I can trigger it pretty reliably by running 'yes=
'
in an ssh session (which doesn't use IPsec) while running the test:
it'll usually trigger in 2 or 3 runs.  The choice of cipher suite
appears to be irrelevant.

I built a relatively old kernel (2.6.34) and could not reproduce the
issue there, so I ran a git bisect.  It pointed to the following, which
(unsurprisingly) no longer reverts cleanly.

Let me know if you need any more info.  I'll see if I can reproduce the
issue with a smaller test case...

  80c802f3073e84c956846e921e8a0b02dfa3755f is the first bad commit
  commit 80c802f3073e84c956846e921e8a0b02dfa3755f
  Author: Timo Ter=E4s <timo.teras@iki.fi>
  Date:   Wed Apr 7 00:30:05 2010 +0000
 =20
      xfrm: cache bundles instead of policies for outgoing flows
     =20
      __xfrm_lookup() is called for each packet transmitted out of
      system. The xfrm_find_bundle() does a linear search which can
      kill system performance depending on how many bundles are
      required per policy.
     =20
      This modifies __xfrm_lookup() to store bundles directly in
      the flow cache. If we did not get a hit, we just create a new
      bundle instead of doing slow search. This means that we can now
      get multiple xfrm_dst's for same flow (on per-cpu basis).
     =20
      Signed-off-by: Timo Teras <timo.teras@iki.fi>
      Signed-off-by: David S. Miller <davem@davemloft.net>
 =20
  :040000 040000 d8e60f5fa4c1329f450d9c7cdf98b34e6a177f22 9f576e68e5bf4=
ce357d7f0305aee5f410250dfe2 M	include
  :040000 040000 f2876df688ee36907af7b4123eea96592faaed3e a3f6f6f94f030=
9106856cd99b38ec90b024eb016 M	net

  [  138.024462] skb_under_panic: text:f83aff05 len:1470 put:14 head:f2=
ee4800 data:f2ee47fa tail:0xf2ee4db8 end:0xf2ee4f40 dev:p10p1
  [  138.036298] ------------[ cut here ]------------
  [  138.037077] kernel BUG at net/core/skbuff.c:147!
  [  138.037077] invalid opcode: 0000 [#1] PREEMPT SMP=20
  [  138.037077] Modules linked in: authenc esp6 xfrm6_mode_transport d=
eflate zlib_deflate ctr twofish_generic twofish_common camellia serpent=
 blowfish_generic blowfish_common cast5 des_generic cbc xcbc rmd160 sha=
512_generic sha256_generic sha1_generic md5 hmac crypto_null af_key nfs=
 lockd auth_rpcgss sunrpc rng_core ip6table_filter ip6_tables iptable_f=
ilter ip_tables x_tables psmouse sg r8169 mii evdev button ipv6 autofs4=
 ehci_hcd sd_mod ohci_hcd usbcore usb_common radeon ttm drm_kms_helper =
drm backlight i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect [last unlo=
aded: scsi_wait_scan]
  [  138.067337]=20
  [  138.067337] Pid: 2846, comm: udp_scan Not tainted 3.2.0-rc2-00043-=
gaa1b052 #53 System manufacturer System Product Name/M4A785T-M
  [  138.067337] EIP: 0060:[<c11ff3d7>] EFLAGS: 00010246 CPU: 0
  [  138.067337] EIP is at skb_push+0x52/0x5b
  [  138.067337] EAX: 00000089 EBX: f3abf000 ECX: 00000080 EDX: 0000000=
3
  [  138.067337] ESI: f3abf000 EDI: f2ee4808 EBP: f2655b70 ESP: f2655b4=
4
  [  138.067337]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
  [  138.067337] Process udp_scan (pid: 2846, ti=3Df2654000 task=3Df268=
3420 task.ti=3Df2654000)
  [  138.067337] Stack:
  [  138.067337]  c13a2802 f83aff05 000005be 0000000e f2ee4800 f2ee47fa=
 f2ee4db8 f2ee4f40
  [  138.067337]  f3abf000 f2725780 f4454d18 f2655b90 f83aff05 f4454d08=
 00000000 f4454c00
  [  138.067337]  f27256c0 f3dfc528 f26fec38 f2655be4 f83b0f58 00000201=
 f2655ba4 00000046
  [  138.067337] Call Trace:
  [  138.067337]  [<f83aff05>] ? ip6_finish_output2+0x26c/0x31a [ipv6]
  [  138.067337]  [<f83aff05>] ip6_finish_output2+0x26c/0x31a [ipv6]
  [  138.067337]  [<f83b0f58>] ip6_fragment+0x3b4/0x941 [ipv6]
  [  138.067337]  [<f83afc99>] ? NF_HOOK.constprop.4+0x30/0x30 [ipv6]
  [  138.067337]  [<f83b1524>] ip6_finish_output+0x3f/0x4c [ipv6]
  [  138.067337]  [<f83b15e9>] ip6_output+0xb8/0xc0 [ipv6]
  [  138.067337]  [<c1252241>] xfrm_output_resume+0x75/0x2c5
  [  138.067337]  [<c125249e>] xfrm_output2+0xd/0xf
  [  138.067337]  [<c1252533>] xfrm_output+0x93/0x9c
  [  138.067337]  [<f83cdb5e>] xfrm6_output_finish+0x13/0x15 [ipv6]
  [  138.067337]  [<f83cda4b>] __xfrm6_output+0x108/0x10d [ipv6]
  [  138.067337]  [<f83cdba7>] xfrm6_output+0x47/0x4c [ipv6]
  [  138.067337]  [<f83af7b4>] dst_output+0x12/0x15 [ipv6]
  [  138.067337]  [<f83b036a>] ip6_local_out+0x17/0x1a [ipv6]
  [  138.067337]  [<f83b2283>] ip6_push_pending_frames+0x2a4/0x346 [ipv=
6]
  [  138.067337]  [<f83bf055>] udp_v6_push_pending_frames+0x213/0x271 [=
ipv6]
  [  138.067337]  [<f83bfea4>] ? udpv6_sendmsg+0x68d/0x832 [ipv6]
  [  138.067337]  [<f83bfec6>] udpv6_sendmsg+0x6af/0x832 [ipv6]
  [  138.067337]  [<c123ffc4>] ? ip_fast_csum+0x30/0x30
  [  138.067337]  [<c1240500>] inet_sendmsg+0x4e/0x57
  [  138.067337]  [<c11f8f0e>] sock_sendmsg+0xbe/0xd9
  [  138.067337]  [<c10542df>] ? mark_lock+0x26/0x1ea
  [  138.067337]  [<c10542df>] ? mark_lock+0x26/0x1ea
  [  138.067337]  [<c10548e7>] ? __lock_acquire+0x444/0xb17
  [  138.067337]  [<c10acd97>] ? fget_light+0x28/0x7c
  [  138.067337]  [<c11fa362>] sys_sendto+0xb1/0xcd
  [  138.067337]  [<c10548e7>] ? __lock_acquire+0x444/0xb17
  [  138.067337]  [<c1021085>] ? __wake_up+0x15/0x3b
  [  138.067337]  [<c10d2f0f>] ? fsnotify+0x64/0x208
  [  138.067337]  [<c102866b>] ? get_parent_ip+0xb/0x31
  [  138.067337]  [<c1055038>] ? lock_release_non_nested+0x7e/0x1bb
  [  138.067337]  [<c11fa396>] sys_send+0x18/0x1a
  [  138.067337]  [<c11fa99f>] sys_socketcall+0xce/0x19a
  [  138.067337]  [<c11508f0>] ? trace_hardirqs_on_thunk+0xc/0x10
  [  138.067337]  [<c12717d0>] sysenter_do_call+0x12/0x36
  [  138.067337] Code: c1 85 f6 0f 45 de 53 ff b1 98 00 00 00 ff b1 94 =
00 00 00 50 ff b1 9c 00 00 00 52 ff 71 50 ff 75 04 68 02 28 3a c1 e8 86=
 c7 06 00 <0f> 0b 8d 65 f8 5b 5e 5d c3 55 89 c1 89 e5 56 53 83 79 54 00=
 8b=20
  [  138.067337] EIP: [<c11ff3d7>] skb_push+0x52/0x5b SS:ESP 0068:f2655=
b44
  [  138.398457] ---[ end trace cb87617e5ef07196 ]---
  [  138.404512] BUG: sleeping function called from invalid context at =
kernel/rwsem.c:21
  [  138.412662] in_atomic(): 0, irqs_disabled(): 0, pid: 2846, name: u=
dp_scan
  [  138.420076] INFO: lockdep is turned off.
  [  138.424721] Pid: 2846, comm: udp_scan Tainted: G      D      3.2.0=
-rc2-00043-gaa1b052 #53
  [  138.433542] Call Trace:
  [  138.436387]  [<c10307b1>] ? console_unlock+0x1b6/0x1c9
  [  138.442035]  [<c1024dbd>] __might_sleep+0xe2/0xe9
  [  138.447249]  [<c127009f>] down_read+0x17/0x3b
  [  138.452139]  [<c105fc85>] acct_collect+0x39/0x134
  [  138.457431]  [<c1032c08>] do_exit+0x188/0x5de
  [  138.462369]  [<c1031464>] ? kmsg_dump+0xdf/0xe7
  [  138.467328]  [<c1004737>] oops_end+0x92/0x9a
  [  138.472238]  [<c1004868>] die+0x51/0x59
  [  138.476546]  [<c1002626>] do_trap+0x89/0xa2
  [  138.481264]  [<c1002776>] ? do_bounds+0x52/0x52
  [  138.486308]  [<c10027e7>] do_invalid_op+0x71/0x7b
  [  138.491727]  [<c11ff3d7>] ? skb_push+0x52/0x5b
  [  138.496685]  [<c12710a0>] ? restore_all+0xf/0xf
  [  138.501659]  [<c10307b1>] ? console_unlock+0x1b6/0x1c9
  [  138.507479]  [<c102369b>] ? need_resched+0x14/0x1e
  [  138.512845]  [<c126f34f>] ? preempt_schedule+0x40/0x46
  [  138.518685]  [<c1030c19>] ? vprintk+0x390/0x3ae
  [  138.523751]  [<c1052d01>] ? trace_hardirqs_off_caller+0x2e/0x86
  [  138.530302]  [<c1150900>] ? trace_hardirqs_off_thunk+0xc/0x10
  [  138.536680]  [<c1271563>] error_code+0x5f/0x64
  [  138.541625]  [<c1002776>] ? do_bounds+0x52/0x52
  [  138.546741]  [<c11ff3d7>] ? skb_push+0x52/0x5b
  [  138.551812]  [<f83aff05>] ? ip6_finish_output2+0x26c/0x31a [ipv6]
  [  138.558652]  [<f83aff05>] ip6_finish_output2+0x26c/0x31a [ipv6]
  [  138.565308]  [<f83b0f58>] ip6_fragment+0x3b4/0x941 [ipv6]
  [  138.571373]  [<f83afc99>] ? NF_HOOK.constprop.4+0x30/0x30 [ipv6]
  [  138.578173]  [<f83b1524>] ip6_finish_output+0x3f/0x4c [ipv6]
  [  138.584534]  [<f83b15e9>] ip6_output+0xb8/0xc0 [ipv6]
  [  138.590172]  [<c1252241>] xfrm_output_resume+0x75/0x2c5
  [  138.596199]  [<c125249e>] xfrm_output2+0xd/0xf
  [  138.601362]  [<c1252533>] xfrm_output+0x93/0x9c
  [  138.606581]  [<f83cdb5e>] xfrm6_output_finish+0x13/0x15 [ipv6]
  [  138.613283]  [<f83cda4b>] __xfrm6_output+0x108/0x10d [ipv6]
  [  138.619672]  [<f83cdba7>] xfrm6_output+0x47/0x4c [ipv6]
  [  138.625676]  [<f83af7b4>] dst_output+0x12/0x15 [ipv6]
  [  138.631628]  [<f83b036a>] ip6_local_out+0x17/0x1a [ipv6]
  [  138.637749]  [<f83b2283>] ip6_push_pending_frames+0x2a4/0x346 [ipv=
6]
  [  138.644714]  [<f83bf055>] udp_v6_push_pending_frames+0x213/0x271 [=
ipv6]
  [  138.652186]  [<f83bfea4>] ? udpv6_sendmsg+0x68d/0x832 [ipv6]
  [  138.658621]  [<f83bfec6>] udpv6_sendmsg+0x6af/0x832 [ipv6]
  [  138.665021]  [<c123ffc4>] ? ip_fast_csum+0x30/0x30
  [  138.670635]  [<c1240500>] inet_sendmsg+0x4e/0x57
  [  138.676069]  [<c11f8f0e>] sock_sendmsg+0xbe/0xd9
  [  138.681502]  [<c10542df>] ? mark_lock+0x26/0x1ea
  [  138.686811]  [<c10542df>] ? mark_lock+0x26/0x1ea
  [  138.692188]  [<c10548e7>] ? __lock_acquire+0x444/0xb17
  [  138.698257]  [<c10acd97>] ? fget_light+0x28/0x7c
  [  138.703692]  [<c11fa362>] sys_sendto+0xb1/0xcd
  [  138.708962]  [<c10548e7>] ? __lock_acquire+0x444/0xb17
  [  138.714935]  [<c1021085>] ? __wake_up+0x15/0x3b
  [  138.720165]  [<c10d2f0f>] ? fsnotify+0x64/0x208
  [  138.725623]  [<c102866b>] ? get_parent_ip+0xb/0x31
  [  138.731295]  [<c1055038>] ? lock_release_non_nested+0x7e/0x1bb
  [  138.737980]  [<c11fa396>] sys_send+0x18/0x1a
  [  138.743113]  [<c11fa99f>] sys_socketcall+0xce/0x19a
  [  138.748806]  [<c11508f0>] ? trace_hardirqs_on_thunk+0xc/0x10
  [  138.755407]  [<c12717d0>] sysenter_do_call+0x12/0x36
  [  198.038028] INFO: rcu_preempt detected stalls on CPUs/tasks: {} (d=
etected by 1, t=3D60002 jiffies)
  [  198.039017] INFO: Stall ended before state dump start

Thanks,
--=20
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
