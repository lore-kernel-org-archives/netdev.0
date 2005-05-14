From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] xfrm: skb_cow_data() does not set proper owner for new skbs.
Date: Sat, 14 May 2005 17:48:35 +0400
Message-ID: <20050514134834.GA2698@uganda.factory.vocord.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks like skb_cow_data() does not set 
proper owner for newly created skb.

If we have several fragments for skb and some of them
are shared(?) or cloned (like in async IPsec) there 
might be a situation when we require recreating skb and 
thus using skb_copy() for it.
Newly created skb has neither a destructor nor a socket
assotiated with it, which must be copied from the old skb.
As far as I can see, current code sets destructor and socket
for the first one skb only and uses truesize of the first skb
only to increment sk_wmem_alloc value.

If above "analysis" is correct then attached patch fixes that.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

--- ./net/xfrm/xfrm_algo.c~	2005-04-27 12:08:59.000000000 +0400
+++ ./net/xfrm/xfrm_algo.c	2005-05-14 17:36:52.000000000 +0400
@@ -698,7 +698,7 @@
 				return -ENOMEM;
 
 			if (skb1->sk)
-				skb_set_owner_w(skb, skb1->sk);
+				skb_set_owner_w(skb2, skb1->sk);
 
 			/* Looking around. Are we still alive?
 			 * OK, link new skb, drop old one */
--
	Evgeniy Polyakov

Crash is better than data corruption. -- Artur Grabowski
