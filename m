From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 00/48] Add namespace support for audit
Date: Tue, 7 May 2013 10:20:21 +0800
Message-ID: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
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

This patchset try to add namespace support for audit.

I choose to assign audit to the user namespace.
Right now,there are six kinds of namespaces, such as
net, mount, ipc, pid, uts and user. the first five
namespaces have special usage. the audit isn't suitable to
belong to these five namespaces, so the user namespace
may be the best choice.

Through I decide to make audit related resources per user
namespace, but audit uses netlink to communicate between kernel
space and user space, and the netlink is a private resource
of per net namespace. So we need the capability to allow the
netlink sockets to communicate with each other in the same user
namespace even they are in different net namespace. [PATCH 2/48]
does this job, it adds a new function "compare" for per netlink
table to compare two sockets. it means the netlink protocols can
has its own compare fuction, For other protocols, two netlink
sockets are different if they belong to the different net namespace.
For audit protocol, two sockets can be the same even they in different
net namespace,we use user namespace not net namespace to make the
decision.

There is one point that some people may dislike,in [PATCH 1/48],
the kernel side audit netlink socket is created only when we create
the first netns for the userns, and this userns will hold the netns
until we destroy this userns.

The other patches just make the audit related resources per
user namespace.

This patchset is sent as an RFC,any comments are welcome.

Gao feng (48):
  Audit: make audit kernel side netlink sock per userns
  netlink: Add compare function for netlink_table
  Audit: implement audit self-defined compare function
  Audit: make audit_skb_queue per user namespace
  Audit: make audit_skb_hold_queue per user namespace
  Audit: make kauditd_task per user namespace
  Audit: make audit_pid per user namespace
  Audit: make audit_nlk_portid per user namesapce
  Audit: make audit_enabled per user namespace
  Audit: change type of audit_ever_enabled to bool
  Audit: make audit_ever_enabled per user namespace
  Audit: make audit_initialized per user namespace
  Audit: only allow init user namespace to change audit_rate_limit
  Audit: only allow init user namespace to change audit_failure
  Audit: allow to send netlink message to auditd in uninit user
    namespace
  Audit: user proper user namespace in audit_log_config_change
  Audit: make kauditd_wait per user namespace
  Audit: make audit_backlog_wait per user namespace
  Audit: remove duplicate comments
  Audit: introduce new audit logging interface for user namespace
  Audit: pass proper user namespace to audit_log_common_recv_msg
  Audit: Log audit config change in uninit user namespace
  Audit: netfilter: Log xt table replace behavior in proper user
    namespace
  Audit: xt_AUDIT: Log audit message in proper user namespace
  Audit: send reply message to the auditd in proper user namespace
  Audit: make audit_inode_hash per user namespace
  Audit: make tree_list per user namespace
  Audit: make audit filter list per user namespace
  Audit: make audit_krule belongs to user namespace
  Audit: reply audit filter list request to proper user namespace
  Audit: pass proper user namespace to audit_filter_syscall
  Audit: pass proper user namespace to audit_filter_inode_name
  Audit: Log filter related audit message to proper user namespace
  Log audit tree related message in proper user namespace
  Audit: Log task related audit message to proper user namespace
  Audit: Log watch related audit message to proper user namespace
  Audit: translate audit_log_start to audit_log_start_ns
  Audit: tty: translate audit_log_start to audit_log_start_ns
  Audit: netlabel: translate audit_log_start to audit_log_start_ns
  Audit: ima: translate audit_log_start to audit_log_start_ns
  Audit: lsm: translate audit_log_start to audit_log_start_ns
  Audit: selinux: translate audit_log_start to audit_log_start_ns
  Audit: xfrm: translate audit_log_start to audit_log_start_ns
  Audit: rename audit_log_start_ns to audit_log_start
  Audit: user audit_enabled_ns to replace audit_enabled
  Audit: rename audit_enabled_ns to audit_enabled
  Audit: make audit_log user namespace awared
  Audit: allow root user of un-init user namespace to set audit

 drivers/tty/tty_audit.c             |   9 +-
 include/linux/audit.h               |  44 ++--
 include/linux/netlink.h             |   1 +
 include/linux/user_namespace.h      |  25 +++
 include/net/xfrm.h                  |   7 +-
 kernel/audit.c                      | 393 +++++++++++++++++++++---------------
 kernel/audit.h                      |  24 +--
 kernel/audit_tree.c                 |  49 ++---
 kernel/audit_watch.c                |  23 ++-
 kernel/auditfilter.c                |  76 +++----
 kernel/auditsc.c                    | 156 ++++++++------
 kernel/user.c                       |  19 ++
 kernel/user_namespace.c             |   3 +
 net/core/dev.c                      |  12 +-
 net/ipv4/cipso_ipv4.c               |   4 +-
 net/netfilter/x_tables.c            |   9 +-
 net/netfilter/xt_AUDIT.c            |   8 +-
 net/netlabel/netlabel_domainhash.c  |   4 +-
 net/netlabel/netlabel_unlabeled.c   |   8 +-
 net/netlabel/netlabel_user.c        |   8 +-
 net/netlink/af_netlink.c            |  26 ++-
 net/netlink/af_netlink.h            |   1 +
 net/xfrm/xfrm_policy.c              |   4 +-
 net/xfrm/xfrm_state.c               |  14 +-
 security/apparmor/lib.c             |   2 +-
 security/integrity/ima/ima_api.c    |   5 +-
 security/integrity/ima/ima_audit.c  |  11 +-
 security/integrity/ima/ima_policy.c |   5 +-
 security/lsm_audit.c                |   8 +-
 security/selinux/avc.c              |   3 +-
 security/selinux/hooks.c            |  17 +-
 security/selinux/selinuxfs.c        |   9 +-
 security/selinux/ss/services.c      |  30 ++-
 security/smack/smack_lsm.c          |   3 +-
 34 files changed, 630 insertions(+), 390 deletions(-)

-- 
1.8.1.4
