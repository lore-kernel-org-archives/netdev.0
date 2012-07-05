From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/19] Disconnect neigh from dst_entry
Date: Thu, 05 Jul 2012 02:55:21 -0700 (PDT)
Message-ID: <20120705.025521.357202791654618782.davem@davemloft.net>
References: <20120703.024543.1597240990462633709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088Ab2GEJz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 05:55:28 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 6C5D8584B24
	for <netdev@vger.kernel.org>; Thu,  5 Jul 2012 02:55:25 -0700 (PDT)
In-Reply-To: <20120703.024543.1597240990462633709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 03 Jul 2012 02:45:43 -0700 (PDT)

> This finally severs neighbour table entries from dst_entry enough that
> we no longer depend upon them outside of the individual protocols.

I'm pushing this now to net-next, with three minor changes.

1) I fubar'd the neigh lookup in the sch_teql changes, I needed to
   add the following code block to __teql_resolve():

       if (dst->dev != dev) {
                struct neighbour *mn;

                mn = __neigh_lookup_errno(n->tbl, n->primary_key, dev);
                neigh_release(n);
                if (IS_ERR(mn))
                        return PTR_ERR(mn);
                n = mn;
        }

2) I adjusted the comment in the neigh backlog handler of
   neigh_update() to read as follows:


	/* Why not just use 'neigh' as-is?  The problem is that
	 * things such as shaper, eql, and sch_teql can end up
	 * using alternative, different, neigh objects to output
	 * the packet in the output path.  So what we need to do
	 * here is re-lookup the top-level neigh in the path so
	 * we can reinject the packet there.
	 */

3) The redirect network event needs to also pass in the path
   destination address so that we can have it available for
   all callers of t3_l2t_get().
