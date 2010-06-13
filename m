From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 5/8] af_netlink: Add needed scm_destroy after scm_send.
Date: Sun, 13 Jun 2010 06:31:06 -0700
Message-ID: <m1ljajgiud.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38425 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab0FMNbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:31:11 -0400
In-Reply-To: <m1hbl7hxo3.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 13 Jun 2010 06\:25\:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


scm_send occasionally allocates state in the scm_cookie, so I have
modified netlink_sendmsg to guarantee that when scm_send succeeds
scm_destory will be called to free that state.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/netlink/af_netlink.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6464a19..35654e7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1306,19 +1306,23 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
 
-	if (NULL == siocb->scm)
+	if (NULL == siocb->scm) {
 		siocb->scm = &scm;
+		memset(&scm, 0, sizeof(scm));
+	}
 	err = scm_send(sock, msg, siocb->scm);
 	if (err < 0)
 		return err;
 
 	if (msg->msg_namelen) {
+		err = -EINVAL;
 		if (addr->nl_family != AF_NETLINK)
-			return -EINVAL;
+			goto out;
 		dst_pid = addr->nl_pid;
 		dst_group = ffs(addr->nl_groups);
+		err =  -EPERM;
 		if (dst_group && !netlink_capable(sock, NL_NONROOT_SEND))
-			return -EPERM;
+			goto out;
 	} else {
 		dst_pid = nlk->dst_pid;
 		dst_group = nlk->dst_group;
@@ -1370,6 +1374,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	err = netlink_unicast(sk, skb, dst_pid, msg->msg_flags&MSG_DONTWAIT);
 
 out:
+	scm_destroy(siocb->scm);
 	return err;
 }
 
-- 
1.6.5.2.143.g8cc62

