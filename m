From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Bonding on bond
Date: Thu, 20 Jan 2011 17:12:59 +0100
Message-ID: <4D385F0B.1010000@gmail.com>
References: <4D374A8F.2020303@gmail.com> <20110120153110.GA3931@midget.suse.cz>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58133 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317Ab1ATQND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 11:13:03 -0500
Received: by wyb28 with SMTP id 28so779519wyb.19
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 08:13:02 -0800 (PST)
In-Reply-To: <20110120153110.GA3931@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/01/2011 16:31, Jiri Bohac a =E9crit :
> On Wed, Jan 19, 2011 at 09:33:19PM +0100, Nicolas de Peslo=FCan wrote=
:
>> Even if it is possible to test for slave and for master with a
>> single condition (IFF_BONDING), I suggest to split the tests and the
>> error messages, to give end user the best possible diagnostic.
>
> OK, why not. The below patch still uses IFF_BONDING to detect a
> master is being enslaved, because IFF_MASTER is also used by the
> eql driver. No idea if it works / someone ever uses it with
> bonding, but it might collide.

Thanks Jiri.

> bonding: prohibit enslaving of bonding masters
>
> Nested bonding is not supported and will result in strange problems, =
e.g.:
> - netif_receive_skb() will not properly change skb->dev to point to t=
he
>    uppoer-most bonding master
> - arp monitor will not work (dev->last_rx is only updated by hardware=
 drivers)
> - accidentally enslaving a bonding master to itself will cause an inf=
inite
>    recursion in the TX path
>
> This patch prevents this by prohibiting a bonding master from being f=
urther enslaved.
>
> Signed-off-by: Jiri Bohac<jbohac@suse.cz>

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index b1025b8..b117dd8 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1453,6 +1453,12 @@ int bond_enslave(struct net_device *bond_dev, =
struct net_device *slave_dev)
>   		return -EBUSY;
>   	}
>
> +	/* cannot enslave a master */
> +	if (slave_dev->priv_flags&  IFF_BONDING) {
> +		pr_debug("Error, cannot enslave a bonding master\n");
> +		return -EBUSY;
> +	}
> +
>   	/* vlan challenged mutual exclusion */
>   	/* no need to lock since we're protected by rtnl_lock */
>   	if (slave_dev->features&  NETIF_F_VLAN_CHALLENGED) {
>

