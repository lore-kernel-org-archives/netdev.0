From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours: ip6_dst_lookup_tail NULL crash
Date: Sun, 7 Sep 2008 22:11:09 +0400
Message-ID: <20080907181109.GA2466@2ka.mipt.ru>
References: <bug-11469-10286@http.bugzilla.kernel.org/> <20080831111304.d57b9f5a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	rdenis@simphalempin.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:35738 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138AbYIGSML (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2008 14:12:11 -0400
Content-Disposition: inline
In-Reply-To: <20080831111304.d57b9f5a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sun, Aug 31, 2008 at 11:13:04AM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > BUG: unable to handle kernel NULL pointer dereference at 0000001d
> > IP: [<f8b375bf>] :ipv6:ip6_dst_lookup_tail+0x95/0x15a
> > *pde = 00000000
> > Oops: 0000 [#14] SMP

Attached patch fixes the problem.
Since dst entry is allowed not to have neighbour entry, flush it just
like with incomplete one. This drops performance of your application
with more than 1024 neighbours to 1024 messages, to fix it you should
tune ipv6 routing parameters (gc intervals, gc threshold, maximum number
of entries and so on). There may be another problem with perfomance
though, at least I was able to bump it 10 times with different settings,
but still two times smaller than with 4k neighbours.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 8b67ca0..582dde5 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -934,7 +934,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		 * dst entry and replace it instead with the
 		 * dst entry of the nexthop router
 		 */
-		if (!((*dst)->neighbour->nud_state & NUD_VALID)) {
+		if (!(*dst)->neighbour || !((*dst)->neighbour->nud_state & NUD_VALID)) {
 			struct inet6_ifaddr *ifp;
 			struct flowi fl_gw;
 			int redirect;

-- 
	Evgeniy Polyakov
