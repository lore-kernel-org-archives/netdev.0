From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] skb pcount with MTU discovery
Date: Sat, 02 Apr 2005 08:47:35 +1000
Message-ID: <E1DHUvP-00050C-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.58.0504011612140.18380@dexter.psc.edu>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jheffner@psc.edu (John Heffner)
In-Reply-To: <Pine.LNX.4.58.0504011612140.18380@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner <jheffner@psc.edu> wrote:
> 
> Common case, start out with mss of 8948.  Send 2 segments; neither are
> acknowledged, and we receive an ICMP can't fragment indicating a pmtu of
> 1500 so mss is set down to 1448.  Now tcp_set_skb_tso_segs() sets tso_segs
> to 6, so tcp_snd_test thinks we are doing TSO and will send the full 6
> mss, and fails the cwnd test since cwnd == 2.

How about fixing tcp_snd_test directly like this?

Of course all this will be moot once Dave finishes his TSO rewrite :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== include/net/tcp.h 1.107 vs edited =====
--- 1.107/include/net/tcp.h	2005-03-16 10:15:03 +11:00
+++ edited/include/net/tcp.h	2005-04-02 08:45:48 +10:00
@@ -1433,6 +1433,9 @@
 		pkts = tcp_skb_pcount(skb);
 	}
 
+	if (!(tp->inet.sk.sk_route_caps & NETIF_F_TSO))
+		pkts = 1;
+
 	/*	RFC 1122 - section 4.2.3.4
 	 *
 	 *	We must queue if
