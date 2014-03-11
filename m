From: Jakub =?utf-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Tue, 11 Mar 2014 13:42:26 +0100
Message-ID: <20140311134226.7a200693@north>
References: <20140310014452.144b0491@north>
 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140310131909.33a3042c@north>
 <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140311014649.1716bde1@north>
 <20140311120059.GB32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	Fan Du <fan.du@windriver.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:6342 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755797AbaCKMmh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 08:42:37 -0400
In-Reply-To: <20140311120059.GB32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Mar 2014 13:00:59 +0100, Steffen Klassert wrote:
> On Tue, Mar 11, 2014 at 01:46:49AM +0100, Jakub Kici=C5=84ski wrote:
> >=20
> > I bisected the other issue to be caused/uncovered by:
> >=20
> > commit 1a1ccc96abb2ed9b8fbb71018e64b97324caef53
> > Author: Steffen Klassert <steffen.klassert@secunet.com>
> > Date:   Wed Feb 19 10:07:34 2014 +0100
> >=20
> >     xfrm: Remove caching of xfrm_policy_sk_bundles
> >    =20
> >     We currently cache socket policy bundles at xfrm_policy_sk_bund=
les.
> >     These cached bundles are never used. Instead we create and cach=
e
> >     a new one whenever xfrm_lookup() is called on a socket policy.
> >    =20
> >     Most protocols cache the used routes to the socket, so let's
> >     remove the unused caching of socket policy bundles in xfrm.
> >    =20
> >     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> >=20
>=20
> This patch should affect only on the usage of IPsec socket policies.
> Do you use socket policies, or do you use IPsec at all?

I'm running pretty standard Fedora 20 installation here (notably with
NetowrkManager removed).  Two daemons that trigger flow_cache warnings
are libvirt and rtkit.=20

I'm not sure how to check IPsec policies, ip xfrm state/policy don't
show anything.

> >=20
> > Machine freezes after FLOW_HASH_RND_PERIOD (default 10 minutes).
> > Now get this warning during boot:
> >=20
> > [   31.664820] ------------[ cut here ]------------
> > [   31.664824] WARNING: CPU: 2 PID: 3560 at /home/kuba/Development/=
Linux/net-next/lib/list_debug.c:33 __list_add+0xac/0xc0()
> > [   31.664826] list_add corruption. prev->next should be next (ffff=
880224579598), but was           (null). (prev=3Dffff8802106140e8).
> > [   31.664827] Modules linked in: xt_CHECKSUM tun bridge stp llc cc=
m xt_conntrack iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4=
 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ftdi_s=
io arc4 rt2800pci rt2800mmio rt2800lib crc_ccitt eeprom_93cx6 rt2x00pci=
 kvm_amd rt2x00mmio rt2x00lib mac80211 kvm snd_ca0106 cfg80211 e1000e s=
nd_ac97_codec ac97_bus microcode serio_raw ptp i2c_piix4 k10temp acpi_c=
pufreq pps_core wmi r8169 mii rfkill nfsd auth_rpcgss nfs_acl lockd bin=
fmt_misc sunrpc usb_storage radeon drm_kms_helper ttm
> > [   31.664855] CPU: 2 PID: 3560 Comm: (t-daemon) Not tainted 3.14.0=
-rc2-1a1ccc96abb2ed9b8fbb71018e64b97324caef53+ #11
> > [   31.664856] Hardware name: Gigabyte Technology Co., Ltd. GA-MA79=
0XT-UD4P/GA-MA790XT-UD4P, BIOS F9b 08/17/2012
> > [   31.664857]  0000000000000009 ffff8802242e7c70 ffffffff81627878 =
ffff8802242e7cb8
> > [   31.664859]  ffff8802242e7ca8 ffffffff8104a28d ffff880210610ea8 =
ffff880224579598
> > [   31.664861]  ffff8802106140e8 ffff880224578000 0000000000000000 =
ffff8802242e7d08
> > [   31.664863] Call Trace:
> > [   31.664865]  [<ffffffff81627878>] dump_stack+0x4d/0x66
> > [   31.664867]  [<ffffffff8104a28d>] warn_slowpath_common+0x7d/0xa0
> > [   31.664869]  [<ffffffff8104a2fc>] warn_slowpath_fmt+0x4c/0x50
> > [   31.664871]  [<ffffffff812fdd8c>] __list_add+0xac/0xc0
> > [   31.664873]  [<ffffffff81055d33>] __internal_add_timer+0x113/0x1=
30
> > [   31.664875]  [<ffffffff81055f47>] internal_add_timer+0x17/0x40
> > [   31.664876]  [<ffffffff810587b2>] mod_timer+0x102/0x230
> > [   31.664878]  [<ffffffff810588f8>] add_timer+0x18/0x20
> > [   31.664880]  [<ffffffff81572204>] flow_cache_init+0x224/0x2b0
> > [   31.664882]  [<ffffffff815f7247>] xfrm_net_init+0x227/0x360
> > [   31.664884]  [<ffffffff815f7171>] ? xfrm_net_init+0x151/0x360
> > [   31.664886]  [<ffffffff81553131>] ops_init+0x41/0x150
> > [   31.664888]  [<ffffffff815532b3>] setup_net+0x73/0x110
> > [   31.664890]  [<ffffffff815537f2>] copy_net_ns+0x72/0x100
> > [   31.664892]  [<ffffffff81072619>] create_new_namespaces+0xf9/0x1=
90
> > [   31.664894]  [<ffffffff81072891>] unshare_nsproxy_namespaces+0x6=
1/0xa0
> > [   31.664895]  [<ffffffff81049949>] SyS_unshare+0x159/0x270
> > [   31.664897]  [<ffffffff81638092>] system_call_fastpath+0x16/0x1b
> >=20
>=20
> I was unable to reproduce this here, but it looks like the flowcache
> namespace changes are still not complete. We leak an active timer
> and all the allocated resources when we exit a namespace.

I also failed to reproduce it reliably on a VM. On a VM it happens 50%
of the times while on physical machine it's triggered reliably on every
boot.

While playing restarting libvirt and rtkit to see it they produce any
xfrm noise I got this:

[  292.624771] BUG: soft lockup - CPU#1 stuck for 22s! [(t-daemon):4655=
]
[  292.624777] Modules linked in: bnep bluetooth 6lowpan_iphc fuse ipt_=
MASQUERADE xt_CHECKSUM tun bridge stp llc ccm xt_conntrack iptable_nat =
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptabl=
e_mangle iptable_security iptable_raw arc4 rt2800pci rt2800mmio rt2800l=
ib crc_ccitt eeprom_93cx6 rt2x00pci rt2x00mmio rt2x00lib ftdi_sio kvm_a=
md mac80211 cfg80211 kvm e1000e snd_ca0106 snd_ac97_codec i2c_piix4 rfk=
ill microcode ac97_bus serio_raw k10temp r8169 mii acpi_cpufreq ptp wmi=
 pps_core nfsd auth_rpcgss nfs_acl lockd binfmt_misc sunrpc usb_storage=
 radeon drm_kms_helper ttm
[  292.624884] CPU: 1 PID: 4655 Comm: (t-daemon) Not tainted 3.14.0-rc2=
d3623099d3509fa68fa28235366049dd3156c63a+ #10
[  292.624889] Hardware name: Gigabyte Technology Co., Ltd. GA-MA790XT-=
UD4P/GA-MA790XT-UD4P, BIOS F9b 08/17/2012
[  292.624894] task: ffff8802228753c0 ti: ffff8800b515a000 task.ti: fff=
f8800b515a000
[  292.624899] RIP: 0010:[<ffffffff81072a63>]  [<ffffffff81072a63>] raw=
_notifier_chain_register+0x23/0x40
[  292.624910] RSP: 0018:ffff8800b515bd98  EFLAGS: 00000246
[  292.624914] RAX: ffff8802014d0ec0 RBX: ffffffff81c23340 RCX: 0000000=
000000004
[  292.624919] RDX: 0000000000000000 RSI: ffff8800b50f1fc0 RDI: ffff880=
2014d0ec8
[  292.624923] RBP: ffff8800b515bd98 R08: 0000000000000000 R09: 0000000=
000000000
[  292.624928] R10: 0000000000000000 R11: 0000000000000000 R12: fffffff=
f81c233a8
[  292.624933] R13: 0000000180040004 R14: 0000000000000246 R15: 000060f=
d00000000
[  292.624939] FS:  00007fa39d6118c0(0000) GS:ffff88022fc80000(0000) kn=
lGS:00000000e26ffb40
[  292.624944] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  292.624948] CR2: 00007fa4b45a7f40 CR3: 00000000bd2e6000 CR4: 0000000=
0000007e0
[  292.624951] Stack:
[  292.624955]  ffff8800b515bdb0 ffffffff8161ff8a ffff8800b50f1100 ffff=
8800b515bde0
[  292.624965]  ffffffff815721be ffff8800b50f1100 0000000000000000 ffff=
8800b50f1160
[  292.624974]  ffff8800b50f1290 ffff8800b515be28 ffffffff815f7321 ffff=
ffff815f7231
[  292.624982] Call Trace:
[  292.624992]  [<ffffffff8161ff8a>] register_cpu_notifier+0x2a/0x40
[  292.625001]  [<ffffffff815721be>] flow_cache_init+0x1de/0x2b0
[  292.625009]  [<ffffffff815f7321>] xfrm_net_init+0x241/0x380
[  292.625016]  [<ffffffff815f7231>] ? xfrm_net_init+0x151/0x380
[  292.625025]  [<ffffffff81553131>] ops_init+0x41/0x150
[  292.625033]  [<ffffffff815532b3>] setup_net+0x73/0x110
[  292.625042]  [<ffffffff815537f2>] copy_net_ns+0x72/0x100
[  292.625050]  [<ffffffff81072619>] create_new_namespaces+0xf9/0x190
[  292.625058]  [<ffffffff81072891>] unshare_nsproxy_namespaces+0x61/0x=
a0
[  292.625065]  [<ffffffff81049949>] SyS_unshare+0x159/0x270
[  292.625073]  [<ffffffff816381d2>] system_call_fastpath+0x16/0x1b
[  292.625077] Code: e9 7b ff ff ff 0f 1f 00 66 66 66 66 90 55 48 8b 07=
 48 89 e5 48 85 c0 74 21 8b 56 10 3b 50 10 7e 0c eb 17 0f 1f 44 00 00 3=
9 50 10 <7c> 0d 48 8d 78 08 48 8b 40 08 48 85 c0 75 ee 48 89 46 08 31 c=
0


This is net-next with head at d3623099d3509fa68fa28235366049dd3156c63a

It takes a few restarts of libvirt/rtkit-daemon to trigger, but I've
definitely seen register_cpu_notifier appearing in backtraces before...
maybe this is some kind of a lead?

> Could you please try the patch below?

Testing now... Expect results in 15 minutes...

> Also, please send your config if the patch does not fix your problem.

config: http://paste.fedoraproject.org/84281/54146313

	-- kuba
