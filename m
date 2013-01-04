From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ndisc: Remove unused space at tail of skb for ndisc
 messages. (TAKE 3)
Date: Fri, 04 Jan 2013 22:58:04 +0900
Message-ID: <50E6DFEC.7080603@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:53247 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754733Ab3ADN6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 08:58:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the size of skb allocated for NDISC is MAX_HEADER +
LL_RESERVED_SPACE(dev) + packet length + dev->needed_tailroom,
but only LL_RESERVED_SPACE(dev) bytes is "reserved" for headers.
As a result, the skb looks like this (after construction of the
message):

head       data                   tail                       end
+--------------------------------------------------------------+
+           |                      |          |                |
+--------------------------------------------------------------+
|<-hlen---->|<---ipv6 packet------>|<--tlen-->|<--MAX_HEADER-->|
    =LL_                               = dev
     RESERVED_                           ->needed_
     SPACE(dev)                            tailroom

As the name implies, "MAX_HEADER" is used for headers, and should
be "reserved" in prior to packet construction.  Or, if some space
is really required at the tail of ther skb, it should be
explicitly documented.

We have several option after construction of NDISC message:

Option 1:

head       data                   tail       end
+---------------------------------------------+
+           |                      |          |
+---------------------------------------------+
|<-hlen---->|<---ipv6 packet------>|<--tlen-->|
   =LL_                                = dev
    RESERVED_                           ->needed_
    SPACE(dev)                            tailroom

Option 2:

head            data                   tail       end
+--------------------------------------------------+
+                |                      |          |
+--------------------------------------------------+
|<--MAX_HEADER-->|<---ipv6 packet------>|<--tlen-->|
                                            = dev
                                             ->needed_
                                               tailroom

Option 3:

head                        data                   tail       end
+--------------------------------------------------------------+
+                |           |                      |          |
+--------------------------------------------------------------+
|<--MAX_HEADER-->|<-hlen---->|<---ipv6 packet------>|<--tlen-->|
                    =LL_                                = dev
                     RESERVED_                          ->needed_
                     SPACE(dev)                           tailroom

Our tunnel drivers try expanding headroom and the space for tunnel
encapsulation was not a mandatory space -- so we are not seeing
bugs here --, but just for optimization for performance critial
situations.

Since NDISC messages are not performance critical unlike TCP,
and as we know outgoing device, LL_RESERVED_SPACE(dev) should be
just enough for the device in most (if not all) cases:
  LL_RESERVED_SPACE(dev) <= LL_MAX_HEADER <= MAX_HEADER
Note that LL_RESERVED_SPACE(dev) is also enough for NDISC over
SIT (e.g., ISATAP).

So, I think Option 1 is just fine here.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 6574175..4c4ccf7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -395,7 +395,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 		len += ndisc_opt_addr_space(dev);
 
 	skb = sock_alloc_send_skb(sk,
-				  (MAX_HEADER + sizeof(struct ipv6hdr) +
+				  (sizeof(struct ipv6hdr) +
 				   len + hlen + tlen),
 				  1, &err);
 	if (!skb) {
@@ -1439,7 +1439,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
 	buff = sock_alloc_send_skb(sk,
-				   (MAX_HEADER + sizeof(struct ipv6hdr) +
+				   (sizeof(struct ipv6hdr) +
 				    len + hlen + tlen),
 				   1, &err);
 	if (buff == NULL) {
-- 
1.7.9.5
