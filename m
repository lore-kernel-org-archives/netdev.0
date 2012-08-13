From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 0/21] User namespace changes to the networking stack.
Date: Mon, 13 Aug 2012 13:07:10 -0700
Message-ID: <87ehnav9n5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


This is a modest set of changes against the current networking stack to
enable basic user namespace support.  Allowing the code to compile with
user namespaces enabled and removing the assumption that there is only
the initial user namespace.

Work to relax the privilege checks in the networking stack from
"capable(CAP_NET_ADMIN)" or "capable(CAP_NET_RAW)" to
"ns_capable(net->user_ns, CAP_NET_ADMIN)" or 
"ns_capable(net->user_ns, CAP_NET_RAW)" allowing root in a user
namespace to control a network namespace will come later.

David there are just enough interdependencies between the user namespace
bits that I intend to merge them all through my user namespace tree.
After the review is complete I will add these patches to my for-next
branch of my user-namespace.git tree where I do not intend to rebase.
If it make sense to pull these into net-next to avoid or reduce
conflicts that should not be a problem.

A current snapshot of my development tree for people who are interested
in seeing the entire picture is at:

git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-always-map-user-v46

Eric W. Biederman (21):
      userns: Convert net/core/scm.c to use kuids and kgids
      userns: Convert __dev_set_promiscuity to use kuids in audit logs
      userns: Convert sock_i_uid to return a kuid_t
      userns: Allow USER_NS and NET simultaneously in Kconfig
      userns: Make seq_file's user namespace accessible
      userns: Print out socket uids in a user namespace aware fashion.
      userns: Use kgids for sysctl_ping_group_range
      net ip6 flowlabel: Make owner a union of struct pid * and kuid_t
      pidns: Export free_pid_ns
      userns: Convert net/ax25 to use kuid_t where appropriate
      netlink: Make the sending netlink socket availabe in NETLINK_CB
      userns: Implement sk_user_ns
      userns: Teach inet_diag to work with user namespaces
      userns: nfnetlink_log: Report socket uids in the log sockets user namespace
      net sched: Pass the skb into change so it can access NETLINK_CB
      userns: Convert cls_flow to work with user namespaces enabled
      userns: Convert xt_LOG to print socket kuids and kgids as uids and gids
      userns xt_recent: Specify the owner/group of ip_list_perms in the initial user namespace
      userns: xt_owner: Add basic user namespace support.
      userns: Make the airo wireless driver use kuids for proc uids and gids
      userns: Convert tun/tap to use kuid and kgid where appropriate

 drivers/net/tun.c             |   46 ++++++++++++++++++++++++++-----------
 drivers/net/wireless/airo.c   |   48 +++++++++++++++++++++++----------------
 fs/seq_file.c                 |    4 +++
 include/linux/inet_diag.h     |    1 +
 include/linux/netlink.h       |    1 +
 include/linux/seq_file.h      |   14 +++++++++++
 include/net/ax25.h            |    4 +-
 include/net/ipv6.h            |    5 +++-
 include/net/netns/ipv4.h      |    3 +-
 include/net/sch_generic.h     |    3 +-
 include/net/sock.h            |   11 ++++++++-
 include/net/tcp.h             |    3 +-
 init/Kconfig                  |   18 --------------
 kernel/pid.c                  |    1 +
 kernel/pid_namespace.c        |    2 +
 net/appletalk/atalk_proc.c    |    3 +-
 net/ax25/ax25_uid.c           |   21 +++++++++++-----
 net/core/dev.c                |    7 +++--
 net/core/scm.c                |   31 ++++++++++++++++++------
 net/core/sock.c               |   10 ++++----
 net/ipv4/inet_diag.c          |   21 ++++++++++++-----
 net/ipv4/ping.c               |   22 +++++++----------
 net/ipv4/raw.c                |    4 ++-
 net/ipv4/sysctl_net_ipv4.c    |   42 ++++++++++++++++++++++------------
 net/ipv4/tcp_ipv4.c           |    6 ++--
 net/ipv4/udp.c                |    4 ++-
 net/ipv4/udp_diag.c           |    5 +++-
 net/ipv6/ip6_flowlabel.c      |   50 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/raw.c                |    3 +-
 net/ipv6/tcp_ipv6.c           |    6 ++--
 net/ipv6/udp.c                |    3 +-
 net/ipx/ipx_proc.c            |    3 +-
 net/key/af_key.c              |    2 +-
 net/llc/llc_proc.c            |    2 +-
 net/netfilter/nfnetlink_log.c |   14 ++++++++---
 net/netfilter/xt_LOG.c        |   16 ++++++++-----
 net/netfilter/xt_owner.c      |   30 +++++++++++++++++++-----
 net/netfilter/xt_recent.c     |   13 +++++++++-
 net/netlink/af_netlink.c      |    6 +++-
 net/packet/af_packet.c        |    2 +-
 net/phonet/socket.c           |    6 +++-
 net/sched/cls_api.c           |    2 +-
 net/sched/cls_basic.c         |    3 +-
 net/sched/cls_cgroup.c        |    3 +-
 net/sched/cls_flow.c          |   19 +++++++++++----
 net/sched/cls_fw.c            |    3 +-
 net/sched/cls_route.c         |    3 +-
 net/sched/cls_rsvp.h          |    3 +-
 net/sched/cls_tcindex.c       |    3 +-
 net/sched/cls_u32.c           |    3 +-
 net/sctp/proc.c               |    6 +++-
 51 files changed, 368 insertions(+), 176 deletions(-)

Eric
