From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] Fix IPv6 GSO type checks in Intel ethernet
	drivers
Date: Sat, 23 Jan 2010 01:24:45 -0800
Message-ID: <20100123092430.11188.13968.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Sridhar Samudrala <sri@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:47549
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752318Ab0AWJZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:25:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>

Found this problem when testing IPv6 from a KVM guest to a remote
host via e1000e device on the host.
The following patch fixes the check for IPv6 GSO packet in Intel
ethernet drivers to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
when packets are forwarded from a guest.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c        |    2 +-
 drivers/net/igb/igb_main.c         |    2 +-
 drivers/net/igbvf/netdev.c         |    2 +-
 drivers/net/ixgbe/ixgbe_main.c     |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3d57ca5..2353e95 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3771,7 +3771,7 @@ static int e1000_tso(struct e1000_adapter *adapter,
 		                                         0, IPPROTO_TCP, 0);
 		cmd_length = E1000_TXD_CMD_IP;
 		ipcse = skb_transport_offset(skb) - 1;
-	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+	} else if (skb_is_gso_v6(skb)) {
 		ipv6_hdr(skb)->payload_len = 0;
 		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 		                                       &ipv6_hdr(skb)->daddr,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d967949..d4bbdf0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3422,7 +3422,7 @@ static inline int igb_tso_adv(struct igb_ring *tx_ring,
 							 iph->daddr, 0,
 							 IPPROTO_TCP,
 							 0);
-	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+	} else if (skb_is_gso_v6(skb)) {
 		ipv6_hdr(skb)->payload_len = 0;
 		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 						       &ipv6_hdr(skb)->daddr,
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index a6c3920..ce33671 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1963,7 +1963,7 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
 		                                         iph->daddr, 0,
 		                                         IPPROTO_TCP,
 		                                         0);
-	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+	} else if (skb_is_gso_v6(skb)) {
 		ipv6_hdr(skb)->payload_len = 0;
 		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 		                                       &ipv6_hdr(skb)->daddr,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 81971ed..b2c0025 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5113,7 +5113,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			                                         iph->daddr, 0,
 			                                         IPPROTO_TCP,
 			                                         0);
-		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+		} else if (skb_is_gso_v6(skb)) {
 			ipv6_hdr(skb)->payload_len = 0;
 			tcp_hdr(skb)->check =
 			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 39544af..652b6f4 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2756,7 +2756,7 @@ static int ixgbevf_tso(struct ixgbevf_adapter *adapter,
 								 IPPROTO_TCP,
 								 0);
 			adapter->hw_tso_ctxt++;
-		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+		} else if (skb_is_gso_v6(skb)) {
 			ipv6_hdr(skb)->payload_len = 0;
 			tcp_hdr(skb)->check =
 			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,

