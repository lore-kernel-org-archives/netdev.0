From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [RFC] sctp/tcp: Question -- ICMPv4 length check (not) redundant?
Date: Fri, 25 Jul 2008 16:20:59 +0100
Message-ID: <20080725152059.GA4656@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43902 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751398AbYGYPVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 11:21:06 -0400
Received: from gerrit.erg.abdn.ac.uk (Debian-exim@gerrit.erg.abdn.ac.uk [139.133.204.176])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id m6PFKxSg020499
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 16:21:01 +0100 (BST)
Received: from gerrit by gerrit.erg.abdn.ac.uk with local (Exim 4.69)
	(envelope-from <gerrit@gerrit.erg.abdn.ac.uk>)
	id 1KMP6J-0001Jd-Vd
	for netdev@vger.kernel.org; Fri, 25 Jul 2008 16:21:00 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wonder if the two pieces of code as marked by the patch below still
serve a purpose. 

>From grepping through the net/ code it seems they are both redundant.

This is on the basis that

 * the v6 counterparts of these handlers ({tcp,sctp}_v6_err) do not have
   this payload-length check;

 * icmp_unreach() in net/ipv4/icmp.c already has this test:

	/* Checkin full IP header plus 8 bytes of protocol to
	 * avoid additional coding at protocol handlers.
	 */
        if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
                goto out;
 
 * a similar test is implemented by icmpv6_notify() in net/ipv6/icmp.c;

 * this type of test seems to be absent in all of the following handlers:
   - tcp_v6_err()		- sctp_v6_err() 
   - __udp4_lib_err()		- __udp6_lib_err()
   - ah4_err()			- ah6_err()
   - esp4_err()			- esp6_err()
   - xfrm_tunnel_err()		- xfrm6_tunnel_err()
   - tunnel4_err()		- tunnel6_err()		- tunnel64_err()
   - ipip_err()			- ipip6_err()
   - ip4ip6_err()		- ip6ip6_err() 
   - ipcomp4_err()		- ipcomp6_err()

---------------------------------------------------------------------------
 The following two are the exceptions in question.
 The question is whether there is a reason for the code marked below.
---------------------------------------------------------------------------

--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -344,11 +344,6 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->len < (iph->ihl << 2) + 8) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
-		return;
-	}
-
 	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
 			iph->saddr, th->source, inet_iif(skb));
 	if (!sk) {
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -534,11 +534,6 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	sk_buff_data_t saveip, savesctp;
 	int err;
 
-	if (skb->len < ihlen + 8) {
-		ICMP_INC_STATS_BH(&init_net, ICMP_MIB_INERRORS);
-		return;
-	}
-
 	/* Fix up skb to look at the embedded net header. */
 	saveip = skb->network_header;
 	savesctp = skb->transport_header;

