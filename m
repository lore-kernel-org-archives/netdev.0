From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/8] netfilter: ipset: Null pointer exception in ipset list:set
Date: Thu, 23 Feb 2017 12:14:06 +0100
Message-ID: <1487848449-2731-6-git-send-email-pablo@netfilter.org>
References: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54910 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751231AbdBWLOY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 06:14:24 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ECEC6A4196
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DBA34DA86D
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BE82BDA841
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:19 +0100 (CET)
In-Reply-To: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vishwanath Pai <vpai@akamai.com>

If we use before/after to add an element to an empty list it will cause
a kernel panic.

$> cat crash.restore
create a hash:ip
create b hash:ip
create test list:set timeout 5 size 4
add test b before a

$> ipset -R < crash.restore

Executing the above will crash the kernel.

Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Reviewed-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_list_set.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 51077c53d76b..178d4eba013b 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -260,11 +260,14 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		else
 			prev = e;
 	}
+
+	/* If before/after is used on an empty set */
+	if ((d->before > 0 && !next) ||
+	    (d->before < 0 && !prev))
+		return -IPSET_ERR_REF_EXIST;
+
 	/* Re-add already existing element */
 	if (n) {
-		if ((d->before > 0 && !next) ||
-		    (d->before < 0 && !prev))
-			return -IPSET_ERR_REF_EXIST;
 		if (!flag_exist)
 			return -IPSET_ERR_EXIST;
 		/* Update extensions */
-- 
2.1.4
