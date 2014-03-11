From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace and
 a system freeze
Date: Tue, 11 Mar 2014 13:00:59 +0100
Message-ID: <20140311120059.GB32371@secunet.com>
References: <20140310014452.144b0491@north>
 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140310131909.33a3042c@north>
 <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140311014649.1716bde1@north>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	Fan Du <fan.du@windriver.com>
To: Jakub =?utf-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44377 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381AbaCKMBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 08:01:04 -0400
Content-Disposition: inline
In-Reply-To: <20140311014649.1716bde1@north>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 01:46:49AM +0100, Jakub Kici=C5=84ski wrote:
>=20
> I bisected the other issue to be caused/uncovered by:
>=20
> commit 1a1ccc96abb2ed9b8fbb71018e64b97324caef53
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Wed Feb 19 10:07:34 2014 +0100
>=20
>     xfrm: Remove caching of xfrm_policy_sk_bundles
>    =20
>     We currently cache socket policy bundles at xfrm_policy_sk_bundle=
s.
>     These cached bundles are never used. Instead we create and cache
>     a new one whenever xfrm_lookup() is called on a socket policy.
>    =20
>     Most protocols cache the used routes to the socket, so let's
>     remove the unused caching of socket policy bundles in xfrm.
>    =20
>     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>=20

This patch should affect only on the usage of IPsec socket policies.
Do you use socket policies, or do you use IPsec at all?

>=20
> Machine freezes after FLOW_HASH_RND_PERIOD (default 10 minutes).
> Now get this warning during boot:
>=20
> [   31.664820] ------------[ cut here ]------------
> [   31.664824] WARNING: CPU: 2 PID: 3560 at /home/kuba/Development/Li=
nux/net-next/lib/list_debug.c:33 __list_add+0xac/0xc0()
> [   31.664826] list_add corruption. prev->next should be next (ffff88=
0224579598), but was           (null). (prev=3Dffff8802106140e8).
> [   31.664827] Modules linked in: xt_CHECKSUM tun bridge stp llc ccm =
xt_conntrack iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 n=
f_nat nf_conntrack iptable_mangle iptable_security iptable_raw ftdi_sio=
 arc4 rt2800pci rt2800mmio rt2800lib crc_ccitt eeprom_93cx6 rt2x00pci k=
vm_amd rt2x00mmio rt2x00lib mac80211 kvm snd_ca0106 cfg80211 e1000e snd=
_ac97_codec ac97_bus microcode serio_raw ptp i2c_piix4 k10temp acpi_cpu=
freq pps_core wmi r8169 mii rfkill nfsd auth_rpcgss nfs_acl lockd binfm=
t_misc sunrpc usb_storage radeon drm_kms_helper ttm
> [   31.664855] CPU: 2 PID: 3560 Comm: (t-daemon) Not tainted 3.14.0-r=
c2-1a1ccc96abb2ed9b8fbb71018e64b97324caef53+ #11
> [   31.664856] Hardware name: Gigabyte Technology Co., Ltd. GA-MA790X=
T-UD4P/GA-MA790XT-UD4P, BIOS F9b 08/17/2012
> [   31.664857]  0000000000000009 ffff8802242e7c70 ffffffff81627878 ff=
ff8802242e7cb8
> [   31.664859]  ffff8802242e7ca8 ffffffff8104a28d ffff880210610ea8 ff=
ff880224579598
> [   31.664861]  ffff8802106140e8 ffff880224578000 0000000000000000 ff=
ff8802242e7d08
> [   31.664863] Call Trace:
> [   31.664865]  [<ffffffff81627878>] dump_stack+0x4d/0x66
> [   31.664867]  [<ffffffff8104a28d>] warn_slowpath_common+0x7d/0xa0
> [   31.664869]  [<ffffffff8104a2fc>] warn_slowpath_fmt+0x4c/0x50
> [   31.664871]  [<ffffffff812fdd8c>] __list_add+0xac/0xc0
> [   31.664873]  [<ffffffff81055d33>] __internal_add_timer+0x113/0x130
> [   31.664875]  [<ffffffff81055f47>] internal_add_timer+0x17/0x40
> [   31.664876]  [<ffffffff810587b2>] mod_timer+0x102/0x230
> [   31.664878]  [<ffffffff810588f8>] add_timer+0x18/0x20
> [   31.664880]  [<ffffffff81572204>] flow_cache_init+0x224/0x2b0
> [   31.664882]  [<ffffffff815f7247>] xfrm_net_init+0x227/0x360
> [   31.664884]  [<ffffffff815f7171>] ? xfrm_net_init+0x151/0x360
> [   31.664886]  [<ffffffff81553131>] ops_init+0x41/0x150
> [   31.664888]  [<ffffffff815532b3>] setup_net+0x73/0x110
> [   31.664890]  [<ffffffff815537f2>] copy_net_ns+0x72/0x100
> [   31.664892]  [<ffffffff81072619>] create_new_namespaces+0xf9/0x190
> [   31.664894]  [<ffffffff81072891>] unshare_nsproxy_namespaces+0x61/=
0xa0
> [   31.664895]  [<ffffffff81049949>] SyS_unshare+0x159/0x270
> [   31.664897]  [<ffffffff81638092>] system_call_fastpath+0x16/0x1b
>=20

I was unable to reproduce this here, but it looks like the flowcache
namespace changes are still not complete. We leak an active timer
and all the allocated resources when we exit a namespace.

Could you please try the patch below?

Also, please send your config if the patch does not fix your problem.

Thanks!

---
 include/net/flow.h     |    1 +
 net/core/flow.c        |   18 ++++++++++++++++++
 net/xfrm/xfrm_policy.c |    7 ++++++-
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index bee3741..64fd248 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -219,6 +219,7 @@ struct flow_cache_object *flow_cache_lookup(struct =
net *net,
 					    u8 dir, flow_resolve_t resolver,
 					    void *ctx);
 int flow_cache_init(struct net *net);
+void flow_cache_fini(struct net *net);
=20
 void flow_cache_flush(struct net *net);
 void flow_cache_flush_deferred(struct net *net);
diff --git a/net/core/flow.c b/net/core/flow.c
index 102f8ea..d31c3c4 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -484,3 +484,21 @@ err:
 	return -ENOMEM;
 }
 EXPORT_SYMBOL(flow_cache_init);
+
+void flow_cache_fini(struct net *net)
+{
+	int i;
+	struct flow_cache *fc =3D &net->xfrm.flow_cache_global;
+
+	del_timer(&fc->rnd_timer);
+
+	for_each_possible_cpu(i) {
+		struct flow_cache_percpu *fcp =3D per_cpu_ptr(fc->percpu, i);
+		kfree(fcp->hash_table);
+		fcp->hash_table =3D NULL;
+	}
+
+	free_percpu(fc->percpu);
+	fc->percpu =3D NULL;
+}
+EXPORT_SYMBOL(flow_cache_fini);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a75fae4..f02f511 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2913,15 +2913,19 @@ static int __net_init xfrm_net_init(struct net =
*net)
 	rv =3D xfrm_sysctl_init(net);
 	if (rv < 0)
 		goto out_sysctl;
+	rv =3D flow_cache_init(net);
+	if (rv < 0)
+		goto out;
=20
 	/* Initialize the per-net locks here */
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
 	rwlock_init(&net->xfrm.xfrm_policy_lock);
 	mutex_init(&net->xfrm.xfrm_cfg_mutex);
=20
-	flow_cache_init(net);
 	return 0;
=20
+out:
+	xfrm_sysctl_fini(net);
 out_sysctl:
 	xfrm_policy_fini(net);
 out_policy:
@@ -2934,6 +2938,7 @@ out_statistics:
=20
 static void __net_exit xfrm_net_exit(struct net *net)
 {
+	flow_cache_fini(net);
 	xfrm_sysctl_fini(net);
 	xfrm_policy_fini(net);
 	xfrm_state_fini(net);
--=20
1.7.9.5
