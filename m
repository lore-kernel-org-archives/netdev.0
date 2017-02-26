From: Felix Jia <felix.jia@alliedtelesis.co.nz>
Subject: [PATCH net/ipv6] net/ipv6: avoid possible dead locking on addr_gen_mode sysctl
Date: Mon, 27 Feb 2017 12:41:23 +1300
Message-ID: <20170226234123.18713-1-felix.jia@alliedtelesis.co.nz>
Cc: Felix Jia <felix.jia@alliedtelesis.co.nz>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:53135 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdBZXw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 18:52:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addr_gen_mode variable can be accessed by both sysctl and netlink.
Repleacd rtnl_lock() with rtnl_trylock() protect the sysctl operation to
avoid the possbile dead lock.`

Signed-off-by: Felix Jia <felix.jia@alliedtelesis.co.nz>
---
 net/ipv6/addrconf.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3a2025f5bf2c..cfc485a8e1c0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5692,13 +5692,18 @@ static int addrconf_sysctl_addr_gen_mode(struct ctl_table *ctl, int write,
 	struct inet6_dev *idev = (struct inet6_dev *)ctl->extra1;
 	struct net *net = (struct net *)ctl->extra2;
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write) {
 		new_val = *((int *)ctl->data);
 
-		if (check_addr_gen_mode(new_val) < 0)
-			return -EINVAL;
+		if (check_addr_gen_mode(new_val) < 0) {
+			ret = -EINVAL;
+			goto out;
+		}
 
 		/* request for default */
 		if (&net->ipv6.devconf_dflt->addr_gen_mode == ctl->data) {
@@ -5707,20 +5712,23 @@ static int addrconf_sysctl_addr_gen_mode(struct ctl_table *ctl, int write,
 		/* request for individual net device */
 		} else {
 			if (!idev)
-				return ret;
+				goto out;
 
-			if (check_stable_privacy(idev, net, new_val) < 0)
-				return -EINVAL;
+			if (check_stable_privacy(idev, net, new_val) < 0) {
+				ret = -EINVAL;
+				goto out;
+			}
 
 			if (idev->cnf.addr_gen_mode != new_val) {
 				idev->cnf.addr_gen_mode = new_val;
-				rtnl_lock();
 				addrconf_dev_config(idev->dev);
-				rtnl_unlock();
 			}
 		}
 	}
 
+out:
+	rtnl_unlock();
+
 	return ret;
 }
 
-- 
2.11.0
