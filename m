From: Brenden Blanco <bblanco@plumgrid.com>
Subject: ipv6_mc_check_mld - kernel BUG at net/core/skbuff.c:1128
Date: Mon, 10 Aug 2015 14:56:12 -0700
Message-ID: <CAMUH3-WBobHryNpxYUzuAr4bPBFkd=QFkWgOoLyGiVf6Qvx0Ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linus.luessing@c0d3.blue
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:33513 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932867AbbHJV4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 17:56:32 -0400
Received: by ykaz130 with SMTP id z130so44319348yka.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 14:56:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

Here is a crash that I am able to easily reproduce. The setup is:

2 VMs, running in libvirt (qemu-kvm)
CPU mode is host-passthrough, virtio drivers used wherever available
Disable ipv6 (just to limit the amount of multicast noise)
Set up a multicast vxlan tunnel between the two VMs
Attach the vxlan device to a linux bridge
Attach a veth pair to the linux bridge
Enable ipv6 on a single veth
At this point, either one of the VMs may crash with the attached trace

Here is the test script. Not all lines are necessary, some are a byproduct of
eliminating various functions from the trace to eliminate them as suspects.

---------------
rmmod ebtable_nat
rmmod ebtables
sysctl net.ipv6.conf.all.disable_ipv6=1
ip l add vxlan0 type vxlan id 10000 group 239.1.1.1 dev eth1
ip l add br0 type bridge
ip l set vxlan0 master br0
ip l set br0 up
ip l set vxlan0 up
ip l add v1a type veth peer name v1b
ip l set v1b master br0
ip l set v1b up
ip l set v1a up
sysctl net.ipv6.conf.v1a.disable_ipv6=0
----------------

Doing some code reading with Alexei, we found a suspect commit, which
introduces an skb_get and skb_may_pull of the same skb, which leads to the BUG
when skb->len == len.

9afd85c9e4552 "net: Export IGMP/MLD message validation code"

static struct sk_buff *skb_checksum_maybe_trim(struct sk_buff *skb,
      unsigned int transport_len)
...
       if (skb->len < len) {
               kfree_skb(skb);
               return NULL;
       } else if (skb->len == len) {
               return skb;
       }
...
static int __ipv6_mc_check_mld(struct sk_buff *skb,
                              struct sk_buff **skb_trimmed)
...
       skb_get(skb);
       skb_chk = skb_checksum_trimmed(skb, transport_len,
                                      ipv6_mc_validate_checksum);



Would someone more familiar with the code be able to suggest a viable solution
or patch to try?

Cheers,
Brenden


Apologies for some of the mangled text:

[  100.879047] ------------[ cut here ]------------
[  100.879105] kernel BUG at net/core/skbuff.c:1128!
[  100.879144] invalid opcode: 0000 [#1]
[  100.879250] Modules linked in: veth bridge stp llc vxlan
ip6_udp_tunnel udp_tunnel ip6table_filter ip6_tables iptable_filter
ip_tables x_tables netconsole configfs btrfs ib_iser rdma_cm iw_cm
ib_cm ib_sa ib_mad ib_core ib_addr openvswitch iscsi_tcp libiscsi_tcp
libiscsi xor scsi_transport_iscsi libcrc32c raid6_pq dm_crypt iosf_mbi
kvm_intel kvm ppdev dm_multipath crct10dif_pclmul scsi_dh crc32_pclmul
ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper
ablk_helper cryptd psmouse input_leds serio_raw floppy 8250_fintek
i2c_piix4 parport_pc pata_acpi mac_hid lp parport virtio_scsi
[last unloaded: ebtables]

[  100.881340] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.2.0-rc4+ #3
[  100.881375] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.8.2-20150617_082717-anatol 04/01/2014
[  100.881416] task: ffff88013abca940 ti: ffff88013abdc000 task.ti:
ffff88013abdc000
[  100.881457] RIP: 0010:[<ffffffff8168d3d7>] [<ffffffff8168d3d7>]
pskb_expand_head+0x227/0x260
[  100.881532] RSP: 0018:ffff88013fd03ab8  EFLAGS: 00010202
[  100.881567] RAX: 0000000000000002 RBX: ffff8800bb601500 RCX: 0000000000000020
[  100.881604] RDX: 0000000000000148 RSI: 0000000000000000 RDI: ffff8800bb601500
[  100.881642] RBP: ffff88013fd03af8 R08: 0000000000000000 R09: 000000000000001c
[  100.881677] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
[  100.881714] R13: ffff8800bb601500 R14: ffff8800bb358840 R15: 0000000000000000
[  100.881749] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000)
knlGS:0000000000000000
[  100.881790] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  100.881828] CR2: 00007f91049f2162 CR3: 0000000136a94000 CR4: 00000000001406e0
[  100.881864] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  100.881902] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  100.881936] Stack:
[  100.881977]  ffff88013fd03b38 ffffffff816cd766 ffff88013fd03b67
ffff8800bb601500
[  100.882149]  ffff88013fd03be0 0000000000000008 ffff8800bb358840
0000000000000000
[  100.882316]  ffff88013fd03b48 ffffffff8168e68f ffff88013fd03b48
000000088168f4d0
[  100.882486] Call Trace:
[  100.882524]  <IRQ>
100.882524]  <IRQ> ace:
03b480000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
0000000000
2717-anatol 04/01/2014
_netfilter if you need this.
 may change behavior in the future.

rser"

31 c0 87 87 b0 01 00 00 f7
 tpm br_netfilter e1000e dw_dmac i2c_hid dw_dmac_core wmi video bridge
8250_dw gpio_lynxpoint i2c_designware_platform ptp mei_me stp
i2c_designware_core pps_core llc acpi_pad mei i2c_core shpchp
spi_pxa2xx_platform processor button xt_addrtype nf_conntrack_ipv4
nf_defrag_ipv4 xt_conntrack ip6table_filter ip6_tables
nf_conntrack_netbios_ns nf_conntrack_broadcast nf_nat_ftp nf_nat
nf_conntrack_ftp nf_conntrack iptable_filter sch_fq_codel nfsd nfs
auth_rpcgss fscache oid_registry nfs_acl lockd grace sunrpc ip_tables
x_tables ext4 mbcache crc16 jbd2 dm_mod hid_generic usbhid hidore
ablk_helper
Aug 10 14:12:43 192.168.1.10 [  100.882558]  [<ffffffff816cd766>] ?
netlink_broadcast_filtered+0x136/0x3e0
Aug 10 14:12:43 192.168.1.10 [  100.882630]  [<ffffffff8168e68f>]
__pskb_pull_tail+0x4f/0x350
Aug 10 14:12:43 192.168.1.10 [  100.882671]  [<ffffffff8177da86>]
ipv6_mc_check_mld+0x286/0x330
Aug 10 14:12:43 192.168.1.10 [  100.882714]  [<ffffffffc03eaf45>]
br_multicast_rcv+0x85/0xb90 [bridge]
Aug 10 14:12:43 192.168.1.10 [  100.882751]  [<ffffffff810bc5e1>] ?
__raw_callee_save___pv_queued_spin_unlock+0x11/0x20
Aug 10 14:12:43 192.168.1.10 [  100.882792]  [<ffffffff8168a3ba>] ?
kfree_skbmem+0x5a/0x60
Aug 10 14:12:43 192.168.1.10 [  100.882829]  [<ffffffffc03dfef2>] ?
br_fdb_update+0x132/0x1e0 [bridge]
Aug 10 14:12:43 192.168.1.10 [  100.882868]  [<ffffffffc03e22b6>]
br_handle_frame_finish+0x296/0x590 [bridge]
Aug 10 14:12:43 192.168.1.10 [  100.882911]  [<ffffffff8169eeaf>] ?
__netif_receive_skb_core+0x63f/0x9a0
Aug 10 14:12:43 192.168.1.10 [  100.882948]  [<ffffffff8170aebe>] ?
udp4_gro_receive+0x11e/0x2d0
Aug 10 14:12:43 192.168.1.10 [  100.882987]  [<ffffffffc03e26ff>]
br_handle_frame+0x14f/0x280 [bridge]
Aug 10 14:12:43 192.168.1.10 [  100.883026]  [<ffffffff8169f228>] ?
__netif_receive_skb+0x18/0x60
Aug 10 14:12:43 192.168.1.10 [  100.883061]  [<ffffffff8169ea41>]
__netif_receive_skb_core+0x1d1/0x9a0
Aug 10 14:12:43 192.168.1.10 [  100.883100]  [<ffffffff8169fe55>] ?
napi_gro_receive+0xb5/0xf0
Aug 10 14:12:43 192.168.1.10 [  100.883136]  [<ffffffff815841bd>] ?
virtnet_receive+0x27d/0x890
Aug 10 14:12:43 192.168.1.10 [  100.883174]  [<ffffffff8169f228>]
__netif_receive_skb+0x18/0x60
Aug 10 14:12:43 192.168.1.10 [  100.883213]  [<ffffffff8169ff2f>]
process_backlog+0x9f/0x150
Aug 10 14:12:43 192.168.1.10 [  100.883248]  [<ffffffff8169f6ac>]
net_rx_action+0x14c/0x320
Aug 10 14:12:43 192.168.1.10 [  100.883289]  [<ffffffff81079a42>]
__do_softirq+0xd2/0x250
Aug 10 14:12:43 192.168.1.10 [  100.883328]  [<ffffffff81079df5>]
irq_exit+0x95/0xa0
Aug 10 14:12:43 192.168.1.10 [  100.883364]  [<ffffffff817aa83a>]
do_IRQ+0x5a/0xe0
Aug 10 14:12:43 192.168.1.10 [  100.883405]  [<ffffffff817a87ab>]
common_interrupt+0x6b/0x6b
Aug 10 14:12:43 192.168.1.10 [  100.883439]  <EOI>
Aug 10 14:12:43 192.168.1.10 100.883439]  <EOI> ffff817a87ab>]
common_interrupt+0x6b/0x6b
Aug 10 14:12:43 192.168.1.10 [  100.883476]  [<ffffffff8105d2b6>] ?
native_safe_halt+0x6/0x10
Aug 10 14:12:43 192.168.1.10 [  100.883550]  [<ffffffff8101ec8e>]
default_idle+0x1e/0xa0
Aug 10 14:12:43 192.168.1.10 [  100.883589]  [<ffffffff8101f35f>]
arch_cpu_idle+0xf/0x20
Aug 10 14:12:43 192.168.1.10 [  100.883625]  [<ffffffff810b59b2>]
default_idle_call+0x32/0x40
Aug 10 14:12:43 192.168.1.10 [  100.883664]  [<ffffffff810b5cce>]
cpu_startup_entry+0x2ae/0x320
Aug 10 14:12:43 192.168.1.10 [  100.883705]  [<ffffffff8104adf5>]
start_secondary+0x175/0x1a0
Aug 10 14:12:43 192.168.1.10 [  100.883740] Code:
Aug 10 14:12:43 192.168.1.10 [  100.885904] RIP
Aug 10 14:12:43 192.168.1.10 [<ffffffff8168d3d7>] pskb_expand_head+0x227/0x260
Aug 10 14:12:43 192.168.1.10 [  100.885973]  RSP <ffff88013fd03ab8>
Aug 10 14:12:43 192.168.1.10 [  100.886017] ---[ end trace 65465776bab2684e ]---
