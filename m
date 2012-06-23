From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in net/ipv6/ip6_fib.c:fib6_dump_table()
Date: Sat, 23 Jun 2012 07:37:31 +0200
Message-ID: <1340429851.4604.11942.camel@edumazet-glaptop>
References: <1340353746.4604.9502.camel@edumazet-glaptop>
	 <4FE476A6.1050209@akamai.com>
	 <1340388785.4604.11442.camel@edumazet-glaptop>
	 <20120622.170237.1504103690155447356.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, kaber@trash.net, dbavatar@gmail.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	pekkas@netcore.fi, kuznet@ms2.inr.ac.ru,
	linux-kernel@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36223 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab2FWFhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 01:37:37 -0400
In-Reply-To: <20120622.170237.1504103690155447356.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>


> 1) Patrick McHardy has been inactive for a while, so do not expect
>    any insight from him.
> 
> 2) Ben Greear isn't even on the CC: list of this discussion yet he
>    appears to be the person who reproduced the crash way back then
>    and is listed in the Tested-by tag of the commit.
> 
>    As a result we aren't likely to get any insight from the one person
>    who actually could hit the crash.
> 
> I'm inclined to just revert simply because we have people active who
> can reproduce regressions introduced by this change and nobody can
> understand why the change is even necessary.

Well, except that :

I spent 3 hours trying to understand Alexey code and failed.

All other /proc/net files don't have a such sophisticated walkers aware
mechanism (easily DOSable by the way, if some guy opens 10.000 handles
and suspend in the middle the dumps).

cat /proc/net/tcp for example can display same socket twice or miss a
socket, because a 'suspend/restart' remembers offsets/counts in a hash
chain, not a pointer to 'next socket'

The fix I submitted is a real one, based on my analysis and tests.
 
Patrick patch was restarting the dump at the root of the tree, and
setting skip = count was doing nothing at all, since all entries were
dumped again.

This is more a stable candidate fix.

If someones smarter than me can find the real bug, then we certainly can
revert Patrick patch ?

[PATCH] ipv6: fib: fix fib dump restart

Commit 2bec5a369ee79576a3 (ipv6: fib: fix crash when changing large fib
while dumping it) introduced ability to restart the dump at tree root,
but failed to skip correctly a count of already dumped entries. Code
didn't match Patrick intent.

We must skip exactly the number of already dumped entries.

Note that like other /proc/net files or netlink producers, we could
still dump some duplicates entries.

Reported-by: Debabrata Banerjee <dbavatar@gmail.com>
Reported-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Ben Greear <greearb@candelatech.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
 net/ipv6/ip6_fib.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 74c21b9..6083276 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1349,8 +1349,8 @@ static int fib6_walk_continue(struct fib6_walker_t *w)
 			if (w->leaf && fn->fn_flags & RTN_RTINFO) {
 				int err;
 
-				if (w->count < w->skip) {
-					w->count++;
+				if (w->skip) {
+					w->skip--;
 					continue;
 				}
 
