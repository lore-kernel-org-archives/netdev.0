From: Patrick McHardy <kaber@trash.net>
Subject: Re: More IPSEC trouble
Date: Sat, 12 Mar 2005 01:13:23 +0100
Message-ID: <42323423.3000001@trash.net>
References: <E1D9Ymg-0001x0-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0503111453320.18067@sorbus2.navaho> <42323125.20706@trash.net> <423233B9.50204@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090809090208090007040601"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
To: Steve Hill <steve@services.navaho.net>
In-Reply-To: <423233B9.50204@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090809090208090007040601
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Patrick McHardy wrote:
> 
>> Steve Hill wrote:
>>
>>> This was a configuration mistake on my part and admittedly it 
>>> shouldn't work properly - however, it triggered a kernel bug: sending 
>>> a packet with the DF flag set which will grow to be > the MTU when 
>>> encrypted causes the kernel to generate an ICMP Frag Needed packet, 
>>> which got caught by the policy and this triggered the kernel to lock 
>>> up hard.
>>
>>
>>
>> Thanks for tracking this down, we need to unlock the state before
>> calling icmp_send(). This patch fixes it, it should apply to 2.6.10
>> if you replace dst_mtu() by dst_pmtu() in the context.
> 
> 
> Second try .. this one compiles.

Embarrasing .. had I actually attached the new patch it would
have compiled :) Time to go to bed it seems ..


--------------090809090208090007040601
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/12 01:10:40+01:00 kaber@coreworks.de 
#   [XFRM]: Avoid possible deadlock for locally generated ICMP errors
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/xfrm6_output.c
#   2005/03/12 01:10:31+01:00 kaber@coreworks.de +5 -3
#   [XFRM]: Avoid possible deadlock for locally generated ICMP errors
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/xfrm4_output.c
#   2005/03/12 01:10:31+01:00 kaber@coreworks.de +5 -3
#   [XFRM]: Avoid possible deadlock for locally generated ICMP errors
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c	2005-03-12 01:12:12 +01:00
+++ b/net/ipv4/xfrm4_output.c	2005-03-12 01:12:12 +01:00
@@ -67,7 +67,7 @@
 	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 }
 
-static int xfrm4_tunnel_check_size(struct sk_buff *skb)
+static int xfrm4_tunnel_check_size(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int mtu, ret = 0;
 	struct dst_entry *dst;
@@ -84,6 +84,7 @@
 	dst = skb->dst;
 	mtu = dst_mtu(dst);
 	if (skb->len > mtu) {
+		spin_unlock_bh(&x->lock);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		ret = -EMSGSIZE;
 	}
@@ -109,9 +110,10 @@
 		goto error;
 
 	if (x->props.mode) {
-		err = xfrm4_tunnel_check_size(skb);
+		err = xfrm4_tunnel_check_size(x, skb);
 		if (err)
-			goto error;
+			/* xfrm4_tunnel_check_size() drops the lock on error */
+			goto error_nolock;
 	}
 
 	xfrm4_encap(skb);
diff -Nru a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- a/net/ipv6/xfrm6_output.c	2005-03-12 01:12:12 +01:00
+++ b/net/ipv6/xfrm6_output.c	2005-03-12 01:12:12 +01:00
@@ -74,7 +74,7 @@
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
 }
 
-static int xfrm6_tunnel_check_size(struct sk_buff *skb)
+static int xfrm6_tunnel_check_size(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int mtu, ret = 0;
 	struct dst_entry *dst = skb->dst;
@@ -84,6 +84,7 @@
 		mtu = IPV6_MIN_MTU;
 
 	if (skb->len > mtu) {
+		spin_unlock_bh(&x->lock);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
 		ret = -EMSGSIZE;
 	}
@@ -109,9 +110,10 @@
 		goto error;
 
 	if (x->props.mode) {
-		err = xfrm6_tunnel_check_size(skb);
+		err = xfrm6_tunnel_check_size(x, skb);
 		if (err)
-			goto error;
+			/* xfrm6_tunnel_check_size drops the lock on error */
+			goto error_nolock;
 	}
 
 	xfrm6_encap(skb);

--------------090809090208090007040601--
