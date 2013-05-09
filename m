From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] macvlan: fix passthru mode race between dev removal and rx path
Date: Thu,  9 May 2013 16:23:40 +0200
Message-ID: <1368109420-14199-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sri@us.ibm.com, kaber@trash.net,
	linux-kernel@vger.kernel.org, mtesar@redhat.com,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:46040 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755201Ab3EIOXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 10:23:46 -0400
Received: by mail-wg0-f43.google.com with SMTP id c11so3015236wgh.34
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 07:23:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if macvlan in passthru mode is created and data are rxed and
you remove this device, following panic happens:

NULL pointer dereference at 0000000000000198
IP: [<ffffffffa0196058>] macvlan_handle_frame+0x153/0x1f7 [macvlan]

I'm using following script to trigger this:
<script>
while [ 1 ]
do
	ip link add link e1 name macvtap0 type macvtap mode passthru
	ip link set e1 up
	ip link set macvtap0 up
	IFINDEX=`ip link |grep macvtap0 | cut -f 1 -d ':'`
	cat /dev/tap$IFINDEX  >/dev/null &
	ip link del dev macvtap0
done
</script>

I run this script while "ping -f" is running on another machine to send
packets to e1 rx.

Reason of the panic is that list_first_entry() is blindly called in
macvlan_handle_frame() even if the list was empty. vlan is set to
incorrect pointer which leads to the crash.

I'm fixing this by protecting port->vlans list by rcu and by preventing
from getting incorrect pointer in case the list is empty.

Introduced by: commit eb06acdc85585f2 "macvlan: Introduce 'passthru' mode to takeover the underlying device"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/macvlan.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d5a141c..1c502bb 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -229,7 +229,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	}
 
 	if (port->passthru)
-		vlan = list_first_entry(&port->vlans, struct macvlan_dev, list);
+		vlan = list_first_or_null_rcu(&port->vlans,
+					      struct macvlan_dev, list);
 	else
 		vlan = macvlan_hash_lookup(port, eth->h_dest);
 	if (vlan == NULL)
@@ -814,7 +815,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (err < 0)
 		goto upper_dev_unlink;
 
-	list_add_tail(&vlan->list, &port->vlans);
+	list_add_tail_rcu(&vlan->list, &port->vlans);
 	netif_stacked_transfer_operstate(lowerdev, dev);
 
 	return 0;
@@ -842,7 +843,7 @@ void macvlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
-	list_del(&vlan->list);
+	list_del_rcu(&vlan->list);
 	unregister_netdevice_queue(dev, head);
 	netdev_upper_dev_unlink(vlan->lowerdev, dev);
 }
-- 
1.7.11.7
