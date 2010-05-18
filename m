From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] bonding: move slave MTU handling from sysfs
Date: Tue, 18 May 2010 14:21:51 +0200
Message-ID: <20100518122150.GB2878@psychotron.lab.eng.brq.redhat.com>
References: <20100517144731.GE2878@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, monis@voltaire.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756990Ab0ERMWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 08:22:05 -0400
Content-Disposition: inline
In-Reply-To: <20100517144731.GE2878@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually, please scratch this, the patch is not correct (res/ret). Will post the
correct one soon.

Jirka

Mon, May 17, 2010 at 04:47:31PM CEST, jpirko@redhat.com wrote:
>For some reason, MTU handling (storing, and restoring) is taking  place in
>bond_sysfs. The correct place for this code is in bond_enslave, bond_release.
>So move it there.
>
>Jirka
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 5e12462..2c3f9db 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1533,6 +1533,14 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 	 */
> 	new_slave->original_flags = slave_dev->flags;
> 
>+	/* Save slave's original mtu and then set it to match the bond */
>+	new_slave->original_mtu = slave_dev->mtu;
>+	res = dev_set_mtu(slave_dev, bond->dev->mtu);
>+	if (res) {
>+		pr_debug("Error %d calling dev_set_mtu\n", res);
>+		goto err_free;
>+	}
>+
> 	/*
> 	 * Save slave's original ("permanent") mac address for modes
> 	 * that need it, and for restoring it upon release, and then
>@@ -1550,7 +1558,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 		res = dev_set_mac_address(slave_dev, &addr);
> 		if (res) {
> 			pr_debug("Error %d calling set_mac_address\n", res);
>-			goto err_free;
>+			goto err_restore_mtu;
> 		}
> 	}
> 
>@@ -1785,6 +1793,9 @@ err_restore_mac:
> 		dev_set_mac_address(slave_dev, &addr);
> 	}
> 
>+err_restore_mtu:
>+	dev_set_mtu(slave_dev, new_slave->original_mtu);
>+
> err_free:
> 	kfree(new_slave);
> 
>@@ -1969,6 +1980,8 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 		dev_set_mac_address(slave_dev, &addr);
> 	}
> 
>+	dev_set_mtu(slave_dev, slave->original_mtu);
>+
> 	slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
> 				   IFF_SLAVE_INACTIVE | IFF_BONDING |
> 				   IFF_SLAVE_NEEDARP);
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 392e291..4e84cfc 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -220,7 +220,6 @@ static ssize_t bonding_store_slaves(struct device *d,
> 	char command[IFNAMSIZ + 1] = { 0, };
> 	char *ifname;
> 	int i, res, ret = count;
>-	u32 original_mtu;
> 	struct slave *slave;
> 	struct net_device *dev = NULL;
> 	struct bonding *bond = to_bond(d);
>@@ -281,43 +280,22 @@ static ssize_t bonding_store_slaves(struct device *d,
> 			memcpy(bond->dev->dev_addr, dev->dev_addr,
> 			       dev->addr_len);
> 
>-		/* Set the slave's MTU to match the bond */
>-		original_mtu = dev->mtu;
>-		res = dev_set_mtu(dev, bond->dev->mtu);
>-		if (res) {
>-			ret = res;
>-			goto out;
>-		}
>-
> 		res = bond_enslave(bond->dev, dev);
>-		bond_for_each_slave(bond, slave, i)
>-			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
>-				slave->original_mtu = original_mtu;
>-		if (res)
>-			ret = res;
> 
> 		goto out;
> 	}
> 
> 	if (command[0] == '-') {
> 		dev = NULL;
>-		original_mtu = 0;
> 		bond_for_each_slave(bond, slave, i)
> 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
> 				dev = slave->dev;
>-				original_mtu = slave->original_mtu;
> 				break;
> 			}
> 		if (dev) {
> 			pr_info("%s: Removing slave %s\n",
> 				bond->dev->name, dev->name);
>-				res = bond_release(bond->dev, dev);
>-			if (res) {
>-				ret = res;
>-				goto out;
>-			}
>-			/* set the slave MTU to the default */
>-			dev_set_mtu(dev, original_mtu);
>+			res = bond_release(bond->dev, dev);
> 		} else {
> 			pr_err("unable to remove non-existent slave %s for bond %s.\n",
> 			       ifname, bond->dev->name);
