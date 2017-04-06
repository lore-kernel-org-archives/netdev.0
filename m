From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH 1/4] net: dsa: add support for the SMSC-LAN9303 tagging format
Date: Thu, 6 Apr 2017 15:36:26 +0200
Message-ID: <201704061536.27164.jbe@pengutronix.de>
References: <20170405092024.16048-1-jbe@pengutronix.de> <20170405092024.16048-2-jbe@pengutronix.de> <20170405171001.GD21965@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:56965 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934780AbdDFNhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:37:07 -0400
In-Reply-To: <20170405171001.GD21965@lunn.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Wednesday 05 April 2017 19:10:01 Andrew Lunn wrote:
> [...]
> > +static int lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
> > +		       struct packet_type *pt, struct net_device *orig_dev)
> > +{
> > +	u16 *lan9303_tag;
> > +	struct dsa_switch_tree *dst = dev->dsa_ptr;
> > +	struct dsa_switch *ds = dst->ds[0];
> > +	unsigned int source_port;
> > +
> > +	if (unlikely(!dst)) {
> > +		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing switch tree device\n");
> > +		goto out_drop; 
> > +	}
>
> By the time you get here, you have already dereferenced dst, in order
> to get ds. So this is pointless.

Ups! Thanks! Fixed in v2.

> > +	lan9303_tag = (u16 *)(skb->data - 2);
> > +
> > +	if (lan9303_tag[0] != htons(0x8100)) {
> > +		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid VLAN marker\n");
> > +		goto out_drop; 
> > +	}
>
> In the transmit function, you use ETH_P_8021Q, please do so here as
> well.

Done in v2.

> > +	source_port = ntohs(lan9303_tag[1]) & 0x3;
> > +
> > +	if (source_port >= DSA_MAX_PORTS) {
> > +		dev_warn_ratelimited(&dev->dev, "Dropping packet due to invalid source port\n");
> > +		goto out_drop; 
> > +	}
>
> You can be more specific here. For this hardware, > 3 is invalid and
> should be dropped. If we later add other chips which have more ports,
> we can relax this check then.

Done in v2.

> > +	/* remove the special VLAN tag between the MAC addresses
> > +	 * and the current ethertype field.
> > +	 */
> > +	skb_pull_rcsum(skb, 2 + 2);
> > +	memmove(skb->data - ETH_HLEN, skb->data - (ETH_HLEN + LAN9303_TAG_LEN),
> > +		2 * ETH_ALEN); 
> > +	skb_push(skb, ETH_HLEN);
>
> Do you need to do anything with the checksum here? Other tagging
> protocols do.

Don't know exactly what you are meaning here. For me it does the same like
the qca_tag_rcv() function in tag_qca.c does.

Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
