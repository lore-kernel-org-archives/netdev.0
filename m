From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 7/17] bonding: make sysfs consistent with ifenslave
 behavior
Date: Fri, 1 Jul 2005 13:47:04 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011345580.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For consistency with ifenslave, instead of exiting with an error, updated 
bonding sysfs to close and attempt to enslave an up adapter.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -1665,10 +1665,19 @@
  		 */
  		if ((slave_dev->flags & IFF_UP)) {
  			printk(KERN_ERR DRV_NAME
-			       ": Error: %s is up\n",
-			       slave_dev->name);
+			       ": %s: Warning: %s is up. Closing it "
+			       "before adding to the bond.\n",
+			       bond_dev->name, slave_dev->name);
  			res = -EPERM;
-			goto err_undo_flags;
+			res = dev_close(slave_dev);
+			if (res)
+			{
+				printk(KERN_ERR DRV_NAME
+				    ": %s: Error: Failed to close %s.\n",
+				    bond_dev->name, slave_dev->name);
+				res = -EPERM;
+				goto err_undo_flags;
+			}
  		}

  		if (slave_dev->set_mac_address == NULL) {
