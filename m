From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c
 (122)
Date: Thu, 12 May 2005 00:17:19 +0200
Message-ID: <4282846F.6070403@tpack.net>
References: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp> <20050510220751.GA459@gondor.apana.org.au> <20050511005836.GA1674@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060109090905070101010608"
Cc: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050511005836.GA1674@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060109090905070101010608
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> I think I understand your patch now.  What's happening is that
> 
> 1) The skb is sent to socket 1.
> 2) Someone does a recvmsg on socket 1 and drops the ref on the skb.
>    Note that the rmalloc is not returned at this point since the
>    skb is still referenced.
> 3) The same skb is now sent to socket 2.

Ahh, even I get the point now.
I actually thought this was caused by another race. More on that later.

> I agree with your solution except that we should still do the skb_get
> if we can.  Here is my version where we only do the skb_get at the
> start.

What about an alternative fix, that avoids even more cloning (where
possible)? This resurrects the skb_orphan call that was moved out, last
time we had 'shared-skb troubles'. It is practically a no-op in the
common case, but still prevents the possible race with recvmsg.
(And I have a weakness for one-line-fixes). :-)


Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>

--------------060109090905070101010608
Content-Type: text/plain;
 name="netlink-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink-1.patch"

diff -ru linux-2.6.12-rc4/net/netlink/af_netlink.c linux-2.6.12-work/net/netlink/af_netlink.c
--- linux-2.6.12-rc4/net/netlink/af_netlink.c	2005-05-11 11:10:20.000000000 +0200
+++ linux-2.6.12-work/net/netlink/af_netlink.c	2005-05-12 00:08:33.634344658 +0200
@@ -697,6 +697,7 @@
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
 	    !test_bit(0, &nlk->state)) {
+		skb_orphan(skb);
 		skb_set_owner_r(skb, sk);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, skb->len);

--------------060109090905070101010608--
