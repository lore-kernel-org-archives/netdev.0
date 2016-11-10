From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] r8152: Fix error path in open function
Date: Wed,  9 Nov 2016 19:51:25 -0800
Message-ID: <1478749885-32212-1-git-send-email-linux@roeck-us.net>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If usb_submit_urb() called from the open function fails, the following
crash may be observed.

r8152 8-1:1.0 eth0: intr_urb submit failed: -19
...
r8152 8-1:1.0 eth0: v1.08.3
Unable to handle kernel paging request at virtual address 6b6b6b6b6b6b6b7b
pgd = ffffffc0e7305000
[6b6b6b6b6b6b6b7b] *pgd=0000000000000000, *pud=0000000000000000
Internal error: Oops: 96000004 [#1] PREEMPT SMP
...
PC is at notifier_chain_register+0x2c/0x58
LR is at blocking_notifier_chain_register+0x54/0x70
...
Call trace:
[<ffffffc0002407f8>] notifier_chain_register+0x2c/0x58
[<ffffffc000240bdc>] blocking_notifier_chain_register+0x54/0x70
[<ffffffc00026991c>] register_pm_notifier+0x24/0x2c
[<ffffffbffc183200>] rtl8152_open+0x3dc/0x3f8 [r8152]
[<ffffffc000808000>] __dev_open+0xac/0x104
[<ffffffc0008082f8>] __dev_change_flags+0xb0/0x148
[<ffffffc0008083c4>] dev_change_flags+0x34/0x70
[<ffffffc000818344>] do_setlink+0x2c8/0x888
[<ffffffc0008199d4>] rtnl_newlink+0x328/0x644
[<ffffffc000819e98>] rtnetlink_rcv_msg+0x1a8/0x1d4
[<ffffffc0008373c8>] netlink_rcv_skb+0x68/0xd0
[<ffffffc000817990>] rtnetlink_rcv+0x2c/0x3c
[<ffffffc000836d1c>] netlink_unicast+0x16c/0x234
[<ffffffc00083720c>] netlink_sendmsg+0x340/0x364
[<ffffffc0007e85d0>] sock_sendmsg+0x48/0x60
[<ffffffc0007e9c30>] SyS_sendto+0xe0/0x120
[<ffffffc0007e9cb0>] SyS_send+0x40/0x4c
[<ffffffc000203e34>] el0_svc_naked+0x24/0x28

Clean up error handling to avoid registering the notifier if the open
function is going to fail.

Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 44d439f50961..677922039548 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3266,10 +3266,8 @@ static int rtl8152_open(struct net_device *netdev)
 		goto out;
 
 	res = usb_autopm_get_interface(tp->intf);
-	if (res < 0) {
-		free_all_mem(tp);
-		goto out;
-	}
+	if (res < 0)
+		goto out_free;
 
 	mutex_lock(&tp->control);
 
@@ -3285,10 +3283,9 @@ static int rtl8152_open(struct net_device *netdev)
 			netif_device_detach(tp->netdev);
 		netif_warn(tp, ifup, netdev, "intr_urb submit failed: %d\n",
 			   res);
-		free_all_mem(tp);
-	} else {
-		napi_enable(&tp->napi);
+		goto out_unlock;
 	}
+	napi_enable(&tp->napi);
 
 	mutex_unlock(&tp->control);
 
@@ -3297,7 +3294,13 @@ static int rtl8152_open(struct net_device *netdev)
 	tp->pm_notifier.notifier_call = rtl_notifier;
 	register_pm_notifier(&tp->pm_notifier);
 #endif
+	return 0;
 
+out_unlock:
+	mutex_unlock(&tp->control);
+	usb_autopm_put_interface(tp->intf);
+out_free:
+	free_all_mem(tp);
 out:
 	return res;
 }
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
