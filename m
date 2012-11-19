From: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 0/5] Containerize syslog
Date: Mon, 19 Nov 2012 16:16:24 +0800
Message-ID: <50A9EAD8.9090501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
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

From: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

In Serge's patch (http://lwn.net/Articles/525629/), syslog_namespace was tied to a user
namespace. We add syslog_ns tied to nsproxy instead, and implement ns_printk in
ip_table context.

We add syslog_namespace as a part of nsproxy, and a new flag CLONE_SYSLOG to unshare
syslog area.

In syslog_namespace, some necessary identifiers for handling syslog buf are contained.
When one container creates a new syslog namespace,containerized buf will be allocated
to store log ownned this container. Containerized identifiers such as log_first_seq
instead of global variable only affect their own buf.The buf will not be free until
syslog_namespace is destructed by host.

Printk should be re-implimented because log buf is isolated into syslog_ns. The function
include printk, /dev/kmsg, do_syslog and kmsg_dump should be realized in container. So,
to make these funtions available in container, a parameter syslog_ns is necessory for
their interfaces.

For container context, the value syslog namespace is reasonable if we use current method
to get syslog_ns when using iptable. Because the log info belong to each containers will
be printed in host.

We add a pointer in net namespace, and use it to track the syslog_ns which was created
when the log was generated in container. Then add ns_printk to provide a new interface
while using syslog_ns.

This patchset is based on the develop tree of net branch
	https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git.

Libo Chen (3):
  printk: modify printk interface for syslog_namespace
  printk: add ns_printk for specific syslog_ns
  printk: use ns_printk in iptable context

Xiang Rui (2):
  Syslog_ns: add syslog_namespace struct and API
  Syslog_ns: add CLONE_NEWSYSLOG and create syslog_ns when copying
    process

 drivers/base/core.c              |    4 +-
 include/linux/nsproxy.h          |    2 +
 include/linux/printk.h           |    5 +-
 include/linux/syslog_namespace.h |   98 ++++++
 include/net/net_namespace.h      |    7 +-
 include/net/netfilter/xt_log.h   |    7 +-
 include/uapi/linux/sched.h       |    3 +-
 init/Kconfig                     |    7 +
 kernel/Makefile                  |    1 +
 kernel/nsproxy.c                 |   19 +-
 kernel/printk.c                  |  646 ++++++++++++++++++++++++--------------
 kernel/syslog_namespace.c        |   65 ++++
 net/core/net_namespace.c         |   12 +-
 net/netfilter/xt_LOG.c           |    4 +-
 14 files changed, 623 insertions(+), 257 deletions(-)
 create mode 100644 include/linux/syslog_namespace.h
 create mode 100644 kernel/syslog_namespace.c
