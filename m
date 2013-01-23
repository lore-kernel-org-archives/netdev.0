From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 11:42:46 +0000 (UTC)
Message-ID: <kdoibl$978$1@ger.gmane.org>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:57054 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755042Ab3AWLnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 06:43:00 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Txyjb-0001Kz-Q9
	for netdev@vger.kernel.org; Wed, 23 Jan 2013 12:43:15 +0100
Received: from 14.205.38.12 ([14.205.38.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 12:43:15 +0100
Received: from xiyou.wangcong by 14.205.38.12 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 12:43:15 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jan 2013 at 02:01 GMT, Yannick Koehler <yannick@koehler.name> wrote:
>
>   I believe that the problem is that once we move the skb into the
> client's receive queue we need to decrease the sk_wmem_alloc variable
> of the server socket since that skb is no more tied to the server.
> The code should then account for this memory as part of the
> sk_rmem_alloc variable on the client's socket.  The function
> "skb_set_owner_r(skb,owner)" would seem to be the function to do that,
> so it would seem to me.

Something like below??

-------->

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0c61236..e273072 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1205,6 +1205,7 @@ restart:
 
 	unix_state_unlock(sk);
 
+	skb_set_owner_r(skb, other);
 	/* take ten and and send info to listening sock */
 	spin_lock(&other->sk_receive_queue.lock);
 	__skb_queue_tail(&other->sk_receive_queue, skb);
@@ -1578,6 +1579,7 @@ restart:
 
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
+	skb_set_owner_r(skb, other);
 	maybe_add_creds(skb, sock, other);
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	if (max_level > unix_sk(other)->recursion_level)
@@ -1693,6 +1695,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		    (other->sk_shutdown & RCV_SHUTDOWN))
 			goto pipe_err_free;
 
+		skb_set_owner_r(skb, other);
 		maybe_add_creds(skb, sock, other);
 		skb_queue_tail(&other->sk_receive_queue, skb);
 		if (max_level > unix_sk(other)->recursion_level)
