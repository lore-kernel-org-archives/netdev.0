From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v3 00/39] faster tree-based sysctl implementation
Date: Mon, 23 May 2011 04:56:11 +0300
Message-ID: <BANLkTim7xn8tM4wTyd_m_nwUQg_CUTapeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>
To: "Eric W . Biederman" <ebiederm@xmission.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62139 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096Ab1EWB4b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:56:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This is version 3 of a patch series that introduces a faster/leaner
sysctl internal implementation.

Due to high number of patches and low general interest I'll just point
you to the tree/branch:

  git://github.com/luciang/linux-2.6-new-sysctl.git   v3-new-sysctl-alg


Patches are on top of v2.6.39. I did not pick a more recent (random)
point in Linus' tree to rebase these onto to not mess up testing.



Changes since v2
(http://thread.gmane.org/gmane.linux.kernel/1137032/focus=3D194748):
- added a compatibility layer to support old registering complex
  sysctl trees. This layer will be deleted once all users of the old
  are changed.
- subdirectories and netns correspondent dirs are now held in rbtrees
- split of from the patches that make changes in the rest of the tree
- rebased on top of 2.6.39




Changes since v1 (http://thread.gmane.org/gmane.linux.kernel/1133667):
- rebased on top of 2.6.39-rc6
- split the patch that adds the new algorithm and data structures.
- fixed a few bugs lingering in the old code
- shrinked a reference counter
- added a new reference counter to maintain ownership information
- added method to register an empty sysctl dir and converted some users
- added checks enforcing the rule that a non-netns specific directory m=
ay
 not be registered after a netns specific one has already been register=
ed.
- added cookie support: register a piece of data with the header to be
 used to make simple conversions on the ctl_table. This saves memory wh=
ere
 we need to register sysctl tables with the same content affecting
 different pieces of data.
- enforced sysctl checks



$ time modprobe dummy numdummies=3DN


NOTE: these stats are from v2. v3 should be a bit slower due to:
- the compatibility layer
- the old stats used cookies to prevent kmemdups() on ctl_table arrays
- the old patches had an optimisation for directories with many
subdirs that was replaced (in v3) with rbtrees

Without this patch series :(
- ipv4 only
 -  N=3D1000  time=3D 0m 06s
 -  N=3D2000  time=3D 0m 30s
 -  N=3D4000  time=3D 2m 35s
- ipv4 and ipv6
 -  N=3D1000  time=3D 0m 24s
 -  N=3D2000  time=3D 2m 14s
 -  N=3D4000  time=3D10m 16s
 -  N=3D5000  time=3D16m  3s

With this patch series    :)
- ipv4 only
 -  N=3D1000  time=3D 0m  0.33s
 -  N=3D2000  time=3D 0m  1.25s
 -  N=3D4000  time=3D 0m  5.31s
- ipv4 and ipv6
 -  N=3D1000  time=3D 0m  0.41s
 -  N=3D2000  time=3D 0m  1.62s
 -  N=3D4000  time=3D 0m  7.64s
 -  N=3D5000  time=3D 0m 12.35s
 -  N=3D8000  time=3D 0m 36.95s




Patches marked with RFC: are patches where reviewers should pay more
attention as I may have missed something.


Part 1: introduce compatibility layer:
  sysctl: introduce temporary sysctl wrappers
  sysctl: register only tables of sysctl files


Part 2: minimal changes to sysctl users:
  sysctl: call sysctl_init before the first sysctl registration
  sysctl: no-child: manually register kernel/random
  sysctl: no-child: manually register kernel/keys
  sysctl: no-child: manually register fs/inotify
  sysctl: no-child: manually register fs/epoll
  sysctl: no-child: manually register root tables


Part 3: cleanups simplifying the new algorithm (created when asked to
break up the new algorithm patch:
  sysctl: faster reimplementation of sysctl_check_table
  sysctl: remove useless ctl_table->parent field
  sysctl: simplify find_in_table
  sysctl: sysctl_head_grab defaults to root header on NULL
  sysctl: delete useless grab_header function
  sysctl: rename ->used to ->ctl_use_refs
  sysctl: rename sysctl_head_grab/finish to sysctl_use_header/unuse
  sysctl: rename sysctl_head_next to sysctl_use_next_header
  sysctl: split ->count into ctl_procfs_refs and ctl_header_refs
  sysctl: rename sysctl_head_get/put to sysctl_proc_inode_get/put
  sysctl: rename (un)use_table to __sysctl_(un)use_header
  sysctl: simplify ->permissions hook
  sysctl: group root-specific operations
  sysctl: introduce ctl_table_group
  sysctl: move removal from list out of start_unregistering


Part 4: new algorithm/data structures:
  sysctl: faster tree-based sysctl implementation


Part 5: checks/warns requested during review:
  sysctl: add duplicate entry and sanity ctl_table checks
  sysctl: alloc ctl_table_header with kmem_cache
  RFC: sysctl: change type of ctl_procfs_refs to u8
  sysctl: check netns-specific registration order respected
  sysctl: warn if registration/unregistration order is not respected
  RFC: sysctl: always perform sysctl checks


Part 6: Eric requested rbtrees for subdirs. I also used rbtrees for
netns correspondent dirs. Hope that adding rbtrees after using the old
list-based implementation is good enough. The rbtree code complicates
things a bit and would uglify the patch adding the new algorithm.
  sysctl: reorder members of ctl_table_header (cleanup)
  sysctl: add ctl_type member
  RFC: sysctl: replace subdirectory list with rbtree
  RFC: sysctl: replace netns corresp list with rbtree
  sysctl: union-ize some ctl_table_header fields


Part 7: Eric requested ability to register an empty dir:
  sysctl: add register_sysctl_dir: register an empty sysctl directory


Part 8: unrequested feature I'd like to piggy back :)
  sysctl: add ctl_cookie and ctl_cookie_handler
  sysctl: add cookie to __register_sysctl_paths
  sysctl: add register_net_sysctl_table_net_cookie


 drivers/char/random.c            |   27 +-
 fs/eventpoll.c                   |   22 +-
 fs/notify/inotify/inotify_user.c |   22 +-
 fs/proc/inode.c                  |    2 +-
 fs/proc/proc_sysctl.c            |  233 +++++---
 include/linux/inotify.h          |    2 -
 include/linux/key.h              |    3 -
 include/linux/poll.h             |    2 -
 include/linux/sysctl.h           |  221 +++++---
 include/net/net_namespace.h      |    4 +-
 init/main.c                      |    1 +
 kernel/Makefile                  |    5 +-
 kernel/sysctl.c                  | 1161 ++++++++++++++++++++++++++++--=
--------
 kernel/sysctl_check.c            |  325 +++++++----
 lib/Kconfig.debug                |    8 -
 net/sysctl_net.c                 |   86 ++--
 security/keys/key.c              |    7 +
 security/keys/sysctl.c           |   18 +-
 18 files changed, 1495 insertions(+), 654 deletions(-)


--=20
=C2=A0.
=2E.: Lucian
