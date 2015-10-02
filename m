From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e: fix offload of GRE tunnels
Date: Thu,  1 Oct 2015 18:25:42 -0700
Message-ID: <1443749142-40988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56725 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbbJBB0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 21:26:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver still was not offloading TSO on GRE tunnels because
it forgot to set the GSO_GRE flag, causing lots of retransmits.

This fixes generic GRE traffic (like a tunnel added like below)
whereas before it would get 1Gb/s or less, now on a 10G adapter
it gets 8.7Gb/s.

ip ad ad 11.1.0.2/24 dev ens2f0
ip l set ens2f0 up
ip link add gre2 type gretap remote 11.1.0.1 local 11.1.0.2 dev ens2f0
ip l set gre2 up
ip ad ad 192.168.124.2/24 dev gre2
ping 192.168.124.1
netperf -H 192.168.124.1

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 48a52b3..171e0b8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8166,6 +8166,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 
 	netdev->hw_enc_features |= NETIF_F_IP_CSUM	 |
 				  NETIF_F_GSO_UDP_TUNNEL |
+				  NETIF_F_GSO_GRE	 |
 				  NETIF_F_TSO;
 
 	netdev->features = NETIF_F_SG		       |
@@ -8173,6 +8174,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 			   NETIF_F_SCTP_CSUM	       |
 			   NETIF_F_HIGHDMA	       |
 			   NETIF_F_GSO_UDP_TUNNEL      |
+			   NETIF_F_GSO_GRE	       |
 			   NETIF_F_HW_VLAN_CTAG_TX     |
 			   NETIF_F_HW_VLAN_CTAG_RX     |
 			   NETIF_F_HW_VLAN_CTAG_FILTER |
-- 
2.4.3
