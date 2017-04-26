From: Jamie Bainbridge <jbainbri@redhat.com>
Subject: [PATCH] ipv6: check raw payload size correctly in ioctl
Date: Wed, 26 Apr 2017 10:43:27 +1000
Message-ID: <1493167407-27969-1-git-send-email-jbainbri@redhat.com>
Cc: Jamie Bainbridge <jbainbri@redhat.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59188 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1433741AbdDZAoc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 20:44:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In situations where an skb is paged, the transport header pointer and
tail pointer can be the same because the skb contents are in frags.

This results in ioctl(SIOCINQ/FIONREAD) incorrectly returning a
length of 0 when the length to receive is actually greater than zero.

skb->len is already correctly set in ip6_input_finish() with
pskb_pull(), so use skb->len as it always returns the correct result
for both linear and paged data.

Signed-off-by: Jamie Bainbridge <jbainbri@redhat.com>
---
 net/ipv6/raw.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index f174e76e6505d4045e940c9fceef765d2aaa937d..0da6a12b5472e322d679572c7244e5c9bc467741 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1178,8 +1178,7 @@ static int rawv6_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		spin_lock_bh(&sk->sk_receive_queue.lock);
 		skb = skb_peek(&sk->sk_receive_queue);
 		if (skb)
-			amount = skb_tail_pointer(skb) -
-				skb_transport_header(skb);
+			amount = skb->len;
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		return put_user(amount, (int __user *)arg);
 	}
-- 
1.8.3.1
