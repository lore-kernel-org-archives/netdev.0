From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] rtnetlink: allocate more memory for dev_set_mac_address()
Date: Thu, 20 Jul 2017 11:27:57 -0700
Message-ID: <20170720182758.20204-1-xiyou.wangcong@gmail.com>
Cc: dsahern@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34103 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935620AbdGTS2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 14:28:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id o88so2995786pfk.1
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 11:28:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

virtnet_set_mac_address() interprets mac address as struct
sockaddr, but upper layer only allocates dev->addr_len
which is ETH_ALEN + sizeof(sa_family_t) in this case.

We lack a unified definition for mac address, so just fix
the upper layer, this also allows drivers to interpret it
to struct sockaddr freely.

Reported-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/rtnetlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d1ba90980be1..ebaa26cf777f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2031,7 +2031,8 @@ static int do_setlink(const struct sk_buff *skb,
 		struct sockaddr *sa;
 		int len;
 
-		len = sizeof(sa_family_t) + dev->addr_len;
+		len = sizeof(sa_family_t) + max_t(size_t, dev->addr_len,
+						  sizeof(*sa));
 		sa = kmalloc(len, GFP_KERNEL);
 		if (!sa) {
 			err = -ENOMEM;
-- 
2.13.0
