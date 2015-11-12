From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Thu, 12 Nov 2015 08:34:53 +0200
Message-ID: <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
References: <56435508.9070802@mellanox.com>
	<CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Joe Stringer <joestringer@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:34297 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbbKLGex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 01:34:53 -0500
Received: by igbxf8 with SMTP id xf8so5468151igb.1
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 22:34:53 -0800 (PST)
In-Reply-To: <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2015 at 12:44 AM, Jesse Gross <jesse@kernel.org> wrote:
> On Wed, Nov 11, 2015 at 6:47 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> Hi Joe/Jesse,
>>
>> We've noticed that VXLAN decap rules set by OVS in the below trivial VXLAN
>> config contain full match on TTL=64 for the outer headers, can you explain
>> the reasoning behind it? is that justa typo in dumping the flow?
>
> Looking at the code, this does indeed seem to be the case. To the best
> of my knowledge, there was no particular reasoning behind it - it
> simply was never an issue so the wildcard generation wasn't improved.

so all of the multi-million vxlan packets that were ever decapsulatd by OVS
arrived with TTL=X=64, this is impossible... when tunneled traffic goes
through routers, they change TTL of the outer packet, right?

so if the was a router between my hosts, the packet would arrive with TTL-63, we
still miss something here.

08:09:32.704276 00:02:c9:e9:bf:32 > f4:52:14:01:da:82, ethertype IPv4
(0x0800), length 148: (tos 0x0, ttl 64, id 31703, offset 0, flags
[DF], proto UDP (17), length 134)
    192.168.31.17.51757 > 192.168.31.18.4789: [no cksum] UDP, length 106
08:09:32.704323 f4:52:14:01:da:82 > 00:02:c9:e9:bf:32, ethertype IPv4
(0x0800), length 148: (tos 0x0, ttl 64, id 45301, offset 0, flags
[DF], proto UDP (17), length 134)
    192.168.31.18.53633 > 192.168.31.17.4789: [no cksum] UDP, length 106


>> I also noticed that on my systems (upstream kernel 4.3.0-rc6+, veth
>> emulating a VM network 192.168.52/24 and host network 192.168.31/24, ovs
>> user-space 2.3.2) something is broken in the encap rule reporting, traffic
>> goes fine (below)

> That is pretty strange, I have never seen that before. It seems that
> the key to be set is being reported as UNSPEC, which is weird if
> traffic is flowing normally. I guess you could try a newer version of
> userspace but I'm not aware of any patches that went in that would
> have fixed a bug in this area.

Seems as clear regression here w.r.t inter-operability between OVS user/kernel,
user space 2.3.2 which is listed in the web site as the latest release
on the LTS branch reports junk,
user space 2.0.90 crashes...

looking in the kernel logs when I did the runs with 2.3.2 I do see
this prints few times

openvswitch: netlink: Key type 62 is out of range max 26

and later the below "Dropping previously announced user features" warning

So I now moved to 2.4.0, and things aren't much better... can you give
a quick try on
your systems for upstream kernel against upstream OVS w.r.t to simple
VXLAN config?

Or.


[root@r-dcs54 ~]# ovs-vsctl show
0ea2d6c6-93d0-4e5d-ad99-d47213bb0bf1
    Bridge ovs-tun
        Port ovs-tun
            Interface ovs-tun
                type: internal
        Port "vxlan0"
            Interface "vxlan0"
                type: vxlan
                options: {dst_port="4789", key="98", remote_ip="192.168.31.18"}
        Port "veth1"
            Interface "veth1"
    ovs_version: "2.4.0"

[root@r-dcs54 ~]# ovs-dpctl show
system@ovs-system:
        lookups: hit:53786 missed:1835 lost:22
        flows: 4
        masks: hit:99881 total:14 hit/pkt:1.80
        port 0: ovs-system (internal)
        port 1: ovs-tun (internal)
        port 2: vxlan_sys_4789 (vxlan)
        port 3: veth1

[root@r-dcs54 ~]# ovs-dpctl dump-flows
recirc_id(0),in_port(3),eth(src=02:d3:6e:35:59:35,dst=9e:1e:90:87:27:1a),eth_type(0x0800),ipv4(tos=0/0x3,frag=no),
packets:111, bytes:10878, used:0.569s, actions:set(unspec(bad key
length 8, expected 0)(00 00 00 00 00 00 00 62)),2

recirc_id(0),tunnel(tun_id=0x62,src=192.168.31.18,dst=192.168.31.17,ttl=64,flags(-df-csum+key)),in_port(2),skb_mark(0),eth(src=9e:1e:90:87:27:1a,dst=02:d3:6e:35:59:35),eth_type(0x0800),ipv4(frag=no),
packets:111, bytes:10878, used:0.569s, actions:3

recirc_id(0),in_port(3),eth(src=02:d3:6e:35:59:35,dst=9e:1e:90:87:27:1a),eth_type(0x0806),
packets:0, bytes:0, used:never, actions:set(unspec(bad key length 8,
expected 0)(00 00 00 00 00 00 00 62)),2

recirc_id(0),tunnel(tun_id=0x62,src=192.168.31.18,dst=192.168.31.17,ttl=64,flags(-df-csum+key)),in_port(2),skb_mark(0),eth(src=9e:1e:90:87:27:1a,dst=02:d3:6e:35:59:35),eth_type(0x0806),
packets:0, bytes:0, used:never, actions:3

[root@r-dcs54 ~]# tcpdump -nnei veth1 icmp -c 2
08:32:34.636523 02:d3:6e:35:59:35 > 9e:1e:90:87:27:1a, ethertype IPv4
(0x0800), length 98: 192.168.52.17 > 192.168.52.18: ICMP echo request,
id 61217, seq 128, length 64
08:32:34.636642 9e:1e:90:87:27:1a > 02:d3:6e:35:59:35, ethertype IPv4
(0x0800), length 98: 192.168.52.18 > 192.168.52.17: ICMP echo reply,
id 61217, seq 128, length 64

[root@r-dcs54 ~]# tcpdump -nnei eth3 udp -c 2
08:32:24.636522 00:02:c9:e9:bf:32 > f4:52:14:01:da:82, ethertype IPv4
(0x0800), length 148: 192.168.31.17.51757 > 192.168.31.18.4789: UDP,
length 106
08:32:24.636575 f4:52:14:01:da:82 > 00:02:c9:e9:bf:32, ethertype IPv4
(0x0800), length 148: 192.168.31.18.53633 > 192.168.31.17.4789: UDP,
length 106


Or.


------------[ cut here ]------------
WARNING: CPU: 3 PID: 16953 at net/openvswitch/datapath.c:1518
ovs_dp_cmd_new+0x1e0/0x3b8 [openvswitch]()
Dropping previously announced user features
Modules linked in: vport_vxlan openvswitch nf_conntrack crc32c_generic
libcrc32c veth netconsole nfsv3 nfs_acl auth_rpcgss oid_registry nfsv4
nfs lockd grace autofs4
 sunrpc rdma_ucm rdma_cm iw_cm ib_ipoib ib_cm ib_uverbs ib_umad
mlx4_en mlx4_ib vxlan udp_tunnel ip6_udp_tunnel ib_sa ib_mad ib_core
ib_addr ipv6 mlx4_core dm_mirror
 dm_region_hash dm_log dm_mod fjes igb dca ptp pps_core sg joydev
microcode rng_core pcspkr ehci_pci ehci_hcd shpchp button sr_mod ext4
jbd2 crc16 usb_storage floppy
 sd_mod ata_generic ata_piix libata scsi_mod uhci_hcd radeon ttm hwmon
[last unloaded: mst_pci]
CPU: 3 PID: 16953 Comm: ovs-vswitchd Tainted: G           O    4.3.0-rc6+ #553
Hardware name: Supermicro X7DWU/X7DWU, BIOS  1.1 04/30/2008
 00000000000005ee ffff88022506b968 ffffffff81216d8b ffffffffa0518068
 ffff88022506b9b8 ffff88022506b9a8 ffffffff81047324 ffff88022506b9a8
 ffffffffa050d8f5 ffff8802144baa80 ffff8802146f0e80 ffff88022506bae8
Call Trace:
 [<ffffffff81216d8b>] dump_stack+0x4f/0x68
 [<ffffffff81047324>] warn_slowpath_common+0xa1/0xbb
 [<ffffffffa050d8f5>] ? ovs_dp_cmd_new+0x1e0/0x3b8 [openvswitch]
 [<ffffffff810473e1>] warn_slowpath_fmt+0x46/0x5f
 [<ffffffffa050d6ef>] ? lookup_datapath.clone.3+0x130/0x156 [openvswitch]
 [<ffffffffa050d8f5>] ovs_dp_cmd_new+0x1e0/0x3b8 [openvswitch]
 [<ffffffff81239705>] ? nla_parse+0x4f/0xec
 [<ffffffff8141d3d0>] genl_family_rcv_msg+0x272/0x2ce
 [<ffffffff81418779>] ? __netlink_alloc_skb+0x1a/0x1a
 [<ffffffff8141c90b>] ? genl_rcv+0x1d/0x3c
 [<ffffffff8141d497>] genl_rcv_msg+0x6b/0x8e
 [<ffffffff8141d42c>] ? genl_family_rcv_msg+0x2ce/0x2ce
 [<ffffffff8141c077>] netlink_rcv_skb+0x43/0x9a
 [<ffffffff8141c90b>] ? genl_rcv+0x1d/0x3c
 [<ffffffff8141c91a>] genl_rcv+0x2c/0x3c
 [<ffffffff8141b625>] netlink_unicast+0x108/0x196
 [<ffffffff81121c36>] ? __might_fault+0x44/0x94
 [<ffffffff8141bc9d>] netlink_sendmsg+0x2da/0x329
 [<ffffffff813d5cf4>] sock_sendmsg+0x31/0x41
 [<ffffffff813d5e4b>] ___sys_sendmsg+0x147/0x1c9
 [<ffffffff8141bcb0>] ? netlink_sendmsg+0x2ed/0x329
 [<ffffffff813d6118>] ? SyS_sendto+0xe2/0x10a
 [<ffffffff81121c7f>] ? __might_fault+0x8d/0x94
 [<ffffffff8116d9b0>] ? __fget_light+0x56/0x81
 [<ffffffff813d4926>] ? move_addr_to_user+0x83/0xa8
 [<ffffffff813d6005>] __sys_sendmsg+0x42/0x63
 [<ffffffff813d6034>] SyS_sendmsg+0xe/0x10
 [<ffffffff814aadd7>] entry_SYSCALL_64_fastpath+0x12/0x6f
---[ end trace f1594c69e4486257 ]---
