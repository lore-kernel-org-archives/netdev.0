From: Ben Greear <greearb@candelatech.com>
Subject: PATCH:  Fix up VLAN memory leaks
Date: Wed, 06 Nov 2002 00:53:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC8D871.9080106@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070703050708000806070400"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   VLAN Mailing List <vlan@Scry.WANfear.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070703050708000806070400
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The first patch makes VLAN code quieter w/regard to the /var/log/messages
output.

The second fixes what I believe are two memory/resource leaks.

I ran a perl script that created and destroyed thousands of VLANs...and
my box is still standing, so I think the changes are good...  Please
look them over for sanity though, I may be mis-understanding some
of Dave's changes...

Patches are against 2.4.20-rc1

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear


--------------070703050708000806070400
Content-Type: text/plain;
 name="vlan1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan1.patch"

--- /home/greear/kernel/2.4/linux-2.4.19/net/8021q/vlan_dev.c	Tue Nov  5 21:32:42 2002
+++ vlan_dev.c	Wed Nov  6 00:18:59 2002
@@ -738,7 +738,7 @@
 
 	while (dmi) {
 		dev_mc_delete(dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-		printk(KERN_INFO "%s: del %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address from vlan interface\n",
+		printk(KERN_DEBUG "%s: del %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address from vlan interface\n",
 		       dev->name,
 		       dmi->dmi_addr[0],
 		       dmi->dmi_addr[1],
@@ -820,7 +820,7 @@
 		for (dmi = vlan_dev->mc_list; dmi != NULL; dmi = dmi->next) {
 			if (vlan_should_add_mc(dmi, VLAN_DEV_INFO(vlan_dev)->old_mc_list)) {
 				dev_mc_add(real_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-				printk(KERN_INFO "%s: add %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address to master interface\n",
+				printk(KERN_DEBUG "%s: add %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address to master interface\n",
 				       vlan_dev->name,
 				       dmi->dmi_addr[0],
 				       dmi->dmi_addr[1],
@@ -838,7 +838,7 @@
 				 * delete it from the real list on the underlying device.
 				 */
 				dev_mc_delete(real_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-				printk(KERN_INFO "%s: del %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address from master interface\n",
+				printk(KERN_DEBUG "%s: del %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address from master interface\n",
 				       vlan_dev->name,
 				       dmi->dmi_addr[0],
 				       dmi->dmi_addr[1],

--------------070703050708000806070400
Content-Type: text/plain;
 name="vlan2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan2.patch"

--- /home/greear/kernel/2.4/linux-2.4.19/net/8021q/vlan.c	Tue Nov  5 21:32:41 2002
+++ vlan.c	Wed Nov  6 00:32:50 2002
@@ -45,7 +45,7 @@
 
 static char vlan_fullname[] = "802.1Q VLAN Support";
 static unsigned int vlan_version = 1;
-static unsigned int vlan_release = 7;
+static unsigned int vlan_release = 8;
 static char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
 static char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
@@ -256,6 +256,10 @@
 				__grp_unhash(grp);
 				spin_unlock_bh(&vlan_group_lock);
 
+                                /* Free the group, after we have removed it from the hash. */
+                                kfree(grp);
+                                grp = NULL;
+                                
 				ret = 1;
 			}
 
@@ -625,7 +629,7 @@
 
 			ret = unregister_vlan_dev(dev,
 						  VLAN_DEV_INFO(vlandev)->vlan_id);
-
+                        dev_put(vlandev);
 			unregister_netdevice(vlandev);
 
 			/* Group was destroyed? */

--------------070703050708000806070400--
