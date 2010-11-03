From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2/4] Ethtool: convert get_sg/set_sg calls to
 hw_features flag
Date: Wed, 3 Nov 2010 15:42:47 -0700
Message-ID: <20101103224247.GB9869@mcarlson.broadcom.com>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
 <9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl>
 <20101102022438.GA4243@mcarlson.broadcom.com>
 <20101103222910.GA24320@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Steve Glendinning" <steve.glendinning@smsc.com>,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	"Rasesh Mody" <rmody@brocade.com>,
	"Debashis Dutt" <ddutt@brocade.com>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"linux-driver@qlogic.com" <linux-driver@qlogic.com>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>
To: "Micha?? Miros??aw" <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4732 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311Ab0KCWm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 18:42:59 -0400
In-Reply-To: <20101103222910.GA24320@rere.qmqm.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 03, 2010 at 03:29:10PM -0700, Micha?? Miros??aw wrote:
> On Mon, Nov 01, 2010 at 07:24:38PM -0700, Matt Carlson wrote:
> > On Fri, Oct 29, 2010 at 09:28:26PM -0700, Micha?? Miros??aw wrote:
> > > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > > index 30ccbb6..b07e2d1 100644
> > > --- a/drivers/net/tg3.c
> > > +++ b/drivers/net/tg3.c
> > > @@ -11306,7 +11306,6 @@ static const struct ethtool_ops tg3_ethtool_ops = {
> > >         .get_rx_csum            = tg3_get_rx_csum,
> > >         .set_rx_csum            = tg3_set_rx_csum,
> > >         .set_tx_csum            = tg3_set_tx_csum,
> > > -       .set_sg                 = ethtool_op_set_sg,
> > >         .set_tso                = tg3_set_tso,
> > >         .self_test              = tg3_self_test,
> > >         .get_strings            = tg3_get_strings,
> > > @@ -14681,6 +14680,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> > >         tp->rx_pending = TG3_DEF_RX_RING_PENDING;
> > >         tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
> > > 
> > > +       dev->hw_features |= NETIF_F_SG;
> > Scatter-gather should not be enabled if TG3_FLAG_BROKEN_CHECKSUMS is set.  I
> > would do the following instead:
> > 
> > 	if (!(tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS))
> > 		dev->hw_features |= NETIF_F_SG;
> > 
> > TG3_FLAG_BROKEN_CHECKSUMS is set in tg3_get_invariants(), so this code
> > would need to be placed later than that function call.
> 
> This bug is there now, so I'll queue this as all other hints of existent
> bugs that this patch series "uncovers".

How so?  This patch would be introducing the bug.  From tg3_get_invariants:

	if (tp->pci_chip_rev_id == CHIPREV_ID_5700_B0)
		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
	else {
		unsigned long features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_GRO;

		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
			features |= NETIF_F_IPV6_CSUM;
		tp->dev->features |= features;
		vlan_features_add(tp->dev, features);
	}

