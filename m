From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/7] Network namespace manipulation with file descriptors
Date: Sat, 07 May 2011 07:18:44 -0700
Message-ID: <m1fwoqoapn.fsf@fess.ebiederm.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<3A54AB469A0294933EAC2257@nimrod.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	linux-fsdevel@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43346 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755050Ab1EGOSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 10:18:49 -0400
In-Reply-To: <3A54AB469A0294933EAC2257@nimrod.local> (Alex Bligh's message of
	"Sat, 07 May 2011 07:58:28 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Bligh <alex@alex.org.uk> writes:

> --On 6 May 2011 19:23:29 -0700 "Eric W. Biederman" <ebiederm@xmission.com>
> wrote:
>
>> This patchset addresses the user interface limitations by introducing
>> proc files you can open to get file descriptors that keep alive and
>> refer to your a tasks namespaces.  Those file descriptors can be passed
>> to the new setns system call or the NET_NS_FD argument in netlink
>> messages.
>
> This is conceptually very interesting. I am one of those people you
> describe with a routing daemon (or more accurately a wrapper around
> existing daemons) that does the unshare() and keeps the network
> alive. It also has a control socket etc.
>
> You say:
>> This addresses three specific problems that can make namespaces hard to
>> work with.
>> - Namespaces require a dedicated process to pin them in memory.
>> - It is not possible to use a namespace unless you are the child
>>   of the original creator.
>> - Namespaces don't have names that userspace can use to talk about
>>   them.
>
> At least for me, the best way to solve the second blob would be to
> be able to unshare to an existing namespace. That way I would be able
> to run a daemon (without modification) in a pre-existing namespace.
> The user interface here would just be an option to 'unshare'. I
> don't think your patch allows this, does it?  Right now I'm effectively
> doing that by causing the pid concerned to fork() and do my bidding,
> but that is far from perfect.

You are essentially describing my setns system call.

> As a secondary issue, ever without your patch, it would be really
> useful to be able to read from userspace the current network namespace.
> (i.e. the pid concerned, or 1 if not unshared). I would like to
> simply modify a routing daemon's init script so it doesn't start
> if in the host, e.g. at the top:
>  [ `cat /proc/.../networknamespace` eq 1 ] && exit 0

You can read the processes network namespace by opening
/proc/<pid>/ns/net.  Unfortunately comparing the network
namespaces for identity is another matter.  You will probably
be better off simply forcing the routing daemon to start
in the desired network namespace in it's initscript.

For purposes of clarity please have a look at my work in
progress patch for iproute2.  This demonstrates how I expect
userspace to work in a multi-network namespace world.

Eric


>From f773bd66c2e31e1ac55b65ce5bc2c17f8845ce5c Mon Sep 17 00:00:00 2001
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Fri, 6 May 2011 00:01:45 -0700
Subject: [PATCH] iproute2:  Add processless netnwork namespace support.

The goal of this code change is to implement a mechanism
such that it is simple to work with a kernel that is
using multiple network namespaces at once.

This comes in handy for interacting with vpns where
there may be rfc1918 address overlaps, and different
policies default routes, name servers and the like.

Configuration specific to a network namespace that
would ordinarily be stored under /etc/ is stored under
/etc/netns/<name>.  For example if the dns server
configuration is different for your vpn you would
create a file /etc/netns/myvpn/resolv.conf.

File descriptors that can be used to manipulate a
network namespace can be created by opening
/var/run/netns/<NAME>.

This adds the following commands to iproute.
ip netns add NAME
ip netns delete NAME
ip netns monitor
ip netns list
ip netns exec NAME cmd ....
ip link set DEV netns NAME

ip netns exec exists to cater the vast majority of programs
that only know how to operate in a single network namespace.
ip netns exec changes the default network namespace, creates
a new mount namespace, remounts /sys and bind mounts netns
specific configuration files to their standard locations.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/if_link.h |    1 +
 ip/Makefile             |    2 +-
 ip/ip.c                 |    4 +-
 ip/ip_common.h          |    2 +
 ip/iplink.c             |    8 +-
 ip/ipnetns.c            |  320 +++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip.8           |   56 ++++++++
 7 files changed, 389 insertions(+), 4 deletions(-)
 create mode 100644 ip/ipnetns.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index e4a3a2d..304c44f 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -136,6 +136,7 @@ enum {
 	IFLA_PORT_SELF,
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
+	IFLA_NET_NS_FD,
 	__IFLA_MAX
 };
 
diff --git a/ip/Makefile b/ip/Makefile
index 6054e8a..2ee4e7c 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -1,4 +1,4 @@
-IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o \
+IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
diff --git a/ip/ip.c b/ip/ip.c
index b127d57..7f0c468 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -44,7 +44,8 @@ static void usage(void)
 "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
-"                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm }\n"
+"                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
+"                   netns }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
@@ -80,6 +81,7 @@ static const struct cmd {
 	{ "xfrm",	do_xfrm },
 	{ "mroute",	do_multiroute },
 	{ "mrule",	do_multirule },
+	{ "netns",	do_netns },
 	{ "help",	do_help },
 	{ 0 }
 };
diff --git a/ip/ip_common.h b/ip/ip_common.h
index a114186..5e5fb76 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -38,6 +38,7 @@ extern int do_ipmonitor(int argc, char **argv);
 extern int do_multiaddr(int argc, char **argv);
 extern int do_multiroute(int argc, char **argv);
 extern int do_multirule(int argc, char **argv);
+extern int do_netns(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
@@ -64,6 +65,7 @@ struct link_util
 };
 
 struct link_util *get_link_kind(const char *kind);
+int get_netns_fd(const char *name);
 
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
diff --git a/ip/iplink.c b/ip/iplink.c
index 48c0254..e5325a6 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -67,6 +67,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ broadcast LLADDR ]\n");
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
+	fprintf(stderr, "	                  [ netns NAME ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
@@ -304,9 +305,12 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
                         NEXT_ARG();
                         if (netns != -1)
                                 duparg("netns", *argv);
-                        if (get_integer(&netns, *argv, 0))
+			if ((netns = get_netns_fd(*argv)) >= 0)
+				addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_FD, &netns, 4);
+			else if (get_integer(&netns, *argv, 0) == 0)
+				addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_PID, &netns, 4);
+			else
                                 invarg("Invalid \"netns\" value\n", *argv);
-                        addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_PID, &netns, 4);
 		} else if (strcmp(*argv, "multicast") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_MULTICAST;
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
new file mode 100644
index 0000000..efb7fd2
--- /dev/null
+++ b/ip/ipnetns.c
@@ -0,0 +1,320 @@
+#define _ATFILE_SOURCE
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/wait.h>
+#include <sys/inotify.h>
+#include <sys/mount.h>
+#include <sys/param.h>
+#include <stdio.h>
+#include <string.h>
+#include <sched.h>
+#include <fcntl.h>
+#include <dirent.h>
+#include <errno.h>
+#include <unistd.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+#define NETNS_RUN_DIR "/var/run/netns"
+#define NETNS_ETC_DIR "/etc/netns"
+
+#ifdef __x86_64__
+#define PRIVATE_SYS_setns 307
+#endif
+
+#ifdef __i386__
+#define PRIVATE_SYS_setns 345
+#endif
+
+#ifndef SYS_setns
+#define SYS_setns PRIVATE_SYS_setns
+#endif
+
+#ifndef CLONE_NEWNET
+#define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
+#endif
+
+#ifndef MNT_DETACH
+#define MNT_DETACH	0x00000002	/* Just detach from the tree */
+#endif /* MNT_DETACH */
+
+
+static int setns(int fd, int nstype)
+{
+	return syscall(SYS_setns, fd, nstype);
+}
+
+static int touch(const char *path, mode_t mode)
+{
+	int fd;
+	fd = open(path, O_RDONLY|O_CREAT, mode);
+	if (fd < 0)
+		return -1;
+	close(fd);
+	return 0;
+}
+
+static void usage(void) __attribute__((noreturn));
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip netns list\n");
+	fprintf(stderr, "       ip netns add NAME\n");
+	fprintf(stderr, "       ip netns delete NAME\n");
+	fprintf(stderr, "       ip netns exec NAME cmd ...\n");
+	fprintf(stderr, "       ip netns monitor\n");
+	exit(-1);
+}
+
+int get_netns_fd(const char *name)
+{
+	char pathbuf[MAXPATHLEN];
+	const char *path, *ptr;
+
+	path = name;
+	ptr = strchr(name, '/');
+	if (!ptr) {
+		snprintf(pathbuf, sizeof(pathbuf), "%s/%s",
+			NETNS_RUN_DIR, name );
+		path = pathbuf;
+	}
+	return open(path, O_RDONLY);
+}
+
+static int netns_list(int argc, char **argv)
+{
+	struct dirent *entry;
+	DIR *dir;
+
+	dir = opendir(NETNS_RUN_DIR);
+	if (!dir)
+		return 0;
+
+	while ((entry = readdir(dir)) != NULL) {
+		if (strcmp(entry->d_name, ".") == 0)
+			continue;
+		if (strcmp(entry->d_name, "..") == 0)
+			continue;
+		printf("%s\n", entry->d_name);
+	}
+	closedir(dir);
+	return 0;
+}
+
+static void bind_etc(const char *name)
+{
+	char etc_netns_path[MAXPATHLEN];
+	char netns_name[MAXPATHLEN];
+	char etc_name[MAXPATHLEN];
+	struct dirent *entry;
+	DIR *dir;
+
+	snprintf(etc_netns_path, sizeof(etc_netns_path), "%s/%s", NETNS_ETC_DIR, name);
+	dir = opendir(etc_netns_path);
+	if (!dir)
+		return;
+
+	while ((entry = readdir(dir)) != NULL) {
+		if (strcmp(entry->d_name, ".") == 0)
+			continue;
+		if (strcmp(entry->d_name, "..") == 0)
+			continue;
+		snprintf(netns_name, sizeof(netns_name), "%s/%s", etc_netns_path, entry->d_name);
+		snprintf(etc_name, sizeof(etc_name), "/etc/%s", entry->d_name);
+		if (mount(netns_name, etc_name, "none", MS_BIND, NULL) < 0) {
+			fprintf(stderr, "Bind %s -> %s failed: %s\n",
+				netns_name, etc_name, strerror(errno));
+		}
+	}
+	closedir(dir);
+}
+
+static int netns_exec(int argc, char **argv)
+{
+	/* Setup the proper environment for apps that are not netns
+	 * aware, and execute a program in that environment.
+	 */
+	const char *name, *cmd;
+	char net_path[MAXPATHLEN];
+	int netns;
+
+	if (argc < 1) {
+		fprintf(stderr, "No netns name specified\n");
+		return -1;
+	}
+	if (argc < 2) {
+		fprintf(stderr, "No cmd specified\n");
+		return -1;
+	}
+	name = argv[0];
+	cmd = argv[1];
+	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
+	netns = open(net_path, O_RDONLY);
+	if (netns < 0) {
+		fprintf(stderr, "Cannot open network namespace: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	if (setns(netns, CLONE_NEWNET) < 0) {
+		fprintf(stderr, "seting the network namespace failed: %s\n",
+			strerror(errno));
+		return -1;
+	}
+
+	if (unshare(CLONE_NEWNS) < 0) {
+		fprintf(stderr, "unshare failed: %s\n", strerror(errno));
+		return -1;
+	}
+	/* Mount a version of /sys that describes the network namespace */
+	if (umount2("/sys", MNT_DETACH) < 0) {
+		fprintf(stderr, "umount of /sys failed: %s\n", strerror(errno));
+		return -1;
+	}
+	if (mount(name, "/sys", "sysfs", 0, NULL) < 0) {
+		fprintf(stderr, "mount of /sys failed: %s\n",strerror(errno));
+		return -1;
+	}
+
+	/* Setup bind mounts for config files in /etc */
+	bind_etc(name);
+
+	if (execvp(cmd, argv + 1)  < 0)
+		fprintf(stderr, "exec of %s failed: %s\n",
+			cmd, strerror(errno));
+	exit(-1);
+}
+
+static int netns_delete(int argc, char **argv)
+{
+	const char *name;
+	char netns_path[MAXPATHLEN];
+
+	if (argc < 1) {
+		fprintf(stderr, "No netns name specified\n");
+		return -1;
+	}
+
+	name = argv[0];
+	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
+	umount2(netns_path, MNT_DETACH);
+	if (unlink(netns_path) < 0) {
+		fprintf(stderr, "Cannot remove %s: %s\n",
+			netns_path, strerror(errno));
+		return -1;
+	}
+	return 0;
+}
+
+static int netns_add(int argc, char **argv)
+{
+	/* This function creates a new network namespace and
+	 * a new mount namespace and bind them into a well known
+	 * location in the filesystem based on the name provided.
+	 *
+	 * The mount namespace is created so that any necessary
+	 * userspace tweaks like remounting /sys, or bind mounting
+	 * a new /etc/resolv.conf can be shared between uers.
+	 */
+	char netns_path[MAXPATHLEN];
+	const char *name;
+
+	if (argc < 1) {
+		fprintf(stderr, "No netns name specified\n");
+		return -1;
+	}
+	name = argv[0];
+
+	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
+
+	/* Create the base netns directory if it doesn't exist */
+	mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
+
+	/* Create the filesystem state */
+	if (touch(netns_path, 0) < 0) {
+		fprintf(stderr, "Could not create %s: %s\n",
+			netns_path, strerror(errno));
+		goto out_delete;
+	}
+	if (unshare(CLONE_NEWNET) < 0) {
+		fprintf(stderr, "Failed to create a new network namespace: %s\n",
+			strerror(errno));
+		goto out_delete;
+	}
+
+	/* Bind the netns last so I can watch for it */
+	if (mount("/proc/self/ns/net", netns_path, "none", MS_BIND, NULL) < 0) {
+		fprintf(stderr, "Bind /proc/self/ns/net -> %s failed: %s\n",
+			netns_path, strerror(errno));
+		goto out_delete;
+	}
+	return 0;
+out_delete:
+	netns_delete(argc, argv);
+	exit(-1);
+	return -1;
+}
+
+
+static int netns_monitor(int argc, char **argv)
+{
+	char buf[4096];
+	struct inotify_event *event;
+	int fd;
+	fd = inotify_init();
+	if (fd < 0) {
+		fprintf(stderr, "inotify_init failed: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	if (inotify_add_watch(fd, NETNS_RUN_DIR, IN_CREATE | IN_DELETE) < 0) {
+		fprintf(stderr, "inotify_add_watch failed: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	for(;;) {
+		ssize_t len = read(fd, buf, sizeof(buf));
+		if (len < 0) {
+			fprintf(stderr, "read failed: %s\n",
+				strerror(errno));
+			return -1;
+		}
+		for (event = (struct inotify_event *)buf;
+		     (char *)event < &buf[len];
+		     event = (struct inotify_event *)((char *)event + sizeof(*event) + event->len)) {
+			if (event->mask & IN_CREATE)
+				printf("add %s\n", event->name);
+			if (event->mask & IN_DELETE)
+				printf("delete %s\n", event->name);
+		}
+	}
+	return 0;
+}
+
+int do_netns(int argc, char **argv)
+{
+	if (argc < 1)
+		return netns_list(0, NULL);
+
+	if ((matches(*argv, "list") == 0) || (matches(*argv, "show") == 0) ||
+	    (matches(*argv, "lst") == 0))
+		return netns_list(argc-1, argv+1);
+
+	if (matches(*argv, "help") == 0)
+		usage();
+
+	if (matches(*argv, "add") == 0)
+		return netns_add(argc-1, argv+1);
+
+	if (matches(*argv, "delete") == 0)
+		return netns_delete(argc-1, argv+1);
+
+	if (matches(*argv, "exec") == 0)
+		return netns_exec(argc-1, argv+1);
+
+	if (matches(*argv, "monitor") == 0)
+		return netns_monitor(argc-1, argv+1);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip netns help\".\n", *argv);
+	exit(-1);
+}
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index c5248ef..1935dc5 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -85,6 +85,9 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .B  netns
 .IR PID " |"
 .br
+.B  netns
+.IR NETNSNAME " |"
+.br
 .B alias
 .IR NAME  " |"
 .br
@@ -162,6 +165,17 @@ tentative " | " deprecated " | " dadfailed " | " temporary " ]"
 .BR "ip addrlabel" " { " list " | " flush " }"
 
 .ti -8
+.BR "ip netns" " { " list " | " monitor " } "
+
+.ti -8
+.BR "ip netns" " { " add " | " delete " } "
+.I NETNSNAME
+
+.ti -8
+.BR "ip netns exec "
+.I NETNSNAME command ...
+
+.ti -8
 .BR "ip route" " { "
 .BR list " | " flush " } "
 .I  SELECTOR
@@ -1006,6 +1020,11 @@ move the device to the network namespace associated with the process
 .IR "PID".
 
 .TP
+.BI netns " NETNSNAME"
+move the device to the network namespace associated with name
+.IR "NETNSNAME".
+
+.TP
 .BI alias " NAME"
 give the device a symbolic name for easy reference.
 
@@ -2470,6 +2489,43 @@ at any time.
 It prepends the history with the state snapshot dumped at the moment
 of starting.
 
+.SH ip netns - process network namespace management
+
+A network namespace is logically another copy of the network stack,
+with it's own routes, firewall rules, and network devices.
+
+By convention a named network namespace is an object at
+.BR "/var/run/netns/" NAME
+that can be opened.  The file descriptor resulting from opening
+.BR "/var/run/netns/" NAME 
+refers to the specified network namespace.  Holding that file
+descriptor open keeps the network namespace alive.  The file
+descriptor can be used with the
+.B setns(2)
+system call to change the network namespace associated with a task.
+
+The convention for network namespace aware applications is to look
+for global network configuration files first in
+.BR "/etc/netns/" NAME "/"
+then in
+.BR "/etc/".
+For example, if you want a different version of
+.BR /etc/resolv.conf
+for a network namespace used to isolate your vpn you would name it
+.BR /etc/netns/myvpn/resolv.conf.
+
+.B ip netns exec
+automates handling of this configuration, file convention for network
+namespace unaware applications, by creating a mount namespace and
+bind mounting all of the per network namespace configure files into
+their traditional location in /etc.
+
+.SS ip netns list - show all of the named network namespaces
+.SS ip netns monitor - report when network namespace names are created and destroyed
+.SS ip netns add NAME - create a new named network namespace
+.SS ip netns delete NAME - delete the name of a network namespace
+.SS ip netns exec NAME cmd ... - Run cmd in the named network namespace
+
 .SH ip xfrm - setting xfrm
 xfrm is an IP framework, which can transform format of the datagrams,
 .br
-- 
1.7.5.1.217.g4e3aa

