From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Wed, 23 Jun 2010 12:51:16 +1000
Message-ID: <20100623125116.1370bdd4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/ipv4/ip_output.c between commit
26cde9f7e2747b6d254b704594eed87ab959afa5 ("udp: Fix bogus UFO packet
generation") from the net-current tree and commit
d8d1f30b95a635dbd610dcc5eb641aca8f4768cf ("net-next: remove useless union
keyword") from the net tree.

Just context changes. I fixed it up (see below) and can carry the fix as
necessary.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/ip_output.c
index 041d41d,6cbeb2e..0000000
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@@ -873,12 -873,10 +873,12 @@@ int ip_append_data(struct sock *sk
  	    !exthdrlen)
  		csummode = CHECKSUM_PARTIAL;
  
 +	skb = skb_peek_tail(&sk->sk_write_queue);
 +
  	inet->cork.length += length;
 -	if (((length> mtu) || !skb_queue_empty(&sk->sk_write_queue)) &&
 +	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
  	    (sk->sk_protocol == IPPROTO_UDP) &&
- 	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+ 	    (rt->dst.dev->features & NETIF_F_UFO)) {
  		err = ip_ufo_append_data(sk, getfrag, from, length, hh_len,
  					 fragheaderlen, transhdrlen, mtu,
  					 flags);
@@@ -1123,9 -1121,8 +1123,9 @@@ ssize_t	ip_append_page(struct sock *sk
  		return -EINVAL;
  
  	inet->cork.length += size;
 -	if ((sk->sk_protocol == IPPROTO_UDP) &&
 +	if ((size + skb->len > mtu) &&
 +	    (sk->sk_protocol == IPPROTO_UDP) &&
- 	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+ 	    (rt->dst.dev->features & NETIF_F_UFO)) {
  		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
  		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
  	}
