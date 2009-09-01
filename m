From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: gracefully exit from rtnl_listen()
Date: Tue, 1 Sep 2009 15:59:55 -0700
Message-ID: <20090901155955.7448c1d6@nehalam>
References: <1251841286-32463-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Ward <david.ward@ll.mit.edu>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58544 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755338AbZIAW76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 18:59:58 -0400
In-Reply-To: <1251841286-32463-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Sep 2009 17:41:26 -0400
David Ward <david.ward@ll.mit.edu> wrote:

> rtnl_listen() (in iproute2's libnetlink) allows a userspace application to
> monitor an RTNETLINK multicast group, so that the application can react to
> changes in the kernel's routing table, neighbor cache, etc. as they occur.
> (This is in contrast with using RTNETLINK to solicit the kernel for a full
> copy of the routing table or neighbor cache at a specific point in time.)
> 
> However rtnl_listen() creates an infinite loop, which does not break in the
> absence of errors, so there does not seem to be any way to gracefully exit
> from it. Existing applications that call rtnl_listen(), such as rtmon, break
> from this loop by terminating the entire application. There should be some
> mechanism for stopping rtnl_listen() and continuing program execution.
> 
> If you assume that rtnl_listen() will only need to be stopped because the
> application has received a signal (such as SIGINT), then the application's
> signal handler can call rtnl_close() to close the RTNETLINK socket.
> Afterwards, with this patch, rtnl_listen() can detect that the socket was
> closed during the interrupt and exit.
> 
> I am offering this as a starting point for consideration, but I feel that
> this is at best a poor solution. What is a better way to fix rtnl_listen()
> (and similar libnetlink functions for consistency)?
> ---
>  lib/libnetlink.c |   15 ++++++++++++---
>  1 files changed, 12 insertions(+), 3 deletions(-)

Good idea, but why not just change the while(1) loop?

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b68e2fd..cecfa34 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -188,7 +188,7 @@ int rtnl_dump_filter(struct rtnl_handle *rth,
 	char buf[16384];
 
 	iov.iov_base = buf;
-	while (1) {
+	while (rtnl->fd >= 0) {
 		int status;
 		struct nlmsghdr *h;
 
@@ -200,12 +200,12 @@ int rtnl_dump_filter(struct rtnl_handle *rth,
 				continue;
 			fprintf(stderr, "netlink receive error %s (%d)\n",
 				strerror(errno), errno);
-			return -1;
+			break;
 		}
 
 		if (status == 0) {
 			fprintf(stderr, "EOF on netlink\n");
-			return -1;
+			break;
 		}
 
 		h = (struct nlmsghdr*)buf;
@@ -251,6 +251,8 @@ skip_it:
 			exit(1);
 		}
 	}
+
+	return -1;
 }
 
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,


