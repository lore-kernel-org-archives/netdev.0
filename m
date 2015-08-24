From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net v2] sctp: start t5 timer only when peer.rwnd is 0 and
 local.state is SHUTDOWN_PENDING
Date: Mon, 24 Aug 2015 15:31:46 -0300
Message-ID: <20150824183146.GB1873@localhost.localdomain>
References: <e5d77a8d7c30ccbcc113506837ae7b8e90625046.1440329440.git.lucien.xin@gmail.com>
 <55DB5ED2.1050702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>, tgraf@infradead.org,
	davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754878AbbHXSbs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 14:31:48 -0400
Content-Disposition: inline
In-Reply-To: <55DB5ED2.1050702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 02:13:38PM -0400, Vlad Yasevich wrote:
> On 08/23/2015 07:30 AM, Xin Long wrote:
> > when A sends a data to B, then A close() and enter into SHUTDOWN_PENDING state,
> > if B neither claim his rwnd is 0 nor send SACK for this data, A will keep
> > retransmitting this data util t5 timeout, Max.Retrans times can't work anymore,
> > which is bad.
> > 
> > if B's rwnd is not 0, it should send abord after Max.Retrans times, only when
> > B's rwnd == 0 and A's retransmitting beyonds Max.Retrans times, A will start
> > t5 timer, which is also commit f8d960524 means, but it lacks the condition
> > peer.rwnd == 0.
> > 
> > Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
> > ---
> >  net/sctp/sm_statefuns.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> > index 3ee27b7..deb9eab 100644
> > --- a/net/sctp/sm_statefuns.c
> > +++ b/net/sctp/sm_statefuns.c
> > @@ -5412,7 +5412,8 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
> >  	SCTP_INC_STATS(net, SCTP_MIB_T3_RTX_EXPIREDS);
> >  
> >  	if (asoc->overall_error_count >= asoc->max_retrans) {
> > -		if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
> > +		if (!q->asoc->peer.rwnd &&
> > +		    asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
> >  			/*
> >  			 * We are here likely because the receiver had its rwnd
> >  			 * closed for a while and we have not been able to
> > 
> 
> This may not work as expected.  peer.rwnd is the calculated peer window, but it
> also gets updated when we receive sacks.  So there is no way to tell that
> the current windows is 0 because peer told us, or because we sent data to make 0
> and the peer hasn't responded.

I'm not sure I follow you, Vlad. I don't think we care on why we have
zero-window in there, just that if we are at it on that stage. Either
one, if it's zero window, we will go through T5 and give it more time to
recover, but if it's not zero window, I don't see a reason to enable T5..

  Marcelo
