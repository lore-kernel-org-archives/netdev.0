From: Florian Westphal <fw@strlen.de>
Subject: Subject: [PATCH ipsec-next 0/8] xfrm: policy: convert lookups to rcu
Date: Thu, 11 Aug 2016 15:17:51 +0200
Message-ID: <1470921479-25592-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54956 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751148AbcHKNRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:17:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit d188ba86dd07a72eb ("xfrm: add rcu protection to sk->sk_policy[]")
sk_policy can rely on rcu protection.

This change allows to also use rcu in xfrm_policy_lookup_bytype and to
avoid grabbing the read-sie policy lock during lookups.

read-side policy rwlock is converted to pure rcu, then the policy_lock is
changed to a plain spinlock as only write-sides remain.

First few patches do some preparation work, the later ones remove
the read-side locks, last patch converts rwlock to spinlock.

I tested this with rcu debug enabled and simple esp tunnel
forwarding udp packets.

If you have better tests for this please let me know and I can re-run with
that.

Florian Westphal (8):
      xfrm: policy: use rcu versions for iteration and list add/del
      xfrm: policy: prepare policy_bydst hash for rcu lookups
      xfrm: policy: add sequence count to synchronize reads with hash resizes
      xfrm: policy: use atomic_inc_not_zero in rcu section
      xfrm: policy: make xfrm_policy_lookup_bytype lockless
      xfrm: policy: only use rcu in xfrm_sk_policy_lookup
      xfrm: policy: don't acquire policy lock in xfrm_spd_getinfo
      xfrm: policy: convert policy_lock to spinlock

 include/net/netns/xfrm.h |    4 -
 net/xfrm/xfrm_policy.c   |  145 +++++++++++++++++++++++++++--------------------
 2 files changed, 88 insertions(+), 61 deletions(-)
