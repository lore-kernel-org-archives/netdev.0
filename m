From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: ip6_fragment() should check CHECKSUM_PARTIAL
Date: Fri, 18 May 2012 23:02:15 +0200
Message-ID: <1337374935.7029.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tore Anderson <tore@fud.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35332 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967372Ab2ERVCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 17:02:19 -0400
Received: by weyu7 with SMTP id u7so2054950wey.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 14:02:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Quoting Tore Anderson from :

If the allfrag feature has been set on a host route (due to an ICMPv6
Packet Too Big received indicating a MTU of less than 1280),
TCP SYN/ACK packets to that destination appears to get an incorrect
TCP checksum. This in turn means they are thrown away as invalid.

In the case of an IPv4 client behind a link with a MTU of less than
1260, accessing an IPv6 server through a stateless translator,
this means that the client can only download a single large file
from the server, because once it is in the server's routing cache
with the allfrag feature set, new TCP connections can no longer
be established.

</endquote>

It appears ip6_fragment() doesn't handle CHECKSUM_PARTIAL properly.

As network drivers are not prepared to fetch correct transport header, a
safe fix is to call skb_checksum_help() before fragmenting packet.

Reported-by: Tore Anderson <tore@fud.no>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Tore Anderson <tore@fud.no>
---
 net/ipv6/ip6_output.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a254e4b..3dc633f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -788,6 +788,10 @@ slow_path_clean:
 	}
 
 slow_path:
+	if ((skb->ip_summed == CHECKSUM_PARTIAL) &&
+	    skb_checksum_help(skb))
+		goto fail;
+
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = hlen;			/* Where to start from */
 
