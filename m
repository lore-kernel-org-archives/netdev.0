From: pablo@netfilter.org
Subject: [PATCH 2/2] [RFC] netlink: fix possible spoofing from non-root processes
Date: Fri, 17 Aug 2012 19:22:29 +0200
Message-ID: <1345224149-5946-3-git-send-email-pablo@netfilter.org>
References: <1345224149-5946-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60266 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757730Ab2HQRXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 13:23:39 -0400
In-Reply-To: <1345224149-5946-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Non-root user-space processes can send netlink messages to other
processes that are well-known for being subscribed to Netlink
asynchronous notifications. This allows ilegitimate non-root
process to send forged messages to them.

This is usually fixed by checking for Netlink portID in the
message receival path of the user-space process. In general,
portID == 0 means that the origin of the messages comes from the
kernel. Thus, discarding any message not coming from the kernel.
This is true for rtnetlink.

However, ctnetlink sets the portID in event messages that has
been triggered by some user-space process, eg. conntrack utility.
So other processes subscribed to ctnetlink events, eg. conntrackd,
know that the event was triggered by some user-space action.

This patch adds capability validation in case that dst_pid is set
in netlink_sendmsg(). This approach is aggressive since any existing
application using any of the Netlink busses to deliver messages
between two user-space processes will break.

[ I don't know any FOSS program making use of Netlink to communicate
  to processes, please, let me know if I'm missing anyone important ]

Anyway, if we want to ensure full backward compatibility, a new
version of this patch including NL_CFG_F_NONROOT_SEND flags need
to be set in all kernel subsystems. However, I don't think it
makes sense to use NETLINK_ROUTE to communicate two processes
that are sending no matter what information that is not related
to link/neighbouring/routing?

Still, if someone wants to make use of Netlink for this, eg.
I remember people willing to implement D-BUS over Netlink,
then we can reserve some Netlink bus explicitly for this and
set NL_CFG_F_NONROOT_SEND to it.

Not related to this, but I noticed that some existing well-known
user-space programs set SO_PASSCRED to obtain credentials while
trying to solve this. But they do it wrong, since they misinterpret
credentials containing pid == 0 as "yes, this message is really
coming from the kernel". So those programs will be also happy
that if this patch gets in, since it will fix spoofing for them.

Reported-by: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netlink/af_netlink.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d04f923..758993f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1373,7 +1373,8 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		dst_pid = addr->nl_pid;
 		dst_group = ffs(addr->nl_groups);
 		err =  -EPERM;
-		if (dst_group && !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
+		if ((dst_group || dst_pid) &&
+		    !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
 			goto out;
 	} else {
 		dst_pid = nlk->dst_pid;
-- 
1.7.10.4
