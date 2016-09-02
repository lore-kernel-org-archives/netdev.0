From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 0/6] net_sched: really switch to RCU for tc actions
Date: Thu,  1 Sep 2016 22:57:14 -0700
Message-ID: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35790 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751734AbcIBF5q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:57:46 -0400
Received: by mail-pa0-f66.google.com with SMTP id cf3so5134346pad.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 22:57:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there are only two tc actions lockless:
gact and mirred. But they are questionable because
we don't have anything to prevent a parallel update
on an existing tc action in hash table while reading
it on fast path, this could be a problem when a tc
action becomes complex.

This patchset introduces a few new tc action API's
based on RCU so that the fast path could now really
be protected by RCU and we can update existing tc
actions safely and race-freely.

Obviously this is still _not_ complete yet, I only
modified mirred action to show the use case of
the new API's, all the rest actions could switch to
the new API's too. The new API's are a bit ugly too,
any suggestion to improve them is welcome.

I tested mirred action with a few test cases, so far
so good, at least no obvious bugs. ;)


Cong Wang (6):
  net_sched: use RCU for action hash table
  net_sched: introduce tcf_hash_replace()
  net_sched: return NULL in tcf_hash_check()
  net_sched: introduce tcf_hash_copy()
  net_sched: use rcu in fast path
  net_sched: switch to RCU API for act_mirred

 include/net/act_api.h  |  3 +++
 net/sched/act_api.c    | 59 +++++++++++++++++++++++++++++++++++++++++++-------
 net/sched/act_mirred.c | 41 ++++++++++++++++-------------------
 3 files changed, 73 insertions(+), 30 deletions(-)

-- 
2.1.0
