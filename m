From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge deadlock on device removal
Date: Mon, 6 Sep 2004 05:15:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040906051523.16e6a431@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes: https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=131569
Dead lock in bridge when removing device interface module. br_del_if
assumes br->lock not held.

This fixes case of:
	brctl addbr b0
	brctl addif b0 eth0
	rmmod eth0

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/bridge/br_notify.c b/net/bridge/br_notify.c
--- a/net/bridge/br_notify.c	2004-09-06 04:45:31 -07:00
+++ b/net/bridge/br_notify.c	2004-09-06 04:45:31 -07:00
@@ -76,10 +76,12 @@
 		break;
 
 	case NETDEV_UNREGISTER:
+		spin_unlock_bh(&br->lock);
 		br_del_if(br, dev);
-		break;
+		goto done;
 	} 
 	spin_unlock_bh(&br->lock);
 
+ done:
 	return NOTIFY_DONE;
 }
