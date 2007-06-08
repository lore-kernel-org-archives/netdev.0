From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] RFC: have tcp_recvmsg() check kthread_should_stop() and
 treat it as if it were signalled
Date: Fri, 8 Jun 2007 13:00:37 -0400
Message-ID: <20070608130037.f1675c29.jlayton@redhat.com>
References: <20070605152340.f09fa6f2.jlayton@redhat.com>
	<20070606085550.GA7351@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968639AbXFHRAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 13:00:41 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l58H0cOx028000
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 13:00:38 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l58H0ck1032646
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 13:00:38 -0400
Received: from tleilax.poochiereds.net (vpn-14-94.rdu.redhat.com [10.11.14.94])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l58H0bf4010852
	for <netdev@vger.kernel.org>; Fri, 8 Jun 2007 13:00:37 -0400
In-Reply-To: <20070606085550.GA7351@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Already sent this to several lists, but forgot netdev ;-)...

This one's sort of outside my normal area of expertise so sending this
as an RFC to gather feedback on the idea.

Some background:

The cifs_mount() and cifs_umount() functions currently send a signal to
the cifsd kthread prior to calling kthread_stop on it. The reasoning is
apparently that it's likely that cifsd will have called kernel_recvmsg()
and if it doesn't do this there can be a rather long delay when a
filesystem is unmounted.

The following patch is a first stab at removing this need. It makes it
so that in tcp_recvmsg() we also check kthread_should_stop() at any
point where we currently check to see if the task was signalled. If
that returns true, then it acts as if it were signalled.

I've tested this on a fairly recent kernel with a cifs module that
doesn't send signals on unmount and it seems to work as expected. I'm
just not clear on whether it will have any adverse side-effects.

Obviously if this approach is OK then we'll probably also want to fix
up other recvmsg functions (udp_recvmsg, etc).

Anyone care to comment?

Thanks,

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bd4c295..1ad91fa 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -258,6 +258,7 @@
 #include <linux/cache.h>
 #include <linux/err.h>
 #include <linux/crypto.h>
+#include <linux/kthread.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -1154,7 +1155,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if (tp->urg_data && tp->urg_seq == *seq) {
 			if (copied)
 				break;
-			if (signal_pending(current)) {
+			if (signal_pending(current) || kthread_should_stop()) {
 				copied = timeo ? sock_intr_errno(timeo) : -EAGAIN;
 				break;
 			}
@@ -1197,6 +1198,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 			    !timeo ||
 			    signal_pending(current) ||
+			    kthread_should_stop() ||
 			    (flags & MSG_PEEK))
 				break;
 		} else {
@@ -1227,7 +1229,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				break;
 			}
 
-			if (signal_pending(current)) {
+			if (signal_pending(current) || kthread_should_stop()) {
 				copied = sock_intr_errno(timeo);
 				break;
 			}
