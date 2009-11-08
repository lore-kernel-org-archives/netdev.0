From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 00/23] Removal of binary sysctl support
Date: Sun, 08 Nov 2009 04:15:26 -0800
Message-ID: <m1639ljjq9.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753869AbZKHMP2@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patchset reimplements sys_sysctl as a compatibility wrapper
around /proc/sys.  After which it removes all of the code to all over
the kernel that is used today to implement the binary sysctls.

I am posting this patchset to give everyone a heads up what is in
flight.

I intend to carry all of these patches in my sysctl tree.

If you add new sysctls to other trees please don't set the .ctl_name
or .strategy fields in struct ctl_table, as setting those fields
is unnecessary now and are removed by this patchset.

Last I looked at linux-next is only one new sysctl that is not in
Linus's tree under net/ipv6.  David I will send you a patch in a
bit to remove the unnecessary .ctl_name = CTL_UNNUMBERED line so
that linux-next continues to compile when my tree makes it there.

For your amusement the diffstat of this whole set of changes:

 arch/arm/kernel/isa.c                          |   11 +-
 arch/arm/mach-bcmring/arch.c                   |    6 -
 arch/frv/kernel/pm.c                           |  106 +--
 arch/frv/kernel/sysctl.c                       |    3 -
 arch/ia64/kernel/crash.c                       |    7 +-
 arch/ia64/kernel/perfmon.c                     |    6 -
 arch/mips/lasat/sysctl.c                       |   99 +--
 arch/powerpc/kernel/idle.c                     |    2 -
 arch/s390/kernel/debug.c                       |    9 +-
 arch/s390/mm/cmm.c                             |    5 +-
 arch/sh/kernel/traps_64.c                      |    7 +-
 arch/x86/kernel/vsyscall_64.c                  |    2 +-
 arch/x86/vdso/vdso32-setup.c                   |    1 -
 crypto/proc.c                                  |   10 +-
 drivers/cdrom/cdrom.c                          |    8 +-
 drivers/char/hpet.c                            |    9 +-
 drivers/char/ipmi/ipmi_poweroff.c              |    9 +-
 drivers/char/pty.c                             |   10 +-
 drivers/char/random.c                          |   42 +-
 drivers/char/rtc.c                             |    9 +-
 drivers/macintosh/mac_hid.c                    |   11 +-
 drivers/md/md.c                                |   10 +-
 drivers/misc/sgi-xp/xpc_main.c                 |    8 -
 drivers/net/wireless/arlan-proc.c              |  181 ++--
 drivers/parport/procfs.c                       |   11 +-
 drivers/s390/char/sclp_async.c                 |    5 +-
 drivers/scsi/scsi_sysctl.c                     |    9 +-
 fs/coda/sysctl.c                               |    4 -
 fs/eventpoll.c                                 |    2 +-
 fs/lockd/svc.c                                 |   14 +-
 fs/nfs/sysctl.c                                |   14 +-
 fs/notify/inotify/inotify_user.c               |    8 +-
 fs/ntfs/sysctl.c                               |    2 -
 fs/ocfs2/stackglue.c                           |   13 +-
 fs/proc/proc_sysctl.c                          |    4 +-
 fs/quota/dquot.c                               |   17 +-
 fs/xfs/linux-2.6/xfs_sysctl.c                  |   32 -
 include/linux/sysctl.h                         |   20 +-
 include/net/dn_dev.h                           |    1 -
 include/net/neighbour.h                        |    3 +-
 init/Kconfig                                   |    1 +
 ipc/ipc_sysctl.c                               |   77 --
 ipc/mq_sysctl.c                                |    7 +-
 kernel/sched.c                                 |    5 +-
 kernel/slow-work.c                             |    5 +-
 kernel/sysctl.c                                |  462 +-------
 kernel/sysctl_binary.c                         | 1485 ++++++++++++++++++++++--
 kernel/sysctl_check.c                          | 1376 +----------------------
 kernel/utsname_sysctl.c                        |   31 -
 lib/Kconfig.debug                              |    2 +-
 net/802/tr.c                                   |    7 +-
 net/appletalk/sysctl_net_atalk.c               |   13 +-
 net/ax25/sysctl_net_ax25.c                     |   38 +-
 net/bridge/br_netfilter.c                      |    6 +-
 net/core/neighbour.c                           |   47 +-
 net/core/sysctl_net_core.c                     |   21 +-
 net/dccp/sysctl.c                              |    8 +-
 net/decnet/dn_dev.c                            |   64 +-
 net/decnet/sysctl_net_decnet.c                 |  124 +--
 net/ipv4/arp.c                                 |    2 +-
 net/ipv4/devinet.c                             |  111 +--
 net/ipv4/ip_fragment.c                         |    6 -
 net/ipv4/netfilter.c                           |    6 +-
 net/ipv4/netfilter/ip_queue.c                  |    3 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   10 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    8 +-
 net/ipv4/route.c                               |   73 +-
 net/ipv4/sysctl_net_ipv4.c                     |  164 +---
 net/ipv4/xfrm4_policy.c                        |    1 -
 net/ipv6/addrconf.c                            |   90 +--
 net/ipv6/icmp.c                                |    4 +-
 net/ipv6/ndisc.c                               |   39 +-
 net/ipv6/netfilter/ip6_queue.c                 |    4 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |    4 +-
 net/ipv6/reassembly.c                          |    6 -
 net/ipv6/route.c                               |   18 +-
 net/ipv6/sysctl_net_ipv6.c                     |   12 +-
 net/ipv6/xfrm6_policy.c                        |    1 -
 net/ipx/sysctl_net_ipx.c                       |    7 +-
 net/irda/irsysctl.c                            |   31 +-
 net/llc/sysctl_net_llc.c                       |   25 +-
 net/netfilter/core.c                           |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c                 |    6 +-
 net/netfilter/ipvs/ip_vs_lblc.c                |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c               |    2 +-
 net/netfilter/nf_conntrack_acct.c              |    1 -
 net/netfilter/nf_conntrack_ecache.c            |    2 -
 net/netfilter/nf_conntrack_proto_dccp.c        |   12 +-
 net/netfilter/nf_conntrack_proto_generic.c     |    8 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |    8 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |   14 +-
 net/netfilter/nf_conntrack_proto_udp.c         |    8 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |    6 +-
 net/netfilter/nf_conntrack_standalone.c        |   14 +-
 net/netfilter/nf_log.c                         |    7 +-
 net/netrom/sysctl_net_netrom.c                 |   30 +-
 net/phonet/sysctl.c                            |    8 +-
 net/rds/ib_sysctl.c                            |   14 +-
 net/rds/iw_sysctl.c                            |   14 +-
 net/rds/sysctl.c                               |   11 +-
 net/rose/sysctl_net_rose.c                     |   26 +-
 net/sctp/sysctl.c                              |   49 +-
 net/sunrpc/sysctl.c                            |    5 +-
 net/sunrpc/xprtrdma/svc_rdma.c                 |   16 +-
 net/sunrpc/xprtrdma/transport.c                |   20 +-
 net/sunrpc/xprtsock.c                          |   18 +-
 net/unix/sysctl_net_unix.c                     |    7 +-
 net/x25/sysctl_net_x25.c                       |   15 +-
 net/xfrm/xfrm_sysctl.c                         |    4 -
 security/keys/sysctl.c                         |    7 +-
 111 files changed, 1702 insertions(+), 3774 deletions(-)

Eric
