From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] net: fix a double free issue for neighbour entry
Date: Wed, 20 May 2015 22:19:49 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1505202103390.1755@ja.home.ssi.bg>
References: <1432085113-25063-1-git-send-email-ying.xue@windriver.com> <1432099637.4060.12.camel@edumazet-glaptop2.roam.corp.google.com> <555C313E.1020003@windriver.com> <alpine.LFD.2.11.1505201050590.1557@ja.home.ssi.bg> <555C484A.7080807@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, alexei@purestorage.com, joern@purestorage.com
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47903 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751663AbbETTUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2015 15:20:07 -0400
In-Reply-To: <555C484A.7080807@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 20 May 2015, Ying Xue wrote:

> Yes, this way is absolutely safe for us! But, for example, if we check refcnt==0
> in write_lock protection, the checking is a bit late. Instead, if the checking
> is advanced to ip_finish_output2(), we can _early_ find the fact that we cannot
> use the neigh entry looked up by __ipv4_neigh_lookup_noref(). Of course, doing
> the check with atomic_read() is unsafe _really_, but once atomic_read() returned
> value tells us neigh refcnt is zero, the result is absolutely true. This is

	The problem is that this atomic_read is just an
extra code that works in rare cases. Modern CPUs have
128-byte cache lines and 'dead', 'refcnt' and 'next'
can be in same cache line. If you take into account the
write-back write policy used by CPU caches and the cache
locking effects, in most of the cases when such reader
finds entry in list, the refcnt will be > 0 and dead
will be 0. The reason: write-back policy makes the whole
cache line public to other CPUs at once. So, without
explicit barriers other CPUs can see data after delay and the
order of stores in same cache line is not observed.
As result, pure reader can not see 0 in refcnt, even if you
put more atomic_read calls at this place. atomic_read contains
only hints to compiler.

	So, we must ensure that if a writer decides to
remove entry other writers should not change things.
More observations for the writers:

- neigh_lookup is initially a reader bur it can increase refcnt
at any time, even while another CPU is under write_lock.
This makes all refcnt checks in neigh_forced_gc,
neigh_flush_dev and neigh_periodic_work racy because
neigh_cleanup_and_release is called after write_unlock.
If a writer decides to remove the entry, other write
operations may try to modify the entry because they
rely on their own reference. What can happen is that
refcnt is 1 when it is decided to remove the entry but
the refcnt can be increased by concurrent writers
such as neigh_lookup callers.

	As result, neigh_lookup followed by neigh_update may
work with dead=1 entry. May be the fix is to add
check for dead flag in neigh_update to avoid modifications
for removed entry, after the both write_lock_bh calls.
This again happens later, i.e. __neigh_lookup calls
neigh_lookup (which does not notice the dead flag early),
we miss to call neigh_create and then neigh_update will fail
on dead==1.

- neigh_timer_handler looks safe, may be it does not
need check for dead flag because if neigh_flush_dev calls
neigh_del_timer and del_timer in neigh_del_timer fails
with 0 (due to other CPU stuck at write_lock in
neigh_timer_handler) the 'if (!(state & NUD_IN_TIMER))'
check in neigh_timer_handler should succeed because
neigh_flush_dev will change nud_state on success of the
'if (atomic_read(&n->refcnt) != 1)' check.

- __neigh_event_send: needs check for dead flag, as
already discussed

Regards

--
Julian Anastasov <ja@ssi.bg>
