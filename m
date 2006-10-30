From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [SCTP]: Always linearise packet on input
Date: Mon, 30 Oct 2006 18:11:28 +1100
Message-ID: <20061030071128.GA15715@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22023 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161163AbWJ3HLg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 02:11:36 -0500
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[SCTP]: Always linearise packet on input

I was looking at a RHEL5 bug report involving Xen and SCTP
(https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=212550).
It turns out that SCTP wasn't written to handle skb fragments at
all.  The absence of any calls to skb_may_pull is testament to
that.

It just so happens that Xen creates fragmented packets more often
than other scenarios (header & data split when going from domU to
dom0).  That's what caused this bug to show up.

Until someone has the time sits down and audits the entire net/sctp
directory, here is a conservative and safe solution that simply
linearises all packets on input.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Sridhar, could you please organise an audit of SCTP to make sure
that it deals with skb fragments (both pages and frag_list) in a
safe manner? Basically before you do an skb_pull or access skb->data
you must ensure that the data you want to access is in the head,
usually by doing skb_may_pull.  Of course, for large payloads it
helps if you can avoid pulling it into the head.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 64f6301..99c0501 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -135,6 +135,9 @@ int sctp_rcv(struct sk_buff *skb)
 
 	SCTP_INC_STATS_BH(SCTP_MIB_INSCTPPACKS);
 
+	if (skb_linearize(skb))
+		goto discard_it;
+
 	sh = (struct sctphdr *) skb->h.raw;
 
 	/* Pull up the IP and SCTP headers. */
