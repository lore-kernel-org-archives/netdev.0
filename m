From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipv4: Properly purge netdev references on uncached
 routes.
Date: Fri, 24 Aug 2012 17:40:47 +0200
Message-ID: <1345822847.19483.8.camel@edumazet-glaptop>
References: <20120731.152033.1148018322961121079.davem@davemloft.net>
	 <20120731154455.2acf97a8@nehalam.linuxnetplumber.net>
	 <20120731.160408.994710172149748635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61407 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755629Ab2HXPkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 11:40:52 -0400
Received: by bkwj10 with SMTP id j10so644340bkw.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 08:40:50 -0700 (PDT)
In-Reply-To: <20120731.160408.994710172149748635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Tue, 2012-07-31 at 16:04 -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 31 Jul 2012 15:44:55 -0700
> 
> > On Tue, 31 Jul 2012 15:20:33 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> >> 
> >> When a device is unregistered, we have to purge all of the
> >> references to it that may exist in the entire system.
> >> 
> >> If a route is uncached, we currently have no way of accomplishing
> >> this.
> >> 
> >> So create a global list that is scanned when a network device goes
> >> down.  This mirrors the logic in net/core/dst.c's dst_ifdown().
> >> 
> >> Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > What about systems will full 1M route table?
> > I wonder if doing rbtree here would make the search faster?
> 
> It only happens for routes like 255.255.255.255 and for those who
> use tclassid on input.
> 
> Everything else is cached in the existing FIB trie entries.

We might have an SMP performance regression on multicast traffic,
because DST_NOCACHE is set on such routes.

What about the following ?

Thanks

[PATCH] ipv4: take rt_uncached_lock only if needed

Multicast traffic allocates dst with DST_NOCACHE, but dst is
not inserted into rt_uncached_list.

This slowdown multicast workloads on SMP because rt_uncached_lock is
contended.

Change the test before taking the lock to actually check the dst
was inserted into rt_uncached_list.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8c8c748..24fd4c5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1263,7 +1263,7 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 {
 	struct rtable *rt = (struct rtable *) dst;
 
-	if (dst->flags & DST_NOCACHE) {
+	if (!list_empty(&rt->rt_uncached)) {
 		spin_lock_bh(&rt_uncached_lock);
 		list_del(&rt->rt_uncached);
 		spin_unlock_bh(&rt_uncached_lock);
