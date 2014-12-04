From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Thu, 4 Dec 2014 08:56:28 +0100
Message-ID: <20141204075627.GE6390@secunet.com>
References: <547F2462.6040405@smart-weblications.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	<stable@vger.kernel.org>
To: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <547F2462.6040405@smart-weblications.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 03, 2014 at 03:55:30PM +0100, Smart Weblications GmbH - Florian Wiessner wrote:
> Hi list,
> 
> 
> 
> [16623.095403] BUG: unable to handle kernel paging request at 00000000010600d0
> [16623.095445] IP: [<ffffffff81547767>] xfrm_selector_match+0x25/0x2f6
> [16623.095480] PGD aeaea067 PUD 85d95067 PMD 0
> [16623.095513] Oops: 0000 [#1] SMP
> [16623.095543] Modules linked in: netconsole xt_nat xt_multiport veth ip_vs_rr
> nfsd lockd nfs_acl auth_rpcgss sunrpc oid_registry iptable_mangle xt_mark
> nf_conntrack_netlink nfnetlink ipt_MASQUERADE iptable_nat nf_nat_ipv4
> nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_tcpudp iptable_filter ip_tables
> cpufreq_ondemand cpufreq_powersave cpufreq_conservative cpufreq_userspace
> ocfs2_stack_o2cb ocfs2_dlm bridge stp llc bonding fuse nf_conntrack_ftp 8021q
> openvswitch gre vxlan xt_conntrack x_tables ocfs2_dlmfs dlm sctp ocfs2
> ocfs2_nodemanager ocfs2_stackglue configfs rbd kvm_intel kvm coretemp ip_vs_ftp
> ip_vs nf_nat nf_conntrack ctr twofish_generic twofish_x86_64 twofish_common
> camellia_generic serpent_generic blowfish_generic blowfish_common cast5_generic
> cast_common xcbc sha512_generic crypto_null af_key xfrm_algo psmouse serio_raw
> i2c_i801 lpc_ich mfd_core evdev btrfs lzo_decompress lzo_compress
> [16623.096062] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.12.33 #1
> [16623.096091] Hardware name: Supermicro X9SCI/X9SCA/X9SCI/X9SCA, BIOS 1.1a
> 09/28/2011
> [16623.096137] task: ffffffff81804450 ti: ffffffff817f4000 task.ti: ffffffff817f4000
> [16623.096182] RIP: 0010:[<ffffffff81547767>]  [<ffffffff81547767>]
> xfrm_selector_match+0x25/0x2f6
> [16623.096233] RSP: 0018:ffff88083fc03900  EFLAGS: 00010246
> [16623.096261] RAX: 0000000000000001 RBX: ffff88083fc03a20 RCX: ffff880787fb1200
> [16623.096292] RDX: 0000000000000002 RSI: ffff88083fc03a20 RDI: 00000000010600a6
> [16623.096323] RBP: 00000000010600a6 R08: 0000000000000000 R09: ffff88083fc039a0
> [16623.096353] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88083fc03a20
> [16623.096383] R13: 0000000000000001 R14: ffffffff818a9700 R15: ffffffffa01c73e0
> [16623.096414] FS:  0000000000000000(0000) GS:ffff88083fc00000(0000)
> knlGS:0000000000000000
> [16623.096469] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [16623.096498] CR2: 00000000010600d0 CR3: 0000000085f0b000 CR4: 00000000000407f0
> [16623.096528] Stack:
> [16623.096550]  0000000000000000 0000000001060002 ffff880787fb1200 ffff88083fc03a20
> [16623.096602]  0000000000000001 ffffffff81547a7c 0000000000000000 ffff8800baad5480
> [16623.096655]  ffffffff81804450 ffffffff818a9700 000000003c9041bc ffffffff81547ef7
> [16623.096721] Call Trace:
> [16623.096744]  <IRQ>
> [16623.096749]  [<ffffffff81547a7c>] ? xfrm_sk_policy_lookup+0x44/0x9b
> [16623.096802]  [<ffffffff81547ef7>] ? xfrm_lookup+0x91/0x446
> [16623.096832]  [<ffffffff81541316>] ? ip_route_me_harder+0x150/0x1b0
> [16623.096865]  [<ffffffffa01b6457>] ? ip_vs_route_me_harder+0x86/0x91 [ip_vs]
> [16623.096899]  [<ffffffffa01b797a>] ? ip_vs_out+0x2d3/0x5bc [ip_vs]
> [16623.096930]  [<ffffffff81501420>] ? ip_rcv_finish+0x2b8/0x2b8

I really wonder why the xfrm_sk_policy_lookup codepath is taken here.
It looks like this is the processing of an inbound ipv4 packet that
is going to be rerouted to the output path by ipvs, so this packet
should not have socket context at all.

xfrm_sk_policy_lookup is called just if the packet has socket context
and the socket has an IPsec output policy configured. Do you use IPsec
socket policies?

> 
> This happens again and again with 3.12.33
> 
> 
> see also: http://www.spinics.net/lists/netdev/msg306283.html
> 
> is this already fixed somehow?
> 

You mentioned in the tread above that it does not happen with
3.17.4, so it should be fixed somehow. But I have no idea how
it was fixed.
