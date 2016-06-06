From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] netfilter: x_tables: don't reject valid target size on some architectures
Date: Tue,  7 Jun 2016 00:38:16 +0200
Message-ID: <1465252697-1986-2-git-send-email-pablo@netfilter.org>
References: <1465252697-1986-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50784 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbcFFWie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 18:38:34 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 65F4ACD6F16
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:38:32 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 54BAF9EBA7
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:38:32 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3CE159EBA9
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:38:27 +0200 (CEST)
In-Reply-To: <1465252697-1986-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Quoting John Stultz:
  In updating a 32bit arm device from 4.6 to Linus' current HEAD, I
  noticed I was having some trouble with networking, and realized that
  /proc/net/ip_tables_names was suddenly empty.
  Digging through the registration process, it seems we're catching on the:

   if (strcmp(t->u.user.name, XT_STANDARD_TARGET) == 0 &&
       target_offset + sizeof(struct xt_standard_target) != next_offset)
         return -EINVAL;

  Where next_offset seems to be 4 bytes larger then the
  offset + standard_target struct size.

next_offset needs to be aligned via XT_ALIGN (so we can access all members
of ip(6)t_entry struct).

This problem didn't show up on i686 as it only needs 4-byte alignment for
u64, but iptables userspace on other 32bit arches does insert extra padding.

Reported-by: John Stultz <john.stultz@linaro.org>
Tested-by: John Stultz <john.stultz@linaro.org>
Fixes: 7ed2abddd20cf ("netfilter: x_tables: check standard target size too")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index c69c892..2675d58 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -612,7 +612,7 @@ int xt_compat_check_entry_offsets(const void *base, const char *elems,
 		return -EINVAL;
 
 	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) == 0 &&
-	    target_offset + sizeof(struct compat_xt_standard_target) != next_offset)
+	    COMPAT_XT_ALIGN(target_offset + sizeof(struct compat_xt_standard_target)) != next_offset)
 		return -EINVAL;
 
 	/* compat_xt_entry match has less strict aligment requirements,
@@ -694,7 +694,7 @@ int xt_check_entry_offsets(const void *base,
 		return -EINVAL;
 
 	if (strcmp(t->u.user.name, XT_STANDARD_TARGET) == 0 &&
-	    target_offset + sizeof(struct xt_standard_target) != next_offset)
+	    XT_ALIGN(target_offset + sizeof(struct xt_standard_target)) != next_offset)
 		return -EINVAL;
 
 	return xt_check_entry_match(elems, base + target_offset,
-- 
2.1.4
