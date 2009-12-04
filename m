From: Gurucharan Shetty <gshetty@riverbed.com>
Subject: [PATCH] ixgbe: allow tx of pre-formatted vlan tagged packets
Date: Fri, 4 Dec 2009 13:12:36 -0800
Message-ID: <1259961156.4198.163.camel@gshetty>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arthur Jones <ajones@riverbed.com>
To: <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from autosupport.riverbed.com ([208.70.196.45]:23865 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757233AbZLDVWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 16:22:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ixgbe: allow tx of pre-formatted vlan tagged packets
  
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

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 77b0381..69157e4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4810,6 +4810,17 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 		                    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
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
 			switch (skb->protocol) {
 			case cpu_to_be16(ETH_P_IP):
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;


