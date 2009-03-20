From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/5] igb: allow tx of pre-formatted vlan tagged
	packets
Date: Fri, 20 Mar 2009 03:16:31 -0700
Message-ID: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Arthur Jones <ajones@riverbed.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:39011 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757826AbZCTKWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 06:22:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arthur Jones <ajones@riverbed.com>

When the 82575 is fed 802.1q packets, it chokes with
an error of the form:

igb 0000:08:00.1 partial checksum but proto=81!

As the logic there was not smart enough to look into
the vlan header to pick out the encapsulated protocol.

There are times when we'd like to send these packets
out without having to configure a vlan on the interface.
Here we check for the vlan tag and allow the packet to
go out with the correct hardware checksum.

Thanks to Kand Ly <kand@riverbed.com> for discovering the
issue and the coming up with a solution.  This patch is
based upon his work.

Signed-off-by: Arthur Jones <ajones@riverbed.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7c4481b..c14d569 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3008,6 +3008,17 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			__be16 protocol;
+
+			if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
+				const struct vlan_ethhdr *vhdr =
+				          (const struct vlan_ethhdr*)skb->data;
+
+				protocol = vhdr->h_vlan_encapsulated_proto;
+			} else {
+				protocol = skb->protocol;
+			}
+
 			switch (skb->protocol) {
 			case cpu_to_be16(ETH_P_IP):
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;

