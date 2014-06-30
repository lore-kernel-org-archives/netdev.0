From: Ben Pfaff <blp@nicira.com>
Subject: [PATCH] netlink: Fix netlink_recvmsg() handling of error from netlink_dump().
Date: Mon, 30 Jun 2014 15:35:04 -0700
Message-ID: <1404167704-22408-1-git-send-email-blp@nicira.com>
Cc: Ben Pfaff <blp@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:47619 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751333AbaF3WmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 18:42:18 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so6902228qac.41
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 15:42:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink_dump() returns a negative errno value on error.  Until now,
netlink_recvmsg() directly recorded that negative value in sk->sk_err,
but that's wrong since sk_err takes positive errno values.  (This manifests
as userspace receiving a positive return value from the recv() system call,
falsely indicating success.)

This bug was introduced in the commit that started checking the
netlink_dump() return value, commit b44d211 (netlink: handle errors from
netlink_dump()).

Multithreaded Netlink dumps are one way to trigger this behavior in
practice, as described in the commit message for the userspace workaround
posted here:
    http://openvswitch.org/pipermail/dev/2014-June/042339.html

Signed-off-by: Ben Pfaff <blp@nicira.com>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 15c731f..b7514b3 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
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
