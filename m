From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: [PATCH] netlink: defer socket destruction a bit
Date: Thu, 12 May 2005 00:19:02 +0200
Message-ID: <428284D6.9000804@tpack.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030308070803010407050700"
Cc: netdev@oss.sgi.com, Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030308070803010407050700
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

In netlink_broadcast() we're sending shared skb's to netlink listeners
when possible (saves some copying). This is OK, since we hold the only
other reference to the skb.

However, this implies that we must drop our reference on the skb, before
allowing a receiving socket to disappear. Otherwise, the socket buffer
accounting is disrupted.


Signed-off-by: Tommy S. Christensen <tommy.christensen@tpack.net>

--------------030308070803010407050700
Content-Type: text/plain;
 name="netlink-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink-2.patch"

diff -ru linux-2.6.12-rc4/net/netlink/af_netlink.c linux-2.6.12-work/net/netlink/af_netlink.c
--- linux-2.6.12-rc4/net/netlink/af_netlink.c	2005-05-11 11:10:20.000000000 +0200
+++ linux-2.6.12-work/net/netlink/af_netlink.c	2005-05-12 00:11:08.990990172 +0200
@@ -785,11 +785,12 @@
 	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
 		do_one_broadcast(sk, &info);
 
+	kfree_skb(skb);
+
 	netlink_unlock_table();
 
 	if (info.skb2)
 		kfree_skb(info.skb2);
-	kfree_skb(skb);
 
 	if (info.delivered) {
 		if (info.congested && (allocation & __GFP_WAIT))

--------------030308070803010407050700--
