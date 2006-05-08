From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [rfc][patch] ipvs: use proper timeout instead of fixed value
Date: Sun, 7 May 2006 23:27:00 -0400
Message-ID: <20060508032700.GB25913@gospo.rdu.redhat.com>
References: <20060504201116.GA24394@gospo.rdu.redhat.com> <Pine.LNX.4.64.0605072302370.7007@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	horms@verge.net.au, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35980 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932271AbWEHD1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 May 2006 23:27:33 -0400
To: Wensong Zhang <wensong@linux-vs.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605072302370.7007@penguin.linux-vs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 07, 2006 at 11:32:00PM +0800, Wensong Zhang wrote:
> 
> Hi Andy,
> 
> Yes, the original sychronziation design is a sort of arbitary or 
> compromised solution. We don't want to synchronize every state change from 
> master to backup load balancer, because we were afraid that there were too 
> much state change synchronization messages and there would be some 
> performance penalty. So, we only sychronize the connection of TCP 
> ESTABLISHED state or UDP to backup load balancer, and use the timeout of 3 
> minutes.
> 
> Your change is probably ok, but we should be aware that it may create a 
> lot of connection entries at backup load balancer for TCP applications, 
> which is much more than that at master load balancer, because there is no 
> connection close synchronization and timeout is changed to 3 minutes to 15 
> minutes.

Wensong,

This is an interesting point.  Do you feel it would be reasonable to
synchronize states for extablished connections and terminating
connections rather than all state changes?  It would seem keeping the
table at a minimum size would be desireable without tracking every state
change since that could create too much noice between master and backup
-- especially for short-lived connections.

I could work some more to expand and test this patch to include more
detailed connection tracking if you (or anyone else) feel it would be
valuable.

-andy


> 
> The simple solution is probably to make timeout value tuneable, so that 
> users can tune it for their application. The better solution is to 
> synchronize very connection state change from master to backup, so that 
> backup have almost the same state of connections.
> 
> Thanks,
> 
> Wensong
> 
> 
> On Thu, 4 May 2006, Andy Gospodarek wrote:
> 
> >
> >Instead of using the default timeout of 3 minutes, this uses the timeout
> >specific to the protocol used for the connection. The 3 minute timeout
> >seems somewhat arbitrary (though I know it is used other places in the
> >ipvs code) and when failing over it would be much nicer to use one of
> >the configured timeout values.
> >
> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >---
> >
> >ip_vs_sync.c |    5 +++--
> >1 files changed, 3 insertions(+), 2 deletions(-)
> >
> >diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
> >--- a/net/ipv4/ipvs/ip_vs_sync.c
> >+++ b/net/ipv4/ipvs/ip_vs_sync.c
> >@@ -67,7 +67,6 @@ struct ip_vs_sync_conn_options {
> >	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
> >};
> >
> >-#define IP_VS_SYNC_CONN_TIMEOUT (3*60*HZ)
> >#define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn))
> >#define FULL_CONN_SIZE  \
> >(sizeof(struct ip_vs_sync_conn) + sizeof(struct ip_vs_sync_conn_options))
> >@@ -279,6 +278,7 @@ static void ip_vs_process_message(const
> >	struct ip_vs_sync_conn *s;
> >	struct ip_vs_sync_conn_options *opt;
> >	struct ip_vs_conn *cp;
> >+	struct ip_vs_protocol *pp;
> >	char *p;
> >	int i;
> >
> >@@ -337,7 +337,8 @@ static void ip_vs_process_message(const
> >			p += SIMPLE_CONN_SIZE;
> >
> >		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
> >-		cp->timeout = IP_VS_SYNC_CONN_TIMEOUT;
> >+		pp = ip_vs_proto_get(s->protocol);
> >+		cp->timeout = pp->timeout_table[cp->state];
> >		ip_vs_conn_put(cp);
> >
> >		if (p > buffer+buflen) {
> >
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
