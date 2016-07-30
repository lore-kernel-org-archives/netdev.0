From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/3] sctp_diag: export timer value only if it is active
Date: Sat, 30 Jul 2016 19:59:30 +0200
Message-ID: <20160730175930.GE18872@orbyte.nwl.cc>
References: <1469811580-32429-1-git-send-email-phil@nwl.cc>
 <1469811580-32429-3-git-send-email-phil@nwl.cc>
 <20160729205113.GA2954@localhost.localdomain>
 <CADvbK_dWaMFz2f8GdavXuhyfiCxRmkT_8n9yHHNwSA3y_73WoA@mail.gmail.com>
 <ffdc7f0d-2c98-d63a-725a-01f738689907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xin Long <lucien.xin@gmail.com>,
	David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51711 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752094AbcG3SAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2016 14:00:21 -0400
Content-Disposition: inline
In-Reply-To: <ffdc7f0d-2c98-d63a-725a-01f738689907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 30, 2016 at 10:33:48AM -0300, Marcelo Ricardo Leitner wrote:
> 
> 
> Em 30-07-2016 10:25, Xin Long escreveu:
> >>> diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
> >>> index f69edcf219e51..0ad6033a7330c 100644
> >>> --- a/net/sctp/sctp_diag.c
> >>> +++ b/net/sctp/sctp_diag.c
> >>> @@ -40,10 +40,12 @@ static void inet_diag_msg_sctpasoc_fill(struct inet_diag_msg *r,
> >>>       }
> >>>
> >>>       r->idiag_state = asoc->state;
> >>> -     r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
> >>> -     r->idiag_retrans = asoc->rtx_data_chunks;
> >>> -     r->idiag_expires = jiffies_to_msecs(
> >>> -             asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);
> >>
> >> I think we have two issues here, prior to your patch, but I noticed
> >> while reviewing it :-)
> >>
> >> This array is actually not based on jiffies but on intervals instead, as
> >> per:
> >>
> >> sm_sideeffect.c:
> >>                 case SCTP_CMD_TIMER_START:                       [1]
> >>                         timer = &asoc->timers[cmd->obj.to];
> >>                         timeout = asoc->timeouts[cmd->obj.to];   <---
> >>                         BUG_ON(!timeout);
> >>
> >>                         timer->expires = jiffies + timeout;      <---
> > understood.
> >
> >>
> >> But more importantly, this array is actually not used for this timeout
> >> and the timeout is sctp_transport dependant, as per:
> >>
> >> /* Schedule retransmission on the given transport */
> >> void sctp_transport_immediate_rtx(struct sctp_transport *t)
> >> {
> >>         /* Stop pending T3_rtx_timer */
> >>         if (del_timer(&t->T3_rtx_timer))
> >>                 sctp_transport_put(t);
> >>
> >>         sctp_retransmit(&t->asoc->outqueue, t, SCTP_RTXR_T3_RTX);
> >>         if (!timer_pending(&t->T3_rtx_timer)) {
> >>                 if (!mod_timer(&t->T3_rtx_timer, jiffies + t->rto))
> >>                                                  ^^^^^^^^^^^^^^^^
> >>                         sctp_transport_hold(t);
> >>
> >> Note how on sctp_get_sctp_info() it fetches the RTO (which is T3_RTX)
> >> this way:
> >>         info->sctpi_p_rto = jiffies_to_msecs(prim->rto);
> >> If we want to know how long is left for the timer to expire, we have to
> >> read directly from it.
> > you are right, 3 timers (T3_tx, hb, rtx_data_chunks) are per transport.
> >
> >>
> >> With git grep -A 1 TIMER_START we can confirm that [1] is never hit for
> >> SCTP_EVENT_TIMEOUT_T3_RTX. Yet, the asoc is allocated with kzalloc(), so
> >> I guess you were just reading -jiffies in there.
> >>
> >> Note however that the stats rtx_data_chunks is the accumulated stats,
> >> it's good, and that we may have multiple T3 timers running at once, with
> >> different timeouts.
> >>
> >> Xin, ideas on how we can fix this? I'm not sure if we can dump
> >> per-transport info in there. Not as it is now, I guess.
> > It's not that easy to dump all transports info besed on current sctp_diag codes.
> 
> Okay
> 
> >
> > Now for the transport's info,  we only choose primary_path to dump.
> 
> Okay
> 
> > It means we should fix this by getting the left time to expire from
> > primary transport t->T3_rtx_timer. like:
> >
> >         r->idiag_expires = jiffies_to_msecs(
> > -               asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);
> > +               asoc->peer.primary_path->T3_rtx_timer.expires - jiffies);
> >
> > but yes, need to check with timer_pending firstly.
> 
> Yes :)
> 
> >
> > what do  you think ?
> >
> 
> Makes sense, LGTM.
> 
> Phil, not sure how you want to proceed here. Wanna handle the change above?

I'll look into this next week. One early question: Does the above mean
we are printing the primary path's timer value for every assoc? If so,
shouldn't we do that for just the EP or the primary path's assoc even?

Thanks, Phil
