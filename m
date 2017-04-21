From: Jamie Bainbridge <jbainbri@redhat.com>
Subject: [PATCH 2/2] ipv6: don't deliver packets with zero length to raw sockets
Date: Fri, 21 Apr 2017 13:58:44 +1000
Message-ID: <1492747124-31821-2-git-send-email-jbainbri@redhat.com>
References: <1492747124-31821-1-git-send-email-jbainbri@redhat.com>
Cc: Jamie Bainbridge <jbainbri@redhat.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51930 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1035016AbdDUD7D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 23:59:03 -0400
In-Reply-To: <1492747124-31821-1-git-send-email-jbainbri@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 assumes there is data after the network header and blindly delivers
skbs to raw sockets without checking the presence of data.

With an application in a common loop where it checks select/poll/epoll
then ioctl(SIOCINQ/FIONREAD) is positive before continuing to
recvfrom(), this behaviour can cause the application to loop forever
on ioctl() because there is a zero-length skb to receive.

With this, it is very easy to make a Denial of Service attack by
crafting a packet which declares a Next Header in the IPv6 header but
does not actually supply a transport header and/or payload.

skb->len is already correctly set in ip6_input_finish() with pskb_pull()
so check this length before delivering zero data to raw sockets.

Signed-off-by: Jamie Bainbridge <jbainbri@redhat.com>
---
 net/ipv6/raw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0da6a12b5472e322d679572c7244e5c9bc467741..29dfdcefe1cc5f4c082ed919026e49e70320605e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -174,7 +174,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
 
-	if (!sk)
+	if (!sk || !(skb->len))
 		goto out;
 
 	net = dev_net(skb->dev);
-- 
1.8.3.1
