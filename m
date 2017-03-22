From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4.11] cgroup, net_cls: iterate the fds of only the
 tasks which are being migrated
Date: Wed, 22 Mar 2017 10:33:28 -0700 (PDT)
Message-ID: <20170322.103328.2258083179184839596.davem@davemloft.net>
References: <20170314232556.GE15132@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org,
        kernel-team@fb.com, ninasc@fb.com, dgoode@fb.com
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314232556.GE15132@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Tue, 14 Mar 2017 19:25:56 -0400

> The net_cls controller controls the classid field of each socket which
> is associated with the cgroup.  Because the classid is per-socket
> attribute, when a task migrates to another cgroup or the configured
> classid of the cgroup changes, the controller needs to walk all
> sockets and update the classid value, which was implemented by
> 3b13758f51de ("cgroups: Allow dynamically changing net_classid").
> 
> While the approach is not scalable, migrating tasks which have a lot
> of fds attached to them is rare and the cost is born by the ones
> initiating the operations.  However, for simplicity, both the
> migration and classid config change paths call update_classid() which
> scans all fds of all tasks in the target css.  This is an overkill for
> the migration path which only needs to cover a much smaller subset of
> tasks which are actually getting migrated in.
> 
> On cgroup v1, this can lead to unexpected scalability issues when one
> tries to migrate a task or process into a net_cls cgroup which already
> contains a lot of fds.  Even if the migration traget doesn't have many
> to get scanned, update_classid() ends up scanning all fds in the
> target cgroup which can be extremely numerous.
> 
> Unfortunately, on cgroup v2 which doesn't use net_cls, the problem is
> even worse.  Before bfc2cf6f61fc ("cgroup: call subsys->*attach() only
> for subsystems which are actually affected by migration"), cgroup core
> would call the ->css_attach callback even for controllers which don't
> see actual migration to a different css.
> 
> As net_cls is always disabled but still mounted on cgroup v2, whenever
> a process is migrated on the cgroup v2 hierarchy, net_cls sees
> identity migration from root to root and cgroup core used to call
> ->css_attach callback for those.  The net_cls ->css_attach ends up
> calling update_classid() on the root net_cls css to which all
> processes on the system belong to as the controller isn't used.  This
> makes any cgroup v2 migration O(total_number_of_fds_on_the_system)
> which is horrible and easily leads to noticeable stalls triggering RCU
> stall warnings and so on.
> 
> The worst symptom is already fixed in upstream by bfc2cf6f61fc
> ("cgroup: call subsys->*attach() only for subsystems which are
> actually affected by migration"); however, backporting that commit is
> too invasive and we want to avoid other cases too.
> 
> This patch updates net_cls's cgrp_attach() to iterate fds of only the
> processes which are actually getting migrated.  This removes the
> surprising migration cost which is dependent on the total number of
> fds in the target cgroup.  As this leaves write_classid() the only
> user of update_classid(), open-code the helper into write_classid().
> 
> Reported-by: David Goode <dgoode@fb.com>
> Fixes: 3b13758f51de ("cgroups: Allow dynamically changing net_classid")
> Cc: stable@vger.kernel.org # v4.4+
> Cc: Nina Schiff <ninasc@fb.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Tejun Heo <tj@kernel.org>

Applied, thanks.
