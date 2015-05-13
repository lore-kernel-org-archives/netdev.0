From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netlink: move nl_table in read_mostly section
Date: Tue, 12 May 2015 17:24:50 -0700
Message-ID: <1431476690.566.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:35509 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959AbbEMAYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 20:24:52 -0400
Received: by iebpz10 with SMTP id pz10so17733128ieb.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 17:24:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

netlink sockets creation and deletion heavily modify nl_table_users
and nl_table_lock.

If nl_table is sharing one cache line with one of them, netlink
performance is really bad on SMP.

ffffffff81ff5f00 B nl_table
ffffffff81ff5f0c b nl_table_users

Putting nl_table in read_mostly section increased performance
of my open/delete netlink sockets test by about 80 %

This came up while diagnosing a getaddrinfo() problem.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index daa0b818174b..dbe885901b34 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -89,7 +89,7 @@ static inline int netlink_is_kernel(struct sock *sk)
 	return nlk_sk(sk)->flags & NETLINK_KERNEL_SOCKET;
 }
 
-struct netlink_table *nl_table;
+struct netlink_table *nl_table __read_mostly;
 EXPORT_SYMBOL_GPL(nl_table);
 
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
