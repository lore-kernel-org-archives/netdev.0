From: Luo Chunbo <chunbo.luo@windriver.com>
Subject: Re: [PATCH 2/2] sctp: fix heartbeat count of path failure
Date: Thu, 20 Aug 2009 09:36:04 +0800
Message-ID: <1250732164.6436.9.camel@pek-cluo-desktop>
References: <1250665268-29770-1-git-send-email-chunbo.luo@windriver.com>
	 <1250665268-29770-2-git-send-email-chunbo.luo@windriver.com>
	 <4A8C10BB.2040804@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42294 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbZHTBgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 21:36:47 -0400
In-Reply-To: <4A8C10BB.2040804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 10:48 -0400, Vlad Yasevich wrote:
> Chunbo Luo wrote:
> > RFC4960 Section 8.2 defined that the transport should enter INACTIVE
> > state only when the value in the error counter exceeds the protocol 
> > parameter 'Path.Max.Retrans' of that destination address. This means 
> > that the transport should enter INACTIVE state after pathmaxrxt+1
> > heartbeats are not acknowledged.
> > 
> > 
> > Signed-off-by: Chunbo Luo <chunbo.luo@windriver.com>
> 
> NAK.  This patch seems to resurface periodically and I have to keep
> explaining that it's wrong.
> 
> Every time we send a HB, we tick up the error count and clear it when
> the HB-ACK is received.  Each HB is separate and not a retransmission,
> so we once we reach the pathmaxrxt, we've already sent max+1 HB, so we
> have time out.  Walk through the code with some values and you'll see
> what I mean.

Although we've already sent max+1 HB, but the code set the transport to
INACTIVE state immediately, which is equal to not sending the max+1 HB
at all.  We should wait for a next period and make sure the max+1 HB was
not acknowledged.

Chunbo 

> 
> -vlad
> 
> > ---
> >  net/sctp/sm_sideeffect.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> > index 86426aa..0e2e269 100644
> > --- a/net/sctp/sm_sideeffect.c
> > +++ b/net/sctp/sm_sideeffect.c
> > @@ -447,7 +447,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
> >  		asoc->overall_error_count++;
> >  
> >  	if (transport->state != SCTP_INACTIVE &&
> > -	    (transport->error_count++ >= transport->pathmaxrxt)) {
> > +	    (transport->error_count++ > transport->pathmaxrxt)) {
> >  		SCTP_DEBUG_PRINTK_IPADDR("transport_strike:association %p",
> >  					 " transport IP: port:%d failed.\n",
> >  					 asoc,
> 
