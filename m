From: Adam Gundy <arg@cyberscience.com>
Subject: soft lockup with conntrackd / keepalived / VLAN
Date: Fri, 02 Jul 2010 10:04:27 -0600
Message-ID: <4C2E0E0B.8040903@cyberscience.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.cyberscience.com ([66.250.49.68]:60535 "EHLO
	mail.us.cyberscience.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759308Ab0GBQkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 12:40:55 -0400
Received: from hermes.us.cyberscience.com ([172.17.10.11]:35835)
	by mail.us.cyberscience.com with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <arg@cyberscience.com>)
	id 1OUijH-0002R8-Ie
	for netdev@vger.kernel.org; Fri, 02 Jul 2010 10:04:39 -0600
Received: from cheetah.dev.us.cyberscience.com ([172.19.30.21])
	by hermes.us.cyberscience.com with esmtpsa (SSL 3.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <arg@cyberscience.com>)
	id 1OUij6-000841-72
	for netdev@vger.kernel.org; Fri, 02 Jul 2010 10:04:39 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've built a pair of router boxes which are using keepalived and conntrackd to 
provide a redundant router setup. we're also using a single 802.1Q VLAN on the 
box.

occasionally, the box will lockup for 5 minutes, during which time routed 
traffic is extremely delayed (2 or 3 second ping times). initially, there were 
no log messages about the lockup. we switched from using an internal nvidia 
(forcedeth) NIC in the belief that it may have been causing the problem.. 
however: with the new gigabit NICs, we still see the hangs, but we also get 
this in the kernel log:

> Jul  2 07:50:12 cerberus1 kernel: [31895.510006] BUG: soft lockup - CPU#0 stuck for 61s! [conntrackd:1951]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] Modules linked in: authenc xfrm_user ah6 ah4 esp6 esp4 xfrm4_mode_beet xfrm4_tunnel xfrm4_mode_tunnel xfrm4_mode_tr
> ansport xfrm6_mode_transport xfrm6_mode_ro xfrm6_mode_beet xfrm6_mode_tunnel ipcomp ipcomp6 xfrm6_tunnel af_key cls_u32 sch_sfq sch_htb nf_conntrack_netlink nfnetli
> nk deflate zlib_deflate ctr camellia cast5 rmd160 sha1_generic crypto_null ccm serpent blowfish twofish twofish_common xcbc sha256_generic sha512_generic des_generi
> c cryptd aes_x86_64 aes_generic tunnel4 xfrm_ipcomp tunnel6 xt_MARK xt_tcpudp xt_esp ipt_ah xt_TCPMSS xt_HL xt_DSCP ipt_MASQUERADE ipt_REDIRECT ipt_LOG ipt_REJECT x
> t_mac xt_length xt_hl xt_dscp xt_tcpmss nf_nat_pptp nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp nf_conntrack_ftp ip_queue iptable_mangle ip
> table_filter xt_mark xt_recent xt_iprange xt_multiport xt_state xt_limit xt_conntrack iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_t
> ables 8021q fbcon tileblit font bitblit garp s
> Jul  2 07:50:17 cerberus1 kernel: oftcursor stp vga16fb vgastate lp shpchp sis_agp parport 8139too 8139cp r8169 mii sata_sis [last unloaded: af_key]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] CPU 0:
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] Modules linked in: authenc xfrm_user ah6 ah4 esp6 esp4 xfrm4_mode_beet xfrm4_tunnel xfrm4_mode_tunnel xfrm4_mode_tr
> ansport xfrm6_mode_transport xfrm6_mode_ro xfrm6_mode_beet xfrm6_mode_tunnel ipcomp ipcomp6 xfrm6_tunnel af_key cls_u32 sch_sfq sch_htb nf_conntrack_netlink nfnetli
> nk deflate zlib_deflate ctr camellia cast5 rmd160 sha1_generic crypto_null ccm serpent blowfish twofish twofish_common xcbc sha256_generic sha512_generic des_generi
> c cryptd aes_x86_64 aes_generic tunnel4 xfrm_ipcomp tunnel6 xt_MARK xt_tcpudp xt_esp ipt_ah xt_TCPMSS xt_HL xt_DSCP ipt_MASQUERADE ipt_REDIRECT ipt_LOG ipt_REJECT x
> t_mac xt_length xt_hl xt_dscp xt_tcpmss nf_nat_pptp nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp nf_conntrack_ftp ip_queue iptable_mangle ip
> table_filter xt_mark xt_recent xt_iprange xt_multiport xt_state xt_limit xt_conntrack iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_t
> ables 8021q fbcon tileblit font bitblit garp s
> Jul  2 07:50:17 cerberus1 kernel: oftcursor stp vga16fb vgastate lp shpchp sis_agp parport 8139too 8139cp r8169 mii sata_sis [last unloaded: af_key]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] Pid: 1951, comm: conntrackd Not tainted 2.6.32-23-server #37-Ubuntu ps6002
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] RIP: 0010:[<ffffffff814e9f52>]  [<ffffffff814e9f52>] __xfrm4_find_bundle+0x52/0xc0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] RSP: 0018:ffff880001c03a88  EFLAGS: 00000282
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] RAX: 0000000000000000 RBX: ffff880001c03ab8 RCX: ffff880001c00000
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] RDX: 000000180c2813ac RSI: ffff880073f9e800 RDI: ffff880073f9e828
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] RBP: ffffffff81013cb3 R08: 0000000000000000 R09: ffff880001c03c44
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880001c03a00
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] R13: ffff880001c03c08 R14: ffff88000c299980 R15: ffffffff8155effc
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] FS:  00007fdec3db5700(0000) GS:ffff880001c00000(0000) knlGS:0000000000000000
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] CR2: 0000000000f1d078 CR3: 00000000715c0000 CR4: 00000000000006f0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006] Call Trace:
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  <IRQ>  [<ffffffff814e9f28>] ? __xfrm4_find_bundle+0x28/0xc0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814ee91e>] ? __xfrm_lookup+0x14e/0x4e0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8146c591>] ? __skb_checksum_complete+0x11/0x20
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814ee71d>] ? __xfrm_policy_check+0x57d/0x630
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814e9ee5>] ? _decode_session4+0x245/0x260
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814eecc6>] ? xfrm_lookup+0x16/0x40
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814eed5b>] ? __xfrm_route_forward+0x6b/0xa0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814a355d>] ? ip_forward+0x2ed/0x420
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814a15ed>] ? ip_rcv_finish+0x12d/0x440
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814a1b75>] ? ip_rcv+0x275/0x360
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8153043d>] ? packet_rcv_spkt+0x4d/0x190
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8147236a>] ? netif_receive_skb+0x38a/0x5d0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff81534be0>] ? __vlan_hwaccel_rx+0x140/0x230
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffffa0012596>] ? rtl8169_rx_interrupt+0x216/0x5b0 [r8169]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffffa0012aad>] ? rtl8169_poll+0x3d/0x270 [r8169]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff81472e5f>] ? net_rx_action+0x10f/0x250
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8106e2f7>] ? __do_softirq+0xb7/0x1e0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff810142ec>] ? call_softirq+0x1c/0x30
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  <EOI>  [<ffffffff81015cb5>] ? do_softirq+0x65/0xa0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8106e77a>] ? local_bh_enable+0x9a/0xa0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffffa00b6185>] ? ipt_do_table+0x295/0x678 [ip_tables]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8106e77a>] ? local_bh_enable+0x9a/0xa0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffffa00b6185>] ? ipt_do_table+0x295/0x678 [ip_tables]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8110ce7b>] ? __krealloc+0x3b/0xa0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffffa00cb983>] ? __nf_ct_ext_add+0x143/0x180 [nf_conntrack]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff811330fd>] ? ksize+0x1d/0xd0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8110ce7b>] ? __krealloc+0x3b/0xa0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffffa00f91d4>] ? nf_nat_rule_find+0x24/0x80 [iptable_nat]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffffa00f9469>] ? nf_nat_fn+0x109/0x1b0 [iptable_nat]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffffa00f9558>] ? nf_nat_local_fn+0x48/0xe0 [iptable_nat]
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814997cc>] ? nf_iterate+0x6c/0xb0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814a4b40>] ? dst_output+0x0/0x20
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff81499884>] ? nf_hook_slow+0x74/0x100
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814a4b40>] ? dst_output+0x0/0x20
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814a6c9f>] ? __ip_local_out+0x9f/0xb0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814a6cc6>] ? ip_local_out+0x16/0x30
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814a6f72>] ? ip_push_pending_frames+0x292/0x420
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814c9210>] ? udp_push_pending_frames+0x170/0x410
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814c9ef2>] ? udp_sendmsg+0x4e2/0x850
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814d2249>] ? inet_sendmsg+0x29/0x60
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff812862ed>] ? aa_revalidate_sk+0x6d/0x90
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff81283bb9>] ? apparmor_socket_sendmsg+0x19/0x20
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff814618ab>] ? sock_sendmsg+0x10b/0x140
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff81085090>] ? autoremove_wake_function+0x0/0x40
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff81085090>] ? autoremove_wake_function+0x0/0x40
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8113f3d5>] ? __mem_cgroup_try_charge+0x55/0x1f0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff810fa819>] ? __alloc_pages_nodemask+0xd9/0x180
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff81461a65>] ? sys_sendto+0x125/0x180
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff81115d7f>] ? handle_mm_fault+0x31f/0x3c0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff8155c883>] ? do_page_fault+0x153/0x3b0
> Jul  2 07:50:17 cerberus1 kernel: [31895.510006]  [<ffffffff810131b2>] ? system_call_fastpath+0x16/0x1b


note, currently the second machine in the cluster is turned off.. same 
behavior with or without it.

I'm seriously inclined to think that the VLAN is a big factor:
the reason for the VLAN is to separate VOIP phones (nothing else on that 
VLAN). this morning, it was possible to trigger the lockup by placing a call. 
as soon as the call was hungup, everything returned to normal...

it's not repeatable, exactly. what seems to happen is that pings through the 
machine get slower and slower over the course of a few hours (from say 15ms to 
50ms), then all of a sudden the machine will throw a five minute 'fit'.

PS: this is a Ubuntu Lucid kernel - 2.6.32. I'm working on a stock kernel to 
see if it still happens..
