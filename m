From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sat, 25 Sep 2004 08:28:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924222803.GA17594@gondor.apana.org.au>
References: <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040922105221.59a67d4b.davem@davemloft.net> <4152EE68.4030803@eurodev.net> <20040923121651.51a58cf2.davem@davemloft.net> <20040924032830.GC6384@gondor.apana.org.au> <20040923223909.6f4da27f.davem@davemloft.net> <20040924062604.GA7393@gondor.apana.org.au> <20040924105855.0e1aecd0.davem@davemloft.net> <20040924220651.GA6096@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Cc: pablo@eurodev.net, hadi@cyberus.ca, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040924220651.GA6096@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Sep 25, 2004 at 08:06:51AM +1000, herbert wrote:
> 
> I agree completely.  I'm just saying that the current NLM_GOODSIZE
> skb is the perfect scratch-pad so we don't need a new one.  All we
> need to do is to insert a helper call just before netlink_unicast
> to copy and trim the packet in the places that need it.

Here is a demonstration of what I meant.  Please note that this is
totally untested.

We could just make the last argument of netlink_unicast into a flag
so that it can do this directly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_user.c 1.51 vs edited =====
--- 1.51/net/xfrm/xfrm_user.c	2004-09-12 21:51:43 +10:00
+++ edited/net/xfrm/xfrm_user.c	2004-09-25 08:22:05 +10:00
@@ -433,10 +433,17 @@
 	resp_skb = xfrm_state_netlink(skb, x, nlh->nlmsg_seq);
 	if (IS_ERR(resp_skb)) {
 		err = PTR_ERR(resp_skb);
-	} else {
-		err = netlink_unicast(xfrm_nl, resp_skb,
-				      NETLINK_CB(skb).pid, MSG_DONTWAIT);
+		goto out_put;
 	}
+
+	err = pskb_expand_head(resp_skb, 0, skb->tail - skb->end, GFP_KERNEL);
+	if (err)
+		goto out_put;
+
+	err = netlink_unicast(xfrm_nl, resp_skb,
+			      NETLINK_CB(skb).pid, MSG_DONTWAIT);
+
+out_put:
 	xfrm_state_put(x);
 out_noput:
 	return err;

--AhhlLboLdkugWU4S--
