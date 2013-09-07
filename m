From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
Date: Sat, 7 Sep 2013 09:34:21 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20D90F64@SJEXCHMB06.corp.ad.broadcom.com>
References: <1378223159-8710-1-git-send-email-mschmidt@redhat.com>
 <504C9EFCA2D0054393414C9CB605C37F20D8F504@SJEXCHMB06.corp.ad.broadcom.com>
 <CADVnQyn0J9QT977X=FjW7byr5_T+p_j8ts7fYkMhkX2HfTU3Sw@mail.gmail.com>
 <CAM8tLiOjF-eQWc6MN-=vRGEkRQiDq8ZQqCWRxp5rOe4-RjR2+g@mail.gmail.com>
 <CADVnQyn-i1SsdqPR1SN5pqbE6sFFD-5_HLqVa6hXmCu2-f8h1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Michal Schmidt" <mschmidt@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Havard Skinnemoen" <hskinnemoen@google.com>,
	"Eric Dumazet" <edumazet@google.com>
To: "Neal Cardwell" <ncardwell@google.com>,
	"Dmitry Kravkov" <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3513 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab3IGJea convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 05:34:30 -0400
In-Reply-To: <CADVnQyn-i1SsdqPR1SN5pqbE6sFFD-5_HLqVa6hXmCu2-f8h1Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Neal Cardwell [mailto:ncardwell@google.com]
> Sent: Saturday, September 07, 2013 6:54 AM
> To: Dmitry Kravkov
> Cc: Dmitry Kravkov; Michal Schmidt; davem@davemloft.net;
> netdev@vger.kernel.org; Ariel Elior; Eilon Greenstein; Havard Skinnemoen;
> Eric Dumazet
> Subject: Re: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
> 
> On Fri, Sep 6, 2013 at 2:40 AM, Dmitry Kravkov <dkravkov@gmail.com>
> wrote:
> > On Wed, Sep 4, 2013 at 8:17 PM, Neal Cardwell <ncardwell@google.com>
> wrote:
> >> On Tue, Sep 3, 2013 at 11:51 AM, Dmitry Kravkov
> <dmitry@broadcom.com> wrote:
> >>>> -----Original Message-----
> >>>> From: Michal Schmidt [mailto:mschmidt@redhat.com]
> >>>> Sent: Tuesday, September 03, 2013 6:46 PM
> >>>> To: davem@davemloft.net
> >>>> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Ariel Elior; Eilon
> >>>> Greenstein
> >>>> Subject: [PATCH net] bnx2x: bail out if unable to acquire
> >>>> stats_sema
> >>>>
> >>>> If we fail to acquire stats_sema in the specified time limit, the
> >>>> chip is probably dead. It probably does not matter whether we try
> >>>> to continue or not, but certainly we should not up() the semaphore
> afterwards.
> >>>>
> >>>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> >>>> ---
> >>>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 24
> >>>> +++++++++++++++++------
> >>
> >> It seems like this patch has the downside that if the down_timeout()
> >> fails, then bnx2x_stats_handle() ends up updating the stats state
> >> machine's state without really executing the real body of the
> >> action().
> >>
> >> In fact it seems like there is a more general pre-existing problem of
> >> this flavor with the bnx2x stats state machine: the
> >> bnx2x_stats_handle() function updates the state machine
> >> bp->stats_state while holding the spin lock, but does not execute the
> >> action() while holding any sort of synchronization, so AFAICT there
> >> is nothing to guarantee that the state machine actions happen in the
> >> order the state machine wants them to happen. For example, if stats
> >> events fire such that we want to execute actions that disable and
> >> then enable stats, we could instead end up executing the actions in
> >> the order that would attempt to enable and then disable them, if we
> >> get unlucky with respect to when interrupts fire, etc.
> >>
> >> It seems to me that instead of having all of the callees of
> >> bnx2x_stats_handle() try to down/up the semaphore, instead
> >> bnx2x_stats_handle() should try to down the stats_sema at the top,
> >> and then if successful, it should change the bp->stats_state, call
> >> the action, and up the stats_sema. Would that work?
> >>
> > handle() is called from sleepable context (open/close) and timer
> > context, then it's not possible to use semaphore for pretection
> 
> But it seems like all of the callees of bnx2x_stats_handle() are already using
> the stats_sema for protection, and the only difference is that
> bnx2x_stats_update uses down_trylock and the other callees use
> down_timeout. What about making this explicit in bnx2x_stats_handle, with
> something like:
> 
> if (event == STATS_EVENT_UPDATE) {
>   if (down_trylock(&bp->stats_sema)) {
>        BNX2X_ERR("stats down_trylock failed\n");
>        goto out;
>   }
> else {
>   if (down_timeout(&bp->stats_sema, HZ/10)) {
>        BNX2X_ERR("stats down_timeout failed\n");
>        goto out;
>   }
> }
> bp->stats_state = ...;
> action = ...;
> action(bp);
> up(&bp->stats_sema);
> 
> That would allow us to protect the bnx2x state machine so that the
> action() events happen in the correct order, and we don't (e.g.) accidentally
> end up doing an enable-then-disable when we wanted disable-then-
> enable.
> 
> Would that work?
Looks like there is no a lot of difference  from current implementation - I will try it and report back...

> 
> neal
> 
>
