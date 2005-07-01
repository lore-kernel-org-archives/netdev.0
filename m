From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 4/17] bonding: return pointer to slave from enslave
Date: Fri, 1 Jul 2005 13:41:08 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011339370.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch changes the bond_enslave function so that it (optionally)
returns a pointer tothe slave struct for a new slave. This
functionality is not used by the existing ioctl interface, but will be
used by the sysfs interface.

This function is also made non-static and a proto is placed in the header.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bonding.h linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h
--- linux-2.6.12post/drivers/net/bonding/bonding.h	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h	2005-06-30 13:58:27.000000000 -0700
@@ -262,6 +262,7 @@
  int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
  int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
  void bond_deinit(struct net_device *bond_dev);
+int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev, struct slave **vassal);
  int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
  int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
  void bond_mii_monitor(struct net_device *bond_dev);
diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -1601,7 +1601,7 @@
  }

  /* enslave device <slave> to bond device <master> */
-static int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
+int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev, struct slave **vassal)
  {
  	struct bonding *bond = bond_dev->priv;
  	struct slave *new_slave = NULL;
@@ -1992,6 +1992,8 @@
  	       new_slave->link != BOND_LINK_DOWN ? "n up" : " down");

  	/* enslave is successful */
+	if (vassal)
+		*vassal=new_slave;
  	return 0;

  /* Undo stages on error */
@@ -4049,6 +4051,7 @@
  		return -EINVAL;
  	}

+	down_write(&(bonding_rwsem));
  	slave_dev = dev_get_by_name(ifr->ifr_slave);

  	dprintk("slave_dev=%p: \n", slave_dev);
@@ -4060,7 +4063,7 @@
  		switch (cmd) {
  		case BOND_ENSLAVE_OLD:
  		case SIOCBONDENSLAVE:
-			res = bond_enslave(bond_dev, slave_dev);
+			res = bond_enslave(bond_dev, slave_dev, NULL);
  			break;
  		case BOND_RELEASE_OLD:
  		case SIOCBONDRELEASE:
