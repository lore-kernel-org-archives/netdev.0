From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/10] netfilter: nfnetlink_log: work around uninitialized variable warning
Date: Wed, 11 Nov 2015 18:33:40 +0100
Message-ID: <1447263223-22662-8-git-send-email-pablo@netfilter.org>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48408 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbbKKRd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 12:33:59 -0500
Received: from antivirus1-rhel7.int (antivirus1.int [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9CB3C1392BF
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8D0BD5AE
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9CD5236D65
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:55 +0100 (CET)
In-Reply-To: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

After a recent (correct) change, gcc started warning about the use
of the 'flags' variable in nfulnl_recv_config()

net/netfilter/nfnetlink_log.c: In function 'nfulnl_recv_config':
net/netfilter/nfnetlink_log.c:320:14: warning: 'flags' may be used uninitialized in this function [-Wmaybe-uninitialized]
net/netfilter/nfnetlink_log.c:828:6: note: 'flags' was declared here

The warning first shows up in ARM s3c2410_defconfig with gcc-4.3 or
higher (including 5.2.1, which is the latest version I checked) I
tried working around it by rearranging the code but had no success
with that.

As a last resort, this initializes the variable to zero, which shuts
up the warning, but means that we don't get a warning if the code
is ever changed in a way that actually causes the variable to be
used without first being written.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 8cbc870829ec ("netfilter: nfnetlink_log: validate dependencies to avoid breaking atomicity")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 06eb48f..740cce4 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -825,7 +825,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	struct net *net = sock_net(ctnl);
 	struct nfnl_log_net *log = nfnl_log_pernet(net);
 	int ret = 0;
-	u16 flags;
+	u16 flags = 0;
 
 	if (nfula[NFULA_CFG_CMD]) {
 		u_int8_t pf = nfmsg->nfgen_family;
-- 
2.1.4
