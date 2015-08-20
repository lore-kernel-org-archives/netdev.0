From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCH net] netlink: mmap: fix tx type check
Date: Thu, 20 Aug 2015 12:43:53 +0900
Message-ID: <20150820034353.GA728@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
 <20150812.163819.620222685130362816.davem@davemloft.net>
 <20150814085807.GA30443@gmail.com>
 <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33541 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbHTDn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 23:43:59 -0400
Received: by padfo6 with SMTP id fo6so11640369pad.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 20:43:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55CDC51D.1060204@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can't send netlink message via mmaped netlink socket since

    commit: a8866ff6a5bce7d0ec465a63bc482a85c09b0d39
    netlink: make the check for "send from tx_ring" deterministic

msg->msg_iter.type is set to WRITE (1) at

    SYSCALL_DEFINE6(sendto, ...
        import_single_range(WRITE, ...
            iov_iter_init(1, WRITE, ...

call path, so that we need to check the type by iter_is_iovec()
to accept the WRITE.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 85ccd8b..4444687 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2456,7 +2456,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	 * sendmsg(), but that's what we've got...
 	 */
 	if (netlink_tx_is_mmaped(sk) &&
-	    msg->msg_iter.type == ITER_IOVEC &&
+	    iter_is_iovec(&msg->msg_iter) &&
 	    msg->msg_iter.nr_segs == 1 &&
 	    msg->msg_iter.iov->iov_base == NULL) {
 		err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
-- 
1.7.10.4
