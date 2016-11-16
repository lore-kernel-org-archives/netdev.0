From: Hangbin Liu <haliu@redhat.com>
Subject: Re: [PATCH] igmp: Make igmp group member RFC 3376 compliant
Date: Wed, 16 Nov 2016 14:20:45 +0800
Message-ID: <20161116062045.GB17935@leo.usersys.redhat.com>
References: <20161103093834.GA31875@sparky-lenivo.brq.redhat.com>
 <20161107.201345.1974283028907025304.davem@davemloft.net>
 <20161108092625.GA14456@sparky-lenivo.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org
To: Michal Tesar <mtesar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53458 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752443AbcKPGUw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 01:20:52 -0500
Content-Disposition: inline
In-Reply-To: <20161108092625.GA14456@sparky-lenivo.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Nov 08, 2016 at 10:26:25AM +0100, Michal Tesar wrote:
> On Mon, Nov 07, 2016 at 08:13:45PM -0500, David Miller wrote:
> 
> > From: Michal Tesar <mtesar@redhat.com>
> > Date: Thu, 3 Nov 2016 10:38:34 +0100
> > 
> > >  2. If the received Query is a General Query, the interface timer is
> > >     used to schedule a response to the General Query after the
> > >     selected delay.  Any previously pending response to a General
> > >     Query is canceled.
> > > --8<--
> > > 
> > > Currently the timer is rearmed with new random expiration time for
> > > every incoming query regardless of possibly already pending report.
> > > Which is not aligned with the above RFE.
> > 
> > I don't read it that way.  #2 says if this is a general query then any
> > pending response to a general query is cancelled.  And that's
> > effectively what the code is doing right now.
> 
> Hi David,
> I think that it is important to notice that the RFC says also 
> that only the first matching rule is applied.
> 
> "
> When new Query with the Router-Alert option arrives on an
> interface, provided the system has state to report, a delay for a
> response is randomly selected in the range (0, [Max Resp Time]) where
> Max Resp Time is derived from Max Resp Code in the received Query
> message.  The following rules are then used to determine if a Report
> needs to be scheduled and the type of Report to schedule.  The rules
> are considered in order and only the first matching rule is applied.

 ^^

Would you like to reconsider about this? I also agree with Michal that we
need to choose the sooner timer. Or if we receive query very quickly, we
will keep refresh the timer and may never reply the report.

Thanks
Hangbin

> 
> 1. If there is a pending response to a previous General Query
> scheduled sooner than the selected delay, no additional response
> needs to be scheduled.
> 
> 2. If the received Query is a General Query, the interface timer is
> used to schedule a response to the General Query after the
> selected delay.  Any previously pending response to a General
> Query is canceled.
> "
> 
> So I would read the above like below:
> If some general query arrives and there is some
> already pending response scheduled sooner,
> no action is needed.
> That is how I understand to the rule [1].
> 
> But when an general query arrives and there is some other
> response already pending, but not sooner as rule one says but later,
> new report should be scheduled and the already pending one
> needs to be canceled.
> That is how I understand to the rule [2]
> 
> If there is no already pending report scheduled
> the first part of the rule [2] is applied
> and new report is scheduled along the selected delay.
> 
> So basically we need to compare the already scheduled response exp time
> with the one coming in and choose the sooner one.
> This is exactly what the patch does.
> 
> What do you think?
> Best regards Michal Tesar
