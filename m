From: Ben Pfaff <blp@nicira.com>
Subject: [PATCH v2] netlink: Fix handling of error from netlink_dump().
Date: Wed,  9 Jul 2014 10:31:22 -0700
Message-ID: <1404927082-8647-1-git-send-email-blp@nicira.com>
Cc: Ben Pfaff <blp@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:41165 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750951AbaGIRcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 13:32:33 -0400
Received: by mail-vc0-f175.google.com with SMTP id hy4so7584060vcb.20
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 10:32:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink_dump() returns a negative errno value on error.  Until now,
netlink_recvmsg() directly recorded that negative value in sk->sk_err, but
that's wrong since sk_err takes positive errno values.  (This manifests as
userspace receiving a positive return value from the recv() system call,
falsely indicating success.) This bug was introduced in the commit that
started checking the netlink_dump() return value, commit b44d211 (netlink:
handle errors from netlink_dump()).

Multithreaded Netlink dumps are one way to trigger this behavior in
practice, as described in the commit message for the userspace workaround
posted here:
    http://openvswitch.org/pipermail/dev/2014-June/042339.html

This commit also fixes the same bug in netlink_poll(), introduced in commit
cd1df525d (netlink: add flow control for memory mapped I/O).

Signed-off-by: Ben Pfaff <blp@nicira.com>
---
v1->v2: Fix same bug in another place, as requested by Dave Miller.

 net/netlink/af_netlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 15c731f..e6fac7e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -636,7 +636,7 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 		while (nlk->cb_running && netlink_dump_space(nlk)) {
 			err = netlink_dump(sk);
 			if (err < 0) {
-				sk->sk_err = err;
+				sk->sk_err = -err;
 				sk->sk_error_report(sk);
 				break;
 			}
@@ -2483,7 +2483,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	    atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2) {
 		ret = netlink_dump(sk);
 		if (ret) {
-			sk->sk_err = ret;
+			sk->sk_err = -ret;
 			sk->sk_error_report(sk);
 		}
 	}
-- 
1.7.10.4
