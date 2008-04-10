From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/14][VLAN]: Migrate proc files when vlan device is moved
	to namespace.
Date: Thu, 10 Apr 2008 19:23:59 +0400
Message-ID: <47FE310F.7020805@openvz.org>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
        Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
To: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47FE2AD4.9080609-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

The preparations to this are done with my patch, that fixed 
proc on vlan device rename. 

This makes /proc/net/vlan/<device> file migrate from one
proc tree to another...

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 net/8021q/vlan.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 7e9d22e..2a739ad 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -154,8 +154,6 @@ void unregister_vlan_dev(struct net_device *dev)
 	grp = __vlan_find_group(real_dev);
 	BUG_ON(!grp);
 
-	vlan_proc_rem_dev(dev);
-
 	/* Take it out of our own structures, but be sure to interlock with
 	 * HW accelerating devices or SW vlan input packet processing.
 	 */
@@ -278,9 +276,6 @@ int register_vlan_dev(struct net_device *dev)
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		real_dev->vlan_rx_add_vid(real_dev, vlan_id);
 
-	if (vlan_proc_add_dev(dev) < 0)
-		pr_warning("8021q: failed to add proc entry for %s\n",
-			   dev->name);
 	return 0;
 
 out_free_group:
@@ -396,6 +391,14 @@ static void __vlan_device_event(struct net_device *dev, unsigned long event)
 			pr_warning("8021q: failed to change proc name for %s\n",
 					dev->name);
 		break;
+	case NETDEV_REGISTER:
+		if (vlan_proc_add_dev(dev) < 0)
+			pr_warning("8021q: failed to add proc entry for %s\n",
+					dev->name);
+		break;
+	case NETDEV_UNREGISTER:
+		vlan_proc_rem_dev(dev);
+		break;
 	}
 }
 
-- 
1.5.3.4
