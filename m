From: Douglas Caetano dos Santos <douglascs@taghos.com.br>
Subject: [PATCH] net/packet: fix missing net_device reference release
Date: Fri, 12 May 2017 15:19:15 -0300
Message-ID: <7daebe52-8542-87cb-551a-1a5b4912f140@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        Jarno Rajahalme <jarno@ovn.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Anoob Soman <anoob.soman@citrix.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Philip Pettersson <philip.pettersson@gmail.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp897.redehostenvio.com.br ([187.84.239.111]:40105 "EHLO
        smtp897.redehostenvio.com.br" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757044AbdELS32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 14:29:28 -0400
Received: from mailexc06.redehost.com.br (187.84.231.133) by smtp837.redehostenvio.com.br id h2nvpg29co85 for <netdev@vger.kernel.org>; Fri, 12 May 2017 15:21:45 -0300 (envelope-from <douglascs@taghos.com.br>)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using a TX ring buffer, if an error occurs processing a control
message (e.g. invalid message), the net_device reference is not
released.

Fixes c14ac9451c348 ("sock: enable timestamping using control messages")
Signed-off-by: Douglas Caetano dos Santos <douglascs@taghos.com.br>
---
 net/packet/af_packet.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f4001763134d..e3eeed19cc7a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2658,13 +2658,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		dev = dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
 	}
 
-	sockc.tsflags = po->sk.sk_tsflags;
-	if (msg->msg_controllen) {
-		err = sock_cmsg_send(&po->sk, msg, &sockc);
-		if (unlikely(err))
-			goto out;
-	}
-
 	err = -ENXIO;
 	if (unlikely(dev == NULL))
 		goto out;
@@ -2672,6 +2665,13 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_put;
 
+	sockc.tsflags = po->sk.sk_tsflags;
+	if (msg->msg_controllen) {
+		err = sock_cmsg_send(&po->sk, msg, &sockc);
+		if (unlikely(err))
+			goto out_put;
+	}
+
 	if (po->sk.sk_socket->type == SOCK_RAW)
 		reserve = dev->hard_header_len;
 	size_max = po->tx_ring.frame_size
-- 
2.12.2
