From: Craig Gallek <kraig@google.com>
Subject: [PATCH net-next] sock_diag: fetch source port from inet_sock
Date: Wed, 17 Jun 2015 10:59:10 -0400
Message-ID: <1434553150-8750-1-git-send-email-kraig@google.com>
Cc: edumazet@google.com, davem@davemloft.net,
	Craig Gallek <kraig@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33276 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbbFQO7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 10:59:21 -0400
Received: by ykfr66 with SMTP id r66so41941883ykf.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 07:59:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an inet_sock is destroyed, its source port (sk_num) is set to
zero as part of the unhash procedure.  In order to supply a source
port as part of the NETLINK_SOCK_DIAG socket destruction broadcasts,
the source port number must be read from inet_sport instead.

Tested: ss -E
Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/ipv4/inet_diag.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 21985d8..ba6a80f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -1095,6 +1095,8 @@ int inet_diag_handler_get_info(struct sk_buff *skb, struct sock *sk)
 	r = nlmsg_data(nlh);
 	memset(r, 0, sizeof(*r));
 	inet_diag_msg_common_fill(r, sk);
+	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_STREAM)
+		r->id.idiag_sport = inet_sk(sk)->inet_sport;
 	r->idiag_state = sk->sk_state;
 
 	if ((err = nla_put_u8(skb, INET_DIAG_PROTOCOL, sk->sk_protocol))) {
-- 
2.2.0.rc0.207.ga3a616c
