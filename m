From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: add mark mode
Date: Fri, 1 May 2009 16:25:09 -0400
Message-ID: <20090501202509.GB6608@gospo.rdu.redhat.com>
References: <20090501173916.GA6608@gospo.rdu.redhat.com> <20090501193403.GA5840@hmsreliant.think-freely.org> <501.1241207536@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33041 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763664AbZEAUZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 16:25:30 -0400
Content-Disposition: inline
In-Reply-To: <501.1241207536@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 01, 2009 at 12:52:16PM -0700, Jay Vosburgh wrote:
> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> >On Fri, May 01, 2009 at 01:39:16PM -0400, Andy Gospodarek wrote:
> >> 
> >> Quite a few people are happy with the way bonding manages to split
> >> traffic to different members of a bond.  Many are quite disappointed
> >> that users or administrators cannot be given more control over the
> >> traffic distribution and would like something that they can control more
> >> easily.  I looked at extending some of the existing modes, but the
> >> cleanest option seemed to be one that created an additional mode to
> >> handle this case.  I hated to create yet another mode, but the
> >> simplicity of this mode made it a nice candidate for a new mode.  I have
> >> decided to call this mode 'mark' (or mode 7).
> >> 
> >> The mark mode of bonding relies on the skb->mark field for outgoing
> >> device selection.  Unmarked frames (ones where the mark is still zero),
> >> will be sent by the first active enslaved device.  Any marked frames
> >> will choose the outgoing device based on result of the modulo of the mark
> >> and the number of enslaved devices.  If that device is inactive
> >> (link-down), the traffic will default back to the first active enslaved
> >> device.  I debated how to use the mark to decide the outgoing device,
> >> but it seemed that modulo of the mark and the number of enslaved devices
> >> would provide the most flexibility for those who currently mark frames
> >> for other purposes.
> >> 
> >> I considered some other options for choosing destination devices based
> >> on marks, but the ones I came up would require additional sysfs
> >> configuration parameters and I would prefer not to add any more to an
> >> already crowded space.
> >> 
> >> I've tested this on a slightly older kernel than the net-next-2.6 tree
> >> than this patch is against by marking frames using mark and connmark
> >> iptables options and it seems to work as I expect.
> >> 
> >> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >> ---
> >> 
> >>  Documentation/networking/bonding.txt |   25 ++++++++++++++
> >>  drivers/net/bonding/bond_main.c      |   59 ++++++++++++++++++++++++++++++++++-
> >>  include/linux/if_bonding.h           |    1 
> >>  3 files changed, 84 insertions(+), 1 deletion(-)
> >> 
> >> diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
> >> index 0876275..7a0d4c2 100644
> >> --- a/Documentation/networking/bonding.txt
> >> +++ b/Documentation/networking/bonding.txt
> >> @@ -582,6 +582,31 @@ mode
> >>  		swapped with the new curr_active_slave that was
> >>  		chosen.
> >>  
> >> +	mark or 7
> >> +
> >> +		Mark-based policy: skbuffs that arrive to be
> >> +		transmitted will have the mark field inspected to
> >> +		determine the destination slave device.  When the
> >> +		skbuff's mark is zero, the first active device in the
> >> +		ordered list of enslaved devices will be used.  When
> >> +		the mark is non-zero the modulo of the mark and the
> >> +		number of enslaved devices will determine the
> >> +		interface used for transmission.  If this device is
> >> +		not active (link-down) then the mark will essentially
> >> +		be ignored and the first active device in the ordered
> >> +		list of enslaved devices will be used.
> >> +
> >> +		The flexibility offered with this mode allows users
> >> +		of netfilter to move various types of traffic to
> >> +		different slaves quite easily.  Information on this
> >> +		can be found in the manpages for iptables/ebtables
> >> +		as well as netfilter documentation.
> >> +
> >> +		Prerequisites:
> >> +
> >> +		1.  Without the ability to mark skbuffs this mode is
> >> +		not useful.  Netfilter greatly aides skbuff marking.
> >> +
> >>  num_grat_arp
> >>  
> >>  	Specifies the number of gratuitous ARPs to be issued after a
> >> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >> index fd73836..5e1d166 100644
> >> --- a/drivers/net/bonding/bond_main.c
> >> +++ b/drivers/net/bonding/bond_main.c
> >> @@ -123,7 +123,7 @@ module_param(mode, charp, 0);
> >>  MODULE_PARM_DESC(mode, "Mode of operation : 0 for balance-rr, "
> >>  		       "1 for active-backup, 2 for balance-xor, "
> >>  		       "3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, "
> >> -		       "6 for balance-alb");
> >> +		       "6 for balance-alb, 7 for mark");
> >>  module_param(primary, charp, 0);
> >>  MODULE_PARM_DESC(primary, "Primary network device to use");
> >>  module_param(lacp_rate, charp, 0);
> >> @@ -175,6 +175,7 @@ const struct bond_parm_tbl bond_mode_tbl[] = {
> >>  {	"802.3ad",		BOND_MODE_8023AD},
> >>  {	"balance-tlb",		BOND_MODE_TLB},
> >>  {	"balance-alb",		BOND_MODE_ALB},
> >> +{	"mark",			BOND_MODE_MARK},
> >>  {	NULL,			-1},
> >>  };
> >>  
> >> @@ -224,6 +225,7 @@ static const char *bond_mode_name(int mode)
> >>  		[BOND_MODE_8023AD]= "IEEE 802.3ad Dynamic link aggregation",
> >>  		[BOND_MODE_TLB] = "transmit load balancing",
> >>  		[BOND_MODE_ALB] = "adaptive load balancing",
> >> +		[BOND_MODE_MARK] = "mark-based transmit balancing",
> >>  	};
> >>  
> >>  	if (mode < 0 || mode > BOND_MODE_ALB)
> >> @@ -4464,6 +4466,57 @@ out:
> >>  	return 0;
> >>  }
> >>  
> >> +static int bond_xmit_mark(struct sk_buff *skb, struct net_device *bond_dev)
> >> +{
> >> +	struct bonding *bond = netdev_priv(bond_dev);
> >> +	struct slave *slave;
> >> +	int i, slave_no, res = 1;
> >> +
> >> +	read_lock(&bond->lock);
> >> +
> >> +	if (!BOND_IS_OK(bond)) {
> >> +		goto out;
> >> +	}
> >> +
> >> +	/* Use the mark as the determining factor for which slave to
> >> +	 * choose for transmission.  When behaving normally all should
> >> +	 * work just fine.  When a slave that is destined to be the
> >> +	 * transmitter of this frame is down, start at the front of the
> >> +	 * list and find the first available slave. */
> 
> 	Why not simply use the N'th up slave instead of reverting to
> slave 0 for the down slave case?  I'm guessing this has to do with
> trying to maintain some fixed balancing of traffic even in the face of
> slave failure.
> 

That could be a reasonable option as well -- in fact that was my first
implementation.  I decided to do it this way, so that a user could
consider the first device as the primary slave for unmarked traffic and
the slave for marked traffic destined for a slave that was down rather
than what might seem like a random choice for traffic.

> >> +	slave_no = skb->mark ? skb->mark % bond->slave_cnt : 0;
> >> +
> >Would it be worthwhile to add a special case here (say all f's in mark, to
> >indicate a frames should be sent out all slaves on the bond?  In the case you
> >have traffic that might need to go to all interface (like maybe igmp)?
> 
> 	If I'm not misunderstanding the purpose of the mode, I think
> it's etherchannel compatible (meaning that the switch has to be
> configured), so I'm not sure why there would ever be a need to flood
> packets to all ports.
> 
> 	I think this would be generally be better a special hash policy,
> in which case both the etherchannel (balance-xor) and 802.3ad modes
> could take advantage of it.  I'd hazard to guess that Andy thought about
> that, too, so what was the impediment?
> 

I wasn't designing this to be etherchannel compatible.  Though it could
work that way, my idea was to use this in an environment where slaves
may be connected to different switches that are capable of moving all of
the traffic to it's destination if needed, but if the traffic is split
in a predictable application specific manner the network can run more
efficiently.  Think of this more as an active-backup mode where the
backup links could actually be utilized.

When I first started on this I considered just extending the
active-backup mode's transmit function, but I didn't want to deal with
the potential loss of duplicate frames in skb_bond_should_drop and I
also didn't want to deal with the complicated failover scenarios of
active-backup mode.

It's probably the most like round-robin (in fact it's quite close), but
I felt that this mode could eventually grow into something more useful
(who knows how it might be extended) and deserved it's own mode rather
than dealing with the possibility of having a larger more complicated
transmit routine in the future when another mode would be just fine.

