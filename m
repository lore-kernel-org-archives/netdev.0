From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 15:49:51 +0200
Message-ID: <20130710134951.GE15411@order.stressinduktion.org>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <20130710111504.GA15411@order.stressinduktion.org> <51DD4ECA.1080506@6wind.com> <20130710131741.GC15411@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:36878 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312Ab3GJNtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 09:49:52 -0400
Content-Disposition: inline
In-Reply-To: <20130710131741.GC15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 03:17:41PM +0200, Hannes Frederic Sowa wrote:
> On Wed, Jul 10, 2013 at 02:08:42PM +0200, Nicolas Dichtel wrote:
> > Le 10/07/2013 13:15, Hannes Frederic Sowa a =C3=A9crit :
> > >On Wed, Jul 10, 2013 at 09:54:58AM +0200, Nicolas Dichtel wrote:
> > >>Le 09/07/2013 23:57, Hannes Frederic Sowa a =C3=A9crit :
> > >>>Are we sure we decrement all sibling's rt6i_nsiblings? Shouldn't=
 we
> > >>>start iterating from fn->leaf? But this does not seem to cause i=
t,
> > >>>because my trace does not report any calls to fib6_del_route.
> > >>Note sure to follow you, but all siblings are listed in rt6i_sibl=
ings, so
> > >>it must be enough.
> > >
> > >My hunch was to iterate over fn->leaf->rt_next and compare the met=
rics=20
> > >like we
> > >do when adding a new route. Then take that rt6_info->rt6i_siblings=
=20
> > >list_head
> > >to iterate over the remaining siblings. But I did not review that =
part
> > >carefully, need to check later.
> > >
> > >>>You could try reproduce it by having an interface autoconfigured=
 with
> > >>>a default router with NUD_VALID neighbour. I then added an unuse=
d vlan
> > >>>interface (vid 100 in my case) and added the following ip addres=
ses:
> > >>>
> > >>>ip -6 a a 2001:ffff::1/64 dev eth0.100
> > >>>ip -6 r a 2000::/3 nexthop via 2001:ffff::30 nexthop via 2001:ff=
ff::31
> > >>>nexthop via 2001:ffff::32 nexthop via 2001:ffff::33
> > >>>
> > >>>(all nexthops should not be reachable)
> > >>>
> > >>>After starting a ping6 2000::1 the box should panic soon, after =
the
> > >>>first nexthop entry times out.
> > >>>
> > >>>Perhaps you could give me a hint?
> > >>I will run some tests with your patch. Will see.
> > >>
> > >>I assume you didn't reproduce this without your patch.
> > >
> > >Current kernel does not correctly select more specific routes, so =
these=20
> > >routes
> > >are not even tried and the logic should not be excercised.
> > >
> > >Ah, sorry, you should also compile your kernel without
> > >CONFIG_IPV6_ROUTER_PREF, too, if you try to reproduce it.
> > I've done this.
> >=20
> > My conf (eth1 autoconfigured, I use net-next + your patch):
> > vconfig add eth1 100
> > ifconfig eth1.100 up
> > ip -6 a a 2001:ffff::1/64 dev eth1.100
> > ip -6 r a 2000::/3 nexthop via 2001:ffff::30 nexthop via 2001:ffff:=
:31=20
> > nexthop via 2001:ffff::32 nexthop via 2001:ffff::33
> > ping6 2000::1
>=20
> Hm, I see. I suspect something with timing. I, too, use a net-next an=
d have
> one function dump_route added and sprinkeld it at some points.
>=20
> When I copy&pasted your calls I could not reproduce it. After a reboo=
t when
> just applying the commands from my history (which I did a lot faster)=
, I got
> the panic again.
>=20
> I'll remove the dump_routes and recheck later.

This patch ontop

--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -46,6 +46,16 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
=20
+static void dump_route(struct rt6_info *rt, const char *prefix)
+{
+       u32 f =3D rt->rt6i_flags;
+       struct rt6key *k =3D &rt->rt6i_dst;
+       printk(KERN_INFO "%s: %p dst %pI6c plen %d gateway %pI6c, sibli=
ngs %d, metric %d, expires %d gateway %d idev6 %p dev %p\n", prefix,
+              rt, &k->addr, k->plen, &rt->rt6i_gateway, rt->rt6i_nsibl=
ings, rt->rt6i_metric, f&RTF_EXPIRES, f&RTF_GATEWAY, rt->rt6i_idev, rt-=
>dst.dev);
+}
+
+
+
 static struct kmem_cache * fib6_node_kmem __read_mostly;
=20
 enum fib_walk_state_t
@@ -693,8 +703,11 @@ static int fib6_add_rt2node(struct fib6_node *fn, =
struct rt6_info *rt,
                         */
                        if (rt->rt6i_flags & RTF_GATEWAY &&
                            !(rt->rt6i_flags & RTF_EXPIRES) &&
-                           !(iter->rt6i_flags & RTF_EXPIRES))
+                           !(iter->rt6i_flags & RTF_EXPIRES)) {
                                rt->rt6i_nsiblings++;
+                               dump_route(rt, "(rt)");
+                               dump_route(iter, "(iter)");
+                       }
                }
=20
                if (iter->rt6i_metric > rt->rt6i_metric)
@@ -718,6 +731,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, s=
truct rt6_info *rt,
                        if (sibling->rt6i_metric =3D=3D rt->rt6i_metric=
) {
                                list_add_tail(&rt->rt6i_siblings,
                                              &sibling->rt6i_siblings);
+                               dump_route(sibling, "(sibling)");
                                break;
                        }
                        sibling =3D sibling->dst.rt6_next;
@@ -730,6 +744,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, s=
truct rt6_info *rt,
                list_for_each_entry_safe(sibling, temp_sibling,
                                         &rt->rt6i_siblings, rt6i_sibli=
ngs) {
                        sibling->rt6i_nsiblings++;
+                       dump_route(sibling, "(sibling increment)");
                        BUG_ON(sibling->rt6i_nsiblings !=3D rt->rt6i_ns=
iblings);
                        rt6i_nsiblings++;
                }

produces this panic:

[   59.234779] (rt): ffff880113242000 dst 2000::1 plen 128 gateway 2001=
:ffff::33, siblings 1, metric 0, expires 0 gateway 2 idev6 ffff8801131a=
b000 dev ffff88011816d000
[   59.243794] (iter): ffff880117e7b680 dst 2000::1 plen 128 gateway 20=
01:ffff::31, siblings 2, metric 0, expires 0 gateway 2 idev6 ffff880113=
1ab000 dev ffff88011816d000
[   59.261383] (rt): ffff880113242000 dst 2000::1 plen 128 gateway 2001=
:ffff::33, siblings 2, metric 0, expires 0 gateway 2 idev6 ffff8801131a=
b000 dev ffff88011816d000
[   59.270030] (iter): ffff880117e7bb00 dst 2000::1 plen 128 gateway 20=
01:ffff::32, siblings 2, metric 0, expires 0 gateway 2 idev6 ffff880113=
1ab000 dev ffff88011816d000
[   59.291933] (sibling): ffff880117e62480 dst 2000::1 plen 128 gateway=
 2001:ffff::30, siblings 2, metric 0, expires 4194304 gateway 2 idev6 f=
fff8801131ab000 dev ffff88011816d000
[   59.306893] (sibling increment): ffff880117e62480 dst 2000::1 plen 1=
28 gateway 2001:ffff::30, siblings 3, metric 0, expires 4194304 gateway=
 2 idev6 ffff8801131ab000 dev ffff88011816d000
[   59.318840] ------------[ cut here ]------------
[   59.319780] kernel BUG at net/ipv6/ip6_fib.c:748!
[   59.319780] invalid opcode: 0000 [#1] SMP=20
[   59.319780] Modules linked in: 8021q nf_conntrack_netbios_ns nf_conn=
track_broadcast ipt_MASQUERADE ip6table_mangle ip6t_REJECT nf_conntrack=
_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle nf_c=
onntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter e=
btables ip6table_filter ip6_tables snd_hda_intel snd_hda_codec snd_hwde=
p snd_seq snd_seq_device snd_pcm snd_page_alloc virtio_balloon snd_time=
r virtio_net snd i2c_piix4 soundcore i2c_core virtio_blk
[   59.319780] CPU: 0 PID: 784 Comm: ping6 Not tainted 3.10.0+ #154
[   59.319780] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   59.319780] task: ffff880117e98000 ti: ffff8801131e4000 task.ti: fff=
f8801131e4000
[   59.319780] RIP: 0010:[<ffffffff815f3ca6>]  [<ffffffff815f3ca6>] fib=
6_add+0x826/0x900
[   59.319780] RSP: 0018:ffff8801131e5788  EFLAGS: 00010202
[   59.319780] RAX: 00000000000000ad RBX: ffff880117e7b680 RCX: ffff880=
11fc0faa8
[   59.319780] RDX: 0000000000000000 RSI: 0000000000000003 RDI: 0000000=
000000246
[   59.319780] RBP: ffff8801131e5848 R08: ffffffff81ce7f00 R09: 0000000=
000000244
[   59.319780] R10: 0000000000000000 R11: 0000000000000243 R12: ffff880=
117e62480
[   59.319780] R13: ffff880117e7bb90 R14: 0000000000000000 R15: ffff880=
113242000
[   59.319780] FS:  00007f83b6958740(0000) GS:ffff88011fc00000(0000) kn=
lGS:0000000000000000
[   59.319780] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   59.319780] CR2: 00007f83b59e5580 CR3: 00000001187d1000 CR4: 0000000=
0000006f0
[   59.319780] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[   59.319780] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[   59.319780] Stack:
[   59.319780]  0000000000000000 0000000100000000 ffff880113035840 ffff=
880113035840
[   59.319780]  ffff8801131e5890 0000000000000000 ffff880119b80a00 0000=
000000000000
[   59.319780]  ffff8801131e5818 ffffffff81180ca3 ffff8801131e58e8 ffff=
ffff8109bf04
[   59.319780] Call Trace:
[   59.319780]  [<ffffffff81180ca3>] ? kmem_cache_alloc+0x1a3/0x1f0
[   59.319780]  [<ffffffff8109bf04>] ? load_balance+0xf4/0x7f0
[   59.319780]  [<ffffffff815eeceb>] ? rt6_bind_peer+0x4b/0x90
[   59.319780]  [<ffffffff815ed985>] __ip6_ins_rt+0x45/0x70
[   59.319780]  [<ffffffff815eee35>] ip6_ins_rt+0x35/0x40
[   59.319780]  [<ffffffff815ef1e4>] ip6_pol_route.isra.44+0x3a4/0x4b0
[   59.319780]  [<ffffffff815ef34a>] ip6_pol_route_output+0x2a/0x30
[   59.319780]  [<ffffffff816161c7>] fib6_rule_action+0xd7/0x210
[   59.319780]  [<ffffffff815ef320>] ? ip6_pol_route_input+0x30/0x30
[   59.319780]  [<ffffffff8106cd8f>] ? try_to_del_timer_sync+0x4f/0x70
[   59.319780]  [<ffffffff81553026>] fib_rules_lookup+0xc6/0x140
[   59.319780]  [<ffffffff816164c4>] fib6_rule_lookup+0x44/0x80
[   59.319780]  [<ffffffff815ef320>] ? ip6_pol_route_input+0x30/0x30
[   59.319780]  [<ffffffff815edea3>] ip6_route_output+0x73/0xb0
[   59.319780]  [<ffffffff815dfdf3>] ip6_dst_lookup_tail+0x2c3/0x2e0
[   59.319780]  [<ffffffff81095838>] ? __enqueue_entity+0x78/0x80
[   59.319780]  [<ffffffff815dfe4d>] ip6_dst_lookup_flow+0x3d/0xa0
[   59.319780]  [<ffffffff815fdbc7>] rawv6_sendmsg+0x267/0xc20
[   59.319780]  [<ffffffff815a8a83>] inet_sendmsg+0x63/0xb0
[   59.319780]  [<ffffffff8128eb93>] ? selinux_socket_sendmsg+0x23/0x30
[   59.319780]  [<ffffffff815218d6>] sock_sendmsg+0xa6/0xd0
[   59.319780]  [<ffffffff81524a68>] SYSC_sendto+0x128/0x180
[   59.319780]  [<ffffffff8109825c>] ? update_curr+0xec/0x170
[   59.319780]  [<ffffffff81041d09>] ? kvm_clock_get_cycles+0x9/0x10
[   59.319780]  [<ffffffff810afd1e>] ? __getnstimeofday+0x3e/0xd0
[   59.319780]  [<ffffffff8152509e>] SyS_sendto+0xe/0x10
[   59.319780]  [<ffffffff8164f159>] system_call_fastpath+0x16/0x1b
[   59.319780] Code: 06 0f 85 c6 fe ff ff 48 8b 95 60 ff ff ff 48 89 c6=
 48 8b 7a 08 e8 cb ee ff ff e9 ae fe ff ff 48 8b 82 28 05 00 00 e9 fc f=
e ff ff <0f> 0b 49 8b 57 30 0d 00 00 40 00 bb ef ff ff ff 41 89 86 14 0=
1=20
[   59.319780] RIP  [<ffffffff815f3ca6>] fib6_add+0x826/0x900
[   59.319780]  RSP <ffff8801131e5788>
[   59.506210] ---[ end trace 3ade307f40880be9 ]---
[   59.507503] Kernel panic - not syncing: Fatal exception in interrupt

I can also reproduce it without this debugging diff:

git log --oneline HEAD^^^..
155b81f ipv6: fix route selection if kernel is not compiled with CONFIG=
_IPV6_ROUTER_PREF
c7e8e8a bridge: fix some kernel warning in multicast timer
734d4e1 sfc: Fix memory leak when discarding scattered packets

(net-next a few days old)

Thanks,

  Hannes
