From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: [PATCH] vlan code accesses released memory
Date: Sun, 4 Jul 2004 23:41:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040704214152.GB7300@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,
  today I was experimenting with vlans, and I have noticed small problem with shutting
down vlan interface with attached multicast addresses: it in its vlan_flush_mc_list() it
first issues dev_mc_delete on list entry, and then it prints that entry to log. But
dev_mc_delete can release memory which was used for multicast entry, and so in better
case bogus MAC address is printed, in worse case kernel oopses (when built with PAGE_ALLOC
debugging).

  Patch below is for 2.6.7, but 2.4.x seems to need it too.
							Best regards,
								Petr Vandrovec
								

Before:
  
eth0.22: del 01:00:5e:00:00:01 mcast address from master interface
eth0.22: del 6b:6b:6b:6b:6b:6b mcast address from vlan interface

After:

eth0.22: del 01:00:5e:00:00:01 mcast address from vlan interface
eth0.22: del 01:00:5e:00:00:01 mcast address from master interface


Signed-off-by: Petr Vandrovec <vandrove@vc.cvut.cz>

diff -urN linux/net/8021q/vlan_dev.c linux/net/8021q/vlan_dev.c
--- linux/net/8021q/vlan_dev.c	2004-07-02 21:11:49.000000000 +0200
+++ linux/net/8021q/vlan_dev.c	2004-07-04 16:42:40.000000000 +0200
@@ -727,7 +727,6 @@
 	struct dev_mc_list *dmi = dev->mc_list;
 
 	while (dmi) {
-		dev_mc_delete(dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		printk(KERN_DEBUG "%s: del %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address from vlan interface\n",
 		       dev->name,
 		       dmi->dmi_addr[0],
@@ -736,6 +735,7 @@
 		       dmi->dmi_addr[3],
 		       dmi->dmi_addr[4],
 		       dmi->dmi_addr[5]);
+		dev_mc_delete(dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		dmi = dev->mc_list;
 	}
 
