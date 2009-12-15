From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: allow tx of pre-formatted vlan tagged packets
Date: Tue, 15 Dec 2009 15:00:31 -0800
Message-ID: <20091215230030.26068.26462.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Gurucharan Shetty <gshetty@riverbed.com>,
	Arthur Jones <ajones@riverbed.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:46564 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934346AbZLOXAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 18:00:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gurucharan Shetty <gshetty@riverbed.com>

When the 82598 is fed 802.1q packets, it chokes with
an error of the form:

ixgbe: eth0: ixgbe_tx_csum: partial checksum but proto=81!

As the logic there was not smart enough to look into
the vlan header to pick out the encapsulated protocol.

There are times when we'd like to send these packets
out without having to configure a vlan on the interface.
Here we check for the vlan tag and allow the packet to
go out with the correct hardware checksum.

This patch is a clone of a previously submitted patch by
Arthur Jones <ajones@riverbed.com> for igb (Commit -
fa4a7ef36ec834fee1719636b30d2f28f4cb0166).

Signed-off-by: Gurucharan Shetty <gshetty@riverbed.com>
Signed-off-by: Arthur Jones <ajones@riverbed.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 22519fa..47c55d2 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5006,7 +5006,18 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 		                    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			switch (skb->protocol) {
+			__be16 protocol;
+
+			if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
+				const struct vlan_ethhdr *vhdr =
+					(const struct vlan_ethhdr *)skb->data;
+
+				protocol = vhdr->h_vlan_encapsulated_proto;
+			} else {
+				protocol = skb->protocol;
+			}
+
+			switch (protocol) {
 			case cpu_to_be16(ETH_P_IP):
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)

