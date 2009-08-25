From: Luo Chunbo <chunbo.luo@windriver.com>
Subject: Re: [PATCH v2] sctp: fix the check for path failure detection
Date: Tue, 25 Aug 2009 16:22:28 +0800
Message-ID: <1251188548.6498.28.camel@pek-cluo-desktop>
References: <1251106637-434-1-git-send-email-chunbo.luo@windriver.com>
	 <4A93949B.2020404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.1.7]:45551 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbZHYLQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 07:16:33 -0400
In-Reply-To: <4A93949B.2020404@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-08-25 at 15:36 +0800, Wei Yongjun wrote:
> Chunbo Luo wrote:
> > The transport error count should be incremented when an outstanding
> > HB is not acknowledged. And the path failure detection should be done
> > before sending out the HB.
> >   
> > Signed-off-by: Chunbo Luo <chunbo.luo@windriver.com>
> > ---
> >  net/sctp/sm_sideeffect.c |    6 +++++-
> >  net/sctp/sm_statefuns.c  |    8 ++++----
> >  2 files changed, 9 insertions(+), 5 deletions(-)
> >
> > diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> > index 86426aa..fbdf4de 100644
> > --- a/net/sctp/sm_sideeffect.c
> > +++ b/net/sctp/sm_sideeffect.c
> > @@ -446,7 +446,11 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
> >  	if (transport->state != SCTP_UNCONFIRMED)
> >  		asoc->overall_error_count++;
> >  
> > -	if (transport->state != SCTP_INACTIVE &&
> > +	/*
> > +	 * The transport error count is incremented when an outstanding HB
> > +	 * is not acknowledged. 
> > +	 */
> >   
> 
> T3-rtx timer expires also need to increment error count.

Yes, T3-rtx timer expires need to increment error count.

> 
> > +	if (transport->hb_sent && transport->state != SCTP_INACTIVE &&
> >  	    (transport->error_count++ >= transport->pathmaxrxt)) {
> >  		SCTP_DEBUG_PRINTK_IPADDR("transport_strike:association %p",
> >  					 " transport IP: port:%d failed.\n",
> > diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> > index 7288192..7f77099 100644
> > --- a/net/sctp/sm_statefuns.c
> > +++ b/net/sctp/sm_statefuns.c
> > @@ -981,10 +981,6 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(const struct sctp_endpoint *ep,
> >  	 */
> >  
> >  	if (transport->param_flags & SPP_HB_ENABLE) {
> > -		if (SCTP_DISPOSITION_NOMEM ==
> > -				sctp_sf_heartbeat(ep, asoc, type, arg,
> > -						  commands))
> > -			return SCTP_DISPOSITION_NOMEM;
> >  		/* Set transport error counter and association error counter
> >  		 * when sending heartbeat.
> >  		 */
> > @@ -992,6 +988,10 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(const struct sctp_endpoint *ep,
> >  				SCTP_TRANSPORT(transport));
> >  		sctp_add_cmd_sf(commands, SCTP_CMD_TRANSPORT_HB_SENT,
> >  				SCTP_TRANSPORT(transport));
> > +		if (SCTP_DISPOSITION_NOMEM ==
> > +				sctp_sf_heartbeat(ep, asoc, type, arg,
> > +						  commands))
> > +			return SCTP_DISPOSITION_NOMEM;
> >  	}
> >  	sctp_add_cmd_sf(commands, SCTP_CMD_HB_TIMER_UPDATE,
> >  			SCTP_TRANSPORT(transport));
> >   
> 
> How about this one:

It is ok to increment the error count. But the path failure detection
should be done before send HB. Otherwise, an extra HB chunk will be sent
out before the transport is marked DOWN . So the changes in
net/sctp/sm_statefuns.c is also needed.



> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 86426aa..fb723dd 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -447,7 +447,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
>  		asoc->overall_error_count++;
>  
>  	if (transport->state != SCTP_INACTIVE &&
> -	    (transport->error_count++ >= transport->pathmaxrxt)) {
> +	    (transport->error_count >= transport->pathmaxrxt)) {
>  		SCTP_DEBUG_PRINTK_IPADDR("transport_strike:association %p",
>  					 " transport IP: port:%d failed.\n",
>  					 asoc,
> @@ -468,6 +468,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_association *asoc,
>  	 * that indicates that we have an outstanding HB.
>  	 */
>  	if (!is_hb || transport->hb_sent) {
> +		transport->error_count++;
>  		transport->last_rto = transport->rto;
>  		transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
>  	}
> 
> 
> 
> 
> 
