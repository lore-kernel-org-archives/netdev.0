From: Francesco Ruggeri <fruggeri@arista.com>
Subject: [PATCH net-next] macvtap: check minor when unregistering
Date: Sat, 23 Apr 2016 15:04:31 -0700
Message-ID: <1461449071-7499-1-git-send-email-fruggeri@arista.com>
Cc: Francesco Ruggeri <fruggeri@arista.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:3626 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752309AbcDWWEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 18:04:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvtap_device_event(NETDEV_UNREGISTER) should check vlan->minor to
determine if it is being invoked in the context of a macvtap_newlink
that failed, for example in this code sequence:

macvtap_newlink
  macvlan_common_newlink
    register_netdevice
      call_netdevice_notifiers(NETDEV_REGISTER, dev)
        macvtap_device_event(NETDEV_REGISTER)
          <fail here, vlan->minor = 0>
      rollback_registered(dev);
        rollback_registered_many
          call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
            macvtap_device_event(NETDEV_UNREGISTER)
              <nothing to clean up here>

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 drivers/net/macvtap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 95394ed..74cb15a 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1303,6 +1303,9 @@ static int macvtap_device_event(struct notifier_block *unused,
 		}
 		break;
 	case NETDEV_UNREGISTER:
+		/* vlan->minor == 0 if NETDEV_REGISTER above failed */
+		if (vlan->minor == 0)
+			break;
 		devt = MKDEV(MAJOR(macvtap_major), vlan->minor);
 		device_destroy(macvtap_class, devt);
 		macvtap_free_minor(vlan);
-- 
1.8.1.4
