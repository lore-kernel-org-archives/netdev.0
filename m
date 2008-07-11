From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] IPv4 Multicast: prevent reception of mcast frames from
	unjoined groups
Date: Fri, 11 Jul 2008 11:21:13 -0400
Message-ID: <20080711152112.GA4534@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3343 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514AbYGKPWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 11:22:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current ipv4 multicast code incorrectly allows frames destined to any
multicast group to be received on any socket that is bound to INADDR_ANY,
regardless of weather or not that socket is subscribed to that group.  The
problem is in the ip_mc_sf_allow function.  If a multicast frame enters that
function, and no maching address is found on the passed in interfaces mc_list,
it returns 1, which causes the frame to be delivered.  It should instead return
0, whcih causes the calling function to skip delivery to the passed in socket.
Tested successfully by myself and the reporter.

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>



igmp.c |   13 +++++++++++--
1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 2769dc4..bf54d39 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2215,6 +2215,9 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
 	struct ip_sf_socklist *psl;
 	int i;
 
+	if (ipv4_is_lbcast(loc_addr))
+		return 1;
+
 	if (!ipv4_is_multicast(loc_addr))
 		return 1;
 
@@ -2223,8 +2226,14 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
 		    pmc->multi.imr_ifindex == dif)
 			break;
 	}
-	if (!pmc)
-		return 1;
+	if (!pmc) {
+		/*
+		 * We aren't explicitly added to any mc group
+		 * so don't deliver
+		 */
+		return 0;
+	}
+
 	psl = pmc->sflist;
 	if (!psl)
 		return pmc->sfmode == MCAST_EXCLUDE;
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
