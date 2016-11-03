From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Update raw socket bind to consider l3 domain
Date: Thu,  3 Nov 2016 09:25:00 -0700
Message-ID: <1478190300-14094-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34515 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758713AbcKCQZL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 12:25:11 -0400
Received: by mail-pf0-f178.google.com with SMTP id n85so34196493pfi.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 09:25:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Binding a raw socket to a local address fails if the socket is bound
to an L3 domain:

    $ vrf-test  -s -l 10.100.1.2 -R -I red
    error binding socket: 99: Cannot assign requested address

Update raw_bind to look consider if sk_bound_dev_if is bound to an L3
domain and use inet_addr_type_table to lookup the address.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/raw.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 6a0bd68a565b..9ef2a602f052 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -695,12 +695,20 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *addr = (struct sockaddr_in *) uaddr;
+	u32 tb_id = RT_TABLE_LOCAL;
 	int ret = -EINVAL;
 	int chk_addr_ret;
 
 	if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_in))
 		goto out;
-	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
+
+	if (sk->sk_bound_dev_if)
+		tb_id = l3mdev_fib_table_by_index(sock_net(sk),
+						 sk->sk_bound_dev_if) ? : tb_id;
+
+	chk_addr_ret = inet_addr_type_table(sock_net(sk), addr->sin_addr.s_addr,
+					    tb_id);
+
 	ret = -EADDRNOTAVAIL;
 	if (addr->sin_addr.s_addr && chk_addr_ret != RTN_LOCAL &&
 	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
-- 
2.1.4
