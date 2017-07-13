From: Jiannan Ouyang <ouyangj@fb.com>
Subject: [PATCH net-next v1 0/3] Flow Based GTP Tunneling
Date: Wed, 12 Jul 2017 17:44:52 -0700
Message-ID: <20170713004455.3946570-1-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <pablo@netfilter.org>, <laforge@gnumonks.org>,
        <pshelar@nicira.com>, <wieger.ijntema.tno@gmail.com>,
        <yi.y.yang@intel.com>, <joe@ovn.org>, <amarpadmanabhan@fb.com>,
        Jiannan Ouyang <ouyangj@fb.com>
To: <osmocom-net-gprs@lists.osmocom.org>, <netdev@vger.kernel.org>,
        <dev@openvswitch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45504 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751069AbdGMApk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 20:45:40 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v6D0hIFw030843
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 17:45:40 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2bnucxgj33-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 17:45:40 -0700
Received: from facebook.com (2401:db00:21:601e:face:0:45:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 96225498676411e7853e6f8865c8440f-6fed7150 for <netdev@vger.kernel.org>;        Wed,
 12 Jul 2017 17:45:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series augmented the existing GTP module to support flow
based GTP tunneling and modified the openvswitch datapath to support the
GTP vport type.

A flow based GTP net device enables that,
1) on the RX path, the outer (IP/UDP/GTP) header information could to be
stored in the metadata_dst struct, and embedded into the skb.
2) on the TX path, packets are encapsulated following instructions in
the metadata_dst field of the skb.

A flow based GTP net device can be integrated with Open vSwitch, which
allows SDN controllers to program GTP tunnels via Open vSwitch. 

Open vSwitch changes are based on patch set
    [PATCH] Add GTP vport based on upstream datapath

Example usage with OVS:

ovs-vsctl add-port br0 gtp-vport -- set interface gtp-vport \
    ofport_request=2 type=gtp option:remote_ip=flow options:key=flow

ovs-ofctl add-flow br0
    "in_port=2,tun_src=192.168.60.141,tun_id=123, \
    actions=set_field:02:00:00:00:00:00->eth_src, \
    set_field:ff:ff:ff:ff:ff:ff->eth_dst,LOCAL"

ovs-ofctl add-flow br0 \
    "in_port=LOCAL,actions=set_tunnel:888, \
    set_field:192.168.60.141->tun_dst,2"

arp -s 10.1.1.122 02:00:00:00:00:00

Jiannan Ouyang (3):
  gtp: refactor to support flow-based gtp encap and decap
  gtp: Support creating flow-based gtp net_device
  openvswitch: Add GPRS Tunnel Protocol (GTP) vport support

 drivers/net/gtp.c                | 375 ++++++++++++++++++++++++++++++++-------
 include/net/gtp.h                |   8 +
 include/uapi/linux/openvswitch.h |   1 +
 net/openvswitch/Kconfig          |  10 ++
 net/openvswitch/Makefile         |   1 +
 net/openvswitch/vport-gtp.c      | 144 +++++++++++++++
 6 files changed, 475 insertions(+), 64 deletions(-)
 create mode 100644 net/openvswitch/vport-gtp.c

-- 
2.9.3
