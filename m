From: David Miller <davem@davemloft.net>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Tue, 03 Jun 2008 09:57:50 -0700 (PDT)
Message-ID: <20080603.095750.120470495.davem@davemloft.net>
References: <20071227181439.6F59.40F06B3A@sm.sony.co.jp>
	<20080110.011602.74511551.davem@davemloft.net>
	<20080111112248.610C.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: mokuno@sm.sony.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751795AbYFCQ5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:57:53 -0400
In-Reply-To: <20080111112248.610C.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Date: Fri, 11 Jan 2008 13:16:29 +0900

> On Thu, 10 Jan 2008 01:16:02 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
> > index c99a8ee..d6f0c51 100644
> > --- a/include/net/iw_handler.h
> > +++ b/include/net/iw_handler.h
> > @@ -483,19 +483,26 @@ extern void wireless_spy_update(struct net_device *	dev,
> >   * Wrapper to add an Wireless Event to a stream of events.
> >   */
> >  static inline char *
> > -iwe_stream_add_event(char *	stream,		/* Stream of events */
> > -		     char *	ends,		/* End of stream */
> > -		     struct iw_event *iwe,	/* Payload */
> > -		     int	event_len)	/* Real size of payload */
> > +iwe_stream_add_event(struct iw_request_info *info, char *stream, char *ends,
> > +		     struct iw_event *iwe, int event_len)
> >  {
> > +	int lcp_len = IW_EV_LCP_LEN;
> > +
> > +#ifdef CONFIG_COMPAT
> > +	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
> > +		event_len -= IW_EV_LCP_LEN;
> > +		event_len += IW_EV_COMPAT_LCP_LEN;
> > +		lcp_len = IW_EV_COMPAT_LCP_LEN;
> > +	}
> > +#endif
> >  	/* Check if it's possible */
> >  	if(likely((stream + event_len) < ends)) {
> >  		iwe->len = event_len;
> >  		/* Beware of alignement issues on 64 bits */
> >  		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
> > -		memcpy(stream + IW_EV_LCP_LEN,
> > -		       ((char *) iwe) + IW_EV_LCP_LEN,
> > -		       event_len - IW_EV_LCP_LEN);
> > +		memcpy(stream + lcp_len,
> > +		       ((char *) iwe) + lcp_len,
> 
> The source address does not have to be adjusted.  I think it should be
> 		       ((char *) iwe) + IW_EV_LCP_LEN,
> or just
> 		       &iwe->u
> I think it is more readable what we want to do here.
> 
> 
> > +		       event_len - lcp_len);
> 
> The length of the real payload does not need to take account of the
> destination offset change.  So we can keep the original code like:
> 
> 		       org_event_len - IW_EV_LCP_LEN);

As long as IW_EV_LCP_LEN and IW_EV_COMPAT_LCP_LEN are different, I am
pretty sure we need to make these adjustments.

There are so many differences in how struct vs. sub-struct alignment will
occur in these cases, that we need to be very careful.

I'll try to look more closely at this and do some testing of my own on
a compat platform.

