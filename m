From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/15]: Fix algorithmic complexity of XFRM control plane
Date: Thu, 17 Aug 2006 01:27:31 -0700 (PDT)
Message-ID: <20060817.012731.74748168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51632
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932312AbWHQI13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:27:29 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a repost of the series I sent the other day with significant
additions and some minor mods to the original patches.

The biggest change since my last posting of this stuff is to add
hashing of non-prefixed policies to speed up policy insert/delete and
lookup.  Alexey Kuznetsov is who this idea came from.

I consider these bits logically complete at this point.  In all of my
stress testing the things showing up at the top of the profiles now
are bzero() in glibc, and memset/memcpy in the kernel :-)

On my desktop I can insert about 60,000 SA entries per second, and I
can insert about 130,000 SPD entries per second.  Before these changes
trying to insert even 30,000 SPD entries would probably take a half
hour or so on the same system.  So we clearly needed improvements
here.

The basic summary:

1) Hash xfrm_state objects using two dynamically sized hash tables.
   One hashes on SPI/PROTO/DADDR, the other on FAMILY/REQID/DADDR/SADDR

   SPI/PROTO/DADDR hash is used on packet input.

   FAMILY/REQID/DADDR/SADDR hash is used on output route resolution lookup,
   and insertion conflict resolution.

   It is also used to assist handling of potential "shadowing" of xfrm_state
   objects when a new xfrm_state is inserted.

2) Hash xfrm_policy objects by index and DADDR/SADDR if not prefixed.

   By "prefixed" we mean that either the DADDR or the SADDR are
   specifying a masked subnet instead of a full IP address.

   All xfrm_policy objects go into the index hash, which is used for
   generating unique policy->index values.

   If an xfrm_policy is "prefixed" it goes onto a per-direction singly
   linked list which looks like the policy lists the code used to have.

   If an xfrm_policy is not "prefixed", it is instead inserted into
   a per-direction hash table which is consulted first on lookups.

   All of the policy hashes are dynamically sized as needed.

3) xfrm_state objects were excessively reference counted.  The based
   implicit reference protected entry into the hashtables, and in
   exchange for not refcounting each timer reference we only pay
   a del_timer_sync() at GC destruction time.

4) xfrm_state insertion of transformations using ESP were computationally
   dominated by the initial IV value computation, via get_random_bytes().
   We can defer this until the first time we actually try to output a
   packet using this xfrm_state.

   This is good for another reason, if the xfrm_state is just for input
   packet the initial IV initialization just wastes random number entropy
   since it will never be used.

5) Generation IDs are used to keep xfrm_state insert/delete from having
   to touch the xfrm_policy database and vice versa.  Previously adding
   or removing an xfrm_state required flushing policy layer cached routes
   and other ugly crap like that.

   Every time we add an xfrm_state into the hashes, we give it a new
   generation count.  When a cached route is made which points to that
   entry, the cached route records this generation count.  On every use
   of that route, we'll go through xfrm_dst_check() which will make sure
   the generation count of the cached route still matches the count of
   the xfrm_state it refers to.  If not, the route will be relooked up.

   When we insert a new xfrm_state, we look for any existing xfrm_states
   that match the same FAMILY/REQID/DADDR/SADDR.  On each such match we
   assign a new generation count to force a mismatch with any cached
   routes referring to those entries.

   A route relookup will also be forced on xfrm_state removal because
   xfrm_dst_check() makes sure that xfrm_state->km.state is set to
   XFRM_STATE_VALID.

6) All linkage converted to hlists so that the hash tables are more
   compact.  This made xfrm_policy_insert()'s priority based insertion
   a little hairy, but overall it seems to be a clear improvement.

Well... I guess that was actually the not-so-basic summary :-)

Now that the control plane is reasonably fast I'll start looking at the
data path.  One of the first ideas I have derived with Herbert Xu is to
put the policy bundle cached routes into the flow cache.
