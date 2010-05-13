From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next-2.6 2/2] bonding: allow user-controlled output
 slave selection
Date: Thu, 13 May 2010 13:15:04 -0400
Message-ID: <20100513171504.GD21535@shamino.rdu.redhat.com>
References: <20100511003245.GB7497@gospo.rdu.redhat.com>
 <17897.1273608579@death.nxdomain.ibm.com>
 <20100512002725.GA2460@localhost.localdomain>
 <25238.1273693314@death.nxdomain.ibm.com>
 <20100512221408.GI7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59069 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685Ab0EMRRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 13:17:05 -0400
Content-Disposition: inline
In-Reply-To: <20100512221408.GI7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 12, 2010 at 06:14:08PM -0400, Andy Gospodarek wrote:
> On Wed, May 12, 2010 at 12:41:54PM -0700, Jay Vosburgh wrote:
> > Neil Horman <nhorman@tuxdriver.com> wrote:
> > 
> > >On Tue, May 11, 2010 at 01:09:39PM -0700, Jay Vosburgh wrote:
> > >> Andy Gospodarek <andy@greyhouse.net> wrote:
> > >> 
> > >> >This patch give the user the ability to control the output slave for
> > >> >round-robin and active-backup bonding.  Similar functionality was
> > >> >discussed in the past, but Jay Vosburgh indicated he would rather see a
> > >> >feature like this added to existing modes rather than creating a
> > >> >completely new mode.  Jay's thoughts as well as Neil's input surrounding
> > >> >some of the issues with the first implementation pushed us toward a
> > >> >design that relied on the queue_mapping rather than skb marks.
> > >> >Round-robin and active-backup modes were chosen as the first users of
> > >> >this slave selection as they seemed like the most logical choices when
> > >> >considering a multi-switch environment.
> > >> >
> > >> >Round-robin mode works without any modification, but active-backup does
> > >> >require inclusion of the first patch in this series and setting
> > >> >the 'keep_all' flag.  This will allow reception of unicast traffic on
> > >> >any of the backup interfaces.
> > >> 
> > >> 	Yes, I did think that the mark business fit better into existing
> > >> modes (I thought of it as kind of a new hash for xor and 802.3ad modes).
> > >> I also didn't expect to see so much new stuff (this, as well as the FCOE
> > >> special cases being discussed elsewhere) being shoehorned into the
> > >> active-backup mode.  I'm not so sure that adding so many special cases
> > >> to active-backup is a good thing.
> > >> 
> > >> 	Now, I'm starting to wonder if you were right, and it would be
> > >> better overall to have a "manual" mode that would hopefully satisfy this
> > >> case as well as the FCOE special case.  I don't think either of these is
> > >> a bad use case, I'm just not sure the right way to handle them is
> > >> another special knob in active-backup mode (either directly, or
> > >> implicitly in __netif_receive_skb), which wasn't what I expected to see.
> > >> 
> > >I honestly don't think a separate mode is warranted here.  While I'm not opposed
> > >to adding a new mode, I really think doing so is no different from overloading
> > >an existing mode.  I say that because to add a new mode in which we explicitly
> > >expect traffic to be directed to various slaves requires that we implement a
> > >policy for frames which have no queue mapping determined on egress.  Any policy
> > >I can think of is really an approximation of an existing policy, so we may as
> > >well reuse the policy code that we already have in place.  About the only way a
> > >separate mode makes sense is in the 'passthrough' queue mode you document below.
> > >In this model, in which queue ids map to slaves in a 1:1 fashion it doesn't make
> > >senes.
> > 
> > 	One goal I'm hoping to achieve is something that would satisfy
> > both the queue map stuff that you're looking for, and would meet the
> > needs of the FCOE people who also want to disable the duplicate
> > suppression (i.e., permit incoming traffic on the inactive slave) for a
> > different special case.
> > 
> > 	The FCOE proposal revolves around, essentially, active-backup
> > mode, but permitting incoming traffic on the inactive slave.  At the
> > moment, the patches attempt to special case things such that only
> > dev_add_pack listeners directly bound to the inactive slave are checked
> > (to permit the FCOE traffic to pass on the inactive slave, but still
> > dropping IP, as ip_rcv is a wildcard bind).
> > 
> > 	Your keep_all patch is, by and large, the same thing, except
> > that it permits anything to come in on the "inactive" slave, and it's a
> > switch that has to be turned on.
> > 
> > 	This seems like needless duplication to me; I'd prefer to see a
> > single solution that handles both cases instead of two special cases
> > that each do 90% of what the other does.
> > 
> > 	As far as a new mode goes, one major reason I think a separate
> > mode is warranted is the semantics: with either of these changes (to
> > permit more or less regular use of the "inactive" slaves), the mode
> > isn't really an "active-backup" mode any longer; there is no "inactive"
> > or "backup" slave.  I think of this as being a major change of
> > functionality, not simply a minor option.
> > 
> > 	Hence my thought that "active-backup" could stay as a "true" hot
> > standby mode (backup slaves are just that: for backup, only), and this
> > new mode would be the place to do the special queue-map / FCOE /
> > whatever that isn't really a hot standby configuration any longer.
> > 
> > 	As far as the behavior of the new mode (your concern about its
> > policy map approximations), in the end, it would probably act pretty
> > much like active-backup with your patch applied: traffic goes out the
> > active slave, unless directed otherwise.  It's a lot less complicated
> > than I had feared.
> > 
> 
> It's beginning to sound like the 'FCoE use-case' and the one Neil and I
> are proposing are quite similar.  The main goal of both is to have the
> option to have multiple slaves send and receive traffic during the
> steady-state, but in the event of a failover all traffic would run on a
> single interface.
> 
> The implementation proposed with this patch is a bit different that the
> 'mark-mode' patch you may recall I posted a few months ago.  It created
> a new mode that essentially did exactly what you are describing --
> transmit on the primary interface unless pushed to another interface via
> info in the skb and receive on all interfaces.  We initially did not
> create a new mode based on your reservations about the previous
> mark-mode patch and went the direction of enhancing one or two modes
> initially (figuring it would be good to run before walking), with the
> idea that other modes could take care of this output slave selection
> logic in the future.


So, its sounding to me like everyone is leaning toward a new mode approach here.
Before we go ahead and start coding, I hear the bullet points for this approach
as:

1) Implement a new bond mode where queue ids are used to steer frames to output
interfaces

2) Use said mode to imply universal frame reception (i.e. remove the keep_all
knob, and turn on that behavior when this new mode is selected)

3) use John F.'s skb_should_drop changes to implement the keep_all feature.

Does that sound about right?

Regards
Neil

