From: Patrick McHardy <kaber@trash.net>
Subject: Re: More IPSEC trouble
Date: Sat, 12 Mar 2005 01:00:37 +0100
Message-ID: <42323125.20706@trash.net>
References: <E1D9Ymg-0001x0-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0503111453320.18067@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050106080400040708060905"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
To: Steve Hill <steve@services.navaho.net>
In-Reply-To: <Pine.LNX.4.61.0503111453320.18067@sorbus2.navaho>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050106080400040708060905
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steve Hill wrote:
> This was a configuration mistake on my part and admittedly it shouldn't 
> work properly - however, it triggered a kernel bug: sending a packet 
> with the DF flag set which will grow to be > the MTU when encrypted 
> causes the kernel to generate an ICMP Frag Needed packet, which got 
> caught by the policy and this triggered the kernel to lock up hard.

Thanks for tracking this down, we need to unlock the state before
calling icmp_send(). This patch fixes it, it should apply to 2.6.10
if you replace dst_mtu() by dst_pmtu() in the context.


--------------050106080400040708060905
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/12 00:59:07+01:00 kaber@coreworks.de 
#   [XFRM]: Avoid possible deadlock for locally generated ICMP errors
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/xfrm6_output.c
#   2005/03/12 00:58:59+01:00 kaber@coreworks.de +3 -1
#   [XFRM]: Avoid possible deadlock for locally generated ICMP errors
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/xfrm4_output.c
#   2005/03/12 00:58:59+01:00 kaber@coreworks.de +3 -1
#   [XFRM]: Avoid possible deadlock for locally generated ICMP errors
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c	2005-03-12 00:59:22 +01:00
+++ b/net/ipv4/xfrm4_output.c	2005-03-12 00:59:22 +01:00
@@ -84,6 +84,7 @@
 	dst = skb->dst;
 	mtu = dst_mtu(dst);
 	if (skb->len > mtu) {
+		spin_unlock_bh(&x->lock);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		ret = -EMSGSIZE;
 	}
@@ -111,7 +112,8 @@
 	if (x->props.mode) {
 		err = xfrm4_tunnel_check_size(skb);
 		if (err)
-			goto error;
+			/* xfrm4_tunnel_check_size() drops the lock on error */
+			goto error_nolock;
 	}
 
 	xfrm4_encap(skb);
diff -Nru a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- a/net/ipv6/xfrm6_output.c	2005-03-12 00:59:22 +01:00
+++ b/net/ipv6/xfrm6_output.c	2005-03-12 00:59:22 +01:00
@@ -84,6 +84,7 @@
 		mtu = IPV6_MIN_MTU;
 
 	if (skb->len > mtu) {
+		spin_unlock_bh(&x->lock);
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
 		ret = -EMSGSIZE;
 	}
@@ -111,7 +112,8 @@
 	if (x->props.mode) {
 		err = xfrm6_tunnel_check_size(skb);
 		if (err)
-			goto error;
+			/* xfrm6_tunnel_check_size() drops the lock on error */
+			goto error_nolock;
 	}
 
 	xfrm6_encap(skb);

--------------050106080400040708060905--
