From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: Bonding on bond
Date: Thu, 20 Jan 2011 16:31:10 +0100
Message-ID: <20110120153110.GA3931@midget.suse.cz>
References: <4D374A8F.2020303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Bohac <jbohac@suse.cz>, Jay Vosburgh <fubar@us.ibm.com>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50771 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755916Ab1ATPbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 10:31:14 -0500
Content-Disposition: inline
In-Reply-To: <4D374A8F.2020303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 19, 2011 at 09:33:19PM +0100, Nicolas de Peslo=FCan wrote:
> Even if it is possible to test for slave and for master with a
> single condition (IFF_BONDING), I suggest to split the tests and the
> error messages, to give end user the best possible diagnostic.

OK, why not. The below patch still uses IFF_BONDING to detect a
master is being enslaved, because IFF_MASTER is also used by the
eql driver. No idea if it works / someone ever uses it with
bonding, but it might collide.

bonding: prohibit enslaving of bonding masters

Nested bonding is not supported and will result in strange problems, e.=
g.:
- netif_receive_skb() will not properly change skb->dev to point to the
  uppoer-most bonding master
- arp monitor will not work (dev->last_rx is only updated by hardware d=
rivers)
- accidentally enslaving a bonding master to itself will cause an infin=
ite
  recursion in the TX path

This patch prevents this by prohibiting a bonding master from being fur=
ther enslaved.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index b1025b8..b117dd8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1453,6 +1453,12 @@ int bond_enslave(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
 		return -EBUSY;
 	}
=20
+	/* cannot enslave a master */
+	if (slave_dev->priv_flags & IFF_BONDING) {
+		pr_debug("Error, cannot enslave a bonding master\n");
+		return -EBUSY;
+	}
+
 	/* vlan challenged mutual exclusion */
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {

--=20
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

