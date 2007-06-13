From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Fix race condition about network device name allocation
Date: Wed, 13 Jun 2007 15:53:35 -0700
Message-ID: <20070613155335.47111c67@localhost>
References: <1178862045.3979.33.camel@kane-linux>
	<20070511092519.1f34ab34@freepuppy>
	<1179130660.3881.23.camel@kane-linux>
	<20070514085840.17a343f7@freepuppy>
	<20070613094521.GA8860@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net
To: Dan Aloni <da-x@monatomic.org>,
	Chad Tindel <ctindel@users.sourceforge.net>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36060 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753502AbXFMWye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 18:54:34 -0400
In-Reply-To: <20070613094521.GA8860@localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bonding refers to device after unregistering. This has always been
a dangerous thing. The following UNTESTED should fix the problem.

--- a/drivers/net/bonding/bond_sysfs.c	2007-06-13 15:48:37.000000000 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2007-06-13 15:49:17.000000000 -0700
@@ -164,9 +164,10 @@ static ssize_t bonding_store_bonds(struc
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
-				unregister_netdevice(bond->dev);
+
 				bond_deinit(bond->dev);
 		        	bond_destroy_sysfs_entry(bond);
+				unregister_netdevice(bond->dev);
 				rtnl_unlock();
 				goto out;
 			}
