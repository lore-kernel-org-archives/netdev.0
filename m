From: Ryan Harper <ryanh@us.ibm.com>
Subject: Possible race with br_del_if()
Date: Thu, 18 Aug 2005 16:40:36 -0500
Message-ID: <20050818214036.GH10593@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I've encountered several oops when adding and removing interfaces from
bridges while using Xen.  Most of the details are available [1]here.
The short of it is the following sequence:

CPU0                    CPU1
add_del_if()            unregister_netdevice()  
br_del_if()             notifier_call_chain(NETDEV_UNREGISTER) 
del_nbp()               
br_stp_disable_port()   // port->state == BR_STATE_DISABLED
                        br_device_event() // dev->br_port != NULL yet
                                          // event is NETDEV_UNREGISTER
                        br_del_if()
                        sysfs_remove_dir(p)
                        kobject_del()
                        dget(dentry)
                        BUG_ON(!atomic_read(&dentry->d_count)

This sequence doesn't happen all of the time.  In many cases, CPU0 moves
along right into destroy_nbp() which sets dev->br_port = NULL, and
be_device_event check (p == NULL) hits and a second br_del_if() isn't
called.

The attached patch is a workaround for the double case, but I'm not sure
if is the right way to deal with this issue, or if it any issue at all.

1. http://bugzilla.xensource.com/bugzilla/show_bug.cgi?id=90

-- 
Ryan Harper
Software Engineer; Linux Technology Center
IBM Corp., Austin, Tx
(512) 838-9253   T/L: 678-9253
ryanh@us.ibm.com


diffstat output:
 br_if.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Signed-off-by: Ryan Harper <ryanh@us.ibm.com>
---
Simple workaround for double call to br_del_if().

Signed-off-by: Ryan Harper <ryanh@us.ibm.com>

--- linux-2.6.12/net/bridge/br_if.c	2005-06-17 14:48:29.000000000 -0500
+++ linux-2.6.12-xen0-smp/net/bridge/br_if.c	2005-08-18 15:17:27.302615846 -0500
@@ -382,7 +382,7 @@
 {
 	struct net_bridge_port *p = dev->br_port;
 	
-	if (!p || p->br != br) 
+	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
 		return -EINVAL;
 
 	br_sysfs_removeif(p);
