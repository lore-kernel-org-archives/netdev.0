From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
Date: Fri, 6 Sep 2013 09:40:29 +0300
Message-ID: <CAM8tLiOjF-eQWc6MN-=vRGEkRQiDq8ZQqCWRxp5rOe4-RjR2+g@mail.gmail.com>
References: <1378223159-8710-1-git-send-email-mschmidt@redhat.com>
	<504C9EFCA2D0054393414C9CB605C37F20D8F504@SJEXCHMB06.corp.ad.broadcom.com>
	<CADVnQyn0J9QT977X=FjW7byr5_T+p_j8ts7fYkMhkX2HfTU3Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	Michal Schmidt <mschmidt@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:63585 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab3IFGka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 02:40:30 -0400
Received: by mail-vc0-f169.google.com with SMTP id ib11so1931306vcb.0
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 23:40:29 -0700 (PDT)
In-Reply-To: <CADVnQyn0J9QT977X=FjW7byr5_T+p_j8ts7fYkMhkX2HfTU3Sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 4, 2013 at 8:17 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Tue, Sep 3, 2013 at 11:51 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
>>> -----Original Message-----
>>> From: Michal Schmidt [mailto:mschmidt@redhat.com]
>>> Sent: Tuesday, September 03, 2013 6:46 PM
>>> To: davem@davemloft.net
>>> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Ariel Elior; Eilon Greenstein
>>> Subject: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
>>>
>>> If we fail to acquire stats_sema in the specified time limit, the chip is
>>> probably dead. It probably does not matter whether we try to continue or
>>> not, but certainly we should not up() the semaphore afterwards.
>>>
>>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
>>> ---
>>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 24
>>> +++++++++++++++++------
>
> It seems like this patch has the downside that if the down_timeout()
> fails, then bnx2x_stats_handle() ends up updating the stats state
> machine's state without really executing the real body of the
> action().
>
> In fact it seems like there is a more general pre-existing problem of
> this flavor with the bnx2x stats state machine: the
> bnx2x_stats_handle() function updates the state machine
> bp->stats_state while holding the spin lock, but does not execute the
> action() while holding any sort of synchronization, so AFAICT there is
> nothing to guarantee that the state machine actions happen in the
> order the state machine wants them to happen. For example, if stats
> events fire such that we want to execute actions that disable and then
> enable stats, we could instead end up executing the actions in the
> order that would attempt to enable and then disable them, if we get
> unlucky with respect to when interrupts fire, etc.
>
> It seems to me that instead of having all of the callees of
> bnx2x_stats_handle() try to down/up the semaphore, instead
> bnx2x_stats_handle() should try to down the stats_sema at the top, and
> then if successful, it should change the bp->stats_state, call the
> action, and up the stats_sema. Would that work?
>
handle() is called from sleepable context (open/close) and timer
context, then it's not possible to use semaphore for pretection

> neal
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Best regards,
Dmitry
