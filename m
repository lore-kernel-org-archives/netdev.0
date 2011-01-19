From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [Bonding-devel] Bonding on bond
Date: Wed, 19 Jan 2011 16:49:51 +0100
Message-ID: <20110119154951.GB8442@midget.suse.cz>
References: <AANLkTim95tsTiOcpPqet2BScZ0pzi5_EBy-PQ_52TjN_@mail.gmail.com>
 <4D354A38.5000802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40750 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973Ab1ASPtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 10:49:52 -0500
Content-Disposition: inline
In-Reply-To: <4D354A38.5000802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 09:07:20AM +0100, Nicolas de Peslo=FCan wrote:
> Staking bond is not supported. Currently, no setup is know to
> require stacking bond.

I agree. This question and weird bugreports from people trying
this come up over and over. How about this patch?


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
index b1025b8..d4d5f42 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1448,8 +1448,8 @@ int bond_enslave(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	}
=20
 	/* already enslaved */
-	if (slave_dev->flags & IFF_SLAVE) {
-		pr_debug("Error, Device was already enslaved\n");
+	if (slave_dev->priv_flags & IFF_BONDING) {
+		pr_debug("Error, Device already enslaved or a bonding master\n");
 		return -EBUSY;
 	}
=20

--=20
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

