From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
 - twice
Date: Mon, 09 Mar 2009 21:53:39 +0100
Message-ID: <49B581D3.6060807@krogh.cc>
References: <491FEAD5.4090205@krogh.cc> <49A7B17F.2020408@krogh.cc> <16084.1235752119@death.nxdomain.ibm.com> <49A84802.7030502@krogh.cc> <30478.1235766943@death.nxdomain.ibm.com> <49AA2973.7040209@krogh.cc> <49AA8B4F.8090405@krogh.cc> <9712.1236279072@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>, aowi@novozymes.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:34360 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414AbZCIUxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 16:53:49 -0400
In-Reply-To: <9712.1236279072@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	However, I did find another bug I introduced during the "mii
> refactor" patch that you mentioned as being the original source of the
> problem.  That bug will cause 802.3ad to not notice speed changes.
> 
> 	Could you test the patch below on your 2.6.68.7 and/or 2.6.27.19
> and see if it resolves your problem (without the forcedeth patch)?

There was something missing from the header to make it compile.. I found 
that in a later version. Patch below fixed the problem (without the 
forcedeth patch).

diff --git a/drivers/net/bonding/bond_main.c 
b/drivers/net/bonding/bond_main.c
index 1b9c4dc..fd61dfb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3516,11 +3516,27 @@ static int bond_slave_netdev_event(unsigned long 
event, struct net_device *slave
                 }
                 break;
         case NETDEV_CHANGE:
-               /*
-                * TODO: is this what we get if somebody
-                * sets up a hierarchical bond, then rmmod's
-                * one of the slave bonding devices?
-                */
+               if (bond->params.mode == BOND_MODE_8023AD ||
+                   bond_is_lb(bond)) {
+                       struct slave *slave;
+
+                       slave = bond_get_slave_by_dev(bond, slave_dev);
+                       if (slave) {
+                               u16 old_speed = slave->speed;
+                               u16 old_duplex = slave->duplex;
+
+                               bond_update_speed_duplex(slave);
+
+                               if (bond_is_lb(bond))
+                                       break;
+
+                               if (old_speed != slave->speed)
+ 
bond_3ad_adapter_speed_changed(slave);
+                               if (old_duplex != slave->duplex)
+ 
bond_3ad_adapter_duplex_changed(slave);
+                       }
+               }
+
                 break;
         case NETDEV_DOWN:
                 /*
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index fb730ec..b1315e4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -248,6 +248,14 @@ static inline struct bonding 
*bond_get_bond_by_slave(struct slave *slave)
         return (struct bonding *)slave->dev->master->priv;
  }

+static inline bool bond_is_lb(const struct bonding *bond)
+{
+        return bond->params.mode == BOND_MODE_TLB
+                || bond->params.mode == BOND_MODE_ALB;
+}
+
+
+
  #define BOND_FOM_NONE                  0
  #define BOND_FOM_ACTIVE                        1
  #define BOND_FOM_FOLLOW                        2

