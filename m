From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sparc oops in ip_fast_csum
Date: Sun, 06 Jan 2008 11:22:04 +1100
Message-ID: <E1JBJHA-0000hy-00@gondolin.me.apana.org.au>
References: <20080105094400.GH27894@ZenIV.linux.org.uk>
Cc: m.kozlowski@tuxland.pl, davem@davemloft.net,
	sparclinux@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: viro@ZenIV.linux.org.uk (Al Viro)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2577 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753869AbYAFAWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 19:22:40 -0500
In-Reply-To: <20080105094400.GH27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@zeniv.linux.org.uk> wrote:
> 
> ip_fast_csum() called from raw_send_hdrinc() from raw_sendmsg() ran through
> the page boundary into unmapped page...  Bloody odd, that, seeing that
> we have checked iph->ihl * 4U <= length and had done
>        err = memcpy_fromiovecend((void *)iph, from, 0, length);
> before the
>                iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
> that had triggered that crap..

Actually if you read the code for ip_fast_csum it's obvious what has
happened.  %o1 == iph->ihl contains the value 2 which is bogus.

[IPV4] raw: Strengthen check on validity of iph->ihl 

We currently check that iph->ihl is bounded by the real length and that
the real length is greater than the minimum IP header length.  However,
we did not check the caes where iph->ihl is less than the minimum IP
header length.

This breaks because some ip_fast_csum implementations assume that which
is quite reasonable.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 66b42f5..e7050f8 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -271,6 +271,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	int hh_len;
 	struct iphdr *iph;
 	struct sk_buff *skb;
+	unsigned int iphlen;
 	int err;
 
 	if (length > rt->u.dst.dev->mtu) {
@@ -304,7 +305,8 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 		goto error_fault;
 
 	/* We don't modify invalid header */
-	if (length >= sizeof(*iph) && iph->ihl * 4U <= length) {
+	iphlen = iph->ihl * 4;
+	if (iphlen >= sizeof(*iph) && iphlen <= length) {
 		if (!iph->saddr)
 			iph->saddr = rt->rt_src;
 		iph->check   = 0;
