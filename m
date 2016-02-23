From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/5] bridge/ovs: avoid skb head copy on frame forwarding
Date: Tue, 23 Feb 2016 13:53:45 +0100
Message-ID: <cover.1456163137.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbcBWMyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 07:54:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, while when an OVS or Linux bridge is used to forward frames towards
some tunnel device, a skb_head_copy() may occur if the ingress device do not
provide enough headroom for the tx encapsulation.

This patch series tries to address the issue implementing a new ndo operation to
allow the master device to control the headroom used when allocating the skb on
frame reception.

Said operation is used by the Linux bridge to notify the bridged ports of
needed_headroom changes, and similar bookkeeping and behaviour is also added to
openvswitch, on a per datapath basis.

Finally, the operation is implemented for veth and tun device, which give
performance improvement in the 6-12% range when forwarding frames from said
devices towards a vxlan tunnel.

Paolo Abeni (5):
  netdev: introduce ndo_set_rx_headroom
  bridge: notify ensabled devices of headroom changes
  ovs: propagate per dp max headroom to all vports
  net/tun: implement ndo_set_rx_headroom
  veth: implement ndo_set_rx_headroom

 drivers/net/tun.c                    | 16 +++++++++++-
 drivers/net/veth.c                   | 26 +++++++++++++++++++
 include/linux/netdevice.h            | 20 +++++++++++++++
 net/bridge/br_if.c                   | 36 +++++++++++++++++++++++++--
 net/openvswitch/datapath.c           | 48 ++++++++++++++++++++++++++++++++++++
 net/openvswitch/datapath.h           |  4 +++
 net/openvswitch/vport-internal_dev.c | 10 +++++++-
 7 files changed, 156 insertions(+), 4 deletions(-)

-- 
1.8.3.1
