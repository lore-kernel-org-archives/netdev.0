From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.9 failed assertion in tcp_timer.c
Date: Fri, 22 Oct 2004 07:57:43 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021215743.GA23062@gondor.apana.org.au>
References: <20041019215054.GA17565@linuxace.com> <E1CK3Az-0004P2-00@gondolin.me.apana.org.au> <20041020164748.GA20905@linuxace.com> <20041020212651.GA8534@gondor.apana.org.au> <20041020225536.GA22179@linuxace.com> <20041021130339.GA19345@gondor.apana.org.au> <20041021165224.GA25399@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>
Content-Disposition: inline
In-Reply-To: <20041021165224.GA25399@linuxace.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 21, 2004 at 09:52:24AM -0700, Phil Oester wrote:
> 
> KERNEL: assertion (!tcp_get_pcount(&tp->packets_out) || !skb_
> 	queue_empty(&sk->sk_write_queue)) failed at net/ipv4/tcp_input.c (2496)

Perhaps the MTU is growing upwards? Does this patch help?

Dave, we need to use the skb's MSS in trim_head as otherwise the
counters will be screwed up.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp_output.c 1.68 vs edited =====
--- 1.68/net/ipv4/tcp_output.c	2004-10-20 15:13:52 +10:00
+++ edited/net/ipv4/tcp_output.c	2004-10-22 07:56:45 +10:00
@@ -566,8 +566,6 @@
 
 int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
-
 	if (skb_cloned(skb) &&
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
@@ -590,7 +588,7 @@
 	/* Any change of skb->len requires recalculation of tso
 	 * factor and mss.
 	 */
-	tcp_set_skb_tso_segs(skb, tp->mss_cache_std);
+	tcp_set_skb_tso_segs(skb, tcp_skb_mss(skb));
 
 	return 0;
 }

--PEIAKu/WMn1b1Hv9--
