From: Willy Tarreau <w@1wt.eu>
Subject: Re: [IPv4] fib: Fix out of bound access of fib_props[]
Date: Sat, 14 Apr 2007 17:48:36 +0200
Message-ID: <20070414154836.GA1758@1wt.eu>
References: <20070324153435.GE521@postel.suug.ch> <20070324.203339.71087299.davem@davemloft.net> <20070414142655.GA21327@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1866 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbXDNPsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2007 11:48:43 -0400
Content-Disposition: inline
In-Reply-To: <20070414142655.GA21327@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 14, 2007 at 04:26:55PM +0200, Willy Tarreau wrote:
> On Sat, Mar 24, 2007 at 08:33:39PM -0700, David Miller wrote:
> > From: Thomas Graf <tgraf@suug.ch>
> > Date: Sat, 24 Mar 2007 16:34:36 +0100
> > 
> > > Fixes a typo which caused fib_props[] to have the wrong size
> > > and makes sure the value used to index the array which is
> > > provided by userspace via netlink is checked to avoid out of
> > > bound access.
> > > 
> > > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > 
> > Applied, thanks.
> 
> Thomas, David, it seems to me that 2.4 needs the same fix for the
> typo, but I see no place where we may add the check for > RTN_MAX.
> Maybe this last one is not needed. If someone could enlighten me,
> or at least provide a means to test if the bug it present, it would
> help me.

Finally, I think I have the correct fix below. Please someone confirm
or tell me I'm nuts.

Thanks in advance,
Willy


>From 230c62b9e7000cfb407a079a21ad0f077f164b21 Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Sat, 14 Apr 2007 17:44:03 +0200
Subject: [IPv4] fib: Fix out of bound access of fib_props[]

Backported from 2.6. Bug found and fixed by Thomas Graf :

Fixes a typo which caused fib_props[] to have the wrong size
and makes sure the value used to index the array which is
provided by userspace via netlink is checked to avoid out of
bound access.
---
 net/ipv4/fib_semantics.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index afdf4bb..b930371 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -83,7 +83,7 @@ static struct
 {
 	int	error;
 	u8	scope;
-} fib_props[RTA_MAX+1] = {
+} fib_props[RTN_MAX+1] = {
         { 0, RT_SCOPE_NOWHERE},		/* RTN_UNSPEC */
 	{ 0, RT_SCOPE_UNIVERSE},	/* RTN_UNICAST */
 	{ 0, RT_SCOPE_HOST},		/* RTN_LOCAL */
@@ -431,6 +431,11 @@ fib_create_info(const struct rtmsg *r, struct kern_rta *rta,
 	const int nhs = 1;
 #endif
 
+	if (r->rtm_type > RTN_MAX) {
+		err = -EINVAL;
+		goto errout;
+	}
+
 	/* Fast check to catch the most weird cases */
 	if (fib_props[r->rtm_type].scope > r->rtm_scope)
 		goto err_inval;
-- 
1.4.4.4

