From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 000/115] faster tree-based sysctl implementation
Date: Mon,  9 May 2011 00:38:12 +0200
Message-ID: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series introduces a faster/leaner sysctl internal implementation:

$ time modprobe dummy numdummies=N

Without this patch series :(
- ipv4 only
  -  N=1000  time= 0m 06s
  -  N=2000  time= 0m 30s
  -  N=4000  time= 2m 35s
- ipv4 and ipv6
  -  N=1000  time= 0m 24s
  -  N=2000  time= 2m 14s
  -  N=4000  time=10m 16s
  -  N=5000  time=16m  3s

With this patch series    :)
- ipv4 only
  -  N=1000  time= 0m  0.33s
  -  N=2000  time= 0m  1.25s
  -  N=4000  time= 0m  5.31s
- ipv4 and ipv6
  -  N=1000  time= 0m  0.41s
  -  N=2000  time= 0m  1.62s
  -  N=4000  time= 0m  7.64s
  -  N=5000  time= 0m 12.35s
  -  N=8000  time= 0m 36.95s


Since v1 (http://thread.gmane.org/gmane.linux.kernel/1133667):
- rebased on top of 2.6.39-rc6
- split the patch that adds the new algorithm and data structures.
- fixed a few bugs lingering in the old code
- shrinked a reference counter
- added a new reference counter to maintain ownership information
- added method to register an empty sysctl dir and converted some users
- added checks enforcing the rule that a non-netns specific directory may
  not be registered after a netns specific one has already been registered.
- added cookie support: register a piece of data with the header to be
  used to make simple conversions on the ctl_table. This saves memory where
  we need to register sysctl tables with the same content affecting
  different pieces of data.
- enforced sysctl checks


Eric also asked for:
- registration based on strings, not the ctl_path version
  -- I did not add this at the moment because of lack of time and,
     if needed, this can be added any time later. The patch series
     is long enogh.

- replacing the per-header list of subdirs with a rbtree.
  -- Again, lack of time, and this can always be added at a later time
     to optimize lookup and duplicate checks. At the moment this patch
     series does not add a complexity regression over the previous
     implementation, au contraire.


For anyone interested in testing these patches check them out from:

  web:   https://github.com/luciang/linux-2.6-new-sysctl
  git:   git://github.com/luciang/linux-2.6-new-sysctl.git


Cc: "Eric W . Biederman" <ebiederm@xmission.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Octavian Purdila <tavi@cs.pub.ro>
Cc: "David S . Miller" <davem@davemloft.net>

Lucian Adrian Grijincu (115):
  sysctl: remove .child from dev/parport/default
  sysctl: parport: reorder .child assignments to simplify review
  sysctl: remove .child from dev/parport/PORT/devices/DEVICE
  sysctl: remove .child from dev/parport/PORT/
  sysctl: remove .child from dev/parport/PORT/devices/
  sysctl: remove .child from kernel/vsyscall64 (x86)
  sysctl: remove .child from abi/vsyscall32 (x86)
  sysctl: remove .child from crypto/fips_enabled
  sysctl: remove .child from dev/cdrom/
  sysctl: remove .child from dev/hpet/
  sysctl: remove .child from dev/ipmi/
  sysctl: remove .child from dev/rtc/
  sysctl: remove .child from dev/mac_hid/
  sysctl: remove .child from dev/raid/
  sysctl: remove .child from xpc/
  sysctl: remove .child from xpc/hb
  sysctl: remove .child from kernel/sclp (s390)
  sysctl: remove .child from dev/scsi
  sysctl: remove .child from kernel/pty
  sysctl: remove .child from coda/
  sysctl: remove .child from fscache/
  sysctl: remove .child from fs/nfs/ nlm_table table
  sysctl: remove .child from fs/nfs/ nfs_cb_table
  sysctl: remove .child from fs/ntfs-debug
  sysctl: remove .child from fs/ocfs2/nm/
  sysctl: remove .child from fs/quota/
  sysctl: remove .child from fs/xfs/
  sysctl: remove .child from kernel/ (ipc)
  sysctl: remove .child from fs/mqueue
  sysctl: sched: add sd_table_template
  sysctl: remove .child from kernel/sched_domain/cpuX/domainY/
  sysctl: remove .child from kernel/ (utsname)
  sysctl: remove .child from sunrpc/
  sysctl: remove .child from sunrpc/svc_rdma
  sysctl: remove .child from sunrpc/ (xprtrdma)
  sysctl: remove .child from sunrpc/ (xprtsock)
  sysctl: remove .child from bus/isa/ (arm)
  sysctl: remove .child from reboot/warm (arm)
  sysctl: remove .child from lasat/ (mips)
  sysctl: remove .child from appldata/ (s390)
  sysctl: remove .child from s390dbf/
  sysctl: remove .child from vm/ (s390)
  sysctl: remove .child from kernel/perfmon/ (ia64)
  sysctl: remove .child from kernel/ (ia64/kdump)
  sysctl: remove .child from kernel/powersave-nap (powerpc)
  sysctl: remove .child from pm/ (frv)
  sysctl: remove .child from frv/
  sysctl: remove .child from sh64/unaligned_fixup/
  sysctl: delete unused register_sysctl_table function
  sysctl: remove .child from ax25 table
  sysctl: remove .child from net/ipv4/route and net/ipv4/neigh tables
  sysctl: remove .child from net/ipv4/neigh table
  sysctl: remove .child from net/ipv6/route, net/ipv6/icmp, net/ipv6
    tables
  sysctl: remove .child from net/llc tables
  sysctl: call sysctl_init before the first sysctl registration
  sysctl: no-child: manually register kernel/random
  sysctl: no-child: manually register kernel/keys
  sysctl: no-child: manually register fs/inotify
  sysctl: no-child: manually register fs/epoll
  sysctl: no-child: manually register root tables
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
  sysctl: faster tree-based sysctl implementation
  sysctl: add duplicate entry and sanity ctl_table checks
  sysctl: alloc ctl_table_header with kmem_cache
  sysctl: single subheader path: optimisation for paths used only once
  sysctl: single subheader path: net/ipv4/conf/DEVICE-NAME/
  sysctl: single subheader path: net/{ipv4|ipv6}/neigh/DEV/
  sysctl: single subheader path: net/ipv6/conf/DEVICE-NAME/
  sysctl: single subheader path: dev/parport/PORT/devices/DEVICE/
  sysctl: single subheader path: net/ax25/DEVICE
  sysctl: single subheader path: kernel/sched_domain/CPU/DOMAIN/
  sysctl: single subheader path: net/decnet/conf/DEVNAME
  sysctl: check netns-specific registration order respected
  RFC: sysctl: convert read-write lock to RCU
  RFC: sysctl: change type of ctl_procfs_refs to u8
  sysctl: warn if registration/unregistration order is not respected
  sysctl: add register_sysctl_dir: register an empty sysctl directory
  sysctl: sched: create empty dir with register_sysctl_dir
  sysctl: ax25: create empty dir with register_sysctl_dir
  sysctl: net/core: create empty dir with register_sysctl_dir
  sysctl: net/ipv4/neigh: create empty dir with register_sysctl_dir
  sysctl: net/ipv6/neigh: create empty dir with register_sysctl_dir
  sysctl: add ctl_cookie
  sysctl: add cookie to __register_sysctl_paths
  sysctl: add register_net_sysctl_table_net_cookie
  sysctl: cookie: share ip4_frags_ns_ctl_table between nets
  sysctl: cookie: share netns_core_table between nets
  sysctl: cookie: share ipv4_net_table between nets
  sysctl: cookie: share ip6_frags_ns_ctl_table between nets
  sysctl: cookie: share ipv6_route_table/ipv6_icmp_table between nets
  sysctl: cookie: share ipv6_bindv6only_table between nets
  sysctl: cookie: share acct_sysctl_table table between nets
  sysctl: cookie: share event_sysctl_table between nets
  net: split nf_ct_sysctl_table
  sysctl: cookie: share nf_ct_sysctl_table between nets
  sysctl: cookie: share unix_table between nets
  sysctl: cookie: share xfrm_table between nets
  sysctl: cookie: add register_net_sysctl_table_custom_cookie
  sysctl: cookie: share devinet tables between network devices
  sysctl: cookie: share addrconf tables between network devices
  RFC: sysctl: always perform sysctl checks

 arch/arm/kernel/isa.c                   |   31 +-
 arch/arm/mach-bcmring/arch.c            |   25 +-
 arch/frv/kernel/pm.c                    |   10 +-
 arch/frv/kernel/sysctl.c                |   12 +-
 arch/ia64/kernel/crash.c                |   13 +-
 arch/ia64/kernel/perfmon.c              |   23 +-
 arch/mips/lasat/sysctl.c                |   13 +-
 arch/powerpc/kernel/idle.c              |   13 +-
 arch/s390/appldata/appldata_base.c      |   42 +-
 arch/s390/kernel/debug.c                |   13 +-
 arch/s390/mm/cmm.c                      |   11 +-
 arch/sh/kernel/traps_64.c               |   21 +-
 arch/x86/kernel/vsyscall_64.c           |   25 +-
 arch/x86/vdso/vdso32-setup.c            |   14 +-
 crypto/proc.c                           |   12 +-
 drivers/cdrom/cdrom.c                   |   22 +-
 drivers/char/hpet.c                     |   38 +-
 drivers/char/ipmi/ipmi_poweroff.c       |   16 +-
 drivers/char/random.c                   |   27 +-
 drivers/char/rtc.c                      |   24 +-
 drivers/macintosh/mac_hid.c             |   26 +-
 drivers/md/md.c                         |   22 +-
 drivers/misc/sgi-xp/xpc_main.c          |   81 ++--
 drivers/parport/procfs.c                |  231 ++++-----
 drivers/s390/char/sclp_async.c          |   13 +-
 drivers/scsi/scsi_sysctl.c              |   28 +-
 drivers/tty/pty.c                       |   23 +-
 fs/coda/sysctl.c                        |   12 +-
 fs/eventpoll.c                          |   22 +-
 fs/fscache/main.c                       |   15 +-
 fs/lockd/svc.c                          |   22 +-
 fs/nfs/sysctl.c                         |   22 +-
 fs/notify/inotify/inotify_user.c        |   22 +-
 fs/ntfs/sysctl.c                        |   15 +-
 fs/ocfs2/stackglue.c                    |   36 +-
 fs/proc/inode.c                         |    2 +-
 fs/proc/proc_sysctl.c                   |  217 +++++---
 fs/quota/dquot.c                        |   21 +-
 fs/xfs/linux-2.6/xfs_sysctl.c           |   22 +-
 include/linux/inetdevice.h              |    6 +-
 include/linux/inotify.h                 |    2 -
 include/linux/ipv6.h                    |    6 +-
 include/linux/key.h                     |    4 +-
 include/linux/poll.h                    |    2 -
 include/linux/sysctl.h                  |  227 ++++++---
 include/net/ax25.h                      |   10 +-
 include/net/ipv6.h                      |    8 +-
 include/net/net_namespace.h             |    7 +-
 include/net/netns/conntrack.h           |    1 +
 include/net/netns/ipv6.h                |    4 +-
 init/main.c                             |    1 +
 ipc/ipc_sysctl.c                        |   12 +-
 ipc/mq_sysctl.c                         |   24 +-
 kernel/Makefile                         |    5 +-
 kernel/sched.c                          |  389 +++++++++----
 kernel/sysctl.c                         |  920 ++++++++++++++++++++-----------
 kernel/sysctl_check.c                   |  322 +++++++-----
 kernel/utsname_sysctl.c                 |   14 +-
 lib/Kconfig.debug                       |    8 -
 net/ax25/af_ax25.c                      |   22 +-
 net/ax25/ax25_dev.c                     |   10 +-
 net/ax25/sysctl_net_ax25.c              |   82 +--
 net/core/neighbour.c                    |    8 +-
 net/core/sysctl_net_core.c              |   33 +-
 net/decnet/dn_dev.c                     |    8 +-
 net/ipv4/devinet.c                      |  154 +++---
 net/ipv4/ip_fragment.c                  |   28 +-
 net/ipv4/route.c                        |   17 +-
 net/ipv4/sysctl_net_ipv4.c              |   40 +--
 net/ipv6/addrconf.c                     |  506 +++++++++---------
 net/ipv6/icmp.c                         |   18 +-
 net/ipv6/reassembly.c                   |   34 +-
 net/ipv6/route.c                        |   36 +-
 net/ipv6/sysctl_net_ipv6.c              |  118 ++---
 net/llc/sysctl_net_llc.c                |   55 +-
 net/netfilter/nf_conntrack_acct.c       |   24 +-
 net/netfilter/nf_conntrack_ecache.c     |   26 +-
 net/netfilter/nf_conntrack_standalone.c |   52 +-
 net/sunrpc/sysctl.c                     |   19 +-
 net/sunrpc/xprtrdma/svc_rdma.c          |   26 +-
 net/sunrpc/xprtrdma/transport.c         |   14 +-
 net/sunrpc/xprtsock.c                   |   16 +-
 net/sysctl_net.c                        |   95 ++--
 net/unix/sysctl_net_unix.c              |   23 +-
 net/xfrm/xfrm_sysctl.c                  |   29 +-
 security/keys/key.c                     |    1 +
 security/keys/sysctl.c                  |   18 +-
 87 files changed, 2436 insertions(+), 2305 deletions(-)

-- 
1.7.5.134.g1c08b
