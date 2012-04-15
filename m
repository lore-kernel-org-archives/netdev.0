From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH v2] bonding: start slaves with link down for ARP monitor
Date: Sun, 15 Apr 2012 15:07:50 -0300
Message-ID: <20120415150750.725652e6@asterix.rh>
References: <20120414220617.DA8BE45BA2@lion.mk-sys.cz>
	<20120415002153.4c4e152a@asterix.rh>
	<19180.1334465333@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60188 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459Ab2DOSIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Apr 2012 14:08:21 -0400
In-Reply-To: <19180.1334465333@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Apr 2012 21:48:53 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Flavio Leitner <fbl@redhat.com> wrote:
> 
> >On Sat, 14 Apr 2012 22:16:16 +0200
> >Michal Kubecek <mkubecek@suse.cz> wrote:
> >
> >> Initialize slave device link state as down if ARP monitor is
> >> active and net_carrier_ok() returns zero. Also shift initial
> >> value of its last_arp_tx so that it doesn't immediately cause
> >> fake detection of "up" state.
> >> 
> >> When ARP monitoring is used, initializing the slave device with
> >> up link state can cause ARP monitor to detect link failure
> >> before the device is really up (with igb driver, this can take
> >> more than two seconds).
> >> 
> >> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> >> ---
> >>  drivers/net/bonding/bond_main.c |   34 +++++++++++++++++++++-------------
> >>  1 files changed, 21 insertions(+), 13 deletions(-)
> >> 
> >> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >> index 62d2409..6a79ee3 100644
> >> --- a/drivers/net/bonding/bond_main.c
> >> +++ b/drivers/net/bonding/bond_main.c
> >> @@ -1726,7 +1726,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> >>  
> >>  	read_lock(&bond->lock);
> >>  
> >> -	new_slave->last_arp_rx = jiffies;
> >> +	new_slave->last_arp_rx = jiffies -
> >> +		(msecs_to_jiffies(bond->params.arp_interval) + 1);
> >>  
> >>  	if (bond->params.miimon && !bond->params.use_carrier) {
> >>  		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
> >> @@ -1751,21 +1752,28 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> >>  	}
> >>  
> >>  	/* check for initial state */
> >> -	if (!bond->params.miimon ||
> >> -	    (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS)) {
> >> -		if (bond->params.updelay) {
> >> -			pr_debug("Initial state of slave_dev is BOND_LINK_BACK\n");
> >> -			new_slave->link  = BOND_LINK_BACK;
> >> -			new_slave->delay = bond->params.updelay;
> >> +	if (bond->params.miimon) {
> >> +		if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
> >> +			if (bond->params.updelay) {
> >> +				new_slave->link = BOND_LINK_BACK;
> >> +				new_slave->delay = bond->params.updelay;
> >> +			} else {
> >> +				new_slave->link = BOND_LINK_UP;
> >> +			}
> >>  		} else {
> >> -			pr_debug("Initial state of slave_dev is BOND_LINK_UP\n");
> >> -			new_slave->link  = BOND_LINK_UP;
> >> +			new_slave->link = BOND_LINK_DOWN;
> >>  		}
> >> +	} else if (bond->params.arp_interval) {
> >> +		new_slave->link = (netif_carrier_ok(slave_dev) ?
> >> +			BOND_LINK_UP : BOND_LINK_DOWN);
> >
> >The interface would have to negotiate the link and report back
> >very very fast because the dev_open(slave) was just called and
> >most drivers initialize the state as DOWN and then wait either
> >for an interrupt or a watchdog to update the link status.
> >
> >Therefore, the practical final result for most cards (if not all)
> >is new_slave->link = BOND_LINK_DOWN and forced to wait for an
> >ARP monitor cycle before going link up according to ARP monitor.
> 
> 	My recollection is that the code was written this way
> specifically because cards could autoneg before the next ARP went out,
> and starting from "up" was the proper choice for the majority of devices
> at the time.  Granted, that was back in the 10/100 days, prior to
> netif_carrier_*, so directly checking carrier was not particularly
> straightforward.  A dim memory says that some cards with WoL would
> assert carrier up almost instantly because carrier was already
> negotiated prior to dev_open being called.
> 
> 	But, yes, the practical result is that most 1G or better cards
> will likely hit this with carrier still down.
> 
> >This will change the current behavior which is faster and good
> >enough for most cases.  What about a new option to decide that?
> >For instance, arp_init_slave=UP/DOWN/MII with default to UP.
> 
> 	By "current behavior" do you mean the current checked in code
> (start at up, flap if autoneg is slow relative to arp_interval), or the
> current (well, prior version) patch (start at down)?
> 

current checked in code.

> 	I'm not in favor of an option for minutiae of this degree.
> 
> 	I'm not really seeing a down side to going with what the carrier
> state is, either, even if most devices are too slow to hit the window.
> 
> 	If the device doesn't do netif_carrier, then this would not be a
> change in behavior.  If the device has wicked fast autoneg, then more
> power to 'em (and they probably need it, since it's likely at 10 or 100
> Mb/sec).  If the device has the currently typical 2-ish second autoneg,
> then the bounce stuff goes away.
> 
> 	Anybody got a 10 or 100 card laying around with fast autoneg to
> try?  Back in the day I used 3c59x and e100s, and I seem to recall that
> the 3c59x board I had was pretty speedy at going carrier up.
> 
> >Jay? Andy? :)
> 
> 	I think the bottom line here for the majority of users is that,
> really, this is about removing some log spew at boot time, and perhaps
> not irritating some functionality that start hitting the device as soon
> as it claims to be carrier up (DHCP, maybe?).  Starting from an assumed
> state of UP or DOWN isn't going to change the actual time the slave
> becomes available, but starting from UP can cause bonding today to
> assert carrier up for the master before it's actually able to transmit
> anything, which may have side effects.
>

My concern was that after the patch most users will have to wait
the link negotiation plus the ARP monitor validation while before
the patch just the link negotiation was enough.

Anyways, I think the patch is correct and I was worried with the
possible consequences while booting the system and etc...

thanks,
fbl
