From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (2/9) bridge - rmmod race
Date: Tue, 13 Apr 2004 15:18:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413151847.50c62126@dell_ss3.pdx.osdl.net>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix observed race between removing bridge module and ip packets
in flight.  Need to remove the hook last, after all bridges are gone
not the other way around.

diff -Nru a/net/bridge/br.c b/net/bridge/br.c
--- a/net/bridge/br.c	Mon Apr 12 16:09:56 2004
+++ b/net/bridge/br.c	Mon Apr 12 16:09:56 2004
@@ -54,16 +54,17 @@
 #endif
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
-	br_handle_frame_hook = NULL;
+
+	br_cleanup_bridges();
+
+	synchronize_net();
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	br_fdb_get_hook = NULL;
 	br_fdb_put_hook = NULL;
 #endif
 
-	br_cleanup_bridges();
-
-	synchronize_net();
+	br_handle_frame_hook = NULL;
 }
 
 EXPORT_SYMBOL(br_should_route_hook);
