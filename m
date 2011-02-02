From: kaber@trash.net
Subject: [PATCH 1/4] netfilter: ctnetlink: fix missing refcount increment during dumps
Date: Thu,  3 Feb 2011 00:45:27 +0100
Message-ID: <1296690330-9887-2-git-send-email-kaber@trash.net>
References: <1296690330-9887-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45198 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755392Ab1BBXpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:45:47 -0500
In-Reply-To: <1296690330-9887-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

In 13ee6ac netfilter: fix race in conntrack between dump_table and
destroy, we recovered spinlocks to protect the dump of the conntrack
table according to reports from Stephen and acknowledgments on the
issue from Eric.

In that patch, the refcount bump that allows to keep a reference
to the current ct object was removed. However, we still decrement
the refcount for that object in the output path of
ctnetlink_dump_table():

        if (last)
                nf_ct_put(last)

Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_netlink.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 93297aa..eead9db 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -667,6 +667,7 @@ restart:
 			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
 						cb->nlh->nlmsg_seq,
 						IPCTNL_MSG_CT_NEW, ct) < 0) {
+				nf_conntrack_get(&ct->ct_general);
 				cb->args[1] = (unsigned long)ct;
 				goto out;
 			}
-- 
1.7.2.3

