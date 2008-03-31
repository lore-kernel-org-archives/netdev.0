From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Mon, 31 Mar 2008 12:33:11 -0700
Message-ID: <20080331123311.64e4ca37@extreme>
References: <20080321110515.422f9798@extreme>
	<47EAAFEC.6000805@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/Hc2P0X7WXYb_ql=UFd4drBW"
Cc: David Miller <davem@davemloft.net>, Jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56681 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752402AbYCaTdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 15:33:19 -0400
In-Reply-To: <47EAAFEC.6000805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/Hc2P0X7WXYb_ql=UFd4drBW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wed, 26 Mar 2008 21:19:56 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Make socket filters work for netlink unicast and notifications.
> > This is useful for applications like Zebra that get overrun with
> > messages that are then ignored.
> > 
> > Note: netlink messages are in host byte order, but packet filter
> > state machine operations are done as network byte order.
> 
> 
> Do you have an example for a filter for this? I have a similar
> patch that adds a new filter instruction for parsing netlink
> attributes, which seemed necessary for getting at nested
> attributes without too much trouble.
> 
> Attached for reference together with a libnl testing
> patch for ctnetlink.
> 

Here is the example program:
   it uses netlink IPC and has one thread send route notifications
   and the other filters.

   to test the mulitcast path used a hacked version of ip_monitor from iproute

   see attachment for the quagga patch.

--MP_/Hc2P0X7WXYb_ql=UFd4drBW
Content-Type: text/x-csrc; name=netlink-ipc.c
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=netlink-ipc.c

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include <netinet/in.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <linux/filter.h>
#include <asm/byteorder.h>

static inline int nlmsg_msg_size(int payload)
{
	return NLMSG_HDRLEN + payload;
}

static inline void *nlmsg_data(const struct nlmsghdr *nlh)
{
	return (unsigned char *) nlh + NLMSG_HDRLEN;
}

static inline int nlmsg_total_size(int payload)
{
	return NLMSG_ALIGN(nlmsg_msg_size(payload));
}

static inline int nlmsg_padlen(int payload)
{
	return nlmsg_total_size(payload) - nlmsg_msg_size(payload);
}


static struct nlmsghdr *nlmsg_put(void *buf, uint32_t pid, uint32_t seq,
				  int type, int payload, int flags)
{
	struct nlmsghdr *nlh;

	nlh = (struct nlmsghdr *) buf;
	nlh->nlmsg_type = type;
	nlh->nlmsg_len = nlmsg_msg_size(payload);
	nlh->nlmsg_flags = flags;
	nlh->nlmsg_pid = pid;
	nlh->nlmsg_seq = seq;

	memset((unsigned char *) nlmsg_data(nlh) + payload, 0,
	       nlmsg_padlen(payload));

	return nlh;
}

static int fill_info(unsigned char *buf, uint32_t pid, uint32_t seq, int event,
		     int flags, unsigned proto)
{
	struct rtmsg *r;
	struct nlmsghdr *nlh;

	nlh = nlmsg_put(buf, pid, seq, event, sizeof(*r), 0);

	r = nlmsg_data(nlh);
	r->rtm_family	 = AF_INET;
	r->rtm_dst_len	= 32;
	r->rtm_src_len	= 0;
	r->rtm_tos	= 0;
	r->rtm_table	= RT_TABLE_MAIN;
	r->rtm_type	= 0;
	r->rtm_scope	= RT_SCOPE_UNIVERSE;
	r->rtm_protocol = RTPROT_UNSPEC;
	r->rtm_flags	= flags;

	return (void *) (r+1) - (void *) buf;
}

static const char *nltypes[] = {
	[RTM_NEWROUTE] = "RTM_NEWROUTE",
	[RTM_DELROUTE] = "RTM_DELROUTE",
	[RTM_GETROUTE] = "RTM_GETROUTE",
	[RTM_NEWLINK] = "RTM_NEWLINK",
	[RTM_DELLINK] = "RTM_DELLINK",
	[RTM_GETLINK] = "RTM_GETLINK",
	[RTM_NEWADDR] = "RTM_NEWADDR",
	[RTM_DELADDR] = "RTM_DELADDR",
	[RTM_GETADDR] = "RTM_GETADDR",
};

static struct sock_filter filter[] = {
	BPF_STMT(BPF_LD|BPF_ABS|BPF_H, 4),		/* 0: ldh [4]	          */
	BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, __constant_htons(RTM_NEWROUTE), 0, 3),	
							/* 1: jeq 0x18 jt 2 jf 5  */
	BPF_STMT(BPF_LD|BPF_ABS|BPF_B, 23),		/* 2: ldb [23]		  */
	BPF_JUMP(BPF_JMP+ BPF_B, RTPROT_ZEBRA, 2, 0),
							/* 3: jeq 0xb jt 4  jf 5  */

	BPF_STMT(BPF_RET|BPF_K, 0),			/* 4: ret 0               */
	BPF_STMT(BPF_RET|BPF_K, 0xffff),		/* 5: ret 0xffff          */
};


int main(int ac, char **av)
{
	int i, sk, cc;
	struct sockaddr_nl snl = {
		.nl_family = AF_NETLINK,
	};
	socklen_t snl_len = sizeof snl;
	pid_t pid;
	unsigned char buf[4096];
	struct sock_fprog prog = {
		.len = sizeof(filter) / sizeof(filter[0]),
		.filter = filter,
	};
	
	for (i = 0; i < prog.len; i++ )
		printf("%d: %#04x %d %d %#08x\n", i,
		       filter[i].code, filter[i].jt, filter[i].jf, filter[i].k);
	printf("\n");
	fflush(stdout);

	sk = socket(AF_NETLINK, SOCK_DGRAM, NETLINK_USERSOCK);
	if (sk < 0)
		perror("socket");

	if (bind(sk, (struct sockaddr *) &snl, sizeof snl) < 0)
		perror("bind");
	
	if (getsockname(sk, (struct sockaddr *) &snl, &snl_len) < 0)
		perror("getsockname");
	
	if (setsockopt(sk, SOL_SOCKET, SO_ATTACH_FILTER, &prog, sizeof(prog)) < 0) 
		perror("setsockopt attach filte");

	pid = fork();
	if (pid == 0) {
		struct nlmsghdr *nlh;
		do {
			struct rtmsg *r;
			cc = recv(sk, &buf, sizeof buf, 0);
			if (cc < 0)
				perror("recv");
			
			for (i = 0; i < 64 && i < cc; i++)
				printf("%02x%c", buf[i],
				       (i % 16) == 15 ? '\n' : ' ');

			nlh = (struct nlmsghdr *) buf;
			printf("\n\tlen=%d type=%s flags=%#x seq=%#x pid=%d\n",
			       nlh->nlmsg_len, nltypes[nlh->nlmsg_type],
			       nlh->nlmsg_flags, nlh->nlmsg_seq, nlh->nlmsg_pid);

			r = NLMSG_DATA(nlh);
			printf("\tfamily=%d table=%d proto=%d type=%#x flags=%#x\n\n",
			       r->rtm_family, r->rtm_table, r->rtm_protocol,
			       r->rtm_type, r->rtm_flags);

		} while (nlh->nlmsg_type != RTM_DELLINK);
		exit(0);
	} else {
		cc = fill_info(buf, 0, 1, RTM_NEWLINK, 0, RTPROT_UNSPEC);
		if (sendto(sk, buf, cc, 0,
			   (struct sockaddr *) &snl, snl_len) < 0)
			perror("sendto");

		cc = fill_info(buf, 0, 1, RTM_NEWROUTE, RTM_F_CLONED, RTPROT_UNSPEC);
		if (sendto(sk, buf, cc, 0,
			   (struct sockaddr *) &snl, snl_len) < 0)
			perror("sendto");

		cc = fill_info(buf, 0, 1, RTM_NEWROUTE, 0, RTPROT_ZEBRA);
		if (sendto(sk, buf, cc, 0,
			   (struct sockaddr *) &snl, snl_len) < 0)
			perror("sendto");

		cc = fill_info(buf, 0, 1, RTM_NEWROUTE, 0, RTPROT_UNSPEC);
		if (sendto(sk, buf, cc, 0,
			   (struct sockaddr *) &snl, snl_len) < 0)
			perror("sendto");

		cc = fill_info(buf, 0, 1, RTM_DELLINK, 0, RTPROT_UNSPEC);
		if (sendto(sk, buf, cc, 0,
			   (struct sockaddr *) &snl, snl_len) < 0)
			perror("sendto");

		waitpid(pid, NULL, 0);
	}

	return 0;
}

--MP_/Hc2P0X7WXYb_ql=UFd4drBW
Content-Type: text/x-patch; name=zebra-filter.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=zebra-filter.patch

>From 2bc693173112ea436884aca19352624504e2246a Mon Sep 17 00:00:00 2001
From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Mon, 31 Mar 2008 12:23:25 -0700
Subject: [PATCH] Filter unwanted netlink messages

Use socket filter to drop unwanted messages on the netlink listen socket.
This prevents problems where the listener socket buffer gets overrruns
with echos of the new route update that occurs when link changes.
---
 lib/zebra.h        |    1 +
 zebra/rt_netlink.c |   33 ++++++++++++++++++++++++++++++++-
 2 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/lib/zebra.h b/lib/zebra.h
index 150aa2c..d4f68cf 100644
--- a/lib/zebra.h
+++ b/lib/zebra.h
@@ -162,6 +162,7 @@ typedef int socklen_t;
 #ifdef HAVE_NETLINK
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
+#include <linux/filter.h>
 #else
 #define RT_TABLE_MAIN		0
 #endif /* HAVE_NETLINK */
diff --git a/zebra/rt_netlink.c b/zebra/rt_netlink.c
index f071eb2..07e473b 100644
--- a/zebra/rt_netlink.c
+++ b/zebra/rt_netlink.c
@@ -41,6 +41,7 @@
 #include "zebra/redistribute.h"
 #include "zebra/interface.h"
 #include "zebra/debug.h"
+#include <stddef.h>
 
 /* Socket interface to kernel */
 struct nlsock
@@ -1938,6 +1939,33 @@ kernel_read (struct thread *thread)
   return 0;
 }
 
+/* Filter out messages from self that occur on listener socket */
+static void netlink_install_filter (int sock)
+{
+  /* BPF code to exclude all RTM_NEWROUTE messages from ZEBRA */
+  struct sock_filter filter[] = {
+    BPF_STMT(BPF_LD|BPF_ABS|BPF_H, offsetof(struct nlmsghdr, nlmsg_type)),
+    						/* 0: ldh [4]	          */
+    BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, htons(RTM_NEWROUTE), 0, 3),	
+						/* 1: jeq 0x18 jt 2 jf 5  */
+    BPF_STMT(BPF_LD|BPF_ABS|BPF_B, 
+	     sizeof(struct nlmsghdr) + offsetof(struct rtmsg, rtm_protocol)),
+    						/* 2: ldb [23]		  */
+    BPF_JUMP(BPF_JMP+ BPF_B, RTPROT_ZEBRA, 2, 0),
+    						/* 3: jeq 0xb jt 4  jf 5  */
+    BPF_STMT(BPF_RET|BPF_K, 0),			/* 4: ret 0               */
+    BPF_STMT(BPF_RET|BPF_K, 0xffff),		/* 5: ret 0xffff          */
+  };
+
+  struct sock_fprog prog = {
+    .len = sizeof(filter) / sizeof(filter[0]),
+    .filter = filter,
+  };
+
+  if (setsockopt(sock, SOL_SOCKET, SO_ATTACH_FILTER, &prog, sizeof(prog)) < 0) 
+    zlog_warn ("Can't install socket filter: %s\n", safe_strerror(errno));
+}
+
 /* Exported interface function.  This function simply calls
    netlink_socket (). */
 void
@@ -1954,5 +1982,8 @@ kernel_init (void)
 
   /* Register kernel socket. */
   if (netlink.sock > 0)
-    thread_add_read (zebrad.master, kernel_read, NULL, netlink.sock);
+    {
+      netlink_install_filter (netlink.sock);
+      thread_add_read (zebrad.master, kernel_read, NULL, netlink.sock);
+    }
 }
-- 
1.5.4.3


--MP_/Hc2P0X7WXYb_ql=UFd4drBW--
