From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 00/24] v1: sysctl header cookies + private children
Date: Sat,  2 Apr 2011 04:53:14 +0200
Message-ID: <cover.1301711868.git.lucian.grijincu__16447.8804720149$1301713291$gmane$org@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32917 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207Ab1DBCxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:53:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

The first patches in this series add a 'cookie' to the struct
ctl_table_header.  This cookie is used to store some data and is
passed to proc_handlers. The 'cookie' part series has already been
posted on netdev/lkml, but it was dropped because sysctl has a bigger
problem: an inefficient algorithm to add new tables.


This is where part two comes along: private ctl_table_header nodes.
Not all sysctl headers are the same: while some of them are at a high
level and have lots of other headers attached to them, most other
headers are children of another header and will never have a child
attached to them. With this in mind, we designate some of these
headers to be 'private children' (I don't really like this terminology
- I'm open to suggestions) of another header.

Performance suffers because every header is consulted:
- when we add a new header (to attach the new header somewhere)
- when lookup failed in a table: we consult every other header to see
  whether it was attached to this table.


Neither of these actions are performed for private children. With more
header registered as private, the number of headers consulted in these
steps lowers and performance is better.

Adding nodes for:
- /proc/sys/net/ipv4/conf/DEVNAME
- /proc/sys/net/ipv6/conf/DEVNAME
- /proc/sys/net/ipv4/neigh/DEVNAME
- /proc/sys/net/ipv6/neigh/DEVNAME
as private children has this effect:


$ time modprobe dummy numdummies=$n

Without these patches:
 - n=5000 => 17:31 minutes
 - n=2000 =>  2:23 minutes
 - n=1000 =>  0:25 minutes

With these patches:
 - n=5000 =>  12.50 seconds
 - n=2000 =>   1.59 seconds
 - n=1000 =>   0.44 seconds


I'll follow up with another series adding the cookie in a few more
places and removing some fields in ctl_table, but I'd like some
feedback for these patches.


Patches are against 2.6.39-rc1.

Lucian Adrian Grijincu (24):
  sysctl: net: call unregister_net_sysctl_table where needed
  sysctl: cookie: add ctl_header_cookie
  sysctl: cookie: pass ctl_header_cookie to proc_handler
  sysctl: cookie: add netns_proc_dointvec and other netns_proc_*
    proc_handlers
  sysctl: cookie: share ip4_frags_ns_ctl_table between nets
  sysctl: cookie: share netns_core_table between nets
  sysctl: cookie: share ipv4_route_flush_table between nets
  sysctl: cookie: share ipv4_net_table between nets
  sysctl: cookie: share ip6_frags_ns_ctl_table between nets
  sysctl: cookie: share ip6_ctl_table, ipv6_icmp_table and
    ipv6_route_table between nets
  sysctl: cookie: share acct_sysctl_table table between nets
  sysctl: cookie: share event_sysctl_table between nets
  sysctl: cookie: share nf_ct_sysctl_table between nets
  sysctl: cookie: share unix_table between nets
  sysctl: cookie: share xfrm_table between nets
  sysctl: add support for private_children headers
  sysctl: add register_net_sysctl_table_with_parent
  sysctl: ipv4: register /proc/sys/net/ipv4/conf empty directory
  sysctl: ipv4: register devinet tables as private children
  sysctl: ipv6: register /proc/sys/net/ipv6/conf empty directory
  sysctl: ipv6: register addrconf tables as private children
  sysctl: ipv4: register /proc/sys/net/ipv4/neigh empty directory
  sysctl: ipv6: register /proc/sys/net/ipv6/neigh empty directory
  sysctl: neigh: ipv4 and ipv6 neigh tables as private children

 arch/frv/kernel/pm.c                    |   22 ++--
 arch/frv/kernel/sysctl.c                |    4 +-
 arch/mips/lasat/sysctl.c                |   28 +++---
 arch/s390/appldata/appldata_base.c      |   15 ++--
 arch/s390/kernel/debug.c                |    6 +-
 arch/s390/mm/cmm.c                      |    4 +-
 drivers/cdrom/cdrom.c                   |   12 +-
 drivers/char/random.c                   |    6 +-
 drivers/macintosh/mac_hid.c             |    4 +-
 drivers/parport/procfs.c                |   29 +++---
 drivers/s390/char/sclp_async.c          |    2 +-
 fs/dcache.c                             |    4 +-
 fs/drop_caches.c                        |    5 +-
 fs/file_table.c                         |   10 +-
 fs/fscache/main.c                       |    6 +-
 fs/inode.c                              |    6 +-
 fs/pipe.c                               |    4 +-
 fs/proc/proc_sysctl.c                   |   24 ++++-
 fs/quota/dquot.c                        |    5 +-
 fs/xfs/linux-2.6/xfs_sysctl.c           |   10 +-
 include/linux/compaction.h              |    6 +-
 include/linux/fs.h                      |   12 +-
 include/linux/ftrace.h                  |    4 +-
 include/linux/hugetlb.h                 |   13 ++-
 include/linux/kprobes.h                 |    6 +-
 include/linux/mm.h                      |    4 +-
 include/linux/mmzone.h                  |   23 ++--
 include/linux/nmi.h                     |    4 +-
 include/linux/perf_event.h              |    2 +-
 include/linux/pipe_fs_i.h               |    2 +-
 include/linux/sched.h                   |   16 ++--
 include/linux/security.h                |    3 +-
 include/linux/swap.h                    |    4 +-
 include/linux/sysctl.h                  |   45 ++++++--
 include/linux/writeback.h               |   18 +--
 include/net/ipv6.h                      |    8 +-
 include/net/ndisc.h                     |    7 +-
 include/net/neighbour.h                 |    9 +-
 include/net/net_namespace.h             |   36 +++++++
 include/net/netns/ipv4.h                |   10 +-
 include/net/netns/ipv6.h                |    4 +-
 ipc/ipc_sysctl.c                        |   21 ++--
 ipc/mq_sysctl.c                         |   11 +-
 kernel/hung_task.c                      |    6 +-
 kernel/kprobes.c                        |    4 +-
 kernel/perf_event.c                     |    4 +-
 kernel/sched.c                          |    4 +-
 kernel/sched_fair.c                     |    4 +-
 kernel/sysctl.c                         |  171 +++++++++++++++++++++++--------
 kernel/trace/ftrace.c                   |    4 +-
 kernel/trace/trace_stack.c              |    4 +-
 kernel/utsname_sysctl.c                 |    6 +-
 kernel/watchdog.c                       |   11 +-
 mm/compaction.c                         |    8 +-
 mm/hugetlb.c                            |   24 +++--
 mm/page-writeback.c                     |   24 ++---
 mm/page_alloc.c                         |   25 ++---
 mm/vmscan.c                             |    6 +-
 net/bridge/br_netfilter.c               |    6 +-
 net/core/neighbour.c                    |    6 +-
 net/core/sysctl_net_core.c              |   33 +-----
 net/decnet/dn_dev.c                     |   10 +-
 net/decnet/sysctl_net_decnet.c          |    8 +-
 net/ipv4/arp.c                          |   71 ++++++++++++-
 net/ipv4/devinet.c                      |   52 +++++++---
 net/ipv4/ip_fragment.c                  |   34 +-----
 net/ipv4/route.c                        |   49 +++-------
 net/ipv4/sysctl_net_ipv4.c              |   78 ++++----------
 net/ipv6/addrconf.c                     |   50 +++++++--
 net/ipv6/af_inet6.c                     |   12 --
 net/ipv6/icmp.c                         |   17 +---
 net/ipv6/ndisc.c                        |   91 ++++++++++++----
 net/ipv6/reassembly.c                   |   34 +-----
 net/ipv6/route.c                        |   60 +++--------
 net/ipv6/sysctl_net_ipv6.c              |   88 ++--------------
 net/irda/irsysctl.c                     |   12 +-
 net/netfilter/ipvs/ip_vs_ctl.c          |   12 +-
 net/netfilter/nf_conntrack_acct.c       |   24 +----
 net/netfilter/nf_conntrack_ecache.c     |   30 +-----
 net/netfilter/nf_conntrack_standalone.c |   30 +-----
 net/netfilter/nf_log.c                  |    5 +-
 net/phonet/sysctl.c                     |    6 +-
 net/sunrpc/sysctl.c                     |    9 +-
 net/sunrpc/xprtrdma/svc_rdma.c          |    2 +-
 net/sysctl_net.c                        |   46 ++++++++-
 net/unix/sysctl_net_unix.c              |   22 +----
 net/xfrm/xfrm_sysctl.c                  |   37 ++-----
 security/min_addr.c                     |    5 +-
 88 files changed, 879 insertions(+), 839 deletions(-)

-- 
1.7.5.rc0

