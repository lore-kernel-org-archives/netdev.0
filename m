From: Jakub =?UTF-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Tue, 11 Mar 2014 01:46:49 +0100
Message-ID: <20140311014649.1716bde1@north>
References: <20140310014452.144b0491@north>
	<1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140310131909.33a3042c@north>
	<1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Fan Du <fan.du@windriver.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:58126 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753860AbaCKAqw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 20:46:52 -0400
In-Reply-To: <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Mar 2014 07:04:36 -0700, Eric Dumazet wrote:
> On Mon, 2014-03-10 at 13:19 +0100, Jakub Kici=C5=84ski wrote:
>=20
> > It helps with the flow_cache warning and BUG ("ip netns add" works)=
 but
> > machine still freezes after 5-10 minutes.  I will try to revert
> > ca925cf1534ebcec332c08719a7dee6ee1782ce4 and see if that solves it.
>=20
> I think the other issue is separate. It might be triggered by
> conntracking change.

I bisected the other issue to be caused/uncovered by:

commit 1a1ccc96abb2ed9b8fbb71018e64b97324caef53
Author: Steffen Klassert <steffen.klassert@secunet.com>
Date:   Wed Feb 19 10:07:34 2014 +0100

    xfrm: Remove caching of xfrm_policy_sk_bundles
   =20
    We currently cache socket policy bundles at xfrm_policy_sk_bundles.
    These cached bundles are never used. Instead we create and cache
    a new one whenever xfrm_lookup() is called on a socket policy.
   =20
    Most protocols cache the used routes to the socket, so let's
    remove the unused caching of socket policy bundles in xfrm.
   =20
    Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>


Machine freezes after FLOW_HASH_RND_PERIOD (default 10 minutes).
Now get this warning during boot:

[   31.664820] ------------[ cut here ]------------
[   31.664824] WARNING: CPU: 2 PID: 3560 at /home/kuba/Development/Linu=
x/net-next/lib/list_debug.c:33 __list_add+0xac/0xc0()
[   31.664826] list_add corruption. prev->next should be next (ffff8802=
24579598), but was           (null). (prev=3Dffff8802106140e8).
[   31.664827] Modules linked in: xt_CHECKSUM tun bridge stp llc ccm xt=
_conntrack iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_=
nat nf_conntrack iptable_mangle iptable_security iptable_raw ftdi_sio a=
rc4 rt2800pci rt2800mmio rt2800lib crc_ccitt eeprom_93cx6 rt2x00pci kvm=
_amd rt2x00mmio rt2x00lib mac80211 kvm snd_ca0106 cfg80211 e1000e snd_a=
c97_codec ac97_bus microcode serio_raw ptp i2c_piix4 k10temp acpi_cpufr=
eq pps_core wmi r8169 mii rfkill nfsd auth_rpcgss nfs_acl lockd binfmt_=
misc sunrpc usb_storage radeon drm_kms_helper ttm
[   31.664855] CPU: 2 PID: 3560 Comm: (t-daemon) Not tainted 3.14.0-rc2=
-1a1ccc96abb2ed9b8fbb71018e64b97324caef53+ #11
[   31.664856] Hardware name: Gigabyte Technology Co., Ltd. GA-MA790XT-=
UD4P/GA-MA790XT-UD4P, BIOS F9b 08/17/2012
[   31.664857]  0000000000000009 ffff8802242e7c70 ffffffff81627878 ffff=
8802242e7cb8
[   31.664859]  ffff8802242e7ca8 ffffffff8104a28d ffff880210610ea8 ffff=
880224579598
[   31.664861]  ffff8802106140e8 ffff880224578000 0000000000000000 ffff=
8802242e7d08
[   31.664863] Call Trace:
[   31.664865]  [<ffffffff81627878>] dump_stack+0x4d/0x66
[   31.664867]  [<ffffffff8104a28d>] warn_slowpath_common+0x7d/0xa0
[   31.664869]  [<ffffffff8104a2fc>] warn_slowpath_fmt+0x4c/0x50
[   31.664871]  [<ffffffff812fdd8c>] __list_add+0xac/0xc0
[   31.664873]  [<ffffffff81055d33>] __internal_add_timer+0x113/0x130
[   31.664875]  [<ffffffff81055f47>] internal_add_timer+0x17/0x40
[   31.664876]  [<ffffffff810587b2>] mod_timer+0x102/0x230
[   31.664878]  [<ffffffff810588f8>] add_timer+0x18/0x20
[   31.664880]  [<ffffffff81572204>] flow_cache_init+0x224/0x2b0
[   31.664882]  [<ffffffff815f7247>] xfrm_net_init+0x227/0x360
[   31.664884]  [<ffffffff815f7171>] ? xfrm_net_init+0x151/0x360
[   31.664886]  [<ffffffff81553131>] ops_init+0x41/0x150
[   31.664888]  [<ffffffff815532b3>] setup_net+0x73/0x110
[   31.664890]  [<ffffffff815537f2>] copy_net_ns+0x72/0x100
[   31.664892]  [<ffffffff81072619>] create_new_namespaces+0xf9/0x190
[   31.664894]  [<ffffffff81072891>] unshare_nsproxy_namespaces+0x61/0x=
a0
[   31.664895]  [<ffffffff81049949>] SyS_unshare+0x159/0x270
[   31.664897]  [<ffffffff81638092>] system_call_fastpath+0x16/0x1b


	-- kuba
