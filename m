From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix tcp_unlink_write_queue()
Date: Wed, 11 Oct 2017 13:27:29 -0700
Message-ID: <1507753649.31614.36.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171011183522.tm2xxgzbdspjtsax@yury-thinkpad>
         <1507747313.31614.27.camel@edumazet-glaptop3.roam.corp.google.com>
         <1507747717.31614.28.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171011194355.n6mb4oe7qt76d6wh@yury-thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Yury Norov <ynorov@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:37795 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752337AbdJKU1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 16:27:31 -0400
Received: by mail-pf0-f196.google.com with SMTP id z80so3253488pff.4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 13:27:31 -0700 (PDT)
In-Reply-To: <20171011194355.n6mb4oe7qt76d6wh@yury-thinkpad>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Yury reported crash with this signature :

[  554.034021] [<ffff80003ccd5a58>] 0xffff80003ccd5a58
[  554.034156] [<ffff00000888fd34>] skb_release_all+0x14/0x30
[  554.034288] [<ffff00000888fd64>] __kfree_skb+0x14/0x28
[  554.034409] [<ffff0000088ece6c>] tcp_sendmsg_locked+0x4dc/0xcc8
[  554.034541] [<ffff0000088ed68c>] tcp_sendmsg+0x34/0x58
[  554.034659] [<ffff000008919fd4>] inet_sendmsg+0x2c/0xf8
[  554.034783] [<ffff0000088842e8>] sock_sendmsg+0x18/0x30
[  554.034928] [<ffff0000088861fc>] SyS_sendto+0x84/0xf8

Problem is that skb->destructor contains garbage, and this is
because I accidentally removed tcp_skb_tsorted_anchor_cleanup()
from tcp_unlink_write_queue()

This would trigger with a write(fd, <invalid_memory>, len) attempt,
and we will add to packetdrill this capability to avoid future
regressions.

Fixes: 75c119afe14f ("tcp: implement rb-tree based retransmit queue")
Reported-by: Yury Norov <ynorov@caviumnetworks.com>
Tested-by: Yury Norov <ynorov@caviumnetworks.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5a95e5886b55e03e4a8bfeac3506c657a4f97dde..15163454174babdcb465904f725b919268dd1bc7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1712,6 +1712,7 @@ static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 {
+	tcp_skb_tsorted_anchor_cleanup(skb);
 	__skb_unlink(skb, &sk->sk_write_queue);
 }
 
