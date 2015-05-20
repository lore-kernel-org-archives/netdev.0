From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v3 net-next 3/4] rocker: do not make neighbour entry
 changes when preparing transactions
Date: Wed, 20 May 2015 21:57:47 +0900
Message-ID: <20150520125744.GA2083@penelope.isobedori.kobe.vergenet.net>
References: <1432100902-10187-1-git-send-email-simon.horman@netronome.com>
 <1432100902-10187-4-git-send-email-simon.horman@netronome.com>
 <555C267B.9070807@lab.ntt.co.jp>
 <20150520074810.GA21934@vergenet.net>
 <555C4776.70508@lab.ntt.co.jp>
 <20150520084623.GA14454@vergenet.net>
 <20150520111736.GE2228@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35084 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbETM56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 08:57:58 -0400
Received: by pacwv17 with SMTP id wv17so66507608pac.2
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 05:57:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150520111736.GE2228@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 01:17:36PM +0200, Jiri Pirko wrote:
> Wed, May 20, 2015 at 10:46:26AM CEST, simon.horman@netronome.com wrote:
> >On Wed, May 20, 2015 at 05:36:06PM +0900, Toshiaki Makita wrote:
> >> On 2015/05/20 16:48, Simon Horman wrote:
> >> > On Wed, May 20, 2015 at 03:15:23PM +0900, Toshiaki Makita wrote:
> >> >> On 2015/05/20 14:48, Simon Horman wrote:
> >> ...
> >> >>>  static void _rocker_neigh_add(struct rocker *rocker,
> >> >>> +			      enum switchdev_trans trans,
> >> >>>  			      struct rocker_neigh_tbl_entry *entry)
> >> >>>  {
> >> >>> +	if (trans == SWITCHDEV_TRANS_PREPARE)
> >> >>> +		return;
> >> >>>  	entry->index = rocker->neigh_tbl_next_index++;
> >> >>
> >> >> Isn't index needed here? It looks to be used in later function call and
> >> >> logging.
> >> > 
> >> > Thanks, that does not follow the usual model of setting values
> >> > during the PREPARE (and all other) transaction phase(s).
> >> > 
> >> >> How about setting index like this?
> >> >>
> >> >> 	entry->index = rocker->neigh_tbl_next_index;
> >> >> 	if (trans == PREPARE)
> >> >> 		return;
> >> >> 	rocker->neigh_tbl_next_index++;
> >> >> 	...
> >> > 
> >> > I am concerned that _rocker_neigh_add() may be called by some other
> >> > caller while a transaction is in process and thus entry->index will
> >> > be inconsistent across callers.
> >> > 
> >> > Perhaps we can convince ourselves that all the bases are covered.
> >> > So far my testing has drawn a blank. But the logic seems difficult to
> >> > reason about.
> >> > 
> >> > As we are basically allocating an index I suppose what is really needed for
> >> > a correct implementation is a transaction aware index allocator, like we
> >> > have for memory (rocker_port_kzalloc etc...).  But that does seem like
> >> > overkill.
> >> > 
> >> > I think that we can make entry->index consistent across
> >> > calls in the same transaction at the expense of breaking the
> >> > rule that per-transaction data should be set during all transaction phases.
> >> > 
> >> > Something like this:
> >> > 
> >> > 
> >> > 	if (trans != SWITCHDEV_TRANS_COMMIT)
> >> > 		/* Avoid index being set to different values across calls
> >> > 		 * to this function by the same caller within the same
> >> > 		 * transaction.
> >> > 		 */
> >> > 		entry->index = rocker->neigh_tbl_next_index++;
> >> > 	if (trans == SWITCHDEV_TRANS_PREPARE)
> >> > 		return;
> >> > 
> >> > 
> >> 
> >> As long as it is guraded by rtnl lock, no worries about this race?  It
> >> seems to be assumed that prepare-commit is guarded by rtnl lock,
> >> according to commit c4f20321 ("rocker: support prepare-commit
> >> transaction model").
> >> 
> >> But as you are concerned, it seems to be able to be called by another
> >> caller, specifically, neigh_timer_handler() in interrupt context without
> >> rtnl lock. IMHO, it should be fixed rather than avoiding the race here.
> >
> >Yes, I believe that is the case I was seeing.
> >
> >Scott, Jiri, how would you like to resolve this?
> 
> 
> I believe that you can depend on rtnl being held - in switchdev_port_obj_add
> there is ASSERT_RTNL assection at the very beginning of the function.

In the prepare-commit scenario, yes, I agree that is the case.
But it does not seem to always be the case when the transaction phase is none.

What I am seeing is:

1. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
   with trans = SWITCHDEV_TRANS_PREPARE

2. rocker_port_ipv4_neigh() is called by rocker_neigh_update()
   with trans = SWITCHDEV_TRANS_NONE.

   The call chain goes up to arp_process() via neigh_update().

3. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
   with trans = SWITCHDEV_TRANS_COMMIT

I believe #2 is not guarded by rtnl.
