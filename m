From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCHSET v3] netfilter, cgroup: implement cgroup2 path match in xt_cgroup
Date: Sat, 21 Nov 2015 11:13:52 -0500
Message-ID: <1448122441-9335-1-git-send-email-tj@kernel.org>
Cc: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

This is v3 of the xt_cgroup2 patchset.  Changes from the last take are

* Folded cgroup2 path matching into xt_cgroup as a new revision rather
  than a separate xt_cgroup2 match as suggested by Pablo.

* Refreshed on top of Nina's net_cls dynamic config update fix patch.
  I included the fix patch as part of this series to ease reviewing.

The changes from v1 to v2 are

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

This patchset includes the following nine patches.

 0001-cgroup-record-ancestor-IDs-and-reimplement-cgroup_is.patch
 0002-kernfs-implement-kernfs_walk_and_get.patch
 0003-cgroup-implement-cgroup_get_from_path-and-expose-cgr.patch
 0004-cgroups-Allow-dynamically-changing-net_classid.patch
 0005-netprio_cgroup-limit-the-maximum-css-id-to-USHRT_MAX.patch
 0006-net-wrap-sock-sk_cgrp_prioidx-and-sk_classid-inside-.patch
 0007-sock-cgroup-add-sock-sk_cgroup.patch
 0008-netfilter-prepare-xt_cgroup-for-multi-revisions.patch
 0009-netfilter-implement-xt_cgroup-cgroup2-path-match.patch

0001-0003 are prepatory patches in kernfs and cgroup.  These patches
are available in the following branch which will stay stable.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-4.5-ancestor-test

0004 is the following net_cls config update fix patch included in this
series to ease reviewing as it causes a conflict with a later patch in
this series.

 http://lkml.kernel.org/g/1448051499-1885574-1-git-send-email-ninasc-b10kYP2dOMg@public.gmane.org

0005-0007 consolidate two cgroup related fields in struct sock into
cgroup_sock_data and update it so that it can alternatively carry a
cgroup pointer.

0008-0009 implement cgroup2 patch matching in xt_cgroup.

This patchset is on top of v4.4-rc1 and also available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-xt_cgroup2

I'll post iptables extension as a reply.  diffstat follows.  Thanks.

 fs/kernfs/dir.c                          |   46 +++++++++++
 include/linux/cgroup-defs.h              |  126 +++++++++++++++++++++++++++++++
 include/linux/cgroup.h                   |   66 +++++++++++++++-
 include/linux/kernfs.h                   |   12 ++
 include/net/cls_cgroup.h                 |   11 +-
 include/net/netprio_cgroup.h             |   16 +++
 include/net/sock.h                       |   13 ---
 include/uapi/linux/netfilter/xt_cgroup.h |   15 +++
 kernel/cgroup.c                          |  126 ++++++++++++++++++++++++-------
 net/Kconfig                              |    6 +
 net/core/dev.c                           |    3 
 net/core/netclassid_cgroup.c             |   37 ++++++---
 net/core/netprio_cgroup.c                |   19 ++++
 net/core/scm.c                           |    4 
 net/core/sock.c                          |   17 ----
 net/netfilter/nft_meta.c                 |    2 
 net/netfilter/xt_cgroup.c                |  108 ++++++++++++++++++++++----
 17 files changed, 531 insertions(+), 96 deletions(-)

--
tejun
