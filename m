From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET v2] netfilter, cgroup: implement xt_cgroup2 match
Date: Thu, 19 Nov 2015 13:52:44 -0500
Message-ID: <1447959171-20749-1-git-send-email-tj@kernel.org>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This is the second take of the xt_cgroup2 patchset.  Changes from the
last take are

* Instead of adding sock->sk_cgroup separately, sock->sk_cgrp_data now
  carries either (prioidx, classid) pair or cgroup2 pointer.  This
  avoids inflating struct sock with yet another cgroup related field.
  Unfortunately, this does add some complexity but that's the
  trade-off and the complexity is contained in cgroup proper.

* Various small updats as per David and Jan's reviews.

In cgroup v1, dealing with cgroup membership was difficult because the
number of membership associations was unbound.  As a result, cgroup v1
grew several controllers whose primary purpose is either tagging
membership or pull in configuration knobs from other subsystems so
that cgroup membership test can be avoided.

net_cls and net_prio controllers are examples of the latter.  They
allow configuring network-specific attributes from cgroup side so that
network subsystem can avoid testing cgroup membership; unfortunately,
these are not only cumbersome but also problematic.

Both net_cls and net_prio aren't properly hierarchical.  Both inherit
configuration from the parent on creation but there's no interaction
afterwards.  An ancestor doesn't restrict the behavior in its subtree
in anyway and configuration changes aren't propagated downwards.
Especially when combined with cgroup delegation, this is problematic
because delegatees can mess up whatever network configuration
implemented at the system level.  net_prio would allow the delegatees
to set whatever priority value regardless of CAP_NET_ADMIN and net_cls
the same for classid.

While it is possible to solve these issues from controller side by
implementing hierarchical allowable ranges in both controllers, it
would involve quite a bit of complexity in the controllers and further
obfuscate network configuration as it becomes even more difficult to
tell what's actually being configured looking from the network side.
While not much can be done for v1 at this point, as membership
handling is sane on cgroup v2, it'd be better to make cgroup matching
behave like other network matches and classifiers than introducing
further complications.

Unfortunately, this ends up adding another cgroup related field to
struct sock - sock->sk_cgroup.  I tried to think of a way to overload
the fields for net_cls and net_prio but couldn't come up with a sane
way to do that.  In the long term, it should be possible to disable
net_cls and net_prio.

This patchset includes the following five patches.

 0001-cgroup-record-ancestor-IDs-and-reimplement-cgroup_is.patch
 0002-kernfs-implement-kernfs_walk_and_get.patch
 0003-cgroup-implement-cgroup_get_from_path-and-expose-cgr.patch
 0004-netprio_cgroup-limit-the-maximum-css-id-to-USHRT_MAX.patch
 0005-net-wrap-sock-sk_cgrp_prioidx-and-sk_classid-inside-.patch
 0006-sock-cgroup-add-sock-sk_cgroup.patch
 0007-netfilter-implement-xt_cgroup2-match.patch

0001-0004 are prepatory patches in kernfs and cgroup.  0005-0006
consolidate two cgroup related fields in struct sock into
cgroup_sock_data and update it so that it can alternatively carry a
cgroup pointer.  0007 implements the new xt_cgroup2 match.

This patchset is on top of v4.4-rc1 and also available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-xt_cgroup2

I'll post iptables extension as a reply.  diffstat follows.  Thanks.

 fs/kernfs/dir.c                           |   46 ++++++++++
 include/linux/cgroup-defs.h               |  124 +++++++++++++++++++++++++++++
 include/linux/cgroup.h                    |   66 +++++++++++++++
 include/linux/kernfs.h                    |   12 ++
 include/net/cls_cgroup.h                  |   11 +-
 include/net/netprio_cgroup.h              |   16 +++
 include/net/sock.h                        |   13 ---
 include/uapi/linux/netfilter/xt_cgroup2.h |   15 +++
 kernel/cgroup.c                           |  126 +++++++++++++++++++++++-------
 net/Kconfig                               |    6 +
 net/core/dev.c                            |    3 
 net/core/netclassid_cgroup.c              |   10 +-
 net/core/netprio_cgroup.c                 |   19 ++++
 net/core/scm.c                            |    4 
 net/core/sock.c                           |   17 ----
 net/netfilter/Kconfig                     |   10 ++
 net/netfilter/Makefile                    |    1 
 net/netfilter/nft_meta.c                  |    2 
 net/netfilter/xt_cgroup.c                 |    3 
 net/netfilter/xt_cgroup2.c                |   78 ++++++++++++++++++
 20 files changed, 512 insertions(+), 70 deletions(-)

--
tejun
