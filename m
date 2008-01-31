From: Chuck Ebbert <cebbert@redhat.com>
Subject: Null pointer dereference in bonding driver, kernel 2.6.24
Date: Thu, 31 Jan 2008 17:36:21 -0500
Message-ID: <47A24D65.2000001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762677AbYAaWpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 17:45:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bond_main.c:

int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
{
...
        /* Check to see if the bond already exists. */
        list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
                if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
                        printk(KERN_ERR DRV_NAME
                               ": cannot add bond %s; it already exists\n",


If 'name' is null we get a null dereference in strnicmp()

The code was added in 2.6.24.

Signed-off-by: Chuck Ebbert <cebbert@redhat.com>

---
(not even compile tested)

 drivers/net/bonding/bond_main.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

--- linux-2.6.24.noarch.orig/drivers/net/bonding/bond_main.c
+++ linux-2.6.24.noarch/drivers/net/bonding/bond_main.c
@@ -4882,15 +4882,17 @@ int bond_create(char *name, struct bond_
 	rtnl_lock();
 	down_write(&bonding_rwsem);
 
-	/* Check to see if the bond already exists. */
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
-		if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
-			printk(KERN_ERR DRV_NAME
-			       ": cannot add bond %s; it already exists\n",
-			       name);
-			res = -EPERM;
-			goto out_rtnl;
-		}
+	if (name) {
+		/* Check to see if the bond already exists. */
+		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
+				printk(KERN_ERR DRV_NAME
+				       ": cannot add bond %s; it already exists\n",
+				       name);
+				res = -EPERM;
+				goto out_rtnl;
+			}
+	}
 
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				ether_setup);
