From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v3] xen network backend driver
Date: Tue, 1 Mar 2011 10:06:49 +0000
Message-ID: <1298974009.5034.2029.camel@zakaz.uk.xensource.com>
References: <1298914061.5034.996.camel@zakaz.uk.xensource.com>
	 <1298919198.2569.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:17525 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755686Ab1CAKGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 05:06:52 -0500
In-Reply-To: <1298919198.2569.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 18:53 +0000, Ben Hutchings wrote:
> On Mon, 2011-02-28 at 17:27 +0000, Ian Campbell wrote:

> This should be defined as unsigned long (ideally it would be u64, but
> that can't be updated atomically on 32-bit systems).
[...]
> Don't update last_rx; it's only needed on slave devices of a bond, and
> the bonding driver takes care of it now.

I made these two changes.

> [...]
> > +static int xenvif_change_mtu(struct net_device *dev, int mtu)
> > +{
> > +	struct xenvif *vif = netdev_priv(dev);
> > +	int max = vif->can_sg ? 65535 - ETH_HLEN : ETH_DATA_LEN;
> > +	if (mtu > max)
> > +		return -EINVAL;
> > +	dev->mtu = mtu;
> > +	return 0;
> > +}
> [...]
> 
> Since any VLAN tag must be inserted inline, shouldn't the MTU limit be
> 65535 - VLAN_ETH_HLEN?

In that case shouldn't the other case also be ETH_FRAME_LEN -
VLAN_ETH_HLEN?

I'm not sure what is customary wrt MTU vs VLAN (or other) overheads
under Linux, do we take the hit of the overhead for every device
regardless of VLAN being configured or not or do we expect that people
will configure the MTU as necessary when they configure a VLAN?

Netback itself will cope fine with either MTU, it's the external
connectivity which will actually matter. e.g. the usual configuration
would be (where vifX.Y represents potentially multiple netback devices):

	eth0 <-> eth0.VLAN <-> br0.VLAN <=> vifX.Y

So ultimately it will be the eth0 hardware/driver which matters.

There is a comment in net/8021q/vlan.c which says 
        /* need 4 bytes for extra VLAN header info,
         * hope the underlying device can handle it.
         */
and propagates the underlying device's MTU unmodified so it seems that
the norm is to leave the MTU at maximum assuming no VLAN overhead and
defer any required tweaking to the admin?

Alternatively you might have the VLAN on the eth0 device inside the
guest (e.g. netback<->netfront acts like a trunk link) in which case
basically the same argument applies?

I don't really mind either way so I'm happy to follow whatever the
convention is.

Ian.

