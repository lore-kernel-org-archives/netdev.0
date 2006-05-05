From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [rfc][patch] ipvs: use proper timeout instead of fixed value
Date: Thu, 4 May 2006 22:51:11 -0400
Message-ID: <20060505025111.GA29142@gospo.rdu.redhat.com>
References: <20060504201116.GA24394@gospo.rdu.redhat.com> <20060505004754.GA6943@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	wensong@linux-vs.org, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:17877 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030289AbWEECvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 22:51:39 -0400
To: Horms <horms@verge.net.au>
Content-Disposition: inline
In-Reply-To: <20060505004754.GA6943@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 05, 2006 at 09:47:56AM +0900, Horms wrote:
> On Thu, May 04, 2006 at 04:11:16PM -0400, Andy Gospodarek wrote:
> > 
> > Instead of using the default timeout of 3 minutes, this uses the timeout
> > specific to the protocol used for the connection. The 3 minute timeout
> > seems somewhat arbitrary (though I know it is used other places in the
> > ipvs code) and when failing over it would be much nicer to use one of
> > the configured timeout values.
> 
> Hi Andy,
> 
> I agree that the current value is somewhat arbitary, 
> however I'm more in favour of setting it idependantly
> of other timeouts, perhaps via proc. In any case,
> won't pp->timeout_table[cp->state] be rather long in
> the ESTABLISHED case?
> 

Horms,

I agree that there could be a long timeout for ESTABLISHED connections,
but I've run across a situation where I need exactly that.  When testing
failover from master to backup I realize that all of my interactive
sessions get dropped much sooner than the timeout I've configured (mine
is currently set for much longer than 3 minutes).  If I wanted
established connections to timeout quickly I would set the timeout to be
a small value.

-andy


> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> > ---
> > 
> >  ip_vs_sync.c |    5 +++--
> >  1 files changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
> > --- a/net/ipv4/ipvs/ip_vs_sync.c
> > +++ b/net/ipv4/ipvs/ip_vs_sync.c
> > @@ -67,7 +67,6 @@ struct ip_vs_sync_conn_options {
> >  	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
> >  };
> >  
> > -#define IP_VS_SYNC_CONN_TIMEOUT (3*60*HZ)
> >  #define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn))
> >  #define FULL_CONN_SIZE  \
> >  (sizeof(struct ip_vs_sync_conn) + sizeof(struct ip_vs_sync_conn_options))
> > @@ -279,6 +278,7 @@ static void ip_vs_process_message(const 
> >  	struct ip_vs_sync_conn *s;
> >  	struct ip_vs_sync_conn_options *opt;
> >  	struct ip_vs_conn *cp;
> > +	struct ip_vs_protocol *pp;
> >  	char *p;
> >  	int i;
> >  
> > @@ -337,7 +337,8 @@ static void ip_vs_process_message(const 
> >  			p += SIMPLE_CONN_SIZE;
> >  
> >  		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
> > -		cp->timeout = IP_VS_SYNC_CONN_TIMEOUT;
> > +		pp = ip_vs_proto_get(s->protocol);
> > +		cp->timeout = pp->timeout_table[cp->state];
> >  		ip_vs_conn_put(cp);
> >  
> >  		if (p > buffer+buflen) {
> 
> -- 
> Horms                                           http://www.vergenet.net/~horms/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
