From: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 00/11] Add namespace support for syslog
Date: Wed, 7 Aug 2013 15:37:04 +0800
Message-ID: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	guz.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
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

This patchset introduces a system log namespace.

In container scenario, all logs are exported to the ring
buffer of host. Then logs belong to a contaier can't be
distinguished. Sometimes,  Some of our guest are 
administered by other sys-admin, that should not have 
access to these infomations.

Syslog namespace is used to include a independent log
buf own to a container, some logs which need to be 
displayed in container are stored to the buf, and others
are all exported to HOST.

The link of the 1st version is http://lwn.net/Articles/525728/.
In that version, syslog_namespace was added into nsproxy
and created through a new clone flag CLONE_SYSLOG when 
cloning a process. There were some discussion in last 
November about the 1st version. The 2nd version
(http://lwn.net/Articles/561271/) used these important 
advice, and referred to Serge's patch
(http://lwn.net/Articles/525629/).

In this patchset, patch01-10 implement a mechanism for 
syslog_ns. Iptables is an actual scene to use syslog ns. 
So patch11 uses ns_printk interface to isolate logs.

Syslog namespace is tied to a user namespace. And we 
must create a new user ns before create a new syslog ns,
because that will make users have full capabilities in 
this new userns after cloning a new user ns. The syslog
namespace can be created through a new command(11) to 
__NR_syslog syscall. That owe to a new syslog flag 
SYSLOG_ACTION_NEW_NS.

In syslog_namespace, some necessary identifiers for 
handling syslog buf are containerized. When one container
creates a new syslog ns, individual buf will be allocated
to store log ownned this container. 

A new interface ns_printk is added to print the logs
which we want to see in the container. Through ns_printk,
we can get more logs related to a specific net ns, for
instance, iptables. Here we use it to report iptable 
logs per contianer. Then default printk targeted at the 
init_syslog_ns will continue to print out most kernel
log to host.

One task in a new syslog ns could affect only current 
container through "dmesg", "dmesg -c" and /dev/kmsg 
actions. The read/write interface such as /dev/kmsg, 
/pro/kmsg and syslog syscall continue to be useful for 
container users.

This patchset is based on linus' linux tree.

v1 --> v2:
  -- Add syslog_ns to user namespace instead of nsproxy.
  -- Create syslog_ns through a new command(11) to __NR_syslog
	syscall instead of CLONE_SYSLOG.
  -- Alter related interfaces and parameters.

v2 --> v3:
  -- Add some changlogs to illustrate the purpose of syslog ns.
  -- Add ns_printk_emit for namespace and make devkmsg_writev
	 per namespace.
  -- Add ns_console_unlock for namespace.
  -- Put user ns while freeing syslog_ns.
  -- Use net instead of skb->dev->nd_net in sb_close.
  -- Clean up.

Rui Xiang (11):
  syslog_ns: add syslog_namespace and put/get_syslog_ns
  syslog_ns: add syslog_ns into user_namespace
  syslog_ns: add init syslog_ns for global syslog
  syslog_ns: make syslog handling per namespace
  syslog_ns: make permisiion check per user namespace
  syslog_ns: use init syslog_ns for console action
  syslog_ns: implement function for creating syslog ns
  syslog_ns: implement ns_printk for specific syslog_ns
  syslog_ns: implement ns_printk_emit for specific syslog_ns
  syslog_ns: implement ns_console_unlock for specific syslog_ns
  netfilter: use ns_printk in iptable context

 fs/proc/kmsg.c                 |  17 +-
 include/linux/console.h        |   1 +
 include/linux/printk.h         |  11 +-
 include/linux/syslog.h         |  81 ++++-
 include/linux/user_namespace.h |   2 +
 include/net/netfilter/xt_log.h |   6 +-
 kernel/printk.c                | 784 +++++++++++++++++++++++++++--------------
 kernel/sysctl.c                |   3 +-
 kernel/user.c                  |   3 +
 kernel/user_namespace.c        |   4 +
 net/netfilter/xt_LOG.c         |   4 +-
 11 files changed, 636 insertions(+), 280 deletions(-)

-- 
1.8.2.2
