From: Francesco Ruggeri <fruggeri@arista.com>
Subject: [PATCH net-next] macvlan: fix failure during registration
Date: Mon, 18 Apr 2016 08:20:11 -0700
Message-ID: <1460992811-46992-1-git-send-email-fruggeri@arista.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Francesco Ruggeri <fruggeri@arista.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:59376 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751799AbcDRPUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 11:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending, did not include netdev the first time ...

If a macvlan/macvtap creation fails in register_netdevice in
call_netdevice_notifiers(NETDEV_REGISTER) then while cleaning things up in
rollback_registered_many it invokes macvlan_uninit. This results in
port->count being decremented twice (in macvlan_uninit and in
macvlan_common_newlink).
A similar problem may exist in the ipvlan driver.
This patch adds priv_flags to struct macvlan_dev and a flag that
macvlan_uninit can use to determine if it is invoked in the context of a
failed newlink.
In macvtap_device_event(NETDEV_UNREGISTER) it also avoids cleaning up
/dev/tapNN in case creation of the char device had previously failed.
Tested in 3.18.
The failure can be reproduced by running the script below a few times. The
script creates macvtap interfaces in different namespaces causing along the
way sysfs_warn_dup failures in macvtap_device_event(NETDEV_REGISTER)
because of conflicting ifindexes, and finally a panic or
"unregister_netdevice: waiting for ddev to become free".

for ((ns=1; ns<3; ns++))
do
  ip netns add ns${ns}
  ip netns exec ns${ns} ip link add dev ddev type dummy
done

for ((ns=1; ns<3; ns++))
do
  for ((mv=0; mv<2; mv++))
  do
    ret=1
    while [ ${ret} != 0 ]
    do
      ip netns exec ns${ns} ip link add link ddev name \
                        macvtap${ns}${mv} type macvtap
      ret=$?
    done &
  done
done

sleep 5
ls /dev/tap*

for ((ns=1; ns<3; ns++))
do
  ip netns exec ns${ns} ip link del ddev &
done

sleep 2
ls /dev/tap*

for ((ns=1; ns<3; ns++))
do
  ip netns del ns${ns}
done

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 drivers/net/macvlan.c      | 11 ++++++++---
 drivers/net/macvtap.c      |  2 ++
 include/linux/if_macvlan.h |  3 +++
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2bcf1f3..11065af 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -823,9 +823,12 @@ static void macvlan_uninit(struct net_device *dev)
 	free_percpu(vlan->pcpu_stats);
 
 	macvlan_flush_sources(port, vlan);
-	port->count -= 1;
-	if (!port->count)
-		macvlan_port_destroy(port->dev);
+
+	if (!(vlan->priv_flags & MACVLAN_PRIV_FLAG_REGISTERING)) {
+		port->count -= 1;
+		if (!port->count)
+			macvlan_port_destroy(port->dev);
+	}
 }
 
 static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
@@ -1313,7 +1316,9 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	}
 
 	port->count += 1;
+	vlan->priv_flags |= MACVLAN_PRIV_FLAG_REGISTERING;
 	err = register_netdevice(dev);
+	vlan->priv_flags &= ~MACVLAN_PRIV_FLAG_REGISTERING;
 	if (err < 0)
 		goto destroy_port;
 
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 95394ed..e770221 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1303,6 +1303,8 @@ static int macvtap_device_event(struct notifier_block *unused,
 		}
 		break;
 	case NETDEV_UNREGISTER:
+		if (vlan->minor == 0)
+			break;
 		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
 		device_destroy(macvtap_class, devt);
 		macvtap_free_minor(vlan);
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index a4ccc31..7cf82d8 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -48,6 +48,7 @@ struct macvlan_dev {
 	netdev_features_t	set_features;
 	enum macvlan_mode	mode;
 	u16			flags;
+	u16			priv_flags;
 	/* This array tracks active taps. */
 	struct macvtap_queue	__rcu *taps[MAX_MACVTAP_QUEUES];
 	/* This list tracks all taps (both enabled and disabled) */
@@ -63,6 +64,8 @@ struct macvlan_dev {
 	unsigned int		macaddr_count;
 };
 
+#define MACVLAN_PRIV_FLAG_REGISTERING	1
+
 static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 				    unsigned int len, bool success,
 				    bool multicast)
-- 
1.8.1.4
