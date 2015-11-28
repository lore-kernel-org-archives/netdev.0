From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V2 00/17] hv_netvsc: Eliminate the additional head room
Date: Sat, 28 Nov 2015 12:20:17 -0800
Message-ID: <1448742017-22693-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net ([208.109.80.60]:42921
	"EHLO p3plsmtps2ded03.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489AbbK1Srp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Nov 2015 13:47:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In an attempt to avoid having to allocate memory on the send path, the netvsc
driver was requesting additional head room so that both rndis header and the
netvsc packet (the state that had to persist) could be placed in the skb.
Since the amount of head room requested was exceeding the default head room
as set in LL_MAX_HEADER, we were forcing a reallocation of skb.

With this patch-set, I have reduced the size of the netvsc packet to less
than 20 bytes and with this reduction we don't need to ask for any additional
headroom. We place the rndis header in the skb head room and we place the
netvsc packet in control buffer area in the skb.

V2:  - Addressed  review comments:
     - Eliminated more fields from netvsc packet structure.

K. Y. Srinivasan (15):
  hv_netvsc: Resize some of the variables in hv_netvsc_packet
  hv_netvsc: Rearrange the hv_negtvsc_packet to be space efficient
  hv_netvsc: Eliminate the channel field in hv_netvsc_packet structure
  hv_netvsc: Eliminate rndis_msg pointer from hv_netvsc_packet
    structure
  hv_netvsc: Eliminatte the data field from struct hv_netvsc_packet
  hv_netvsc: Eliminate send_completion from struct hv_netvsc_packet
  hv_netvsc: Eliminate send_completion_ctx from struct hv_netvsc_packet
  hv_netvsc: Don't ask for additional head room in the skb
  hv_netvsc: Eliminate page_buf from struct hv_netvsc_packet
  hv_netvsc: Eliminate send_completion_tid from struct hv_netvsc_packet
  hv_netvsc: Eliminate is_data_pkt from struct hv_netvsc_packet
  hv_netvsc: Eliminate completion_func from struct hv_netvsc_packet
  hv_netvsc: Eliminate xmit_more from struct hv_netvsc_packet
  hv_netvsc: Eliminate status from struct hv_netvsc_packet
  hv_netvsc: Eliminate vlan_tci from struct hv_netvsc_packet

Vitaly Kuznetsov (2):
  hv_netvsc: move subchannel existence check to netvsc_select_queue()
  hv_netvsc: remove locking in netvsc_send()

 drivers/net/hyperv/hyperv_net.h   |   48 +++++++----------
 drivers/net/hyperv/netvsc.c       |  102 ++++++++++++++++++-------------------
 drivers/net/hyperv/netvsc_drv.c   |   93 +++++++++++++---------------------
 drivers/net/hyperv/rndis_filter.c |   66 ++++++++++++------------
 include/linux/netdevice.h         |    4 +-
 5 files changed, 138 insertions(+), 175 deletions(-)

-- 
1.7.4.1
