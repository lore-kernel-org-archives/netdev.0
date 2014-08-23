From: vyasevich@gmail.com
Subject: [PATCH 8/8] qlge: Fix TSO for non-accelerated vlan traffic
Date: Fri, 22 Aug 2014 22:17:10 -0400
Message-ID: <1408760230-7457-9-git-send-email-vysevich@gmail.com>
References: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:57242 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbaHWCRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 22:17:40 -0400
Received: by mail-qa0-f41.google.com with SMTP id j7so10483854qaq.0
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 19:17:39 -0700 (PDT)
In-Reply-To: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevic@redhat.com>

This device claims TSO support for vlans.  It also allows a user to
control vlan acceleration offloading.  As such, it is possible to turn
off vlan acceleration and configure a vlan which will continue to send
TSO traffic.

In such situation the packet passed down the the device will contain
a vlan header and skb->protocol will be set to ETH_P_8021Q.
The device assumes that skb->protocol contains network protocol
value and uses that value to set up TSO information.
This results in corrupted frames sent on the wire.

This patch extracts the protocol value correctly by using a
vlan_get_protocol() helper and corrects corrupt TSO frames.

CC: Shahed Shaikh <shahed.shaikh@qlogic.com>
CC: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
CC: Ron Mercer <ron.mercer@qlogic.com>
CC: linux-driver@qlogic.com
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 188626e..3e96f26 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2556,6 +2556,7 @@ static int ql_tso(struct sk_buff *skb, struct ob_mac_tso_iocb_req *mac_iocb_ptr)
 
 	if (skb_is_gso(skb)) {
 		int err;
+		__be16 l3_proto = vlan_get_protocol(skb);
 
 		err = skb_cow_head(skb, 0);
 		if (err < 0)
@@ -2572,7 +2573,7 @@ static int ql_tso(struct sk_buff *skb, struct ob_mac_tso_iocb_req *mac_iocb_ptr)
 				<< OB_MAC_TRANSPORT_HDR_SHIFT);
 		mac_iocb_ptr->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 		mac_iocb_ptr->flags2 |= OB_MAC_TSO_IOCB_LSO;
-		if (likely(skb->protocol == htons(ETH_P_IP))) {
+		if (likely(l3_proto == htons(ETH_P_IP))) {
 			struct iphdr *iph = ip_hdr(skb);
 			iph->check = 0;
 			mac_iocb_ptr->flags1 |= OB_MAC_TSO_IOCB_IP4;
@@ -2580,7 +2581,7 @@ static int ql_tso(struct sk_buff *skb, struct ob_mac_tso_iocb_req *mac_iocb_ptr)
 								 iph->daddr, 0,
 								 IPPROTO_TCP,
 								 0);
-		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		} else if (l3_proto == htons(ETH_P_IPV6)) {
 			mac_iocb_ptr->flags1 |= OB_MAC_TSO_IOCB_IP6;
 			tcp_hdr(skb)->check =
 			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-- 
1.9.3
