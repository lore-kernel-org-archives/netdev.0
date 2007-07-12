From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] IPROUTE2: Fix bug  in display of ipv6 cloned/cached
	routes
Date: Thu, 12 Jul 2007 12:20:44 -0700
Message-ID: <1184268044.12609.21.camel@localhost.localdomain>
References: <1184179063.16607.9.camel@localhost.localdomain>
	 <4695257E.8080105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38079 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761039AbXGLTUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 15:20:48 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6CJKkEd025964
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 15:20:46 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6CJKkNk523464
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 15:20:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6CJKkKc023303
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 15:20:46 -0400
In-Reply-To: <4695257E.8080105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-11 at 20:46 +0200, Patrick McHardy wrote:
> Sridhar Samudrala wrote:
> > This patch fixes a bug in the 'ip' command to display 
> > IPv6 cloned routes.
> >   ip -6 route ls cache
> > returns empty even when there are cloned routes because of
> > of a missing else in print_route() routine.
> 
> 
> Looks good. The ip6_multiple_tables case seems to be missing
> filtering for cloned entries entirely, would you mind adding
> that as well?
> 

I found an issue with my original patch. If cache/cloned is 
specified, it dumps the cloned routes irrespective of the table
specified. I think this is a better fix and also should address
the case you were mentioning above.

Thanks
Sridhar

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/ip/iproute.c b/ip/iproute.c
index 6fe4a70..9694bc7 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -178,7 +178,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				return 0;
 		}
 		if (filter.tb) {
-			if (r->rtm_flags&RTM_F_CLONED)
+			if (!filter.cloned && r->rtm_flags&RTM_F_CLONED)
 				return 0;
 			if (filter.tb == RT_TABLE_LOCAL) {
 				if (r->rtm_type != RTN_LOCAL)
@@ -191,6 +191,10 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			}
 		}
 	} else {
+		if (filter.cloned) {
+			if (!(r->rtm_flags&RTM_F_CLONED))
+				return 0;
+		}
 		if (filter.tb > 0 && filter.tb != table)
 			return 0;
 	}


