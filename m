From: Jeff Garzik <jgarzik@pobox.com>
Subject: [bk patches] 2.4.x net drvr bug fixes
Date: Thu, 31 Jul 2003 15:16:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030731191646.GA30639@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: marcelo@conectiva.com.br
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Marcelo, please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.4

Others may download the patch (included below) from

ftp://ftp.??.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.4/2.4.22-pre10-netdrvr1.patch.bz2

This will update the following files:

 Documentation/networking/ifenslave.c |    3 +--
 drivers/net/bonding/bond_main.c      |   15 +++++++++------
 2 files changed, 10 insertions(+), 8 deletions(-)

through these ChangeSets:

<fubar@us.ibm.com> (03/07/31 1.1051)
   [netdrvr bonding] fix ifenslave ia64 build

<willy@w.ods.org> (03/07/31 1.1050)
   [netdrvr bonding] fix kernel panic when optional feature used
   
     - now the last one fixes a kernel panic due to a cheap hack which was introduced
       to determine the source IP address to use with ARP checks. It takes the first
       address of the first slave, and puts a lock on it. If there's no address, its
       ip_ptr is NULL, and the kernel panics while trying to get the lock. You can
       reproduce it easily this way :
   
       # modprobe eth0
       # modprobe bonding mode=active-backup miimon=1000
       # ip link set bond0 up
       # ifenslave bond0 eth0
       => kernel panic !
   

<willy@w.ods.org> (03/07/31 1.1049)
   [netdrvr bonding] fix a typo in the MODULE_PARM_DESC






diff -Nru a/Documentation/networking/ifenslave.c b/Documentation/networking/ifenslave.c
--- a/Documentation/networking/ifenslave.c	Thu Jul 31 15:13:34 2003
+++ b/Documentation/networking/ifenslave.c	Thu Jul 31 15:13:34 2003
@@ -140,8 +140,7 @@
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/ioctl.h>
-#include <linux/if.h>
-#include <linux/if_arp.h>
+#include <net/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/if_bonding.h>
 #include <linux/sockios.h>
diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Jul 31 15:13:34 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Jul 31 15:13:34 2003
@@ -524,7 +524,7 @@
 MODULE_PARM(miimon, "i");
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 MODULE_PARM(use_carrier, "i");
-MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; 09 for off, 1 for on (default)");
+MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; 0 for off, 1 for on (default)");
 MODULE_PARM(mode, "s");
 MODULE_PARM_DESC(mode, "Mode of operation : 0 for round robin, 1 for active-backup, 2 for xor");
 MODULE_PARM(arp_interval, "i");
@@ -1594,11 +1594,14 @@
 #endif
 			bond_set_slave_inactive_flags(new_slave);
 		}
-		read_lock_irqsave(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
-		ifap= &(((struct in_device *)slave_dev->ip_ptr)->ifa_list);
-		ifa = *ifap;
-		my_ip = ifa->ifa_address;
-		read_unlock_irqrestore(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
+		if (((struct in_device *)slave_dev->ip_ptr) != NULL) {
+			read_lock_irqsave(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
+			ifap= &(((struct in_device *)slave_dev->ip_ptr)->ifa_list);
+			ifa = *ifap;
+			if (ifa != NULL)
+				my_ip = ifa->ifa_address;
+			read_unlock_irqrestore(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
+		}
 
 		/* if there is a primary slave, remember it */
 		if (primary != NULL) {
