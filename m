From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] [RFC] netlink: fix possible spoofing from non-root
 processes
Date: Sun, 19 Aug 2012 23:23:27 +0200
Message-ID: <20120819212327.GA14853@1984>
References: <1345224149-5946-1-git-send-email-pablo@netfilter.org>
 <1345224149-5946-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58679 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127Ab2HSVXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Aug 2012 17:23:32 -0400
Content-Disposition: inline
In-Reply-To: <1345224149-5946-3-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 17, 2012 at 07:22:29PM +0200, pablo@netfilter.org wrote:
[...]
> [ I don't know any FOSS program making use of Netlink to communicate
>   to processes, please, let me know if I'm missing anyone important ]

Patrick pinged me for little reminder on NETLINK_USERSOCK. We still
have to allow netlink-to-netlink userspace communication for it.

So, please find a new version of this patch that allows non-root
processes for that Netlink bus. For others, my patch restricts to root
processes the ability of sending messages with dst_pid != 0.

--sdtB3X0nJg68CQEu
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-RFC-netlink-fix-possible-spoofing-from-non-root-proc.patch"

>From 78ed359b9802569caebbf2d3507d08d6c7204a84 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 16 Aug 2012 17:58:18 +0200
Subject: [PATCH] [RFC] netlink: fix possible spoofing from non-root processes

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

[ Patrick McHardy has pinged me to let me know about NETLINK_USERSOCK.
  Thus, this patch sets NL_CFG_F_NONROOT_SEND to allow non-root
  netlink-to-netlink userspace communication for that Netlink bus. ]

However, if we want to ensure full backward compatibility, a new
version of this patch including NL_CFG_F_NONROOT_SEND flags need
to be set in all kernel subsystems. However, I don't think it
makes sense to use NETLINK_ROUTE to communicate two processes
that are sending no matter what information that is not related
to link/neighbouring/routing?

Still, if someone wants to make use of Netlink for this, eg.
I remember people willing to implement D-BUS over Netlink,
then they can reserve some Netlink bus explicitly for this and
set NL_CFG_F_NONROOT_SEND to it.

Reported-by: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netlink/af_netlink.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d04f923..b3e0e2c 100644
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
@@ -2141,6 +2142,7 @@ static void __init netlink_add_usersock_entry(void)
 	rcu_assign_pointer(nl_table[NETLINK_USERSOCK].listeners, listeners);
 	nl_table[NETLINK_USERSOCK].module = THIS_MODULE;
 	nl_table[NETLINK_USERSOCK].registered = 1;
+	nl_table[NETLINK_USERSOCK].flags = NL_CFG_F_NONROOT_SEND;
 
 	netlink_table_ungrab();
 }
-- 
1.7.10.4


--sdtB3X0nJg68CQEu--
