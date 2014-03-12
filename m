From: Fan Du <fan.du@windriver.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Wed, 12 Mar 2014 18:02:23 +0800
Message-ID: <532030AF.8010605@windriver.com>
References: <20140310014452.144b0491@north> <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com> <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com> <20140310131909.33a3042c@north> <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com> <20140311014649.1716bde1@north> <20140311120059.GB32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?SmFrdWIgS2ljacWEc2tp?= <moorray3@wp.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:34136 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbaCLKDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 06:03:15 -0400
In-Reply-To: <20140311120059.GB32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2014=E5=B9=B403=E6=9C=8811=E6=97=A5 20:00, Steffen Klassert wrote:
> On Tue, Mar 11, 2014 at 01:46:49AM +0100, Jakub Kici=C5=84ski wrote:
>> >
>> >  I bisected the other issue to be caused/uncovered by:
>> >
>> >  commit 1a1ccc96abb2ed9b8fbb71018e64b97324caef53
>> >  Author: Steffen Klassert<steffen.klassert@secunet.com>
>> >  Date:   Wed Feb 19 10:07:34 2014 +0100
>> >
>> >       xfrm: Remove caching of xfrm_policy_sk_bundles
>> >
>> >       We currently cache socket policy bundles at xfrm_policy_sk_b=
undles.
>> >       These cached bundles are never used. Instead we create and c=
ache
>> >       a new one whenever xfrm_lookup() is called on a socket polic=
y.
>> >
>> >       Most protocols cache the used routes to the socket, so let's
>> >       remove the unused caching of socket policy bundles in xfrm.
>> >
>> >       Signed-off-by: Steffen Klassert<steffen.klassert@secunet.com=
>
>> >
> This patch should affect only on the usage of IPsec socket policies.
> Do you use socket policies, or do you use IPsec at all?
>
>> >
>> >  Machine freezes after FLOW_HASH_RND_PERIOD (default 10 minutes).
>> >  Now get this warning during boot:
>> >
>> >  [   31.664820] ------------[ cut here ]------------
>> >  [   31.664824] WARNING: CPU: 2 PID: 3560 at /home/kuba/Developmen=
t/Linux/net-next/lib/list_debug.c:33 __list_add+0xac/0xc0()
>> >  [   31.664826] list_add corruption. prev->next should be next (ff=
ff880224579598), but was           (null). (prev=3Dffff8802106140e8).
>> >  [   31.664827] Modules linked in: xt_CHECKSUM tun bridge stp llc =
ccm xt_conntrack iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ip=
v4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ftdi=
_sio arc4 rt2800pci rt2800mmio rt2800lib crc_ccitt eeprom_93cx6 rt2x00p=
ci kvm_amd rt2x00mmio rt2x00lib mac80211 kvm snd_ca0106 cfg80211 e1000e=
 snd_ac97_codec ac97_bus microcode serio_raw ptp i2c_piix4 k10temp acpi=
_cpufreq pps_core wmi r8169 mii rfkill nfsd auth_rpcgss nfs_acl lockd b=
infmt_misc sunrpc usb_storage radeon drm_kms_helper ttm
>> >  [   31.664855] CPU: 2 PID: 3560 Comm: (t-daemon) Not tainted 3.14=
=2E0-rc2-1a1ccc96abb2ed9b8fbb71018e64b97324caef53+ #11
>> >  [   31.664856] Hardware name: Gigabyte Technology Co., Ltd. GA-MA=
790XT-UD4P/GA-MA790XT-UD4P, BIOS F9b 08/17/2012
>> >  [   31.664857]  0000000000000009 ffff8802242e7c70 ffffffff8162787=
8 ffff8802242e7cb8
>> >  [   31.664859]  ffff8802242e7ca8 ffffffff8104a28d ffff880210610ea=
8 ffff880224579598
>> >  [   31.664861]  ffff8802106140e8 ffff880224578000 000000000000000=
0 ffff8802242e7d08
>> >  [   31.664863] Call Trace:
>> >  [   31.664865]  [<ffffffff81627878>] dump_stack+0x4d/0x66
>> >  [   31.664867]  [<ffffffff8104a28d>] warn_slowpath_common+0x7d/0x=
a0
>> >  [   31.664869]  [<ffffffff8104a2fc>] warn_slowpath_fmt+0x4c/0x50
>> >  [   31.664871]  [<ffffffff812fdd8c>] __list_add+0xac/0xc0
>> >  [   31.664873]  [<ffffffff81055d33>] __internal_add_timer+0x113/0=
x130
>> >  [   31.664875]  [<ffffffff81055f47>] internal_add_timer+0x17/0x40
>> >  [   31.664876]  [<ffffffff810587b2>] mod_timer+0x102/0x230
>> >  [   31.664878]  [<ffffffff810588f8>] add_timer+0x18/0x20
>> >  [   31.664880]  [<ffffffff81572204>] flow_cache_init+0x224/0x2b0
>> >  [   31.664882]  [<ffffffff815f7247>] xfrm_net_init+0x227/0x360
>> >  [   31.664884]  [<ffffffff815f7171>] ? xfrm_net_init+0x151/0x360
>> >  [   31.664886]  [<ffffffff81553131>] ops_init+0x41/0x150
>> >  [   31.664888]  [<ffffffff815532b3>] setup_net+0x73/0x110
>> >  [   31.664890]  [<ffffffff815537f2>] copy_net_ns+0x72/0x100
>> >  [   31.664892]  [<ffffffff81072619>] create_new_namespaces+0xf9/0=
x190
>> >  [   31.664894]  [<ffffffff81072891>] unshare_nsproxy_namespaces+0=
x61/0xa0
>> >  [   31.664895]  [<ffffffff81049949>] SyS_unshare+0x159/0x270
>> >  [   31.664897]  [<ffffffff81638092>] system_call_fastpath+0x16/0x=
1b
>> >
> I was unable to reproduce this here, but it looks like the flowcache
> namespace changes are still not complete. We leak an active timer
> and all the allocated resources when we exit a namespace.
My bad! and embarrassing=E3=80=82=E3=80=82=E3=80=82
Thanks for the fix for my errors.

>
> Could you please try the patch below?

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
