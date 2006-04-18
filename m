From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP]: Fix truesize underflow
Date: Tue, 18 Apr 2006 22:32:04 +1000
Message-ID: <20060418123204.GA3962@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55055 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750897AbWDRMdm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 08:33:42 -0400
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>,
	Phil Oester <kernel@linuxace.com>,
	Mark Nipper <nipsy@bitgnome.net>,
	"David S. Miller" <davem@davemloft.net>,
	jesse.brandeburg@intel.com, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	Andi Kleen <ak@suse.de>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

You're absolutely right about there being a problem with the TSO packet
trimming code.  The cause of this lies in the tcp_fragment() function.

When we allocate a fragment for a completely non-linear packet the
truesize is calculated for a payload length of zero.  This means that
truesize could in fact be less than the real payload length.

When that happens the TSO packet trimming can cause truesize to become
negative.  This in turn can cause sk_forward_alloc to be -n * PAGE_SIZE
which would trigger the warning.

I've copied the code you used in tso_fragment which should work here.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Everyone who's having the sk_forward_alloc warning problem should give
this patch a go to see if it cures things.

Just in case this still doesn't fix it, could everyone please also verify
whether disabling SMP has any effect on reproducing this?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tcp-fragment.patch"

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b871db6..44df1db 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -551,7 +551,9 @@
 	buff = sk_stream_alloc_skb(sk, nsize, GFP_ATOMIC);
 	if (buff == NULL)
 		return -ENOMEM; /* We'll just try again later. */
-	sk_charge_skb(sk, buff);
+
+	buff->truesize = skb->len - len;
+	skb->truesize -= buff->truesize;
 
 	/* Correct the sequence numbers. */
 	TCP_SKB_CB(buff)->seq = TCP_SKB_CB(skb)->seq + len;

--BXVAT5kNtrzKuDFl--
