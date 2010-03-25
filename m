From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH RFC 0/2] caching bundles instead of policies
Date: Thu, 25 Mar 2010 11:24:49 +0200
Message-ID: <1269509091-6440-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:52529 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab0CYJZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 05:25:02 -0400
Received: by ey-out-2122.google.com with SMTP id d26so870382eyd.19
        for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 02:25:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not yet intended for commit (see below), but rather a
snapshot of what I'm working with currently. And to get some feedback
on the direction where I'm going.

The first patch changes flow cache reference counting fundamentally.
It no longer assumes that the cached objects are GC'd later, but instead
calls the virtualized delete method to delete (or drop it's reference).
This does now mean that ->delete() call can be slowish. The plan is to
add ->check() which is called when ever the cache is flushed, add all
deleted entries to GC list, and have the main flush routine delete the
GC list entries.

I wanted to suggest this because:
 - xfrm_policy_put() is currently never guaranteed to be fast, instead
   it can always result to slow path. Only the flow cache wanted to have
   fast free when bh is disabled, and this was made possible with the
   policy GC ensuring that cache is flushed before policies are freed.
 - now that we can cache bundles or policies, it makes sense to have
   more selective flushing; otherwise we lose some of the speed ups.
   This also means that flushing gets faster, and is needed very rarely
   (sensible points are GC'ing bundles and when interface goes down)
 - now we don't have to do two periodic/delayed GC's: one for bundles,
   and one for policies. instead we can have central code for that in
   the flow cache. this also means that the flow cache hash is the
   owner of bundle, and when the flow cache entry is expired the bundle
   is dst_free()'d (which we would want to do anyway). no need to keep
   bundles in separate global (or policy specific) list

Does this sound acceptable approach?

What the current patch set is missing:
 - delayed deletion of flow cache objects
 - doing check() on flush for each object
 - removing the policy GC
 - some of the other flow cache improvements from my original patch

Also, we might want to cache dummy bundles in xfrm_check_policy().
The reason is that if we matched sub policy originally, we always have
to do O(n) search for the main policy.

Timo Teras (2):
  flow: virtualize get and entry deletion methods
  xfrm: cache bundles instead of policies for outgoing flows

 include/net/flow.h      |   17 +-
 include/net/xfrm.h      |   12 +-
 net/core/flow.c         |  102 ++++---
 net/ipv4/xfrm4_policy.c |   22 --
 net/ipv6/xfrm6_policy.c |   31 --
 net/xfrm/xfrm_policy.c  |  755 +++++++++++++++++++++++++----------------------
 6 files changed, 471 insertions(+), 468 deletions(-)

