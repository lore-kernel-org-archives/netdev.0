From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: Fri, 18 Mar 2005 20:11:29 +1100
Message-ID: <20050318091129.GA28658@gondor.apana.org.au>
References: <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050318090310.GA28443@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch makes ipt_TCPMSS use the correct MTU value for clamping.
This is a bit tricky actually since TCPMSS can be used in FORWARD,
LOCAL_OUT as well as POST_ROUTING.

In the first two cases we haven't performed IPsec yet so dst_mtu
obviously does the right thing.  As it is, POST_ROUTING is performed
after xfrm_output so MSS clamping is useless there.

With Patrick's IPsec netfilter stuff, there will be a POST_ROUTING
processing before IPsec processing, in which case dst_mtu also returns
exactly what we want.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

BTW Patrick, how is the IPsec netfilter stuff going?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-22

===== net/ipv4/netfilter/ipt_TCPMSS.c 1.13 vs edited =====
--- 1.13/net/ipv4/netfilter/ipt_TCPMSS.c	2004-06-04 15:04:05 +10:00
+++ edited/net/ipv4/netfilter/ipt_TCPMSS.c	2005-03-18 19:56:34 +11:00
@@ -87,14 +87,14 @@
 			return NF_DROP; /* or IPT_CONTINUE ?? */
 		}
 
-		if(dst_pmtu((*pskb)->dst) <= (sizeof(struct iphdr) + sizeof(struct tcphdr))) {
+		if(dst_mtu((*pskb)->dst) <= (sizeof(struct iphdr) + sizeof(struct tcphdr))) {
 			if (net_ratelimit())
 				printk(KERN_ERR
-		       			"ipt_tcpmss_target: unknown or invalid path-MTU (%d)\n", dst_pmtu((*pskb)->dst));
+		       			"ipt_tcpmss_target: unknown or invalid path-MTU (%d)\n", dst_mtu((*pskb)->dst));
 			return NF_DROP; /* or IPT_CONTINUE ?? */
 		}
 
-		newmss = dst_pmtu((*pskb)->dst) - sizeof(struct iphdr) - sizeof(struct tcphdr);
+		newmss = dst_mtu((*pskb)->dst) - sizeof(struct iphdr) - sizeof(struct tcphdr);
 	} else
 		newmss = tcpmssinfo->mss;
 

--sdtB3X0nJg68CQEu--
