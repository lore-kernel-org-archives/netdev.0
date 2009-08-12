From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
Date: Wed, 12 Aug 2009 16:00:41 -0400
Message-ID: <4A831F69.1080703@hp.com>
References: <4A76A009.40605@wpkg.org>	<1249346282.6479.5.camel@merlyn> <20090803.212007.253928711.davem@davemloft.net> <4A77D2BA.3040304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, john.dykstra1@gmail.com,
	mangoo@wpkg.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:20844 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbZHLUAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 16:00:47 -0400
In-Reply-To: <4A77D2BA.3040304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> David Miller a =E9crit :
>> From: John Dykstra <john.dykstra1@gmail.com>
>> Date: Mon, 03 Aug 2009 19:38:01 -0500
>>
>>> There's a good chance e51a67a9c8a2ea5c563f8c2ba6613fe2100ffe67 from=
 the
>>> current mainline will fix this problem.
>>>
>>> Dave, Eric's fix might be a candidate for -stable.  The symptom is
>>> usually a WARN, but the impact is significant.
>> Hmmm, I'll double-check.  I thought I had submitted this one.
>>
>> Thanks for the heads up.
>=20
> Hmm, I dont see how this patch could solve Tomasz case...
> Since commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
> (net: No more expensive sock_hold()/sock_put() on each tx)
> was not part of 2.6.30.4 AFAIK
>=20
> This is the WARN_ON(sk->sk_forward_alloc) that triggers...
>=20
> Sounds like a truesize mismatch rather than a sk_refcount one ?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

BTW, I've seen the same issue in 2.6.28 and 2.6.29 while doing a bunch
of NFS-over-UDP testing.  I've seen the issue reported in 2.6.27 as wel=
l,
but it went by ignored.  It's not easy to reproduce as it seems like it
requires quite a bit traffic over over multiple interfaces.

I've been looking at this for a while and haven't caught the bugger.

Here is the stack trace from 2.6.28:

May 13 16:17:38 dl380g6-2 kernel: [ 4473.086015] ------------[ cut here
]-------
-----
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086017] WARNING: at
net/ipv4/af_inet.c:
155 inet_sock_destruct+0x15d/0x182()
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086019] Modules linked in: sct=
p
libcrc32c sg edd nfsd auth_rpcgss exportfs nfs lockd nfs_acl sunrpc def=
late
zlib_deflate ctr twofish twofish_common camellia serpent blowfish des_g=
eneric
cbc aes_x86_64 aes_generic xcbc rmd160 sha256_generic sha1_generic cryp=
to_null
af_key loop serio_raw psmouse hpilo shpchp pci_hotplug container button=
 evdev
ext3 jbd mbcache ses enclosure sd_mod crc_t10dif usbhid hid ehci_hcd uh=
ci_hcd
mptsas mptscsih mptbase scsi_transport_sas bnx2 zlib_inflate cciss scsi=
_mod
thermal processor fan thermal_sys [last unloaded: ipmi_msghandler]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086053] Pid: 4570, comm: nfsd =
Not
tainted 2.6.28-clim-9-amd64 #1
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086055] Call Trace:
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086062]  [<ffffffff8024307f>]
warn_on_slowpath+0x58/0x7d
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086066]  [<ffffffff804b5ada>] =
?
_spin_unlock_irq+0x1c/0x35
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086069]  [<ffffffff8024813f>] =
?
local_bh_disable+0xe/0x10
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086072]  [<ffffffff804b58af>] =
?
_spin_lock_bh+0x23/0x29
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086074]  [<ffffffff8024826a>] =
?
local_bh_enable+0x88/0xa1
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086076]  [<ffffffff8024813f>] =
?
local_bh_disable+0xe/0x10
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086078]  [<ffffffff80454e77>]
inet_sock_destruct+0x15d/0x182
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086082]  [<ffffffff80400719>]
sk_free+0x1e/0xda
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086084]  [<ffffffff80400899>]
sk_common_release+0xc4/0xc9
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086087]  [<ffffffff8044c399>]
udp_lib_close+0x9/0xb
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086089]  [<ffffffff8045490a>]
inet_release+0x50/0x57
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086091]  [<ffffffff803fda24>]
sock_release+0x20/0xb1
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086093]  [<ffffffff803fdad7>]
sock_close+0x22/0x26
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086097]  [<ffffffff802bb867>]
__fput+0xd4/0x198
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086099]  [<ffffffff802bb940>]
fput+0x15/0x17
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086116]  [<ffffffffa025a67e>]
svc_sock_free+0x3b/0x51 [sunrpc]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086131]  [<ffffffffa0264834>]
svc_xprt_free+0x3b/0x4c [sunrpc]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086144]  [<ffffffffa02647f9>] =
?
svc_xprt_free+0x0/0x4c [sunrpc]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086147]  [<ffffffff8034f509>]
kref_put+0x43/0x4f
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086161]  [<ffffffffa0263c1a>]
svc_close_xprt+0x50/0x59 [sunrpc]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086174]  [<ffffffffa0263c6e>]
svc_close_all+0x4b/0x64 [sunrpc]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086187]  [<ffffffffa0259b6f>]
svc_destroy+0x99/0x13d [sunrpc]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086201]  [<ffffffffa0259cc7>]
svc_exit_thread+0xb4/0xbd [sunrpc]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086210]  [<ffffffffa02ed8f5>]
nfsd+0x277/0x291 [nfsd]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086218]  [<ffffffffa02ed67e>] =
?
nfsd+0x0/0x291 [nfsd]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086226]  [<ffffffffa02ed67e>] =
?
nfsd+0x0/0x291 [nfsd]
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086229]  [<ffffffff80256464>]
kthread+0x49/0x76
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086232]  [<ffffffff802134f9>]
child_rip+0xa/0x11
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086235]  [<ffffffff8025641b>] =
?
kthread+0x0/0x76
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086238]  [<ffffffff802134ef>] =
?
child_rip+0x0/0x11
May 13 16:17:38 dl380g6-2 kernel: [ 4473.086240] ---[ end trace
7a78cc0dbbc1385d ]---


And here is one from 2.6.29 (nearly identical):

15764.278127] ------------[ cut here]------------
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278130] WARNING: at
net/ipv4/af_inet.c:156 inet_sock_destruct+0x16f/0x194()
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278133] Hardware name: ProLian=
t DL380 G6
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278134] Modules linked in: sct=
p crc32c
libcrc32c edd nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc deflat=
e
zlib_deflate ctr twofish twofish_common camellia serpent blowfish des_g=
eneric
cbc aes_x86_64 aes_generic xcbc rmd160 sha256_generic sha1_generic cryp=
to_null
af_key loop psmouse hpilo serio_raw container shpchp pci_hotplug button=
 evdev
ext3 jbd mbcache ata_generic usbhid hid ata_piix libata mptsas ide_pci_=
generic
mptscsih ide_core mptbase ehci_hcd uhci_hcd scsi_transport_sas cciss bn=
x2
zlib_inflate e1000e scsi_mod thermal processor fan thermal_sys [last un=
loaded:
ipmi_msghandler]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278184] Pid: 5146, comm: nfsd =
Not
tainted 2.6.29-clim-2-amd64 #1
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278186] Call Trace:
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278194]  [<ffffffff80243317>]
warn_slowpath+0xd3/0x10f
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278200]  [<ffffffff80240107>] =
?
finish_task_switch+0x2b/0xc8
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278207]  [<ffffffff804c5e20>] =
?
_spin_lock+0x9/0xc
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278210]  [<ffffffff804c5f3d>] =
?
_spin_lock_bh+0x19/0x1e
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278214]  [<ffffffff8046429f>]
inet_sock_destruct+0x16f/0x194
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278220]  [<ffffffff8040d612>]
sk_free+0x1e/0xf9
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278223]  [<ffffffff8040d7b3>]
sk_common_release+0xc6/0xcb
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278227]  [<ffffffff8045b14c>]
udp_lib_close+0x9/0xb
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278231]  [<ffffffff80463d83>]
inet_release+0x50/0x57
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278234]  [<ffffffff8040a93d>]
sock_release+0x1a/0x76
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278237]  [<ffffffff8040a9bb>]
sock_close+0x22/0x26
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278242]  [<ffffffff802c34e0>]
__fput+0xd4/0x199
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278246]  [<ffffffff802c35bd>]
fput+0x18/0x1a
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278274]  [<ffffffffa028c2cf>]
svc_sock_free+0x3b/0x51 [sunrpc]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278296]  [<ffffffffa02960d6>]
svc_xprt_free+0x3b/0x4b [sunrpc]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278317]  [<ffffffffa029609b>]
? svc_xprt_free+0x0/0x4b [sunrpc]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278321]  [<ffffffff80358d15>]
kref_put+0x4b/0x57
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278342]  [<ffffffffa02954db>]
svc_close_xprt+0x50/0x59 [sunrpc]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278362]  [<ffffffffa029552f>]
svc_close_all+0x4b/0x64 [sunrpc]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278383]  [<ffffffffa028b827>]
svc_destroy+0x99/0x13d [sunrpc]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278404]  [<ffffffffa028b97f>]
svc_exit_thread+0xb4/0xbd [sunrpc]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278419]  [<ffffffffa03178cc>]
nfsd+0x244/0x25e [nfsd]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278431]  [<ffffffffa0317688>] =
?
nfsd+0x0/0x25e [nfsd]
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278436]  [<ffffffff802561c1>]
kthread+0x49/0x76
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278440]  [<ffffffff8021241a>]
child_rip+0xa/0x20
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278443]  [<ffffffff80256178>] =
?
kthread+0x0/0x76
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278446]  [<ffffffff80212410>] =
?
child_rip+0x0/0x20
Jun 29 19:48:50 dl380g6-3 kernel: [15764.278448] ---[ end trace
fdb0852e39bf7319 ]---

It smells like a race to me but I can't find/prove it.

-vlad
