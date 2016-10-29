From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: mangle zero checksum in skb_checksum_help()
Date: Sat, 29 Oct 2016 11:02:36 -0700
Message-ID: <1477764156.7065.282.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33399 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932602AbcJ2SCi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 14:02:38 -0400
Received: by mail-pf0-f195.google.com with SMTP id a136so1024661pfa.0
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 11:02:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Sending zero checksum is ok for TCP, but not for UDP.

UDPv6 receiver should by default drop a frame with a 0 checksum,
and UDPv4 would not verify the checksum and might accept a corrupted
packet.

Simply replace such checksum by 0xffff, regardless of transport.

This error was caught on SIT tunnels, but seems generic.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej Żenczykowski <maze@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dbc871306910..899a0f00e721 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2484,7 +2484,7 @@ int skb_checksum_help(struct sk_buff *skb)
 			goto out;
 	}
 
-	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+	*(__sum16 *)(skb->data + offset) = csum_fold(csum) ?: CSUM_MANGLED_0;
 out_set_summed:
 	skb->ip_summed = CHECKSUM_NONE;
 out:
