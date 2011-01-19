From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Bonding on bond
Date: Wed, 19 Jan 2011 21:33:19 +0100
Message-ID: <4D374A8F.2020303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:62778 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870Ab1ASUdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 15:33:23 -0500
Received: by yib18 with SMTP id 18so660469yib.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 12:33:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/01/2011 16:49, Jiri Bohac a =E9crit :
 > On Tue, Jan 18, 2011 at 09:07:20AM +0100, Nicolas de Peslo=FCan wrot=
e:
 >> Staking bond is not supported. Currently, no setup is know to
 >> require stacking bond.

 > I agree. This question and weird bugreports from people trying
 > this come up over and over. How about this patch?

Why not. Adding this to the documentation should also help.

 > bonding: prohibit enslaving of bonding masters
 >
 > Nested bonding is not supported and will result in strange problems,=
 e.g.:
 > - netif_receive_skb() will not properly change skb->dev to point to =
the
 >   uppoer-most bonding master
 > - arp monitor will not work (dev->last_rx is only updated by hardwar=
e drivers)
 > - accidentally enslaving a bonding master to itself will cause an in=
finite
 >   recursion in the TX path
 >
 > This patch prevents this by prohibiting a bonding master from being =
further enslaved.
 >
 > Signed-off-by: Jiri Bohac <jbohac@suse.cz>
 >
 > diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
 > index b1025b8..d4d5f42 100644
 > --- a/drivers/net/bonding/bond_main.c
 > +++ b/drivers/net/bonding/bond_main.c
 > @@ -1448,8 +1448,8 @@ int bond_enslave(struct net_device *bond_dev, =
struct net_device *slave_dev)
 >  	}
 >
 >  	/* already enslaved */
 > -	if (slave_dev->flags & IFF_SLAVE) {
 > -		pr_debug("Error, Device was already enslaved\n");
 > +	if (slave_dev->priv_flags & IFF_BONDING) {
 > +		pr_debug("Error, Device already enslaved or a bonding master\n");

Even if it is possible to test for slave and for master with a single c=
ondition (IFF_BONDING), I=20
suggest to split the tests and the error messages, to give end user the=
 best possible diagnostic.

If the device is already a master, let's say it.
If the device is already enslaved, let's continue to say it. It might e=
ven be better to give the=20
name of the other master that already own this slave.

 >  		return -EBUSY;
 >  	}
 >
 >
 >
 > --
 > Jiri Bohac <jbohac@suse.cz>
 > SUSE Labs, SUSE CZ
