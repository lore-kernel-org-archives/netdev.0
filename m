From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] netlink: fix broadcasting to the wrong group.
Date: Mon, 17 Apr 2006 13:36:33 +0400
Message-ID: <20060417093632.GA29057@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:13799 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750712AbWDQJgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 05:36:46 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

When application is bound to group N and it is less than 32
and has first bit set (I tested with 1, 3, 5) and kernel broadcasts
events to group number 1, application will receive messages, even if
1. it was not subscribed to that group
2. it was bound to different group

Attached trivial test module and userspace program.
make
insmod nltest.ko
./nluser -g5

see the dmesg.
Test module sends data to group number 1, but application is bound and
subscribed to group 5, but still receives messages.

This issue happens due to the following check in do_one_broadcast():

if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
	    !test_bit(p->group - 1, nlk->groups))

nlk->groups is set at bind time to the userspace provided bind group.
So in above case it will be 5.
But above test_bit() is supposed to check subscribed groups, which are
set using set_bit(users_group - 1, nlk->groups).
So when kernelspace broadcasts to group 1 above test_bit() returns true
and message is delivered to the wrong socket.

Attached patch removes nlk->groups[0] assignment at bind time since it
is completely meaningless due to subscription introduction.
nltest.c - simple test module which broadcasts events to group 1.
nluser.c - userspace application which receives data from socket bound
to specified group.

Tested with different groups (less than 32 though).
With patch applied it is required to subscribe to any group one wants to
listen to.
Patch is against 2.6.16

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 59dc7d1..895958b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -588,7 +588,6 @@ static int netlink_bind(struct socket *s
 	netlink_update_subscriptions(sk, nlk->subscriptions +
 	                                 hweight32(nladdr->nl_groups) -
 	                                 hweight32(nlk->groups[0]));
-	nlk->groups[0] = (nlk->groups[0] & ~0xffffffffUL) | nladdr->nl_groups; 
 	netlink_table_ungrab();
 
 	return 0;

-- 
	Evgeniy Polyakov

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename="nltest.c"

/*
 * nltest.c - netlink testing module.
 *
 * Copyright (c) 2006 Evgeniy Polyakov <johnpol@2ka.mipt.ru>
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/skbuff.h>
#include <linux/netlink.h>
#include <net/sock.h>

static struct sock *nls;
static atomic_t nls_seq = ATOMIC_INIT(0);
static u32 nls_groups = 1;
module_param(nls_groups, uint, 0);

static unsigned int nls_pid;
static unsigned int nls_size = PAGE_SIZE;

static void nls_work_func(void *data);
static DECLARE_WORK(nls_work, nls_work_func, NULL);

static int nls_netlink_broadcast(void)
{
	unsigned int size;
	struct sk_buff *skb;
	struct nlmsghdr *nlh;
	unsigned int pid;
	int ret;

	size = NLMSG_SPACE(nls_size);

	skb = alloc_skb(size, GFP_KERNEL);
	if (!skb)
		return -ENOMEM;

	pid = nls_pid;

	nlh = NLMSG_PUT(skb, pid, atomic_inc_return(&nls_seq), NLMSG_DONE, size - sizeof(*nlh));
	NETLINK_CB(skb).dst_group = nls_groups;
	ret = netlink_broadcast(nls, skb, pid, nls_groups, GFP_KERNEL);

	printk("%s: group: %u, pid: %u, ret: %d.\n", __func__, nls_groups, pid, ret);
	
	return ret;

nlmsg_failure:
	kfree_skb(skb);
	return -EINVAL;
}

static void nls_work_func(void *data)
{
	nls_netlink_broadcast();
	schedule_delayed_work(&nls_work, HZ);
}

static int nls_init(void)
{
	nls = netlink_kernel_create(NETLINK_W1, 1, NULL, THIS_MODULE);
	if (!nls) {
		printk(KERN_ERR "Failed to create new netlink socket(%u).\n",
			NETLINK_W1);
	}

	schedule_delayed_work(&nls_work, HZ);

	return 0;
}

static void nls_fini(void)
{
	cancel_rearming_delayed_work(&nls_work);
	flush_scheduled_work();
	if (nls && nls->sk_socket)
		sock_release(nls->sk_socket);
}

module_init(nls_init);
module_exit(nls_fini);

MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Netlink testing module.");

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename="nluser.c"

/*
 * 	nluser.c
 *
 * Copyright (c) 2006 Evgeniy Polyakov <johnpol@2ka.mipt.ru>
 * 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include <asm/types.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/poll.h>
#include <sys/mman.h>
#include <sys/signal.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/wait.h>

#include <linux/netlink.h>
#include <linux/types.h>
#include <linux/rtnetlink.h>

#include <arpa/inet.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <time.h>

static int need_exit;

static void usage(char *procname)
{
	fprintf(stderr, "Usage: %s -l logfile -g group -p pid -s size -h\n", procname);
	fprintf(stderr, "	-l logfile	- log file. Default stdout.\n");
	fprintf(stderr, "	-g group	- group number used. Default 1.\n");
	fprintf(stderr, "	-p pid		- pid number used. Default is process id.\n");
	fprintf(stderr, "	-s size		- receiving buffer size. Default is 4096.\n");
	fprintf(stderr, "	-h		- this help.\n");
}

static int nls_create_user(FILE *out, unsigned int size, unsigned int pid, unsigned int group)
{
	struct pollfd pfd;
	struct sockaddr_nl l_local;
	char *buf;
	int s, len, received = 0;
	struct nlmsghdr *reply;

	buf = malloc(size * 2);	/* Should be enough to store netlink overhead. */
	if (!buf)
		return -ENOMEM;

	s = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_W1);
	if (s == -1) {
		perror("socket");
		return -1;
	}

	l_local.nl_family = AF_NETLINK;
	l_local.nl_groups = group;
	l_local.nl_pid = pid;

	if (bind(s, (struct sockaddr *)&l_local, sizeof(struct sockaddr_nl)) == -1) {
		fprintf(out, "Failed to bind to pid %u: %s [%d].\n", pid, strerror(errno), errno);
		close(s);
		return -1;
	}

	len = l_local.nl_groups;
	setsockopt(s, 270, 1, &len, sizeof(len));

	pfd.fd = s;

	while (!need_exit) {
		pfd.events = POLLIN;
		pfd.revents = 0;
		switch (poll(&pfd, 1, -1)) {
			case 0:
				need_exit = 1;
				break;
			case -1:
				if (errno != EINTR) {
					need_exit = 1;
					break;
				}
				continue;
		}
		if (need_exit)
			break;
		
		memset(buf, 0, 2 * size);
		len = recv(s, buf, 2 * size, 0);
		if (len == -1) {
			perror("recv buf");
			close(s);
			return -1;
		}
		reply = (struct nlmsghdr *)buf;

		fprintf(out, "%3d: pid=%u, seq=%u.\n", received, reply->nlmsg_pid, reply->nlmsg_seq);

		switch (reply->nlmsg_type) {
		case NLMSG_ERROR:
			fprintf(out, "Error message received.\n");
			break;
		case NLMSG_DONE:
			received++;
			break;
		default:
			break;
		}
	}

	close(s);

	return 0;
}

int main(int argc, char *argv[])
{
	int ch;
	FILE *out;
	char *logfile = NULL;
	unsigned int size, pid, group;

	size = 4096;
	pid = getpid();
	group = 1;
	
	while ((ch = getopt(argc, argv, "l:g:s:p:h")) != -1) {
		switch (ch) {
			case 'l':
				logfile = optarg;
				break;
			case 'g':
				group = atoi(optarg);
				break;
			case 's':
				size = atoi(optarg);
				break;
			case 'p':
				pid = atoi(optarg);
				break;
			default:
			case 'h':
				usage(argv[0]);
				return -1;
		}
	}

	if (logfile == NULL) {
		out = stdout;
		logfile = "(stdout)";
	} else {
		out = fopen(argv[1], "a+");
		if (!out) {
			fprintf(stderr, "Unable to open %s for writing: %s\n",
				argv[1], strerror(errno));
			out = stdout;
			logfile = "(stdout)";
		}
	}

	printf("logfile: %s, size: %u, pid: %u, group: %u.\n", logfile, size, pid, group);

	return nls_create_user(out, size, pid, group);
}

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename=Makefile

obj-m		:= nltest.o

KDIR	:= /lib/modules/$(shell uname -r)/build
#KDIR	:= /usr/local/src/linux/linux-2.6.9
#KDIR	:= /home/s0mbre/aWork/git/linux-2.6/linux-2.6.w1
PWD	:= $(shell pwd)

UCFLAGS	:= -I$(KDIR)/include -W -Wall

default:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) MOD_ROOT=`pwd` modules

clean:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) MOD_ROOT=`pwd` clean
	@rm -f nluser *.o *~

nluser: nluser.c
	$(CC) $(UCFLAGS) nluser.c -o nluser

--J2SCkAp4GZ/dPZZf--
