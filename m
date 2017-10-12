From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] ipvlan: always use the current L2 addr of the master
Date: Wed, 11 Oct 2017 17:16:26 -0700
Message-ID: <20171012001626.3255-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:50187 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752626AbdJLAQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 20:16:34 -0400
Received: by mail-pf0-f196.google.com with SMTP id m63so2556664pfk.7
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 17:16:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

If the underlying master ever changes its L2 (e.g. bonding device),
then make sure that the IPvlan slaves always emit packets with the
current L2 of the master instead of the stale mac addr which was
copied during the device creation. The problem can be seen with
following script -

  #!/bin/bash
  # Create a vEth pair
  ip link add dev veth0 type veth peer name veth1
  ip link set veth0 up
  ip link set veth1 up
  ip link show veth0
  ip link show veth1
  # Create an IPvlan device on one end of this vEth pair.
  ip link add link veth0 dev ipvl0 type ipvlan mode l2
  ip link show ipvl0
  # Change the mac-address of the vEth master.
  ip link set veth0 address 02:11:22:33:44:55

Fixes: 2ad7bf363841 ("ipvlan: Initial check-in of the IPVLAN driver.")
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index c74893c1e620..5832091680f4 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -407,7 +407,7 @@ static int ipvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 	 * while the packets use the mac-addr on the physical device.
 	 */
 	return dev_hard_header(skb, phy_dev, type, daddr,
-			       saddr ? : dev->dev_addr, len);
+			       saddr ? : phy_dev->dev_addr, len);
 }
 
 static const struct header_ops ipvlan_header_ops = {
@@ -730,6 +730,11 @@ static int ipvlan_device_event(struct notifier_block *unused,
 			ipvlan_adjust_mtu(ipvlan, dev);
 		break;
 
+	case NETDEV_CHANGEADDR:
+		list_for_each_entry(ipvlan, &port->ipvlans, pnode)
+			ether_addr_copy(ipvlan->dev->dev_addr, dev->dev_addr);
+		break;
+
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlying device to change its type. */
 		return NOTIFY_BAD;
-- 
2.15.0.rc0.271.g36b669edcc-goog
