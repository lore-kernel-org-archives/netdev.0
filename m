From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours:
	ip6_dst_lookup_tail NULL crash
Date: Tue, 9 Sep 2008 11:39:55 -0400
Message-ID: <20080909153955.GD5991@hmsreliant.think-freely.org>
References: <20080831111304.d57b9f5a.akpm@linux-foundation.org> <20080907181109.GA2466@2ka.mipt.ru> <200809072119.50307.rdenis@simphalempin.com> <20080908.131547.26037628.davem@davemloft.net> <20080909113215.GB5991@hmsreliant.think-freely.org> <20080909143105.GA24239@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rdenis@simphalempin.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56111 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbYIIPmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 11:42:15 -0400
Content-Disposition: inline
In-Reply-To: <20080909143105.GA24239@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 06:31:05PM +0400, Evgeniy Polyakov wrote:
> Hi.
> 
> On Tue, Sep 09, 2008 at 07:32:15AM -0400, Neil Horman (nhorman@tuxdriver.com) wrote:
> > +	/*
> > +	 * Here if the dst entry we've looked up
> > +	 * has a neighbour entry that is in the INCOMPLETE
> > +	 * state and the src address from the flow is
> > +	 * marked as OPTIMISTIC, we release the found
> > +	 * dst entry and replace it instead with the
> > +	 * dst entry of the nexthop router
> > +	 */
> > +	if (dst->neighbour && !((*dst)->neighbour->nud_state & NUD_VALID)) {
>             ^^^
> This should be (*dst)->neighbour, isn't it?
> 
Dang it, yes it should.  Sorry.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 ip6_output.c |   64 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 32 insertions(+), 32 deletions(-)


diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a4402de..e6671bd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -943,39 +943,39 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	}
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-		/*
-		 * Here if the dst entry we've looked up
-		 * has a neighbour entry that is in the INCOMPLETE
-		 * state and the src address from the flow is
-		 * marked as OPTIMISTIC, we release the found
-		 * dst entry and replace it instead with the
-		 * dst entry of the nexthop router
-		 */
-		if (!((*dst)->neighbour->nud_state & NUD_VALID)) {
-			struct inet6_ifaddr *ifp;
-			struct flowi fl_gw;
-			int redirect;
-
-			ifp = ipv6_get_ifaddr(net, &fl->fl6_src,
-					      (*dst)->dev, 1);
-
-			redirect = (ifp && ifp->flags & IFA_F_OPTIMISTIC);
-			if (ifp)
-				in6_ifa_put(ifp);
-
-			if (redirect) {
-				/*
-				 * We need to get the dst entry for the
-				 * default router instead
-				 */
-				dst_release(*dst);
-				memcpy(&fl_gw, fl, sizeof(struct flowi));
-				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
-				*dst = ip6_route_output(net, sk, &fl_gw);
-				if ((err = (*dst)->error))
-					goto out_err_release;
-			}
+	/*
+	 * Here if the dst entry we've looked up
+	 * has a neighbour entry that is in the INCOMPLETE
+	 * state and the src address from the flow is
+	 * marked as OPTIMISTIC, we release the found
+	 * dst entry and replace it instead with the
+	 * dst entry of the nexthop router
+	 */
+	if ((*dst)->neighbour && !((*dst)->neighbour->nud_state & NUD_VALID)) {
+		struct inet6_ifaddr *ifp;
+		struct flowi fl_gw;
+		int redirect;
+
+		ifp = ipv6_get_ifaddr(net, &fl->fl6_src,
+				      (*dst)->dev, 1);
+
+		redirect = (ifp && ifp->flags & IFA_F_OPTIMISTIC);
+		if (ifp)
+			in6_ifa_put(ifp);
+
+		if (redirect) {
+			/*
+			 * We need to get the dst entry for the
+			 * default router instead
+			 */
+			dst_release(*dst);
+			memcpy(&fl_gw, fl, sizeof(struct flowi));
+			memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
+			*dst = ip6_route_output(net, sk, &fl_gw);
+			if ((err = (*dst)->error))
+				goto out_err_release;
 		}
+	}
 #endif
 
 	return 0;
> -- 
> 	Evgeniy Polyakov
> 

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
