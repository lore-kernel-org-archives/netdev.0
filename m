From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH net] ipv6: avoid dad-failures for addresses with NODAD
Date: Fri, 12 May 2017 17:03:39 -0700
Message-ID: <20170513000339.15843-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33961 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757496AbdEMADo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 20:03:44 -0400
Received: by mail-pf0-f193.google.com with SMTP id w69so8557834pfk.1
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 17:03:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Every address gets added with TENTATIVE flag even for the addresses with
IFA_F_NODAD flag and dad-work is scheduled for them. During this DAD process
we realize it's an address with NODAD and complete the process without
sending any probe. However the TENTATIVE flags stays on the
address for sometime enough to cause misinterpretation when we receive a NS.
While processing NS, if the address has TENTATIVE flag, we mark it DADFAILED
and endup with an address that was originally configured as NODAD with
DADFAILED.

We can't avoid scheduling dad_work for addresses with NODAD but we can
avoid adding TENTATIVE flag to avoid this racy situation.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/ipv6/addrconf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b09ac38d8dc4..53f2dc092023 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1022,7 +1022,10 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	INIT_HLIST_NODE(&ifa->addr_lst);
 	ifa->scope = scope;
 	ifa->prefix_len = pfxlen;
-	ifa->flags = flags | IFA_F_TENTATIVE;
+	ifa->flags = flags;
+	/* No need to add the TENTATIVE flag for addresses with NODAD */
+	if (!(flags & IFA_F_NODAD))
+		ifa->flags |= IFA_F_TENTATIVE;
 	ifa->valid_lft = valid_lft;
 	ifa->prefered_lft = prefered_lft;
 	ifa->cstamp = ifa->tstamp = jiffies;
-- 
2.13.0.rc2.291.g57267f2277-goog
