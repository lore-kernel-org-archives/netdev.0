From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_unix: fix bug on large send()
Date: Sun, 11 Aug 2013 21:54:48 -0700
Message-ID: <1376283288.3338.7.camel@edumazet-glaptop>
References: <1375997852.4004.130.camel@edumazet-glaptop>
	 <20130811140605.GA5666@order.stressinduktion.org>
	 <1376231553.3291.0.camel@edumazet-glaptop>
	 <20130811143715.GA3699@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	David Rientjes <rientjes@google.com>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:50768 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3HLEyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 00:54:53 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so6434435pbc.15
        for <netdev@vger.kernel.org>; Sun, 11 Aug 2013 21:54:52 -0700 (PDT)
In-Reply-To: <20130811143715.GA3699@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit e370a723632 ("af_unix: improve STREAM behavior with fragmented
memory") added a bug on large send() because the
skb_copy_datagram_from_iovec() call always start from the beginning
of iovec.

We must instead use the @sent variable to properly skip the
already processed part.

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/unix/af_unix.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index fee9e33..86de99a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1669,7 +1669,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		skb_put(skb, size - data_len);
 		skb->data_len = data_len;
 		skb->len = size;
-		err = skb_copy_datagram_from_iovec(skb, 0, msg->msg_iov, 0, size);
+		err = skb_copy_datagram_from_iovec(skb, 0, msg->msg_iov,
+						   sent, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
