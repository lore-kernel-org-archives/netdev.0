From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/13] netfilter: xt_NFLOG: fix unexpected truncated packet
Date: Fri, 21 Oct 2016 12:12:14 +0200
Message-ID: <1477044743-18948-5-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36382 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754959AbcJUKMs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 06:12:48 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 87D6526E24
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 76561DA81C
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 51F0BBAC39
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:38 +0200 (CEST)
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Justin and Chris spotted that iptables NFLOG target was broken when they
upgraded the kernel to 4.8: "ulogd-2.0.5- IPs are no longer logged" or
"results in segfaults in ulogd-2.0.5".

Because "struct nf_loginfo li;" is a local variable, and flags will be
filled with garbage value, not inited to zero. So if it contains 0x1,
packets will not be logged to the userspace anymore.

Fixes: 7643507fe8b5 ("netfilter: xt_NFLOG: nflog-range does not truncate packets")
Reported-by: Justin Piszcz <jpiszcz@lucidpixels.com>
Reported-by: Chris Caputo <ccaputo@alt.net>
Tested-by: Chris Caputo <ccaputo@alt.net>
Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_NFLOG.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index 018eed7e1ff1..8668a5c18dc3 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -32,6 +32,7 @@ nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	li.u.ulog.copy_len   = info->len;
 	li.u.ulog.group	     = info->group;
 	li.u.ulog.qthreshold = info->threshold;
+	li.u.ulog.flags	     = 0;
 
 	if (info->flags & XT_NFLOG_F_COPY_LEN)
 		li.u.ulog.flags |= NF_LOG_F_COPY_LEN;
-- 
2.1.4
