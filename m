From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: ipt_ULOG: fix incorrect setting of ulog timer
Date: Mon, 24 Jun 2013 17:16:26 +0200
Message-ID: <1372086986-4080-2-git-send-email-pablo@netfilter.org>
References: <1372086986-4080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51604 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab3FXPQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 11:16:38 -0400
In-Reply-To: <1372086986-4080-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

The parameter of setup_timer should be &ulog->nlgroup[i].
the incorrect parameter will cause kernel panic in
ulog_timer.

Bug introducted in commit 355430671ad93546b34b4e91bdf720f3a704efa4
"netfilter: ipt_ULOG: add net namespace support for ipt_ULOG"

ebt_ULOG doesn't have this problem.

[ I have mangled this patch to fix nlgroup != 0 case, we were
  also crashing there --pablo ]

Tested-by: George Spelvin <linux@horizon.com>
Reported-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_ULOG.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index ff4b781..32b0e97 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -125,15 +125,16 @@ static void ulog_send(struct ulog_net *ulog, unsigned int nlgroupnum)
 /* timer function to flush queue in flushtimeout time */
 static void ulog_timer(unsigned long data)
 {
+	unsigned int groupnum = *((unsigned int *)data);
 	struct ulog_net *ulog = container_of((void *)data,
 					     struct ulog_net,
-					     nlgroup[*(unsigned int *)data]);
+					     nlgroup[groupnum]);
 	pr_debug("timer function called, calling ulog_send\n");
 
 	/* lock to protect against somebody modifying our structure
 	 * from ipt_ulog_target at the same time */
 	spin_lock_bh(&ulog->lock);
-	ulog_send(ulog, data);
+	ulog_send(ulog, groupnum);
 	spin_unlock_bh(&ulog->lock);
 }
 
@@ -407,8 +408,11 @@ static int __net_init ulog_tg_net_init(struct net *net)
 
 	spin_lock_init(&ulog->lock);
 	/* initialize ulog_buffers */
-	for (i = 0; i < ULOG_MAXNLGROUPS; i++)
-		setup_timer(&ulog->ulog_buffers[i].timer, ulog_timer, i);
+	for (i = 0; i < ULOG_MAXNLGROUPS; i++) {
+		ulog->nlgroup[i] = i;
+		setup_timer(&ulog->ulog_buffers[i].timer, ulog_timer,
+			    (unsigned long)&ulog->nlgroup[i]);
+	}
 
 	ulog->nflognl = netlink_kernel_create(net, NETLINK_NFLOG, &cfg);
 	if (!ulog->nflognl)
-- 
1.7.10.4
