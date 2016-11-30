From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/11] netfilter: arp_tables: fix invoking 32bit "iptable -P INPUT ACCEPT" failed in 64bit kernel
Date: Wed, 30 Nov 2016 22:57:25 +0100
Message-ID: <1480543045-3389-12-git-send-email-pablo@netfilter.org>
References: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42156 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755118AbcK3V5t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 16:57:49 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5DE2F13C0EE
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4EE79DA860
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3A510DA85D
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:57:45 +0100 (CET)
In-Reply-To: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hongxu Jia <hongxu.jia@windriver.com>

Since 09d9686047db ("netfilter: x_tables: do compat validation via
translate_table"), it used compatr structure to assign newinfo
structure.  In translate_compat_table of ip_tables.c and ip6_tables.c,
it used compatr->hook_entry to replace info->hook_entry and
compatr->underflow to replace info->underflow, but not do the same
replacement in arp_tables.c.

It caused invoking 32-bit "arptbale -P INPUT ACCEPT" failed in 64bit
kernel.
--------------------------------------
root@qemux86-64:~# arptables -P INPUT ACCEPT
root@qemux86-64:~# arptables -P INPUT ACCEPT
ERROR: Policy for `INPUT' offset 448 != underflow 0
arptables: Incompatible with this kernel
--------------------------------------

Fixes: 09d9686047db ("netfilter: x_tables: do compat validation via translate_table")
Signed-off-by: Hongxu Jia <hongxu.jia@windriver.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index b31df597fd37..697538464e6e 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1201,8 +1201,8 @@ static int translate_compat_table(struct xt_table_info **pinfo,
 
 	newinfo->number = compatr->num_entries;
 	for (i = 0; i < NF_ARP_NUMHOOKS; i++) {
-		newinfo->hook_entry[i] = info->hook_entry[i];
-		newinfo->underflow[i] = info->underflow[i];
+		newinfo->hook_entry[i] = compatr->hook_entry[i];
+		newinfo->underflow[i] = compatr->underflow[i];
 	}
 	entry1 = newinfo->entries;
 	pos = entry1;
-- 
2.1.4
