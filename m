From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETFILTER] sip: Fix RTP address NAT
Date: Wed, 2 May 2007 14:01:02 +1000
Message-ID: <20070502040102.GA28343@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3983 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2992704AbXEBEB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 00:01:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[NETFILTER] sip: Fix RTP address NAT

I needed to use this recently to talk to a Cisco server.  In my case
I only did SNAT while the Cisco server used a different address for
RTP traffic than the one for SIP.  I discovered that nf_nat_sip NATed
the RTP address to the SIP one which was unnecessary but OK.  However,
in doing so it did not DNAT the destination address on the RTP traffic
to the Cisco back to the original RTP address.

This patch corrects this by noting down the RTP address and using it
when the expectation fires.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index bfd88e4..fac97cf 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -222,6 +222,29 @@ static unsigned int mangle_sdp(struct sk_buff **pskb,
 	return mangle_content_len(pskb, ctinfo, ct, dptr);
 }
 
+static void ip_nat_sdp_expect(struct nf_conn *ct,
+			      struct nf_conntrack_expect *exp)
+{
+	struct nf_nat_range range;
+
+	/* This must be a fresh one. */
+	BUG_ON(ct->status & IPS_NAT_DONE_MASK);
+
+	/* Change src to where master sends to */
+	range.flags = IP_NAT_RANGE_MAP_IPS;
+	range.min_ip = range.max_ip
+		= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
+	/* hook doesn't matter, but it has to do source manip */
+	nf_nat_setup_info(ct, &range, NF_IP_POST_ROUTING);
+
+	/* For DST manip, map port here to where it's expected. */
+	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
+	range.min = range.max = exp->saved_proto;
+	range.min_ip = range.max_ip = exp->saved_ip;
+	/* hook doesn't matter, but it has to do destination manip */
+	nf_nat_setup_info(ct, &range, NF_IP_PRE_ROUTING);
+}
+
 /* So, this packet has hit the connection tracking matching code.
    Mangle it, and change the expectation to match the new version. */
 static unsigned int ip_nat_sdp(struct sk_buff **pskb,
@@ -239,13 +262,14 @@ static unsigned int ip_nat_sdp(struct sk_buff **pskb,
 	/* Connection will come from reply */
 	newip = ct->tuplehash[!dir].tuple.dst.u3.ip;
 
+	exp->saved_ip = exp->tuple.dst.u3.ip;
 	exp->tuple.dst.u3.ip = newip;
 	exp->saved_proto.udp.port = exp->tuple.dst.u.udp.port;
 	exp->dir = !dir;
 
 	/* When you see the packet, we need to NAT it the same as the
 	   this one. */
-	exp->expectfn = nf_nat_follow_master;
+	exp->expectfn = ip_nat_sdp_expect;
 
 	/* Try to get same port: if not, try to change it. */
 	for (port = ntohs(exp->saved_proto.udp.port); port != 0; port++) {
