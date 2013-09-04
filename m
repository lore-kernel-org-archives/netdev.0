From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
Date: Wed, 4 Sep 2013 13:17:19 -0400
Message-ID: <CADVnQyn0J9QT977X=FjW7byr5_T+p_j8ts7fYkMhkX2HfTU3Sw@mail.gmail.com>
References: <1378223159-8710-1-git-send-email-mschmidt@redhat.com>
	<504C9EFCA2D0054393414C9CB605C37F20D8F504@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michal Schmidt <mschmidt@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:57685 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231Ab3IDRRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 13:17:21 -0400
Received: by mail-ee0-f54.google.com with SMTP id e53so346660eek.27
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 10:17:19 -0700 (PDT)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20D8F504@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 3, 2013 at 11:51 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
>> -----Original Message-----
>> From: Michal Schmidt [mailto:mschmidt@redhat.com]
>> Sent: Tuesday, September 03, 2013 6:46 PM
>> To: davem@davemloft.net
>> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Ariel Elior; Eilon Greenstein
>> Subject: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
>>
>> If we fail to acquire stats_sema in the specified time limit, the chip is
>> probably dead. It probably does not matter whether we try to continue or
>> not, but certainly we should not up() the semaphore afterwards.
>>
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 24
>> +++++++++++++++++------

It seems like this patch has the downside that if the down_timeout()
fails, then bnx2x_stats_handle() ends up updating the stats state
machine's state without really executing the real body of the
action().

In fact it seems like there is a more general pre-existing problem of
this flavor with the bnx2x stats state machine: the
bnx2x_stats_handle() function updates the state machine
bp->stats_state while holding the spin lock, but does not execute the
action() while holding any sort of synchronization, so AFAICT there is
nothing to guarantee that the state machine actions happen in the
order the state machine wants them to happen. For example, if stats
events fire such that we want to execute actions that disable and then
enable stats, we could instead end up executing the actions in the
order that would attempt to enable and then disable them, if we get
unlucky with respect to when interrupts fire, etc.

It seems to me that instead of having all of the callees of
bnx2x_stats_handle() try to down/up the semaphore, instead
bnx2x_stats_handle() should try to down the stats_sema at the top, and
then if successful, it should change the bp->stats_state, call the
action, and up the stats_sema. Would that work?

neal
