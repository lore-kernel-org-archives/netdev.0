From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] e1000e: allow tx of pre-formatted vlan tagged
	packets
Date: Thu, 19 Mar 2009 04:13:08 -0700
Message-ID: <20090319111308.11601.93121.stgit@lost.foo-projects.org>
References: <20090319111226.11601.40603.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Arthur Jones <ajones@riverbed.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:60497
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755365AbZCSLNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:13:32 -0400
In-Reply-To: <20090319111226.11601.40603.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arthur Jones <ajones@riverbed.com>

As with igb, when the e1000e driver is fed 802.1q
packets with hardware checksum on, it chokes with an
error of the form:

checksum_partial proto=81!

As the logic there was not smart enough to look into
the vlan header to pick out the encapsulated protocol.

There are times when we'd like to send these packets
out without having to configure a vlan on the interface.
Here we check for the vlan tag and allow the packet to
go out wiht the correct hardware checksum.

Thanks to Kand Ly <kand@riverbed.com> for discovering the
issue and the coming up with a solution.  This patch is
based upon his work.

Fixups from Stephen Hemminger <shemminger@vyatta.com> and
Alexander Duyck <alexander.h.duyck@intel.com>

Signed-off-by: Arthur Jones <ajones@riverbed.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/e1000e/netdev.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index da876d5..d092eaf 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3764,10 +3764,16 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 	unsigned int i;
 	u8 css;
 	u32 cmd_len = E1000_TXD_CMD_DEXT;
+	__be16 protocol;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return 0;
 
+	if (skb->protocol == cpu_to_be16(ETH_P_8021Q))
+		protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
+	else
+		protocol = skb->protocol;
+
 	switch (skb->protocol) {
 	case cpu_to_be16(ETH_P_IP):
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
@@ -3780,7 +3786,8 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 		break;
 	default:
 		if (unlikely(net_ratelimit()))
-			e_warn("checksum_partial proto=%x!\n", skb->protocol);
+			e_warn("checksum_partial proto=%x!\n",
+			       be16_to_cpu(protocol));
 		break;
 	}
 

