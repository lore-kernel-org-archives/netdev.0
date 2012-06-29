From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: BUG: NULL pointer in ctnetlink_conntrack_event
Date: Fri, 29 Jun 2012 18:29:05 +0200
Message-ID: <20120629162905.GB3785@1984>
References: <mdaatbj.9730f14767bb2419ed11e14ac50382b8@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <mdaatbj.9730f14767bb2419ed11e14ac50382b8@obelix.schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 29, 2012 at 02:29:37PM +0200, Hans Schillstrom wrote:
> Hello,
>=20
> There is a "hard to find" problem in ctnetlink_conntrack_event() when cal=
ling
> netlink_has_listeners() net->nfnl is NULL.
>=20
> The rcu stuff seems to be right at a first look but who knows...
>=20
> The line below fix the problem, but that is not the root cause.
>=20
>  int nfnetlink_has_listeners(struct net *net, unsigned int group)
>  {
> -       return netlink_has_listeners(net->nfnl, group);
> +       return net->nfnl ? netlink_has_listeners(net->nfnl, group) : 0 ;
>  }
>=20
> Yes it is a 3.0.26 kernel but this patch is applied
> netfilter: nf_conntrack: make event callback registration per-netns

I think this patch above is missing some rcu_access_pointer usage.

Please, see patch attached.

> It happens when adding a number of containers with does a "nfct_query(h, =
NFCT_Q_CREATE, ct);"
> and most likely one namespace shuts down.
>=20
> Any idea why the timer is running at this point ?
>=20
>=20
> BUG: unable to handle kernel NULL pointer dereference at 000000000000027c
> IP: [<ffffffff813615db>] netlink_has_listeners+0xb/0x60
> PGD 0
> Oops: 0000 [#3] PREEMPT SMP
> CPU 0
> Modules linked in: ip6table_raw(N) xt_NOTRACK(N) iptable_raw(N) ipt_REJEC=
T(N) xt_sctp(N) xt_multiport(N) xt_connmark(N) xt_mark(N) xt_conntrack(N) i=
p6table_mangle(N) ip_vs(N) nf_conntrack_netlink(N) nfnetlink(N) ip6_tunnel(=
N) tunnel6(N) macvlan(N) xt_HMARK(N) ipv6_find_hdr(N) iptable_mangle(N) nf_=
conntrack_ipv6(N) nf_defrag_ipv6(N) ip6t_LOG(N) ip6table_filter(N) ip6_tabl=
es(N) nf_conntrack_ipv4(N) nf_defrag_ipv4(N) xt_state(N) xt_tcpudp(N) xt_u3=
2(N) xt_comment(N) xt_length(N) xt_hashlimit(N) ipt_LOG(N) xt_limit(N) ipta=
ble_filter(N) ip_tables(N) x_tables(N) nf_conntrack_ftp(N) nf_conntrack_tft=
p(N) nf_conntrack(N) mptsas(N) mptscsih(N) mptbase(N) sg(N) scsi_transport_=
sas(N) i2c_i801(N) i2c_core(N) button(N) pcspkr(N) ahci(N) libahci(N) proce=
ssor(N) serio_raw(N) thermal_sys(N) hwmon(N) iTCO_wdt(N) iTCO_vendor_suppor=
t(N) libata(N) ioatdma(N) ixgbe(N) mdio(N) nfs(N) lockd(N) fscache(N) auth_=
rpcgss(N) nfs_acl(N) sunrpc(N) af_packet(N) ipv6(N) ipv6_lib(N) bonding(N) =
e1000e(N) igb(N) dca(N) mii(N) 8021q(N) garp(N) st
> p(N) llc(N) softdog(N) xfs(N) exportfs(N) sd_mod(N) crc_t10dif(N) usb_sto=
rage(N) scsi_mod(N) ehci_hcd(N) uhci_hcd(N) usbcore(N) usb_common(N)
> Supported: Yes
>=20
> Pid: 0, comm: swapper Tainted: G      D    N  3.0.26-0.2-default
> RIP: 0010:[<ffffffff813615db>]  [<ffffffff813615db>] netlink_has_listener=
s+0xb/0x60
> RSP: 0018:ffff88063f203da0  EFLAGS: 00010286
> RAX: ffff88063f203e30 RBX: 0000000000000000 RCX: ffffffffa04c60f0
> RDX: 0000000000000004 RSI: 0000000000000003 RDI: 0000000000000000
> RBP: 0000000000000003 R08: 0000000000000000 R09: ffff88063f2114a0
> R10: 0000000000000000 R11: ffffffff8101e760 R12: ffff8805e2a45788
> R13: 0000000000000000 R14: 0000000000000002 R15: 0000000000000004
> FS:  0000000000000000(0000) GS:ffff88063f200000(0000) knlGS:0000000000000=
000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 000000000000027c CR3: 0000000001a03000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a0b0=
20)
> Stack:
>  0000000000000000 0000000000000000 ffff8805e2a45800 ffffffffa04c453e
>  ffff88063f203e30 0000000400000001 ffff8805e24e6c80 0000000300000000
>  0000000000000000 ffff880610044000 ffff880610044800 ffff8805e2a45788
> Call Trace:
>  [<ffffffffa04c453e>] ctnetlink_conntrack_event+0x51e/0x570 [nf_conntrack=
_netlink]
>  [<ffffffffa042a27b>] death_by_timeout+0x12b/0x190 [nf_conntrack]
>  [<ffffffff810608ec>] run_timer_softirq+0x14c/0x270
>  [<ffffffff81059d25>] __do_softirq+0xa5/0x180
>  [<ffffffff813ff43c>] call_softirq+0x1c/0x30
>  [<ffffffff810043f5>] do_softirq+0x65/0xa0
>  [<ffffffff81059b15>] irq_exit+0xc5/0x100
>  [<ffffffff8101f5a9>] smp_apic_timer_interrupt+0x69/0xa0
>  [<ffffffff813febf3>] apic_timer_interrupt+0x13/0x20
>  [<ffffffffa0230806>] acpi_idle_enter_bm+0x255/0x28f [processor]
>  [<ffffffff813179e2>] cpuidle_idle_call+0xd2/0x120
>  [<ffffffff810019f3>] cpu_idle+0x63/0xd0
>  [<ffffffff81bf0f65>] start_kernel+0x3e4/0x4bf
>  [<ffffffff81bf03c3>] x86_64_start_kernel+0x114/0x12f
> Code: ff 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 e9 cb c5 fc ff 66 6=
6 2e 0f 1f 84 00 00 00 00 00 55 89 f5 53 48 89 fb 48 83 ec 08 <f6> 87 7c 02=
 00 00 01 74 41 e8 47 50 d5 ff 0f b6 83 21 01 00 00
> RIP  [<ffffffff813615db>] netlink_has_listeners+0xb/0x60
>  RSP <ffff88063f203da0>
> CR2: 000000000000027c
> ---[ end trace a057af0b3004c67a ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Pid: 0, comm: swapper Tainted: G      D    N  3.0.26-0.2-default #1
> Call Trace:
>  [<ffffffff81004672>] dump_trace+0x82/0x380
>  [<ffffffff813f4fa2>] dump_stack+0x69/0x6f
>  [<ffffffff813f5050>] panic+0xa8/0x20c
>  [<ffffffff813f9b21>] oops_end+0xe1/0xf0
>  [<ffffffff81030e50>] no_context+0x100/0x270
>  [<ffffffff81031135>] __bad_area_nosemaphore+0x175/0x220
>  [<ffffffff813fbb36>] do_page_fault+0x3a6/0x590
>  [<ffffffff813f8d15>] page_fault+0x25/0x30
>  [<ffffffff813615db>] netlink_has_listeners+0xb/0x60
>  [<ffffffffa04c453e>] ctnetlink_conntrack_event+0x51e/0x570 [nf_conntrack=
_netlink]
>  [<ffffffffa042a27b>] death_by_timeout+0x12b/0x190 [nf_conntrack]
>  [<ffffffff810608ec>] run_timer_softirq+0x14c/0x270
>  [<ffffffff81059d25>] __do_softirq+0xa5/0x180
>  [<ffffffff813ff43c>] call_softirq+0x1c/0x30
>  [<ffffffff810043f5>] do_softirq+0x65/0xa0
>  [<ffffffff81059b15>] irq_exit+0xc5/0x100
>  [<ffffffff8101f5a9>] smp_apic_timer_interrupt+0x69/0xa0
>  [<ffffffff813febf3>] apic_timer_interrupt+0x13/0x20
>  [<ffffffffa0230806>] acpi_idle_enter_bm+0x255/0x28f [processor]
>  [<ffffffff813179e2>] cpuidle_idle_call+0xd2/0x120
>  [<ffffffff810019f3>] cpu_idle+0x63/0xd0
>  [<ffffffff81bf0f65>] start_kernel+0x3e4/0x4bf
>  [<ffffffff81bf03c3>] x86_64_start_kernel+0x114/0x12f
> Rebooting in 1 seconds..
> --
> Regards=20
> Hans Schillstrom
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel=
" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--XsQoSWH+UP9D9v3l
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="missing-rcu_access_pointer.patch"

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index a88fb69..e1ce104 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -78,7 +78,7 @@ nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *e;
 
-	if (net->ct.nf_conntrack_event_cb == NULL)
+	if (!rcu_access_pointer(net->ct.nf_conntrack_event_cb))
 		return;
 
 	e = nf_ct_ecache_find(ct);

--XsQoSWH+UP9D9v3l--
