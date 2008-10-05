From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/6] [NET] dsa: add support for original DSA tagging format
Date: Mon, 6 Oct 2008 01:56:58 +0200
Message-ID: <20081005235658.GA30332@xi.wantstofly.org>
References: <20080929023829.GI21560@xi.wantstofly.org> <1223054759.3984.76.camel@achroite> <20081003193250.GA15924@xi.wantstofly.org> <20081004112235.GG7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:54598 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbYJEX5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 19:57:03 -0400
Content-Disposition: inline
In-Reply-To: <20081004112235.GG7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 04, 2008 at 12:22:37PM +0100, Ben Hutchings wrote:

> > > > Most of the DSA switches currently in the field do not support the
> > > > Ethertype DSA tagging format that one of the previous patches added
> > > > support for, but only the original DSA tagging format.
> > > > 
> > > > The original DSA tagging format carries the same information as the
> > > > Ethertype DSA tagging format, but with the difference that it does not
> > > > have an ethertype field.  In other words, when receiving a packet that
> > > > is tagged with an original DSA tag, there is no way of telling in
> > > > eth_type_trans() that this packet is in fact a DSA-tagged packet.
> > > > 
> > > > This patch adds a hook into eth_type_trans() which is only compiled in
> > > > if support for a switch chip that doesn't support Ethertype DSA is
> > > > selected, and which checks whether there is a DSA switch driver
> > > > instance attached to this network device which uses the old tag format.
> > > > If so, it sets the protocol field to ETH_P_DSA without looking at the
> > > > packet, so that the packet ends up in the right place.
> > > [...]
> > > 
> > > Why should this go in eth_type_trans()?  Why don't you put the hook into
> > > the specific network driver(s) that need it?
> > >
> > > For that matter, why should dsa_ptr go in struct net_device and not in
> > > the private state for the specific network drivers that need it?
> > 
> > DSA is just another protocol.  Putting hooks in specific network driver
> > to handle a certain protocol doesn't seem like the right thing to do to
> > me.
> 
> If it's just another protocol then put dsa_ptr along with the other
> protocol pointers (ip_ptr etc.).

OK, I'll do that.


> For those drivers that work with the original DSA tagging format, it's
> apparently not just another protocol.

The original DSA tagging format can work with any NIC, as long as you
hook up that NIC directly to a DSA switch chip instead of to a PHY.  In
embedded designs you mostly see platform bus drivers like mv643xx_eth
and gianfar and such, but there's no reason you can't do it with any
other MAC that exposes a (R)(G)MII interface.

The only reason that eth_type_trans() needs a hack is that the original
DSA tagging format has information starting right after the ethernet
source address, so there's no way to tell that original DSA tagged
frames are in fact original DSA tagged frames.  (The way we tell is by
having the DSA switch driver decide -- it configures the directly
attached switch chip to always send DSA tagged packets to the cpu's
switch port, and then forces all packets received on the underlying
ethernet device to get ETH_P_DSA assigned to skb->protocol.)
