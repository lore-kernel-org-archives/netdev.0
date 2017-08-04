From: Florian Westphal <fw@strlen.de>
Subject: Re: XFRM pcpu cache issue
Date: Fri, 4 Aug 2017 18:55:43 +0200
Message-ID: <20170804165543.GD15456@breakpoint.cc>
References: <AM4PR0501MB1940130EB22A118F3524DA54DBB10@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Yossef Efraim <yossefe@mellanox.com>
To: Ilan Tayari <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:47192 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752433AbdHDQ5q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 12:57:46 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB1940130EB22A118F3524DA54DBB10@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilan Tayari <ilant@mellanox.com> wrote:
> I debugged a little the regression I told you about the other day...
> 
> Steps and Symptoms:
> 1. Set up a host-to-host IPSec tunnel (or transport, doesn't matter)
> 2. Ping over IPSec, or do something to populate the pcpu cache
> 3. Join a MC group, then leave MC group
> 4. Try to ping again using same CPU as before -> traffic doesn't egress the machine at all
> 
> If trying from another CPU (with clean cache), it pings well.
> If clearing the pcpu cache, it works well again.

Yes, I think i see the problem, thanks for debugging this.

I dropped the stale_bundle() check vs. rfc, that was a stupid thing
to do because that is what would detect this....


Does this help?

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1818,7 +1818,8 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	    xdst->num_pols == num_pols &&
 	    !xfrm_pol_dead(xdst) &&
 	    memcmp(xdst->pols, pols,
-		   sizeof(struct xfrm_policy *) * num_pols) == 0) {
+		   sizeof(struct xfrm_policy *) * num_pols) == 0 &&
+	    xfrm_bundle_ok(xdst)) {
 		dst_hold(&xdst->u.dst);
 		return xdst;
 	}
