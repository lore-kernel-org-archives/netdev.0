From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN redirect using TC
Date: Sun, 14 Aug 2016 17:06:50 +0300
Message-ID: <20160814140652.15985-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33164 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbcHNOHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 10:07:09 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so6565785wme.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 07:07:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>>

Hi,

I would like to make it possible to manage VXLAN encap/decap using the flower
classifier, mirred action and vxlan device.
In order to make the solution scaleable, I'm using a shared vxlan device, with
encapsulation information packed in the metadata - by the mirred action in the
encap flow, and used in the decap flow, by the flower classifier.

For example for virt use case:
# [uplink NIC] --{cls_flower & mirred}--> [vxlan dev] --{udp/ip stack}--> [tap]
# [tap dev] --{udp/ip stack}--> [vxlan dev] --{cls_flower & mirred}--> [uplink NIC]
# In the example, vxlan tunnel ip's are 11.11.11.* and the real devices ip's
# are: 11.11.0.*

ip link add $VXLAN type vxlan dstport 4789 external

ifconfig $VXLAN up

tc qdisc add dev $ETH ingress

# ENCAP rule for ARP
tc filter add dev $ETH protocol 0x806 parent ffff: prio 11 \
		flower \
		action mirred egress redirect dev $VXLAN enc_src_ip 11.11.0.1 enc_dst_ip 11.11.0.2 enc_key_id 11 enc_dst_port 4789

# ENCAP rule for ICMP
tc filter add dev $ETH protocol ip parent ffff: prio 10 \
		flower ip_proto 1 \
		action mirred egress redirect dev $VXLAN enc_src_ip 11.11.0.1 enc_dst_ip 11.11.0.2 enc_key_id 11 enc_dst_port 4789

tc qdisc add dev $VXLAN ingress

# DECAP rule for ARP
tc filter add dev $VXLAN protocol 0x806 parent ffff: prio 11 \
		flower enc_src_ip 11.11.0.2 enc_dst_ip 11.11.0.1 enc_key_id 11 \
		action mirred egress redirect dev $ETH

# DECAP rule for ICMP
tc filter add dev $VXLAN protocol ip parent ffff: prio 10 \
		flower enc_src_ip 11.11.0.2 enc_dst_ip 11.11.0.1 enc_key_id 11 \
		action mirred egress redirect dev $ETH

Next step will be to enable offloading of those rules.

Following two patches to cls_flower and act_mirred were used to validate and
test this approach, and supplied to make things clearer, they will be modified
before the actual submission.

Thanks,
Amir

Amir Vadai (2):
  net/sched: cls_flower: Introduce classify by vxlan outer headers
  net/sched: act_mirred: Introduce vxlan support

 include/net/tc_act/tc_mirred.h        |  5 +++
 include/uapi/linux/pkt_cls.h          | 11 +++++
 include/uapi/linux/tc_act/tc_mirred.h |  7 ++++
 net/sched/act_mirred.c                | 79 +++++++++++++++++++++++++++++++++++
 net/sched/cls_flower.c                | 53 +++++++++++++++++++++++
 5 files changed, 155 insertions(+)

-- 
2.9.0
