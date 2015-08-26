From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 0/5] act_bpf: remove spinlock in fast path
Date: Tue, 25 Aug 2015 20:06:30 -0700
Message-ID: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36590 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbbHZDGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 23:06:43 -0400
Received: by pacgr6 with SMTP id gr6so11352964pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 20:06:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 version had a race condition in cleanup path of bpf_prog.
I tried to fix it by adding new callback 'cleanup_rcu' to 'struct tcf_common'
and call it out of act_api cleanup path, but Daniel noticed
(thanks for the idea!) that most of the classifiers already do action cleanup
out of rcu callback.
So instead this set of patches converts tcindex and rsvp classifiers to call
tcf_exts_destroy() after rcu grace period and since action cleanup logic
in __tcf_hash_release() is only called when bind and refcnt goes to zero,
it's guaranteed that cleanup() callback is called from rcu callback.
More specifically:
patches 1 and 2 - simple fixes
patches 2 and 3 - convert tcf_exts_destroy in tcindex and rsvp to call_rcu
patch 5 - removes spin_lock from act_bpf

The cleanup of actions is now universally done after rcu grace period
and in the future we can drop (now unnecessary) call_rcu from tcf_hash_destroy()
patch 5 is using synchronize_rcu() in act_bpf replacement path, since it's
very rare and alternative of dynamically allocating 'struct tcf_bpf_cfg' just
to pass it to call_rcu looks even less appealing.

Alexei Starovoitov (5):
  net_sched: make tcf_hash_destroy() static
  net_sched: act_bpf: remove unnecessary copy
  net_sched: convert tcindex to call tcf_exts_destroy from rcu callback
  net_sched: convert rsvp to call tcf_exts_destroy from rcu callback
  net_sched: act_bpf: remove spinlock in fast path

 include/net/act_api.h       |    1 -
 include/net/tc_act/tc_bpf.h |    2 +-
 net/sched/act_api.c         |    3 +--
 net/sched/act_bpf.c         |   38 ++++++++++++++++++++------------------
 net/sched/cls_rsvp.h        |   18 ++++++++++++++----
 net/sched/cls_tcindex.c     |   29 +++++++++++++++++++++++++----
 6 files changed, 61 insertions(+), 30 deletions(-)

-- 
1.7.9.5
