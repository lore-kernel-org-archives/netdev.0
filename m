From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Wed, 11 Nov 2015 16:47:36 +0200
Message-ID: <56435508.9070802@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Joe Stringer <joestringer@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0054.outbound.protection.outlook.com ([157.56.112.54]:41047
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750818AbbKKOsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 09:48:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe/Jesse,

We've noticed that VXLAN decap rules set by OVS in the below trivial 
VXLAN config contain full match on TTL=64 for the outer headers, can you 
explain the reasoning behind it? is that justa typo in dumping the flow?

I also noticed that on my systems (upstream kernel 4.3.0-rc6+, veth 
emulating a VM network 192.168.52/24 and host network 192.168.31/24, ovs 
user-space 2.3.2) something is broken in the encap rule reporting, 
traffic goes fine (below)

I tried downgrading the ovs 2.0.90 and ovs-dpctl dump-flows crashes, the 
core dump (...) doesn't say much.

Is there a kernel patch that can assist here? if not, what user-space 
version you recommend to make that dumping work
better?

Or.

# ovs-vsctl show
0ea2d6c6-93d0-4e5d-ad99-d47213bb0bf1
     Bridge ovs-tun
         Port ovs-tun
             Interface ovs-tun
                 type: internal
         Port "vxlan0"
             Interface "vxlan0"
                 type: vxlan
                 options: {dst_port="4789", key="98", 
remote_ip="192.168.31.18"}
         Port "veth1"
             Interface "veth1"
     ovs_version: "2.3.2"

# ovs-dpctl show
system@ovs-system:
         lookups: hit:41456 missed:1364 lost:15
         flows: 4
         masks: hit:54475 total:6 hit/pkt:1.27
         port 0: ovs-system (internal)
         port 1: ovs-tun (internal)
         port 2: vxlan_sys_4789 (vxlan: df_default=false, ttl=0)
         port 3: veth1

# ovs-dpctl dump-flows

decap rule:

recirc_id(0),skb_priority(0),tunnel(tun_id=0x62,src=192.168.31.18,dst=192.168.31.17,tos=0x0,ttl=64,flags(key)),in_port(2),skb_mark(0),eth(src=9e:1e:90:87:27:1a,dst=ce:57:32:ec:06:1a),eth_type(0x0800),ipv4(src=192.168.52.18/0.0.0.0,dst=192.168.52.17/0.0.0.0,proto=1/0,tos=0/0,ttl=64/0,frag=no/0xff), 
packets:3, bytes:294, used:0.012s, actions:3

encap rule:

recirc_id(0),skb_priority(0),in_port(3),eth(src=ce:57:32:ec:06:1a,dst=9e:1e:90:87:27:1a),eth_type(0x0800),ipv4(src=192.168.52.17/0.0.0.0,dst=192.168.52.18/0.0.0.0,proto=1/0,tos=0/0x3,ttl=64/0,frag=no/0xff), 
packets:2, bytes:196, used:0.012s, actions:set(unspec(bad key length 8, 
expected -1)(00 00 00 00 00 00 00 62)),2


[root@r-dcs54 vxlan]# tcpdump -nnei veth0 icmp -c 2
16:41:06.037788 0e:35:5a:35:13:5c > 9e:1e:90:87:27:1a, ethertype IPv4 
(0x0800), length 98: 192.168.52.17 > 192.168.52.18: ICMP echo request, 
id 5946, seq 1566, length 64
16:41:06.037903 9e:1e:90:87:27:1a > 0e:35:5a:35:13:5c, ethertype IPv4 
(0x0800), length 98: 192.168.52.18 > 192.168.52.17: ICMP echo reply, id 
5946, seq 1566, length 64


[root@r-dcs54 vxlan]# tcpdump -nnei eth3 udp -c 2
16:40:56.037061 00:02:c9:e9:bf:32 > f4:52:14:01:da:82, ethertype IPv4 
(0x0800), length 148: 192.168.31.17.51757 > 192.168.31.18.4789: UDP, 
length 106
16:40:56.037121 f4:52:14:01:da:82 > 00:02:c9:e9:bf:32, ethertype IPv4 
(0x0800), length 148: 192.168.31.18.53633 > 192.168.31.17.4789: UDP, 
length 106
