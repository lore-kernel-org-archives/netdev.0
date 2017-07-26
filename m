From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] dccp: fix a memleak that dccp_ipv6 doesn't put reqsk properly
Date: Wed, 26 Jul 2017 14:19:09 +0800
Message-ID: <17b2008535695e5885775418a31ee74f3ca704f5.1501049949.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:38119 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbdGZGTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 02:19:19 -0400
Received: by mail-pf0-f193.google.com with SMTP id c23so14672754pfe.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 23:19:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dccp_v6_conn_request, after reqsk gets alloced and hashed into
ehash table, reqsk's refcnt is set 3. one is for req->rsk_timer,
one is for hlist, and the other one is for current using.

The problem is when dccp_v6_conn_request returns and finishes using
reqsk, it doesn't put reqsk. This will cause reqsk refcnt leaks and
reqsk obj never gets freed.

Jianlin found this issue when running dccp_memleak.c in a loop, the
system memory would run out.

dccp_memleak.c:
  int s1 = socket(PF_INET6, 6, IPPROTO_IP);
  bind(s1, &sa1, 0x20);
  listen(s1, 0x9);
  int s2 = socket(PF_INET6, 6, IPPROTO_IP);
  connect(s2, &sa1, 0x20);
  close(s1);
  close(s2);

This patch is to put the reqsk before dccp_v6_conn_request returns,
just as what tcp_conn_request does.

Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/dccp/ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index c376af5..1b58eac 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -380,6 +380,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
+	reqsk_put(req);
 	return 0;
 
 drop_and_free:
-- 
2.1.0
